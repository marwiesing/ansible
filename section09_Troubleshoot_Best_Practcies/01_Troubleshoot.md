### Enhanced Transcript: Troubleshooting Ansible

Welcome to this section of the course, where we’ll delve into “Other Ansible Resources and Areas”. The first video in this section focuses on troubleshooting Ansible, followed by best practices.

---

#### Key Topics Covered:
1. **Troubleshooting SSH Connectivity**
2. **Syntax Checking in Ansible**
3. **Stepping Through Playbooks**
4. **Starting Playbooks at Specific Tasks**
5. **Configuring Logging for Ansible**
6. **Using Verbosity for Debugging**

---

### 1. Troubleshooting SSH Connectivity

#### Example Scenario:
You want to connect from `ubuntu-c` to `ubuntu1` using SSH, but there is an issue with authentication. Here’s how to troubleshoot:

1. **Initial Connection:**
   - Attempt to SSH into `ubuntu1`.
     ```bash
     ssh user@ubuntu1
     ```
   - If successful, the connection works as expected.

2. **Simulated Error:**
   - Permissions on the `authorized_keys` file are incorrectly set to `777`.
     ```bash
     chmod 777 ~/.ssh/authorized_keys
     ```
   - When you reconnect, you are prompted for a password, indicating a permissions issue.

3. **Client-Side Debugging:**
   - Use the `-v` flag to increase verbosity:
     ```bash
     ssh -v user@ubuntu1
     ```
   - This provides detailed output about the connection attempt, showing it reverted to password authentication.

4. **Server-Side Debugging:**
   - Connect to `ubuntu1` and run the SSH daemon in debug mode on a specific port:
     ```bash
     sudo /usr/sbin/sshd -d -p 1234
     ```
   - Reconnect from the client, specifying the port:
     ```bash
     ssh -p 1234 user@ubuntu1
     ```
   - Check the debug output for errors, such as:
     ```
     Authentication refused: bad ownership or modes for file /home/user/.ssh/authorized_keys
     ```

5. **Fix the Issue:**
   - Correct the permissions:
     ```bash
     chmod 600 ~/.ssh/authorized_keys
     ```
   - Retry the connection, which should now succeed.

**Tip:** Use this approach for other SSH-related issues, such as key mismatches or host verification failures.

---

### 2. Syntax Checking in Ansible

Before running playbooks, validate their syntax to catch errors early:

```bash
ansible-playbook playbook.yml --syntax-check
```

#### Example:
- Check a playbook called `blocks.yml`:
  ```bash
  ansible-playbook blocks.yml --syntax-check
  ```
- Output confirms if the syntax is valid or highlights issues.

**Best Practice:** Incorporate syntax checks into your CI/CD pipeline to prevent deployment failures.

---

### 3. Stepping Through Playbooks

Use the `--step` option to execute tasks one at a time:

```bash
ansible-playbook playbook.yml --step
```

#### Example:
- Execute `blocks.yml` interactively:
  ```bash
  ansible-playbook blocks.yml --step
  ```
- Choose “Yes” or “No” for each task:
  - Yes: Executes the task.
  - No: Skips the task.

**Use Case:** Debug complex playbooks by isolating specific tasks.

---

### 4. Starting at a Specific Task

Use the `--start-at-task` option to begin execution from a named task:

```bash
ansible-playbook playbook.yml --start-at-task="Install python-dnspython"
```

#### Example:
- Start a playbook at the task “Install python-dnspython”:
  ```bash
  ansible-playbook blocks.yml --start-at-task="Install python-dnspython"
  ```
- Ansible skips tasks before the specified one and executes from the starting point.

**Tip:** Combine this with `--tags` for targeted execution.

---

### 5. Configuring Logging

By default, Ansible does not log executions. Enable logging in `ansible.cfg`:

```ini
[defaults]
log_path = /var/log/ansible.log
```

#### Example:
1. Edit the configuration file:
   ```bash
   nano /etc/ansible/ansible.cfg
   ```
2. Add the log path under `[defaults]`.
3. Run the playbook and check the log file:
   ```bash
   ansible-playbook playbook.yml
   cat /var/log/ansible.log
   ```

**Use Case:** Maintain logs for auditing and debugging purposes.

---

### 6. Using Verbosity for Debugging

Increase verbosity to get detailed output:

- `-v`: Basic information.
- `-vv`: Input and output details.
- `-vvv`: Connection details to managed hosts.
- `-vvvv`: Detailed connection plugins, scripts, and user context.

#### Example:
- Run `blocks.yml` with maximum verbosity:
  ```bash
  ansible-playbook blocks.yml -vvvv
  ```
- Output includes:
  - Task execution details.
  - Connection logs.
  - Plugin and script data.

**Tip:** Use higher verbosity levels cautiously, as they can produce excessive output.

---

### Summary:
- Debug SSH issues using client and server-side tools.
- Validate playbook syntax before execution.
- Step through or start at specific tasks to isolate issues.
- Enable logging in `ansible.cfg` for persistent records.
- Leverage verbosity levels for detailed insights during troubleshooting.

These approaches ensure efficient and effective troubleshooting, minimizing downtime and errors in your Ansible workflows.

---

Join us in the next video, where we’ll explore best practices with Ansible to enhance your playbook development and management.

