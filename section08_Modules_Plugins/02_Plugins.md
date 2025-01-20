### Enhanced and Detailed Version of the Transcript: Creating Plugins in Ansible

---

**Welcome to the video on Creating Plugins!**  
In this video, we will delve into the following topics:  
- The different types of plugins in Ansible.  
- Hands-on creation of a **lookup plugin**.  
- Hands-on creation of a **filter plugin**.  

---

### **Understanding Ansible Plugins**
Ansible plugins extend the core functionality of Ansible. Whether knowingly or unknowingly, you’ve already been using plugins throughout the course. 

#### **Examples of Built-in Plugins:**
1. **`with_items`**:  
   - This is a built-in **lookup plugin** used for iterating over lists.
   - For example: 
     ```yaml
     tasks:
       - name: Install packages
         yum:
           name: "{{ item }}"
           state: present
         with_items:
           - httpd
           - nginx
     ```
   - The source code for this plugin can be found at: [Ansible Source Code](https://github.com/ansible/ansible).

2. **`hostvars` and `groupvars`**:
   - These are managed by **vars plugins**, enabling the loading of variables for hosts and groups from designated directories.

If you are interested in exploring the inner workings, you can find the source code in the official [Ansible GitHub repository](https://github.com/ansible/ansible).

---

### **Types of Plugins in Ansible**
Ansible supports several plugin types, each serving different purposes. Examples include:
- **Action Plugins**: Customize the behavior of modules.
- **Lookup Plugins**: Fetch data from external sources.
- **Filter Plugins**: Manipulate or transform data in Jinja2 templates.
- **Vars Plugins**: Load variables from external sources.
- **Callback Plugins**: Add custom logging or notifications.
- **Connection Plugins**: Handle communication with hosts.
- **Inventory Plugins**: Extend inventory sourcing capabilities.
- **Test Plugins**: Add custom Jinja2 test functionality.

To explore all available plugin types, refer to the [official Ansible documentation on plugins](https://docs.ansible.com/ansible/latest/plugins.html).

---

### **Custom Plugin Creation**
Let’s create two types of custom plugins:
1. **A lookup plugin**: `sorted_items` – It sorts a list before returning it.  
2. **A filter plugin**: `reverse_upper` – It reverses a string and converts it to uppercase.  

#### **Prerequisites for Custom Plugins**
Custom plugins are placed in specific directories. For example:
- **Lookup Plugins**: `lookup_plugins/`
- **Filter Plugins**: `filter_plugins/`

You can configure the path for custom plugins in your `ansible.cfg` file:
```ini
[defaults]
lookup_plugins = ./lookup_plugins
filter_plugins = ./filter_plugins
```

---

### **Example 1: Creating a Lookup Plugin**
#### **Objective:**  
Create a lookup plugin `sorted_items` to sort a given list.

#### **Steps:**
1. **Create the directory**:  
   Navigate to your project directory and create `lookup_plugins/`.
   ```bash
   mkdir -p lookup_plugins
   cd lookup_plugins
   ```

2. **Use an existing plugin as a base**:  
   Download the source code for the `with_items` plugin from Ansible’s source tree:
   ```bash
   curl -O https://raw.githubusercontent.com/ansible/ansible/devel/lib/ansible/plugins/lookup/items.py
   mv items.py sorted_items.py
   ```

3. **Edit the plugin code**:
   Open `sorted_items.py` and modify it:
   - Import the `LookupBase` class.
   - Implement the `run` method to sort the input list:
     ```python
     from ansible.plugins.lookup import LookupBase

     class LookupModule(LookupBase):
         def run(self, terms, variables=None, **kwargs):
             return sorted(terms)
     ```

4. **Test the plugin**:  
   Create a playbook to test the plugin:
   ```yaml
   - hosts: localhost
     tasks:
       - name: Test sorted_items plugin
         debug:
           msg: "{{ lookup('sorted_items', ['z', 'b', 'a', 'm']) }}"
   ```
   **Expected Output:**
   ```
   TASK [Test sorted_items plugin] ***********************************************
   ok: [localhost] => {
       "msg": [
           "a",
           "b",
           "m",
           "z"
       ]
   }
   ```

---

### **Example 2: Creating a Filter Plugin**
#### **Objective:**  
Create a filter plugin `reverse_upper` to reverse a string and convert it to uppercase.

#### **Steps:**
1. **Create the directory**:  
   Navigate to your project directory and create `filter_plugins/`.
   ```bash
   mkdir -p filter_plugins
   cd filter_plugins
   ```

2. **Use an existing plugin as a base**:  
   Download a filter plugin from Ansible’s source tree, such as `to_nice_yaml`:
   ```bash
   curl -O https://raw.githubusercontent.com/ansible/ansible/devel/lib/ansible/plugins/filter/core.py
   mv core.py reverse_upper.py
   ```

3. **Edit the plugin code**:
   Modify the `reverse_upper.py` file to include the `reverse_upper` function:
   ```python
   from ansible.errors import AnsibleFilterError

   def reverse_upper(value):
       if not isinstance(value, str):
           raise AnsibleFilterError("Input must be a string")
       return value[::-1].upper()

   class FilterModule:
       def filters(self):
           return {
               'reverse_upper': reverse_upper
           }
   ```

4. **Test the plugin**:  
   Create a playbook to test the plugin:
   ```yaml
   - hosts: localhost
     tasks:
       - name: Test reverse_upper filter
         debug:
           msg: "{{ 'ansible' | reverse_upper }}"
   ```
   **Expected Output:**
   ```
   TASK [Test reverse_upper filter] ***********************************************
   ok: [localhost] => {
       "msg": "ELBISNA"
   }
   ```

---

### **Key Takeaways**
- Custom plugins allow you to extend Ansible’s functionality to meet specific requirements.
- Using existing plugins as a starting point reduces development time and errors.
- Knowledge of Python is invaluable for creating and customizing plugins.
- Ansible provides various plugin types, each with a specific purpose, such as lookup, filter, vars, and callback plugins.

For further learning, consider exploring the Ansible GitHub repository and the [Ansible Plugin Development Guide](https://docs.ansible.com/ansible/latest/dev_guide/plugins.html). 

---
---
---


### Explanation and Updates for `items.py` and `host_group_vars.py`

#### **1. `items.py`**
This file implements the **`items` lookup plugin**, which is used to process lists in Ansible. It is a core component of looping mechanisms in Ansible, most notably the `with_items` construct.

##### **Key Elements of `items.py`:**
- **Purpose**: Processes and optionally flattens lists provided to it.  
- **Documentation**: Includes usage details and examples to help understand its functionality:
  - Examples such as looping over lists, adding users, and processing nested dictionaries demonstrate the plugin's flexibility.
- **Method Overview**:
  - The `run` method is defined in `LookupModule`:
    ```python
    def run(self, terms, **kwargs):
        return self._flatten(terms)
    ```
    - **Input (`terms`)**: The items provided to the plugin.
    - **Operation**: Uses `_flatten`, an inherited method from `LookupBase`, to flatten the list one level.

##### **Enhancements and Observations**:
1. **Flatten Behavior**:  
   The `_flatten` method flattens lists but does not recurse. For recursive flattening, the `flattened` lookup plugin is recommended.
2. **Customizations**:  
   This file can serve as a template for creating new lookup plugins:
   - Add sorting functionality (e.g., `sorted(terms)`).
   - Transform data before returning it.

---

#### **2. `host_group_vars.py`**
This file implements the **`host_group_vars` vars plugin**, which loads variables for groups and hosts from the `group_vars/` and `host_vars/` directories.

##### **Key Elements of `host_group_vars.py`:**
- **Purpose**: Automatically loads YAML or JSON variable files associated with hosts or groups from predefined directories.
- **Documentation**:
  - Explains the role of `group_vars` and `host_vars`.
  - Mentions supported file extensions (`.yaml`, `.yml`, `.json`) and exclusions (e.g., hidden files, backups).
- **Options**:
  - `_valid_extensions`: Specifies allowed file extensions.
  - `stage`: Configuration for staging variables.
- **Key Methods**:
  - `get_vars`:  
    This is the main method that loads variables for hosts and groups. It validates input entities, determines the type (host or group), and processes relevant files.
  - `load_found_files`:  
    This helper method loads and combines variable data from discovered files.

##### **Enhancements and Observations**:
1. **Improved Debugging**:  
   The `_display.debug` calls provide insights into directory processing, which can be enhanced by logging additional details about loaded files.
2. **Extension Flexibility**:  
   The `_valid_extensions` option can be customized in `ansible.cfg` for additional formats, like `.xml` or `.ini`.
3. **Custom Plugin Ideas**:
   - Extend the plugin to support variable precedence or merge strategies.
   - Add validation for variables (e.g., type checking, value constraints).

---

### **Creating a Custom `sorted_items` Lookup Plugin**
Using `items.py` as a base, let’s create a plugin that sorts lists. This enhances the core functionality by ensuring that the output is always in sorted order.

#### **Implementation:**
1. **Steps to Modify `items.py`:**
   - Replace `_flatten` with `sorted` to sort lists:
     ```python
     def run(self, terms, **kwargs):
         return sorted(terms)
     ```
   - Update the `DOCUMENTATION` section to reflect the new functionality:
     ```python
     short_description: Returns a sorted list
     description:
       - This plugin sorts a given list and returns it in ascending order.
     ```
   - Rename the class to `LookupSortedModule` for clarity:
     ```python
     class LookupSortedModule(LookupBase):
     ```

2. **Example Playbook to Test `sorted_items`:**
   ```yaml
   - hosts: localhost
     tasks:
       - name: Test sorted_items plugin
         debug:
           msg: "{{ lookup('sorted_items', [5, 3, 4, 2, 1]) }}"
   ```
   **Expected Output:**
   ```
   TASK [Test sorted_items plugin] ***********************************************
   ok: [localhost] => {
       "msg": [
           1,
           2,
           3,
           4,
           5
       ]
   }
   ```

---

### **Customizing the Vars Plugin**
The `host_group_vars.py` plugin can be customized to add features like advanced validation, alternative directory structures, or dynamic variable loading.

#### **Ideas for Enhancements:**
1. **Dynamic Loading Based on Environment**:
   Modify `get_vars` to load variables from environment-specific directories, such as `dev_group_vars` or `prod_group_vars`.
   ```python
   if 'ANSIBLE_ENV' in os.environ:
       subdir = f"{os.environ['ANSIBLE_ENV']}_group_vars"
   else:
       subdir = 'group_vars'
   ```

2. **Variable Validation**:
   Add a method to validate variable values against predefined criteria:
   ```python
   def validate_vars(self, data):
       for key, value in data.items():
           if not isinstance(value, (str, int)):
               raise AnsibleParserError(f"Invalid type for {key}: {type(value)}")
       return data
   ```

---

### **Key Takeaways**
- The `items.py` and `host_group_vars.py` files showcase how core plugins work in Ansible.
- Using these as templates, you can easily create custom plugins tailored to your needs.
- Always document your plugins thoroughly, following the Ansible standard for `DOCUMENTATION`, `EXAMPLES`, and `RETURN` sections.
- Test custom plugins with simple playbooks to ensure functionality and correctness.