#### **Introduction: Task Delegation in Ansible**

In this session, we’ll cover how to delegate specific tasks to be executed on designated hosts or control hosts. Task delegation is particularly useful when we need to centralize operations or perform actions that affect multiple nodes but are orchestrated from a single location.

#### Objective
By the end of this session, you will understand how to:
1. Generate and distribute SSH key pairs across hosts.
2. Manage access control with **tcpwrappers** using `/etc/hosts.allow` and `/etc/hosts.deny`.
3. Use the `delegate_to` module for centralized task execution.

We will:
- Restrict SSH access to certain hosts (`ubuntu-c`, `centos1`, and `ubuntu1`).
- Use `tcpwrappers` to enforce these rules.
- Test SSH connectivity after implementing the rules.

Let’s get started!

---

### Revision 01: Key Generation and Distribution

#### Overview
This playbook performs the following:
1. **Generate an SSH keypair** for the `ubuntu3` host.
2. **Distribute the SSH keypair** to target hosts, setting appropriate permissions.
3. **Install the public key** on `ubuntu3` to allow password-less access.

#### Breakdown of Plays

1. **Generate SSH Keypair**
   - **Hosts**: `ubuntu-c` (control host).
   - **Task**:
     ```yaml
     - name: Generate an OpenSSH keypair for ubuntu3
       openssh_keypair:
         path: ~/.ssh/ubuntu3_id_rsa
     ```
     The `openssh_keypair` module generates a private-public keypair at the specified path.

2. **Distribute SSH Keypair**
   - **Hosts**: All Linux hosts.
   - **Task**:
     ```yaml
     - name: Copy ubuntu3 OpenSSH keypair with permissions
       copy:
         owner: root
         src: "{{ item.0 }}"
         dest: "{{ item.0 }}"
         mode: "{{ item.1 }}"
       with_together:
         - ["~/.ssh/ubuntu3_id_rsa", "~/.ssh/ubuntu3_id_rsa.pub"]
         - ["0600", "0644"]
     ```
     Here, the `with_together` loop ensures:
     - Private key (`0600`) has restrictive permissions.
     - Public key (`0644`) is readable by all.

3. **Install Public Key on `ubuntu3`**
   - **Hosts**: `ubuntu3`.
   - **Task**:
     ```yaml
     - name: Add public key to ubuntu3 authorized_keys file
       authorized_key:
         user: root
         state: present
         key: "{{ lookup('file', '~/.ssh/ubuntu3_id_rsa.pub') }}"
     ```
     This uses the `authorized_key` module to append the public key to `~/.ssh/authorized_keys` for password-less login.

---

### Revision 02: Connectivity Validation

#### Overview
In this revision, we validate SSH connectivity using the newly installed key. An additional task is introduced to execute an SSH command from the control host (`ubuntu-c`).

#### New Task: Validate SSH Access
- **Command**:
  ```yaml
  - name: Check SSH connectivity
    command: ssh -i ~/.ssh/ubuntu3_id_rsa \
             -o BatchMode=yes \
             -o StrictHostKeyChecking=no \
             -o UserKnownHostsFile=/dev/null \
             root@ubuntu3 date
    changed_when: False
    ignore_errors: True
  ```
  - **Options Explained**:
    - `-i ~/.ssh/ubuntu3_id_rsa`: Use the private key for authentication.
    - `BatchMode=yes`: Prevents prompts for key verification.
    - `StrictHostKeyChecking=no`: Skips host fingerprint checks.
    - `UserKnownHostsFile=/dev/null`: Avoids writing to `~/.ssh/known_hosts`.
  - **Purpose**: The `date` command ensures connectivity without modifying the system.

---

### Revision 03: Task Delegation with `delegate_to`

#### Overview
Here, we introduce task delegation to centralize rule updates in `/etc/hosts.allow` on `ubuntu3`.

#### New Task: Add Rules to `/etc/hosts.allow`
- **Hosts**: `ubuntu-c`, `centos1`, `ubuntu1`.
- **Task**:
  ```yaml
  - name: Add host to /etc/hosts.allow for sshd
    lineinfile:
      path: /etc/hosts.allow
      line: "sshd: {{ ansible_hostname }}.diveinto.io"
      create: True
    delegate_to: ubuntu3
  ```
  - **Key Concept**: `delegate_to` ensures this task is executed on `ubuntu3` while iterating over `ubuntu-c`, `centos1`, and `ubuntu1`.

#### Validation Task
- **Repeat SSH Connectivity Test**: Ensure hosts in `/etc/hosts.allow` can connect, and others cannot.

---

### Revision 04: Adding Deny Rules

#### Overview
We expand the playbook to add deny rules in `/etc/hosts.deny`. This ensures only explicitly allowed hosts can SSH into `ubuntu3`.

#### New Task: Add Deny Rule
- **Task**:
  ```yaml
  - name: Drop SSH connectivity from all other hosts
    lineinfile:
      path: /etc/hosts.deny
      line: "sshd: ALL"
      create: True
  ```
  - **Effect**: Blocks SSH access from any host not listed in `/etc/hosts.allow`.

#### Expected Behavior
- Hosts listed in `/etc/hosts.allow` (e.g., `ubuntu-c`) can still connect.
- All other hosts (e.g., `centos2`, `ubuntu2`) are blocked.

---

### Revision 05: Cleanup and Reusability

#### Overview
In the final revision, we implement cleanup tasks to remove rules from `/etc/hosts.allow` and `/etc/hosts.deny`. This ensures the system returns to its initial state.

#### Cleanup Tasks
1. **Remove Allow Rules**
   ```yaml
   - name: Remove host entries in /etc/hosts.allow for sshd
     lineinfile:
       path: /etc/hosts.allow
       line: "sshd: {{ ansible_hostname }}.diveinto.io"
       state: absent
     delegate_to: ubuntu3
   ```

2. **Remove Deny Rules**
   ```yaml
   - name: Remove deny rules in /etc/hosts.deny
     lineinfile:
       path: /etc/hosts.deny
       line: "sshd: ALL"
       state: absent
   ```

#### Reusability
- By running the cleanup tasks, you can repeat the cycle of adding, testing, and removing rules without manual intervention.

---

### Key Takeaways
1. **Task Delegation**: Enables centralized execution of tasks on specific hosts, simplifying management.
2. **Tcpwrappers**: Effective for basic access control, though deprecated in favor of modern security practices like firewalls.
3. **Validation and Cleanup**: Always validate connectivity and ensure playbooks are idempotent for reusability.

---

### Conclusion
Task delegation showcases the power of Ansible in managing complex scenarios with centralized control. By combining `delegate_to` with modules like `lineinfile` and `authorized_key`, you can efficiently manage access control across distributed systems.
