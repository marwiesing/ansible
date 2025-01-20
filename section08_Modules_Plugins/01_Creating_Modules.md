### Enhanced Guide to Creating Modules and Plugins in Ansible

Welcome to the detailed walkthrough of **Creating Modules and Plugins** in Ansible. This guide expands on key concepts and practical steps, integrating additional examples and insights for clarity and application.

---

### Section Overview

1. **Creating Modules**:
    - Understand how Ansible modules work.
    - Build modules using shell scripts and Python.
    - Leverage debugging tools for module development.
2. **Creating Plugins**:
    - A subsequent video will cover plugins in detail.

---

### Downloading the Ansible Source Code

To explore module creation effectively, download the Ansible source code:

```bash
cd ~
git clone https://github.com/ansible/ansible.git
```
> This may take a while. Once cloned, navigate back to your working directory using `cd -`.

---

### Module Basics: Structure and Functionality


```bash
$ ~/ansible/hacking/test-module.py -m ~/ansible/lib/ansible/modules/command.py -a hostname
* including generated source, if any, saving to: /home/ansible/.ansible_module_generated
* ansiballz module detected; extracted module source to: /home/ansible/debug_dir
***********************************
RAW OUTPUT

{"changed": true, "stdout": "ubuntu-c", "stderr": "", "rc": 0, "cmd": ["hostname"], "start": "2025-01-20 12:02:58.507137", "end": "2025-01-20 12:02:58.510018", "delta": "0:00:00.002881", "msg": "", "invocation": {"module_args": {"_raw_params": "hostname", "_uses_shell": false, "expand_argument_vars": true, "stdin_add_newline": true, "strip_empty_ends": true, "argv": null, "chdir": null, "executable": null, "creates": null, "removes": null, "stdin": null}}}


***********************************
PARSED OUTPUT
{
    "changed": true,
    "cmd": [
        "hostname"
    ],
    "delta": "0:00:00.002881",
    "end": "2025-01-20 12:02:58.510018",
    "invocation": {
        "module_args": {
            "_raw_params": "hostname",
            "_uses_shell": false,
            "argv": null,
            "chdir": null,
            "creates": null,
            "executable": null,
            "expand_argument_vars": true,
            "removes": null,
            "stdin": null,
            "stdin_add_newline": true,
            "strip_empty_ends": true
        }
    },
    "msg": "",
    "rc": 0,
    "start": "2025-01-20 12:02:58.507137",
    "stderr": "",
    "stdout": "ubuntu-c"
}
```

#### Exploring an Existing Module

Navigate to the Ansible source tree and inspect the `command` module:

```bash
cd ansible/lib/ansible/modules/command.py
```

Key observations:
- **JSON Output**: Modules communicate results using JSON format.
- **Essential Fields**: `changed` and `rc` (return code) fields denote success or failure.
- **Example Usage**:

```bash
ansible localhost -m ansible.builtin.command -a 'hostname'
```
Output:
```json
{
  "changed": false,
  "rc": 0,
  "stdout": "ubuntu-c",
  "stderr": "",
  "failed": false
}
```
- Modify the command to something invalid, such as `xyz`, to observe failure outputs:

```json
{
  "changed": false,
  "rc": 127,
  "stdout": "",
  "stderr": "/bin/sh: 1: xyz: not found",
  "failed": true
}
```

---

### Writing a Custom Module in Shell

#### Step 1: Basic Shell Script
Create a file `icmp.sh`:

```bash
#!/bin/bash

echo '{
  "changed": false,
  "rc": 0
}'
```
Test the module:

```bash
ansible localhost -m icmp.sh -a ''
```
Output:
```json
{
  "changed": false,
  "rc": 0
}
```

#### Step 2: Introducing Errors
Simulate an error by modifying `icmp.sh` to ping an unreachable IP:

```bash
#!/bin/bash
ping -c 1 128.0.0.1
if [ $? -eq 0 ]; then
  echo '{ "changed": true, "rc": 0 }'
else
  echo '{ "failed": true, "changed": false, "rc": 1 }'
fi
```
Run the script and observe:
- Successful pings produce a `changed` output.
- Failures include `failed: true` and relevant messages.

#### Step 3: Accepting Parameters
Enhance `icmp.sh` to accept a `target` parameter:

```bash
#!/bin/bash
TARGET=${1:-127.0.0.1}
ping -c 1 $TARGET
if [ $? -eq 0 ]; then
  echo '{ "changed": true, "rc": 0 }'
else
  echo '{ "failed": true, "changed": false, "rc": 1 }'
fi
```
Pass parameters via Ansible:

```bash
ansible localhost -m icmp.sh -a 'target=google.com'
```

---

### Writing a Custom Module in Python

#### Advantages of Python Modules
- Pre-built templates simplify tasks.
- Easier integration with Ansible documentation (`ansible-doc`).
- Supports usage of existing Ansible modules within custom ones.

#### Step 1: Using a Template
Start with the official Python module template. Save it as `icmp.py`:

```python
from ansible.module_utils.basic import AnsibleModule

def main():
    module_args = {
        'target': {'type': 'str', 'default': '127.0.0.1'}
    }
    module = AnsibleModule(argument_spec=module_args)

    target = module.params['target']
    rc, stdout, stderr = module.run_command(['ping', '-c', '1', target])

    if rc == 0:
        module.exit_json(changed=True, stdout=stdout)
    else:
        module.fail_json(msg="Ping failed", stderr=stderr)

if __name__ == '__main__':
    main()
```

#### Step 2: Testing the Python Module
Run the module:

```bash
ansible localhost -m icmp.py -a 'target=google.com'
```
Observe outputs for success and failure. Use `ansible-doc` to confirm documentation inclusion:

```bash
ansible-doc -M ./library -l
```

---

### Using Custom Modules in Playbooks

#### Directory Structure
Ansible expects custom modules in a `library/` directory relative to the playbook:

```bash
project_dir/
  playbook.yaml
  library/
    icmp.py
```

#### Example Playbook
Create `playbook.yaml`:

```yaml
- hosts: localhost
  tasks:
    - name: Test ICMP module
      icmp:
        target: google.com
```
Run the playbook:

```bash
ansible-playbook playbook.yaml
```

---

### Summary

1. **Key Insights**:
   - Modules communicate via JSON.
   - Modules can be written in any language but must adhere to JSON output requirements.
   - Python simplifies advanced module creation with templates and built-in utilities.

2. **Practical Use Cases**:
   - Perform network checks using ICMP ping.
   - Extend Ansible’s functionality with custom scripts.

3. **Next Steps**:
   - Explore creating custom plugins to further extend Ansible’s capabilities.

Congratulations on mastering the basics of creating Ansible modules! Next, we’ll dive into plugins to further enhance your Ansible workflows.

---
---

### Enhanced Breakdown of Your ICMP File and Test Module

#### **Shell Scripts Overview**

1. **Basic ICMP Ping Script (Static Target):**
   - This script pings `127.0.0.1` and outputs JSON with a `changed` field if successful or a `failed` field if not.

   ```bash
   #!/bin/bash

   ping -c 1 127.0.0.1 >/dev/null 2>/dev/null

   if [ $? == 0 ]; then
       echo "{\"changed\": true, \"rc\": 0}"
   else
       echo "{\"failed\": true, \"msg\": \"failed to ping\", \"rc\": 1}"
   fi
   ```

   **Output Examples:**
   - **Success:** `{"changed": true, "rc": 0}`
   - **Failure:** `{"failed": true, "msg": "failed to ping", "rc": 1}`

---

2. **Parameterized ICMP Script:**
   - This script dynamically accepts a target IP or hostname using the `source` command to process arguments.

   ```bash
   #!/bin/bash

   source $1 >/dev/null 2>&1
   TARGET=${target:-127.0.0.1}

   ping -c 1 ${TARGET} >/dev/null 2>/dev/null

   if [ $? == 0 ]; then
       echo "{\"changed\": true, \"rc\": 0}"
   else
       echo "{\"failed\": true, \"msg\": \"failed to ping\", \"rc\": 1}"
   fi
   ```

   **Usage with Ansible:**
   ```bash
   ansible localhost -m icmp.sh -a 'target=google.com'
   ```

---

#### **Python-Based Module (Advanced)**

1. **Features of `icmp.py`:**
   - **Documentation:** Includes YAML-based metadata for use with `ansible-doc`.
   - **Arguments:** Accepts a target (IP or hostname).
   - **JSON Output:** Ensures proper integration with Ansible.
   - **Debugging:** Provides detailed output, including return codes and errors.

   ```python
   from ansible.module_utils.basic import AnsibleModule

   def run_module():
       module_args = dict(
           target=dict(type='str', required=True)
       )
       module = AnsibleModule(argument_spec=module_args)

       target = module.params['target']
       rc, stdout, stderr = module.run_command(['ping', '-c', '1', target])

       result = {
           'changed': False,
           'debug': {'rc': rc, 'stdout': stdout, 'stderr': stderr}
       }

       if rc != 0:
           module.fail_json(msg="failed to ping", **result)
       else:
           result['changed'] = True
           module.exit_json(**result)

   def main():
       run_module()

   if __name__ == '__main__':
       main()
   ```

   **Test the Module:**
   ```bash
   ansible localhost -m icmp.py -a 'target=google.com'
   ```

---

#### **Testing Modules with `test-module.py`**

- **Purpose:** `test-module.py` facilitates debugging and testing of modules outside the full Ansible execution stack.

- **Command Example:**
   ```bash
   ./hacking/test-module.py -m ./icmp.py -a 'target=127.0.0.1'
   ```

- **Debugging with Generated Files:**
   - Temporary files for source and arguments:
     - Source: `~/.ansible_module_generated`
     - Arguments: `~/.ansible_test_module_arguments`

---

### Recommendations and Use Cases

1. **Shell vs. Python Modules:**
   - **Shell:** Quick prototyping or tasks requiring external scripts.
   - **Python:** Better for complex logic, advanced debugging, and reusable templates.

2. **Using `test-module.py`:**
   - Ideal for iterative development.
   - Allows precise debugging without running full playbooks.

3. **Playbook Integration:**
   - Place custom modules in the `library/` directory relative to your playbook.
   - Example playbook:

     ```yaml
     - hosts: localhost
       tasks:
         - name: Test ICMP Module
           icmp:
             target: google.com
     ```

This breakdown should help you refine and extend your module development process effectively. Let me know if you need additional examples or clarifications!