### Ansible Architecture and Design - Configuration

---

#### **Introduction to Section 3**
Welcome to the third section of the course: **Ansible Architecture and Design**. 

In this section, we’ll explore:

1. **Ansible Configuration**:
   - Understanding configuration files and how they influence Ansible's behavior.
   - Discovering configuration file precedence and the role of environment variables.

2. **Ansible Inventories**:
   - Defining and managing inventories.
   - Using host and group variables.
   - Simplifying group management with ranges.
   - Configuring root connectivity in inventories.
   - Adapting Ansible for different target configurations.

3. **Ansible Modules**:
   - Exploring common modules.
   - Learning how to interact with these modules using the `ansible` command-line tool.

#### **Ansible Configuration**
Ansible's functionality is heavily influenced by its configuration files. These files define how Ansible operates and the resources it utilizes.

---

### **Ansible Version and Configuration**![configuration](image-1.png)

#### **Checking Ansible Version**
- On the control host (e.g., `ubuntu-c`), run:
  ```bash
  ansible --version
  ```
  **Output Example**:
  - Ansible version: `2.10.3` (or higher).
  - **Note**: The version displayed here corresponds to **ansible-base**, the core component of Ansible.  
    Updates to `ansible-base` may affect the displayed version, but the course content is designed to work with any supported version.

#### **Configuration File**![config](image.png)
- The `config file` entry in the output is critical.
  - **Initial State**: If it says `None`, no configuration file is currently in use.
  - **Default Locations**: Ansible searches for configuration files in the following order of precedence:
    1. **Environment Variable**: `$ANSIBLE_CONFIG` (highest priority).
    2. **Current Directory**: `./ansible.cfg`.
    3. **User's Home Directory**: `~/.ansible.cfg`.
    4. **System-wide Default**: `/etc/ansible/ansible.cfg` (lowest priority).

---

### **Demonstrating Configuration File Locations**

#### **1. System-wide Configuration (`/etc/ansible/ansible.cfg`)**
- This is the lowest-priority configuration file.
- Typically created when Ansible is installed via package managers:
  - **Ubuntu/Debian**: `apt install ansible`
  - **RHEL/CentOS**: `yum install ansible` or `dnf install ansible`.

##### **Creating the File**:
1. Switch to the root user:
   ```bash
   su -
   ```
   (Enter the password, e.g., `password`).

2. Create the directory and file:
   ```bash
   mkdir -p /etc/ansible
   touch /etc/ansible/ansible.cfg
   ```

3. Verify the configuration file:
   ```bash
   ansible --version
   ```
   - The `config file` entry should now reference `/etc/ansible/ansible.cfg`.

#### **2. User-specific Configuration (`~/.ansible.cfg`)**
- This hidden file in the user's home directory takes precedence over the system-wide file.

##### **Creating the File**:
1. Navigate to the home directory:
   ```bash
   cd ~
   ```

2. Confirm the current directory:
   ```bash
   pwd
   ```

3. Create the hidden file:
   ```bash
   touch .ansible.cfg
   ```

4. Verify:
   ```bash
   ansible --version
   ```
   - The `config file` entry now references `~/.ansible.cfg`.

#### **3. Current Directory Configuration (`./ansible.cfg`)**
- A configuration file in the current directory overrides both system-wide and user-specific files.
- This method is ideal for maintaining configurations alongside project-specific files.

##### **Creating the File**:
1. Create and navigate to a test directory:
   ```bash
   mkdir testdir
   cd testdir
   ```

2. Create the file:
   ```bash
   touch ansible.cfg
   ```

3. Verify:
   ```bash
   ansible --version
   ```
   - The `config file` entry now references `./ansible.cfg`.

---

### **4. Environment Variable (`$ANSIBLE_CONFIG`)**
- The `$ANSIBLE_CONFIG` environment variable has the highest priority.  
- This allows flexibility to specify a configuration file with any name.

##### **Example**:
1. Create a configuration file:
   ```bash
   touch this_is_my_example_ansible.cfg
   ```

2. Set the environment variable:
   ```bash
   export ANSIBLE_CONFIG=$(pwd)/this_is_my_example_ansible.cfg
   ```

3. Verify:
   ```bash
   ansible --version
   ```
   - The `config file` entry now references the file specified by `$ANSIBLE_CONFIG`.

4. Clean up:
   ```bash
   unset ANSIBLE_CONFIG
   ```

---

### **Summary**
- Configuration file precedence (lowest to highest):
  1. `/etc/ansible/ansible.cfg`
  2. `~/.ansible.cfg`
  3. `./ansible.cfg`
  4. `$ANSIBLE_CONFIG` environment variable.
- Each method provides flexibility depending on user requirements:
  - System-wide setups (`/etc/ansible`).
  - User-specific preferences (`~/.ansible.cfg`).
  - Project-specific configurations (`./ansible.cfg`).
  - Dynamic configurations with environment variables.

---

Ansible allows multiple layers of configuration files to provide **flexibility and granularity** for managing different environments, projects, and user preferences. Below are some **examples** where different layers of configuration files are beneficial:

---

### **1. System-wide Configuration (`/etc/ansible/ansible.cfg`)**
- **Use Case**: Standardizing configurations across an organization or environment.
- **Example**:
  - An organization has multiple teams using a shared Ansible control node.
  - The system administrator configures a default inventory location and disables host key checking for all users:
    ```ini
    [defaults]
    inventory = /etc/ansible/hosts
    host_key_checking = False
    retry_files_enabled = False
    ```
  - All users on the system will inherit these settings by default.

---

### **2. User-specific Configuration (`~/.ansible.cfg`)**
- **Use Case**: Personalizing settings for individual users without affecting others.
- **Example**:
  - A developer wants to override the default inventory for their projects and change the log path:
    ```ini
    [defaults]
    inventory = ~/my_ansible_projects/inventory
    log_path = ~/ansible_logs/ansible.log
    ```
  - This configuration applies only to the developer's account, allowing them to customize Ansible for personal use while preserving the system-wide defaults.

---

### **3. Project-specific Configuration (`./ansible.cfg`)**
- **Use Case**: Managing project-specific settings to keep configurations self-contained.
- **Example**:
  - A team is working on a deployment project with unique SSH settings and custom retry behavior:
    ```ini
    [defaults]
    inventory = ./inventory
    host_key_checking = False
    retry_files_enabled = True
    ```
  - This configuration ensures that any developer working on the project automatically uses the correct settings, even if their user-specific or system-wide configurations differ.

---

### **4. Configuration via Environment Variables (`ANSIBLE_CONFIG`)**
- **Use Case**: Temporarily overriding configurations for special tasks or environments.
- **Example**:
  - A sysadmin is testing a new Ansible setup and wants to use a custom configuration file for this session:
    ```bash
    export ANSIBLE_CONFIG=/path/to/custom_ansible.cfg
    ansible all -m ping
    ```
  - This approach is temporary and ensures the original configurations remain intact after the session.

---

### **Practical Scenarios Highlighting the Need for Layers**

#### **Scenario 1: Multi-team Environment**
- **System-wide Config**: The sysadmin sets `/etc/ansible/ansible.cfg` to standardize settings like `retry_files_enabled=False` and default inventory.
- **User Config**: Individual teams working on different projects configure `~/.ansible.cfg` to define unique inventory paths for their projects.
- **Project Config**: For a specific project, the team creates a `./ansible.cfg` file in the project directory to define SSH settings and other customizations.

#### **Scenario 2: Handling Sensitive Environments**
- **System-wide Config**: Enforces security policies like `host_key_checking=True`.
- **User Config**: Developers testing locally may disable host key checking in `~/.ansible.cfg` to simplify development:
  ```ini
  host_key_checking = False
  ```
- **Project Config**: For a sensitive deployment project, the `./ansible.cfg` ensures stricter settings like:
  ```ini
  [defaults]
  host_key_checking = True
  private_key_file = /path/to/secure_key.pem
  ```

#### **Scenario 3: Temporary Debugging**
- A developer wants to debug a specific task with custom logging:
  ```bash
  export ANSIBLE_CONFIG=debug_ansible.cfg
  ansible-playbook playbook.yml
  ```
  - Once debugging is complete, they unset the environment variable:
    ```bash
    unset ANSIBLE_CONFIG
    ```

---

### **Why This Layered Approach is Useful**
1. **Granularity**: Different configurations are applied to different scopes—system-wide, user-specific, or project-specific.
2. **Flexibility**: Temporary changes via `ANSIBLE_CONFIG` allow testing without altering persistent configurations.
3. **Portability**: Project-specific configurations (`./ansible.cfg`) ensure consistency across environments and developers.
4. **User Independence**: User-specific settings (`~/.ansible.cfg`) let individuals work with their preferences while maintaining overall system policies.

This hierarchy ensures Ansible is adaptable to a wide range of scenarios and user requirements.

---

### **Next Steps**
In the next video, we will explore **Ansible Inventories**, including:
- Defining inventory files.
- Applying host and group variables.
- Simplifying group definitions.
- Configuring inventory for root access.

