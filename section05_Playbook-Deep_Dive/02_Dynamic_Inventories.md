**Dynamic Inventories in Ansible: Enhanced Transcript**

---

### Introduction to Dynamic Inventories

Dynamic inventories in Ansible allow you to define your hosts dynamically rather than using a static file. This approach is particularly useful in environments where the infrastructure is dynamic, such as cloud-based platforms (AWS, GCP, Azure) or container orchestration systems like Kubernetes.

In this session, we will cover:

1. **Requirements for Dynamic Inventories**
2. **Creating a Dynamic Inventory with Minimal Scripting**
3. **Interrogating a Dynamic Inventory**
4. **Performance Enhancements with `_meta`**
5. **Using the Ansible Python Framework for Dynamic Inventories**

---

### Requirements for a Dynamic Inventory

To create a dynamic inventory, your script must:

1. **Be Executable:** The file must be executable and capable of being run from the command line. It can be written in any programming or scripting language.
2. **Support `--list` and `--host` Options:**
   - `--list`: Returns a JSON-encoded dictionary containing all inventory information.
   - `--host <hostname>`: Returns a JSON dictionary with host-specific variables or an empty dictionary if none exist.
3. **Output Valid JSON:** The script must output valid JSON for both options.

---

### Example: Dynamic Inventory Script

Here’s an example of a basic dynamic inventory script in Python:

```python
#!/usr/bin/env python3

import argparse
import json

class Inventory:
    def __init__(self):
        self.parse_args()
        self.define_inventory()
        if self.args.list:
            print(json.dumps(self.list_inventory(), indent=4))
        elif self.args.host:
            print(json.dumps(self.host_inventory(self.args.host), indent=4))

    def parse_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('--list', action='store_true', help='List all inventory')
        parser.add_argument('--host', help='Get variables for a specific host')
        self.args = parser.parse_args()

    def define_inventory(self):
        self.inventory = {
            "group1": {
                "hosts": ["host1", "host2"],
                "vars": {"example_var": "value1"}
            },
            "_meta": {
                "hostvars": {
                    "host1": {"ansible_host": "192.168.1.1"},
                    "host2": {"ansible_host": "192.168.1.2"}
                }
            }
        }

    def list_inventory(self):
        return self.inventory

    def host_inventory(self, hostname):
        return self.inventory["_meta"]["hostvars"].get(hostname, {})

if __name__ == "__main__":
    Inventory()
```

Save this script as `inventory.py`, make it executable (`chmod +x inventory.py`), and test it with the following commands:

```bash
./inventory.py --list
./inventory.py --host host1
```

---

### Integrating Dynamic Inventories with Ansible

#### Specifying a Dynamic Inventory

You can use the `-i` option in Ansible to specify the path to the dynamic inventory script:

```bash
ansible all -i inventory.py --list-hosts
  hosts (7):
    ubuntu-c
    centos1
    centos2
    centos3
    ubuntu1
    ubuntu2
    ubuntu3
```

This command displays all hosts in the dynamic inventory.

#### Using Ansible Modules

To ensure the dynamic inventory is working as expected, use the `ping` module:

```bash
ansible all -i inventory.py -m ping -o
ubuntu-c | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.10"},"changed": false,"ping": "pong"}
ubuntu1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.10"},"changed": false,"ping": "pong"}
centos1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.9"},"changed": false,"ping": "pong"}
centos3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.9"},"changed": false,"ping": "pong"}
centos2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.9"},"changed": false,"ping": "pong"}
ubuntu2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.10"},"changed": false,"ping": "pong"}
ubuntu3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.10"},"changed": false,"ping": "pong"}
```

---

### Performance Enhancements with `_meta`

By default, Ansible calls the script with `--host <hostname>` for each host, which can be time-consuming, especially for large inventories. To optimize performance:

1. Include the `_meta` key in the JSON output of the `--list` option.
2. Store host variables under `_meta`.

#### Example with `_meta`

Here’s how to include `_meta` in the inventory script:

```python
def list_inventory(self):
    return {
        "group1": {
            "hosts": ["host1", "host2"],
        },
        "_meta": {
            "hostvars": {
                "host1": {"ansible_host": "192.168.1.1"},
                "host2": {"ansible_host": "192.168.1.2"}
            }
        }
    }
```

With this structure, Ansible retrieves all host variables in a single call to `--list`, significantly improving execution speed for large inventories.

#### Timing Comparison

Consider an inventory with 1,000 hosts:

- Without `_meta`: Over a minute to gather all host variables.
- With `_meta`: A few seconds.

To benchmark:

```bash
$ for i in {1..10}; do echo \'fake${i}\'\,; done | tr "\n" " "
$ tail -f /var/tmp/ansible_dynamic_inventory.log &

```

```bash
$ time ansible all -i inventory.py --list-hosts
...
    centos1
    centos2
    centos3
    ubuntu1
    ubuntu2
    ubuntu3

real    0m21.018s
user    0m17.205s
sys     0m3.803s
```



---

### Debugging Dynamic Inventories

When debugging, avoid using `print()` for logging messages, as Ansible expects JSON output. Instead, use a logger:

```python
import logging

logging.basicConfig(filename='/tmp/inventory.log', level=logging.DEBUG)
logger = logging.getLogger(__name__)

logger.debug("Debugging message")
```

- ``ansible@ubuntu-c:~/diveintoansible/Ansible Playbooks, Deep Dive/Dynamic Inventories/02``
```bash
$ ansible all -i inventory.py --list-hosts
  hosts (7):
    ubuntu-c
    centos1
    centos2
    centos3
    ubuntu1
    ubuntu2
    ubuntu3

$ cat /var/tmp/ansible_dynamic_inventory.log 
2025-01-16 11:09:55,393 INFO list executed
2025-01-16 11:09:55,412 INFO host executed for ubuntu-c
2025-01-16 11:09:55,431 INFO host executed for ubuntu3
2025-01-16 11:09:55,450 INFO host executed for ubuntu1
2025-01-16 11:09:55,468 INFO host executed for centos3
2025-01-16 11:09:55,487 INFO host executed for centos1
2025-01-16 11:09:55,505 INFO host executed for ubuntu2
2025-01-16 11:09:55,524 INFO host executed for centos2
```

---

### Advanced: Dynamic Inventories in Cloud Environments

Dynamic inventories are particularly powerful when integrated with cloud environments:

- **AWS:** Use the [AWS dynamic inventory plugin](https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_ec2_inventory.html) to fetch EC2 instances.
- **Azure:** Retrieve VM details using the [Azure dynamic inventory plugin](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_inventory.html).
- **GCP:** Use the [GCP dynamic inventory plugin](https://docs.ansible.com/ansible/latest/collections/google/cloud/gcp_compute_inventory.html).

For example, using AWS:

1. Install the required collection:

   ```bash
   ansible-galaxy collection install amazon.aws
   ```

2. Configure the plugin in `aws_ec2.yaml`:

   ```yaml
   plugin: amazon.aws.aws_ec2
   regions:
     - us-east-1
   filters:
     tag:Environment: production
   keyed_groups:
     - key: tags.Name
       prefix: ec2_
   ```

3. Run Ansible commands:

   ```bash
   ansible all -i aws_ec2.yaml --list-hosts
   ```

---

### Conclusion

Dynamic inventories are a powerful feature in Ansible, enabling seamless management of dynamic infrastructure. By adhering to the requirements, leveraging `_meta`, and integrating with cloud providers, you can enhance the scalability and performance of your Ansible deployments.

In the next session, we’ll explore integrating dynamic inventories with specific use cases, such as AWS and Kubernetes.

---

