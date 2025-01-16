## Exploring Looping in Ansible

Hello and welcome to this deep dive into **looping** in Ansible. In this session, we'll explore how looping can enhance your playbook creation, providing a flexible and powerful way to handle repetitive tasks efficiently. This topic will cover:

1. **Loop types**: `with_items`, `with_dict`, `with_subelements`, `with_nested`, `with_together`, and more.
2. **Advanced uses**: Random choice and retry-until loops.
3. **Examples and improvements**: Revisiting previous scenarios and showcasing where loops could improve simplicity and readability.

---

### **1. Revisiting Examples with Loops**

#### **Simplifying MOTD Playbook**

In our first example (`revision 01`), we set the `Message of the Day (MOTD)` differently for CentOS and Ubuntu. Initially, we hardcoded variables for `motd_centos` and `motd_ubuntu`. By `revision 02`, this was streamlined to use `ansible_distribution` dynamically. Here’s the updated task:

```yaml
- name: Configure a MOTD (message of the day)
  copy:
    content: "Welcome to {{ ansible_distribution }} Linux - Ansible Rocks\n"
    dest: /etc/motd
```

We can further improve this using loops. By introducing `with_items` in `revision 03`, we iterate through supported distributions:

```yaml
- name: Configure a MOTD
  copy:
    content: "Welcome to {{ item }} Linux - Ansible Rocks!\n"
    dest: /etc/motd
  with_items:
    - CentOS
    - Ubuntu
  when: ansible_distribution == item
```

This reduces code repetition and ensures scalability if we add new distributions.

---

### **2. Creating and Managing Users**

#### **Creating Multiple Users with `with_items`**
In `revision 05`, we demonstrate how to create multiple users in a single task:

```yaml
- name: Create users
  user:
    name: "{{ item }}"
  with_items:
    - hayley
    - lily
    - anwen
```

This is ideal for tasks like provisioning accounts for a family or team. After running the playbook, the accounts will appear in `/etc/passwd`. 

#### **Using `with_dict` for Additional Metadata**
In `revision 07`, we expand the task to include metadata like full names using `with_dict`:

```yaml
- name: Create users with full names
  user:
    name: "{{ item.key }}"
    comment: "{{ item.value.full_name }}"
  with_dict:
    hayley:
      full_name: "Hayley Spurin"
    lily:
      full_name: "Lily Spurin"
    anwen:
      full_name: "Anwen Spurin"
```

This approach organizes user information better, particularly in large deployments.

#### **Nested Metadata with `with_subelements`**
In `revision 09`, we structure data hierarchically using `with_subelements`. For instance:

```yaml
- name: Create users with nested data
  user:
    name: "{{ item.1 }}"
    comment: "{{ item.1 | title }} {{ item.0.surname }}"
  with_subelements:
    - families:
        - surname: Spurin
          members: 
            - hayley
            - lily
        - surname: Jalba
          members: 
            - ana
    - members
```

This avoids repetitive surname entries for related accounts.

---

### **3. Enhancing Directories with Nested and Paired Loops**

#### **Nested Directories**
In `revision 12`, we use `with_nested` to create user directories:

```yaml
- name: Create user directories
  file:
    dest: "/home/{{ item.0 }}/{{ item.1 }}"
    state: directory
  with_nested:
    - [james, hayley, lily]
    - [photos, documents, movies]
```

This creates directories like `/home/james/photos` for each user.

#### **Paired Directories**
In `revision 13`, we pair users with their interests using `with_together`:

```yaml
- name: Pair users with directories
  file:
    dest: "/home/{{ item.0 }}/{{ item.1 }}"
    state: directory
  with_together:
    - [james, lily]
    - [tech, dancing]
```

This ensures each user’s folder aligns with their specific interest.

---

### **4. Secure User Authentication**

#### **SSH Keys with `with_file`**
In `revision 14`, we manage SSH keys efficiently:

```yaml
- name: Add public keys
  authorized_key:
    user: james
    key: "{{ item }}"
  with_file:
    - /home/ansible/.ssh/id_rsa.pub
    - /home/ansible/.ssh/id_dsa.pub
```

This facilitates adding multiple keys without repetitive code.

---

### **5. Sequences and Formatting**

#### **Using `with_sequence`**
We automate sequence generation in `revision 16`:

```yaml
- name: Create directories with sequences
  file:
    dest: "/home/james/sequence_{{ item }}"
    state: directory
  with_sequence: start=0 end=100 stride=10
```

This creates directories `sequence_0`, `sequence_10`, etc.

#### **Hexadecimal Formats**
In `revision 18`, we explore formatting:

```yaml
- name: Create hex directories
  file:
    dest: "/home/james/hex_sequence_{{ item }}"
    state: directory
  with_sequence: start=0 end=16 format=%x
```

This generates hex directories like `hex_sequence_0`, `hex_sequence_a`.

---

### **6. Advanced Loops**

#### **Random Choices**
In `revision 20`, we use `with_random_choice` to pick a directory at random:

```yaml
- name: Create random directory
  file:
    dest: "/home/james/{{ item }}"
    state: directory
  with_random_choice:
    - google
    - facebook
    - microsoft
```

This adds variability to configurations.

#### **Until Loops**
The `until` loop is explored in `revision 21`:

```yaml
- name: Run until condition met
  script: random.sh
  register: result
  retries: 100
  until: result.stdout.find("10") != -1
  delay: 1
```

Here, we rerun a script until it outputs `10`. This is valuable for state-based retries.

---

### **7. Recommendations**

- **Expand Your Knowledge**: Explore other looping constructs like `with_lines`, `with_ini`, and custom plugins.
- **Optimize Performance**: Combine loops with asynchronous tasks to handle larger inventories.
- **Debugging Tips**: Use `debug` tasks to examine `item` structures during iterations.

---

This concludes our detailed walkthrough of looping in Ansible. We encourage you to experiment with these techniques in your playbooks and explore the official [Ansible documentation](https://docs.ansible.com) for even more possibilities. Stay tuned for the next session on **Performance and Speed Optimization**!