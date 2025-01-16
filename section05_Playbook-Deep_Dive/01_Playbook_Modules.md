### Section: Ansible Playbooks - Deep Dive  
**Video: Ansible Playbook Modules**

Welcome to this section on **Ansible Playbooks: Deep Dive**. In this video, we’ll explore **Ansible Playbook Modules** through a series of hands-on examples. Let’s outline what we’ll cover:  
1. **Ansible Playbook Modules**: Understand key modules and their applications.  
2. **Dynamic Inventories**: Learn how to use and create them.  
3. **Register Variables**: Store and reuse data from tasks.  
4. **Conditional Execution**: Implement `when` statements.  
5. **Loops**: Explore different loop constructs.  
6. **Performance Optimization**: Optimize execution using asynchronous, serial, and parallel tasks.  
7. **Task Delegation**: Assign tasks to specific nodes.  
8. **Magic Variables**: Leverage special Ansible variables.  
9. **Blocks**: Structure tasks with optional recovery actions.  
10. **Ansible Vault**: Secure sensitive information.  

---

### Directory Overview for This Section  
Each revision of this section has its own set of files in the `~/diveintoansible/Ansible Playbooks, Deep Dive/Playbook Modules/` directory. The key playbooks discussed in the transcript are located within their respective revision folders. Here's a quick reference:  

#### Directory Structure:
- **01**: `set_fact_playbook.yaml` (Introduction to `set_fact`).  
- **02**: `set_fact_playbook.yaml` (Setting multiple facts, overwriting defaults).  
- **03**: `set_fact_playbook.yaml` (OS-specific facts using `when`).  
- **04**: `pause_playbook.yaml` (Pausing playbook execution).  
- **05**: `pause_playbook.yaml` (Prompting the user).  
- **06**: `wait_for_playbook.yaml` and `run_webserver_playbook.yaml` (Web server setup and waiting for conditions).  
- **07**: `assemble_playbook.yaml` (Combining configuration files with `assemble`).  
- **08**: `add_host_playbook.yaml` (Dynamically adding hosts).  
- **09**: `add_host_playbook.yaml` (Alternate YAML structure).  
- **10**: `group_by_playbook.yaml` (Grouping hosts dynamically).  
- **11**: `fetch_playbook.yaml` (Fetching files from remote hosts).  

---

### Playbook Modules Overview  
Ansible is a **batteries-included framework** with thousands of built-in modules for various tasks. Let’s examine some of the most commonly used modules.

---

#### **1. `set_fact` Module**  
The `set_fact` module dynamically defines variables (facts) during playbook execution.

- **Directory Reference**: `01/set_fact_playbook.yaml`.  
- **Example 1**: Setting a single fact.  
```yaml
- name: Set a fact
  set_fact:
    our_fact: "Ansible Rocks!"

- name: Show custom fact
  debug:
    msg: "{{ our_fact }}"
```
Output:
```
ok: [ubuntu3] => our_fact: "Ansible Rocks!"
ok: [centos3] => our_fact: "Ansible Rocks!"
```

- **Example 2**: Setting multiple facts and overwriting default ones.  
  - **Directory Reference**: `02/set_fact_playbook.yaml`.  
```yaml
- name: Set multiple facts
  set_fact:
    our_fact: "Ansible Deep Dive"
    ansible_distribution: "{{ ansible_distribution | upper }}"
```

- **Example 3**: Using `set_fact` with `when` for OS-specific variables.  
  - **Directory Reference**: `03/set_fact_playbook.yaml`.  
```yaml
- name: Set installation variables for CentOS
  set_fact:
    webserver_application_path: /usr/share/nginx/html
    webserver_application_user: root
  when: ansible_distribution == "CentOS"
```
This approach is useful for dynamic playbooks that adjust behavior based on the target system.

---

#### **2. `pause` Module**  
The `pause` module halts playbook execution for a defined time or until user input.  

- **Directory Reference**: `04/pause_playbook.yaml`, `05/pause_playbook.yaml`.  
- **Example**: Pausing for 10 seconds.  
```yaml
- name: Pause for 10 seconds
  pause:
    seconds: 10
```
- **Prompting for Confirmation**: Useful for manual verification steps.  
```yaml
- name: Prompt user to verify
  pause:
    prompt: "Please check that the webserver is running, then press Enter to continue."
```

---

#### **3. `wait_for` Module**  
The `wait_for` module ensures that a resource (e.g., a port or file) is ready.  
- **Directory Reference**: `06/wait_for_playbook.yaml`.  
- **Example**: Waiting for port 80 (HTTP).  
```yaml
- name: Wait for webserver on port 80
  wait_for:
    port: 80
```

---

#### **4. `assemble` Module**  
The `assemble` module merges multiple configuration files into one.  

- **Directory Reference**: `07/assemble_playbook.yaml`.  
- **Example**: Combine SSH configurations.  
```yaml
- name: Assemble SSH configuration
  assemble:
    src: conf.d/
    dest: sshd_config
```
- **Practical Use Case**: Separating configuration entries for individual hosts in `conf.d/`.

---

#### **5. `add_host` Module**  
Dynamically add hosts to an inventory or group during playbook execution.  

- **Directory Reference**: `08/add_host_playbook.yaml`.  
- **Example**: Adding and using dynamic groups.  
```yaml
- name: Add centos1 to adhoc_group1
  add_host:
    name: centos1
    groups: adhoc_group1
```

---

#### **6. `group_by` Module**  
The `group_by` module groups hosts dynamically based on specific criteria or facts.  

- **Directory Reference**: `10/group_by_playbook.yaml`.  
- **Example**: Grouping hosts by OS.  
```yaml
- name: Group by OS distribution
  group_by:
    key: "custom_{{ ansible_distribution | lower }}"
```

---

#### **7. `fetch` Module**  
The `fetch` module retrieves files from remote hosts to the control node.  

- **Directory Reference**: `11/fetch_playbook.yaml`.  
- **Example**: Fetch OS release files.  
```yaml
- name: Fetch /etc/redhat-release
  fetch:
    src: /etc/redhat-release
    dest: /tmp/redhat-release/{{ inventory_hostname }}/
```

---

### Final Notes  
- **Key Takeaways**:  
  - Use `set_fact` for dynamic variable assignment.  
  - Leverage `pause` for manual verification or delays.  
  - Ensure resources are ready with `wait_for`.  
  - Simplify configuration management with `assemble`.  
  - Dynamically manage inventories using `add_host` and `group_by`.  
  - Retrieve important data with `fetch`.  

In the next video, we’ll focus on **Dynamic Inventories**. See you there!  