To ensure that similar issues do not occur in other projects, here’s a step-by-step guide to troubleshoot and fix the root causes of such problems systematically:

---

### **1. Validate SSH Configuration**
**Problem:** SSH key or connection configuration issues.
**Solution:**
- **Check SSH Key Permissions:**
  Ensure your private key has the correct permissions (`chmod 600 ~/.ssh/id_rsa`).
  ```bash
  chmod 600 /home/ansible/.ssh/id_rsa
  ```
- **Test Manual SSH Connections:**
  Use `ssh` to verify connections manually:
  ```bash
  ssh -i /home/ansible/.ssh/id_rsa ansible@<hostname>
  ```
  If you encounter issues:
  - Ensure the `ansible` user exists on the target machine.
  - Verify that the public key is added to the `~/.ssh/authorized_keys` file on the remote machine.

---

### **2. Ensure Correct Inventory File**
**Problem:** Mismatch or duplicate variables in the `hosts` inventory file.
**Solution:**
- **Remove Conflicting Variables:**
  In the `[centos:vars]` section, you set `ansible_user=root`, which overrides the user for `centos1`, `centos2`, and `centos3`. This is unnecessary since the `ansible_user=ansible` is already defined for each host.
  
  **Fixed `hosts` File:**
  ```ini
  [all]
  centos1 ansible_host=172.22.0.7 ansible_port=2222 ansible_user=ansible ansible_ssh_private_key_file=/home/ansible/.ssh/id_rsa
  centos2 ansible_host=172.22.0.9 ansible_port=22 ansible_user=ansible ansible_ssh_private_key_file=/home/ansible/.ssh/id_rsa
  centos3 ansible_host=172.22.0.8 ansible_port=22 ansible_user=ansible ansible_ssh_private_key_file=/home/ansible/.ssh/id_rsa

  [control]
  ubuntu-c ansible_connection=local

  [centos]
  centos1
  centos2
  centos3

  [ubuntu]
  ubuntu[1:3]

  [ubuntu:vars]
  ansible_become=true
  ansible_become_pass=password

  [linux:children]
  centos
  ubuntu
  ```

---

### **3. Verify `ansible.cfg`**
**Problem:** Misconfigured or redundant settings in the Ansible configuration.
**Solution:**
- Ensure the configuration aligns with the inventory file:
  - `inventory` points to the correct file.
  - `private_key_file` matches the path used in the inventory.
  - Remove unnecessary `[all]` section.

**Fixed `ansible.cfg`:**
```ini
[defaults]
inventory = hosts
host_key_checking = False
remote_user = ansible
private_key_file = /home/ansible/.ssh/id_rsa

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
pipelining = True
```

---

### **4. Test Ansible Connections**
Run these commands to verify connections:
- **Ping All Hosts:**
  ```bash
  ansible all -m ping -u ansible
  ```
- **Run Setup Module:**
  ```bash
  ansible all -m setup -u ansible
  ```

---

### **5. Use Debugging to Identify Issues**
**Problem:** Still facing connection issues?
**Solution:**
- Add the `-vvv` flag to commands to debug:
  ```bash
  ansible centos1 -m ping -vvv
  ```
- Look for:
  - SSH key issues.
  - Incorrect user or host configuration.
  - Port mismatch or blocked ports.

---

### **6. Common Pitfalls to Avoid**
- **Incorrect Ports:** Ensure that ports (e.g., `22` or `2222`) are correctly specified.
- **Duplicate Variables:** Avoid variable duplication or conflict in inventory files.
- **Key Issues:** Ensure public keys are added to remote hosts, and permissions are correctly set.

---

### **7. Automate Key Deployment (Optional)**
If you frequently add new hosts, consider using `ssh-copy-id` to deploy public keys:
```bash
ssh-copy-id -i /home/ansible/.ssh/id_rsa.pub ansible@<hostname>
```

---

### Final Steps
Once everything is working:
1. Save your inventory and configuration files for future reuse.
2. Document host-specific settings for easy debugging later.

By following this guide, you can avoid and quickly resolve similar issues in future projects. Let me know if you need clarification on any of these steps! 😊