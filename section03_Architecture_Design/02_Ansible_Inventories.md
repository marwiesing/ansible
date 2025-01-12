#### **Introduction to Ansible Inventories**

Welcome to the video on **Ansible Inventories**. In this session, we’ll cover:

1. **Understanding Ansible inventories**:
   - What they are and how they are used.
   - The types of inventories available.
   
2. **Managing connectivity**:
   - Providing root connectivity to CentOS hosts.
   - Using `sudo` for Ubuntu hosts.

3. **Variables in inventories**:
   - Host variables (host vars).
   - Group variables (group vars).

4. **Improving inventory structure**:
   - Simplifying entries with host ranges.
   - Using children groups for hierarchical organization.

5. **Real-world applications**:
   - Handling non-standard SSH ports.
   - Writing inventories in alternate formats like YAML and JSON.
   - Overriding variables with command-line options.

---

### **Recap of the Previous Video**
In the last video, we learned about **Ansible Configuration**:
- The role of `ansible.cfg` and its precedence.
- Configuring the course repository.

Now, we’ll dive into inventories, building on the foundational concepts.

---

### **Ansible Inventory Basics**

#### **Definition**
An **inventory** is a file listing the hosts (nodes) Ansible can manage. It organizes systems into groups and defines variables to manage them effectively.

#### **Types of Inventories**
1. **Static Inventory**:
   - Fixed list of hosts defined in a file (INI, YAML, or JSON formats).
   
2. **Dynamic Inventory**:
   - Generated dynamically using scripts or plugins, often integrating with cloud providers.

---

### **Course Repository Structure**

#### **Revisions and Hands-On Approaches**
The course repository offers:
1. **Ready-to-Use Revisions**:
   - Pre-configured examples (`01`, `02`, `03`, etc.).
   - Ideal for quick progress or reference.
   
2. **Hands-On Template**:
   - Skeleton files for creating configurations from scratch.
   - Encourages learning by doing but is more error-prone.

Each directory is self-contained, allowing incremental learning.

#### **Starting the Lab**
Navigate to the `inventories` folder:
```bash
cd Dive_Into_Ansible/Ansible_Architecture_and_Design/inventories/01
```

---

### **Testing Connectivity**
Verify connectivity to a CentOS host:
```bash
ansible -i hosts all -m ping
```
- The `hosts` file specifies the inventory.
- The `ping` module checks connectivity.

---

### **Understanding Inventory Files**

#### **Default Inventory**
The default inventory file (`hosts`) is referenced in `ansible.cfg`:
```ini
[defaults]
inventory = hosts
```

#### **INI Format**
An INI-style inventory groups hosts:
```ini
[all]
centos1
```
- All hosts belong to the implicit `all` group.
- Groups can be explicitly named (e.g., `[centos]`).

---

### **Configuring SSH Connectivity**

#### **Host Key Checking**
Ansible uses SSH to connect to hosts. By default, it validates host keys, requiring manual confirmation on the first connection.

##### **Temporary Override**
Use the environment variable for a single command:
```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible all -m ping
```

##### **Permanent Configuration**
Add the following to `ansible.cfg`:
```ini
[defaults]
host_key_checking = False
```

---

### **Groups and Variables**

#### **Grouping Hosts**
Organize hosts into groups:
```ini
[centos]
centos1
centos2
```

#### **Host Variables**
Define specific variables for a host:
```ini
centos1 ansible_user=root
```

#### **Group Variables**
Apply variables to all hosts in a group:
```ini
[centos:vars]
ansible_user=root
```

#### **Children Groups**
Group multiple groups under a parent:
```ini
[linux:children]
centos
ubuntu
```

---

### **Improving Inventory with Ranges**
Use ranges to simplify repetitive entries:
```ini
[centos]
centos[1:3]
```
This expands to `centos1`, `centos2`, `centos3`.

---

### **Handling Non-Standard SSH Ports**
Hosts running SSH on non-default ports require configuration:
1. Specify the port in the inventory:
   ```ini
   centos1 ansible_port=2222
   ```
2. Alternatively, use the `:` notation:
   ```ini
   centos1:2222
   ```

---

### **Alternate Inventory Formats**

#### **YAML Format**
Equivalent to the INI example:
```yaml
centos:
  hosts:
    centos1:
      ansible_user: root
```
- YAML uses hierarchical structures.
- Begin and end with `---` and `...` for clarity (optional).

#### **JSON Format**
Convert YAML to JSON using Python:
```bash
python -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=4)' < hosts.yml > hosts.json
```

---

### **Overriding Variables**
Override inventory variables with the `-e` flag:
```bash
ansible -i hosts all -e ansible_port=22 -m ping
```
- Overrides `ansible_port` for all hosts during the command.

---

### **Key Takeaways**
1. Inventories define the hosts and their configurations.
2. Group and host variables simplify management.
3. Alternate formats (YAML/JSON) are supported.
4. Overrides and dynamic adjustments are possible.

---

### **Next Steps**
In the next video, we’ll explore **Ansible Modules**:
- Common modules and their uses.
- Using the `ansible` command-line tool for module execution.

Join me as we dive deeper into Ansible!