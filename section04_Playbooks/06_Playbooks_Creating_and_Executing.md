#### **Introduction**
Welcome to this session on creating and executing Ansible playbooks! In this video, we’ll dive deep into a practical challenge designed to reinforce the knowledge you’ve gained about Ansible’s architecture and design. This exercise involves deploying an NGINX web server across both CentOS and Ubuntu systems, adapting the playbook to accommodate the differences between these operating systems, and leveraging advanced Ansible features for efficiency and automation.

#### **Objectives**
1. Install NGINX on both CentOS and Ubuntu systems.
2. Handle differences in package management tools and NGINX configurations between these operating systems.
3. Use Jinja2 templating for customizing website content.
4. Explore the "Ansible Managed" feature for configuration management.
5. Add a hidden "Easter egg" feature to the deployed application for fun.

---

### **Environment and Directory Overview**
The project structure includes:
```plaintext
ansible@ubuntu-c:~/diveintoansible/Ansible Playbooks, Creating and Executing/template$ ls *
ansible.cfg  hosts  nginx_playbook.yaml

files:
playbook_stacker.zip

group_vars:
centos  ubuntu

host_vars:
centos1  ubuntu-c

templates:
index.html-ansible_managed.j2  index.html-base.j2  index.html-easter_egg.j2  index.html-logos.j2

vars:
logos.yaml
```

#### **Key Configuration Files**
1. **`ansible.cfg`:** Sets global configuration options for Ansible.
   ```ini
   [defaults]
   inventory = hosts
   host_key_checking = False
   ansible_managed = Managed by Ansible - file:{file} - host:{host} - uid:{uid}
   ```

2. **`nginx_playbook.yaml`:** The primary playbook for deploying and managing NGINX.
3. **`group_vars/centos`:** Variables specific to CentOS.
   ```yaml
   ---
   ansible_user: root
   nginx_root_location: /usr/share/nginx/html
   ...
   ```
4. **`group_vars/ubuntu`:** Variables specific to Ubuntu.
   ```yaml
   ---
   ansible_become: true
   ansible_become_pass: password
   nginx_root_location: /var/www/html
   ...
   ```

5. **Templates:** Includes multiple Jinja2 templates for customizing the website.
   - **`index.html-base.j2`:** Base template.
   - **`index.html-logos.j2`:** Template with OS-specific logos.
   - **`index.html-easter_egg.j2`:** Template for the Easter egg.

---

#### **1. Installing EPEL on CentOS**
**Task:** Add the Extra Packages for Enterprise Linux (EPEL) repository on CentOS-based systems.

- **Key Modules:** `yum` or `dnf` (based on system compatibility).
- **Options Used:**
  - `name`: Specifies the package (e.g., `epel-release`).
  - `update_cache`: Updates the repository cache.
  - `state`: Ensures the package is installed.

**Example Task in Playbook:**
```yaml
- name: Install EPEL on CentOS
  yum:
    name: epel-release
    update_cache: yes
    state: present
  when: ansible_distribution == "CentOS"
```

**Explanation:**
- **`yum` Module:** Manages packages for CentOS-based distributions.
- **Conditional `when`:** Ensures the task runs only for CentOS systems.

**Verification:**
Run the playbook and confirm that:
- The task is skipped for Ubuntu hosts.
- EPEL is successfully installed on CentOS hosts.

---

#### **2. Installing NGINX**
To cater to both operating systems:
- Use the `yum` or `dnf` module for CentOS.
- Use the `apt` module for Ubuntu.

**Playbook Tasks:**
```yaml
- name: Install NGINX on CentOS
  yum:
    name: nginx
    update_cache: yes
    state: present
  when: ansible_distribution == "CentOS"

- name: Install NGINX on Ubuntu
  apt:
    name: nginx
    update_cache: yes
    state: present
  when: ansible_distribution == "Ubuntu"
```

**Explanation:**
- The `package` module abstracts away the differences between `yum`/`dnf` (CentOS) and `apt` (Ubuntu).
- The package is installed to the default location defined in group variables (`group_vars/centos` or `group_vars/ubuntu`).

Alternatively, simplify this with the `package` module:
```yaml
- name: Install NGINX
  package:
    name: nginx
    state: present
```

**Outcome:**
The `package` module automatically selects the correct package manager, reducing redundancy.

---

#### **3. Ensuring NGINX Service is Running**
Use the `service` module to restart NGINX:
```yaml
- name: Restart NGINX
  service:
    name: nginx
    state: restarted
  notify: Check HTTP Service
```

**Explanation:**
- **`service` Module:** Manages services on the target system.
- **`notify`:** Triggers the handler to validate NGINX's functionality.

**Use Case:** Restarting is useful after configuration changes.

---

#### **4. Validating NGINX with Handlers**
Add a handler to verify that NGINX is running correctly:
```yaml
handlers:
  - name: Check HTTP Service
    uri:
      url: "http://{{ ansible_default_ipv4.address }}"
      status_code: 200
```

**Explanation:**
- The `uri` module performs an HTTP GET request to confirm the server returns a `200 OK` status.
- **Expected Status Code:** A `200 OK` response indicates the web server is functioning correctly.

---

#### **5. Managing Configuration Files with Jinja2 Templates**
Deploy a custom `index.html` using the `template` module:
```yaml
  - name: Template index.html-base.j2 to index.html on target
    template:
      src: index.html-base.j2
      dest: "{{ nginx_root_location }}/index.html"
      mode: 0644
```
**Key Points:**
- **Source (`src`):** Points to the template file.
- **Destination (`dest`):** Uses the `nginx_root_location` variable from group variables.
- **Permissions (`mode`):** Ensures the file is readable by the web server.


- **Group Variables (Groupvars):**
  Define paths for different OS families:
  ```yaml
    $ cat group_vars/*
    ---
    ansible_user: root
    nginx_root_location: /usr/share/nginx/html
    ...
    ---
    ansible_become: true
    ansible_become_pass: password
    nginx_root_location: /var/www/html
    ...
  ```

---

#### **6. Using "Ansible Managed"**
Include the `ansible_managed` string in your templates to denote managed files:
```jinja
<!-- Managed by {{ ansible_managed }} -->
```

Update your `ansible.cfg`:
```ini
[defaults]
ansible_managed = Managed by Ansible - file:{file} - host:{host} - uid:{uid}
```

---

#### **7. Adding Visual Customizations**
Leverage a variables file (`logos.yaml`) to display OS-specific logos:
```yaml
vars_files:
  - vars/logos.yaml
```

Modify the template to dynamically load logos:
```jinja
<img src="{{ logo_url }}" alt="Logo">
```

---

#### **8. Adding an Easter Egg**
**Objective:** Add a hidden game, "Playbook Stacker," to the deployed website.

**Steps:**
1. Change the Source:
    ```yaml
    - name: Template index.html-easter_egg.j2 to index.html on target
      template:
        src: index.html-easter_egg.j2
        dest: "{{ nginx_root_location }}/index.html"
        mode: 0644  
    ```

2. Install `unzip` (required for unarchiving files):
    ```yaml
    - name: Install unzip
      package:
        name: unzip
        state: latest
    ```

3. Unarchive the game into the NGINX root directory:
    ```yaml
    - name: Unarchive playbook stacker game
      unarchive:
        src: playbook_stacker.zip
        dest: "{{ nginx_root_location }}"
        mode: 0755
    ```

**Outcome:**
- Clicking the logo launches the game.
- The game files are extracted to the appropriate directory based on the OS.


---

#### **Conclusion**
Through this hands-on challenge, you’ve:
1. Deployed NGINX across different Linux distributions using Ansible.
2. Handled OS-specific configurations with group and host variables.
3. Customized the website using Jinja2 templates.
4. Used Ansible’s `managed` feature for configuration tracking.
5. Added a fun Easter egg to the deployed application.

This project consolidates your knowledge of Ansible, preparing you for real-world scenarios involving automation, configuration management, and customization.