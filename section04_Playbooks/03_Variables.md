# **Ansible Playbooks: Variables**

## **Overview**
This session explores 17 examples demonstrating how variables are defined, accessed, and manipulated in Ansible. Each example resides in a dedicated directory with playbooks, configuration files, and inventory definitions.

---

## **Directory Structure**
The directories are organized as follows:

- **General Contents**:
  - `ansible.cfg`: Configuration for Ansible execution.
  - `hosts`: Inventory file defining target systems.
  - `variables_playbook.yaml`: Playbook for the specific example.

- **Special Cases**:
  - **06**: Introduces `external_vars.yaml` for modular variable management.
  - **15-17**: Utilize `group_vars` and `host_vars` for group- and host-specific variables.

- **Extended Examples in `17`**:
  - Demonstrates passing variables via YAML and JSON files (`extra_vars_file.yaml` and `extra_vars_file.json`).

---

## **Key Concepts by Directory**

| **Directory** | **Key Concept**                                                                                          |
|---------------|----------------------------------------------------------------------------------------------------------|
| `01`          | Basic key-value variable usage.                                                                          |
| `02`          | Working with dictionaries and accessing values via dot/bracket notation.                                 |
| `03`          | Inline dictionary syntax and access.                                                                     |
| `04`          | Using lists and accessing elements by index.                                                             |
| `05`          | Inline lists and their usage.                                                                            |
| `06`          | Referencing variables from an external YAML file.                                                        |
| `07`          | Prompting users for input via `vars_prompt`.                                                             |
| `08`          | Secure input for sensitive variables like passwords.                                                     |
| `09`          | Accessing host-specific variables using `hostvars`.                                                      |
| `10`          | Demonstrates errors when accessing undefined variables in `hostvars`.                                    |
| `11`          | Using the `default` filter to handle missing variables.                                                  |
| `12`          | Accessing group-level variables via `group_vars`.                                                        |
| `13`          | Errors caused by undefined group variables.                                                              |
| `14`          | Accessing group variables through `hostvars`.                                                            |
| `15`          | Combining `hostvars` and `group_vars` for flexible variable handling.                                    |
| `16`          | Passing extra variables at runtime using INI, JSON, and YAML formats.                                    |
| `17`          | Passing variables as YAML or JSON files.                                                                 |

---

## **Detailed Examples**

### **1. Simple Key-Value Variables**
**Objective**: Demonstrates defining and accessing a key-value pair.

**Playbook**:
```yaml
vars:
  example_key: "example value"
tasks:
  - name: Display key-value variable
    debug:
      msg: "{{ example_key }}"
```

**Result**:
```plaintext
"msg": "example value"
```

---

### **2. Dictionaries**
**Objective**: Demonstrates working with dictionaries using dot and bracket notations.

**Variable Example**:
```yaml
dict:
  dict_key: "dictionary value"
```

**Result**:
```plaintext
"msg": "dictionary value"
```

---

### **3. Inline Dictionaries**
**Objective**: Defines and accesses inline dictionaries.

**Variable Example**:
```yaml
inline_dict: { inline_key: "inline value" }
```

---

### **4. Lists**
**Objective**: Demonstrates accessing list elements.

**Variable Example**:
```yaml
named_list:
  - item1
  - item2
```

---

### **5. Inline List**
**Objective**: Shows how to define and access an inline list.  

**Example Variable**:
```yaml
vars:
  inline_named_list: [ item1, item2, item3, item4 ]
```

**Output**:
```plaintext
TASK [Display the inline list]
ok: [centos1] => {"msg": ["item1", "item2", "item3", "item4"]}

TASK [Access first item using dot notation]
ok: [centos1] => {"msg": "item1"}

TASK [Access first item using bracket notation]
ok: [centos1] => {"msg": "item1"}
```

---

### **6. External Variables File**
**Objective**: Illustrates how to reference variables stored in an external YAML file (`external_vars.yaml`).

**External File**:
```yaml
external_example_key: "example value"
external_dict:
  dict_key: "This is a dictionary value"
external_named_list:
  - item1
  - item2
  - item3
```

**Playbook**:
```yaml
vars_files:
  - external_vars.yaml
```

**Output**:
Displays values from the external file using the same access methods as in previous examples.

---

### **7. User Input Variables**
**Objective**: Uses `vars_prompt` to prompt for user input.  

**Playbook**:
```yaml
vars_prompt:
  - name: username
    private: False
```

**Execution**:
The user is prompted for their username during playbook execution:
```plaintext
username: james
```

**Output**:
```plaintext
TASK [Display username]
ok: [centos1] => {"msg": "james"}
```

---

### **8. Secure User Input**
**Objective**: Uses `vars_prompt` to securely prompt for sensitive input (e.g., passwords).

**Playbook**:
```yaml
vars_prompt:
  - name: password
    private: True
```

**Execution**:
The user is prompted for a password, and input remains hidden:
```plaintext
password: ********
```

**Output**:
```plaintext
TASK [Display password]
ok: [centos1] => {"msg": "dummy"}
```

---

## **9. Using Hostvars**
**Objective**: Demonstrates accessing variables using the `hostvars` dictionary for a specific host.

**Playbook**:
```yaml
tasks:
  - name: Access `ansible_port` using dot notation
    debug:
      msg: "{{ hostvars[ansible_hostname].ansible_port }}"
  - name: Access `ansible_port` using dictionary notation
    debug:
      msg: "{{ hostvars[ansible_hostname]['ansible_port'] }}"
```

**Execution**:
For `centos1`, where `ansible_port` is set, the output shows:
```plaintext
"msg": "2222"
```

---

## **10. Hostvars with Missing Variables**
**Objective**: Shows how missing variables in `hostvars` lead to errors when not handled properly.

**Scenario**:
- `ansible_port` is defined only for `centos1`.
- The playbook tries to access `ansible_port` for all `centos` hosts.

**Result**:
- `centos1`: Succeeds with `"2222"`.
- `centos2` and `centos3`: Fail with an undefined variable error.

---

## **11. Hostvars with Default Values**
**Objective**: Uses the `default` filter to handle missing variables in `hostvars`.

**Playbook**:
```yaml
tasks:
  - name: Access `ansible_port` with a default value
    debug:
      msg: "{{ hostvars[ansible_hostname].ansible_port | default('22') }}"
```

**Execution**:
- `centos1`: `"2222"`
- `centos2` and `centos3`: `"22"`

---

## **12. Group Variables**
**Objective**: Accesses variables set at the group level using `group_vars`.

**Playbook**:
```yaml
tasks:
  - name: Access `ansible_user` from `group_vars`
    debug:
      msg: "{{ ansible_user }}"
```

**Result**:
For `centos` hosts, where `ansible_user` is defined in `group_vars/centos.yaml`, the output is `"root"`.

---

## **13. Missing Group Variables**
**Objective**: Shows errors when group variables are undefined.

**Scenario**:
- `ansible_user` is not set for `ubuntu` group.
- Playbook fails for `ubuntu1`, `ubuntu2`, and `ubuntu3` with:
```plaintext
The task includes an option with an undefined variable. The error was: 'ansible_user' is undefined
```

---

## **14. Group Variables in Hostvars**
**Objective**: Demonstrates that group variables are accessible via the `hostvars` dictionary.

**Playbook**:
```yaml
tasks:
  - name: Access `ansible_user` from `hostvars`
    debug:
      msg: "{{ hostvars[ansible_hostname].ansible_user }}"
```

**Execution**:
For `centos1`, the output is `"root"`.

---

## **15. Combining Hostvars and Groupvars**
**Objective**: Combines the use of `hostvars` and `group_vars` in the same playbook.

**Playbook**:
```yaml
tasks:
  - name: Access `ansible_port` from `hostvars`
    debug:
      msg: "{{ hostvars[ansible_hostname].ansible_port }}"
  - name: Access `ansible_user` from `group_vars`
    debug:
      msg: "{{ ansible_user }}"
```

**Execution**:
- `centos1`: `"2222"` (port), `"root"` (user).

---

## **16. Extra Variables**
**Objective**: Explores passing variables at runtime using the `--extra-vars` flag.

### Formats:
1. **INI Format**:
   ```bash
   ansible-playbook variables_playbook.yaml -e extra_vars_key="extra vars value"
   ```

2. **JSON Format**:
   ```bash
   ansible-playbook variables_playbook.yaml -e '{"extra_vars_key": "extra vars value"}'
   ```

3. **YAML Format**:
   ```bash
   ansible-playbook variables_playbook.yaml -e "{extra_vars_key: extra vars value}"
   ```

**Output**:
For all formats, the output is:
```plaintext
"msg": "extra vars value"
```

---

## **17. Variables from Files**
**Objective**: Demonstrates passing variables as entire YAML or JSON files.

### Formats:
1. **YAML File**:
   ```bash
   ansible-playbook variables_playbook.yaml -e @extra_vars_file.yaml
   ```

2. **JSON File**:
   ```bash
   ansible-playbook variables_playbook.yaml -e @extra_vars_file.json
   ```

**Execution**:
Both formats produce:
```plaintext
"msg": "extra vars value"
```
**Formats**:
1. INI: `-e key=value`.
2. JSON: `-e '{"key": "value"}'`.
3. YAML: `-e "{key: value}"`.

---

### **17. Variables from Files**
**Objective**: Pass variables as entire YAML or JSON files during playbook execution.

**Example**:
```bash
ansible-playbook playbook.yaml -e @extra_vars_file.yaml
```

---

## **Suggestions for Organization**
- Use `group_vars` and `host_vars` for scalable inventory management.
- Modularize variable definitions with external files.
- Leverage `default` filters for robust playbooks.

---

## **Conclusion**
These examples provide a comprehensive guide to managing variables in Ansible. By following this structure, you can build scalable, modular, and error-resilient playbooks for real-world applications.

