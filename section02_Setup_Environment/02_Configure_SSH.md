### Setting Up SSH Connectivity Between Hosts

#### Lab Setup and SSH Overview ![overview](image.png)

In our previous video, we configured and set up our lab environment. Now, we’ll move on to configure **SSH connectivity between hosts**, which is a prerequisite for managing systems with **Ansible**, an agentless automation tool. 

Since Ansible relies on **passwordless SSH connectivity** to interact with target hosts, we must establish a **trusted relationship** between the Ansible control host and the managed systems.

#### What Happens During an SSH Session?![connectivity](image-1.png)

When you initiate an SSH session, several key steps occur to establish a secure and authenticated connection. For example, consider the following command executed on the Ansible control host (`ubuntu-c`):

```bash
ssh ubuntu1
```

This command initiates an SSH connection from the control host to the managed host (`ubuntu1`). Let’s break down the process:

1. **Protocol Negotiation**:
   - Both the client (`ubuntu-c`) and the server (`ubuntu1`) exchange and verify supported SSH protocol versions.
   - If the protocols are incompatible, the connection is terminated.

2. **Cryptographic Negotiation**:
   - The client and server agree on cryptographic primitives (encryption algorithms) to use for the session.
   - The **Diffie-Hellman key exchange algorithm** is then used to negotiate a **session key**, ensuring secure communication.

3. **Host Key Verification**:
   - The client receives the server’s public host key and prompts the user to verify it.
   - On accepting the key, the fingerprint is stored in the client’s `~/.ssh/known_hosts` file. This ensures future connections can verify the server’s identity.

4. **Encrypted Session**:
   - After the key exchange, the session is encrypted using the negotiated session key. This guarantees data confidentiality and integrity.

5. **Authentication**:
   - At this stage, the user is prompted to authenticate (e.g., by entering a password).
   - Once authenticated, the SSH connection is fully established.

#### Demonstration in the Lab

1. Open the **Ansible Terminal** and log in to the control host (`ubuntu-c`) using the username `ansible` and password `password`.
2. Test connectivity to the managed host (`ubuntu1`) using:

   ```bash
   ssh ubuntu1
   ```

3. Upon connecting:
   - Accept the host’s fingerprint. This will write the fingerprint to the control host’s `~/.ssh/known_hosts` file.
   - Enter the password (`password`) to complete the authentication and establish the connection.

4. Use the following command to view the `known_hosts` file:

   ```bash
   cat ~/.ssh/known_hosts
   ```

   The file contains entries for the target host’s **hostname** and **IP address**, captured during the first connection.

#### Public and Private Key Authentication

While password-based authentication works, it’s not ideal for automation with Ansible. Instead, we configure **public-private key authentication**:

1. **Generate a Key Pair**:
   - Use `ssh-keygen` on the control host to create a key pair:
     ```bash
     ssh-keygen
     ```
   - Accept the defaults and note the two files generated in the `~/.ssh` directory:
     - **Private Key**: Used by the client for authentication (e.g., `id_rsa`).
     - **Public Key**: Shared with the server and stored in its `~/.ssh/authorized_keys` file (e.g., `id_rsa.pub`).

2. **Copy the Public Key**:
   - Use `ssh-copy-id` to copy the public key to the target host:
     ```bash
     ssh-copy-id ansible@ubuntu1
     ```
   - After entering the password, the public key is added to the server’s `authorized_keys` file. Permissions are also automatically set correctly.

3. **Test Key-Based Authentication**:
   - Connect to the target host again:
     ```bash
     ssh ubuntu1
     ```
   - This time, no password is required.

#### Automating Key Distribution with Loops

For environments with multiple target hosts, manually distributing keys can be tedious. Here’s how to automate the process using **loops** and the `sshpass` utility:

1. **Install `sshpass`**:
   ```bash
   sudo apt update
   sudo apt install sshpass
   ```

2. **Create a Password File**:
   - Store the password (`password`) in a file for use with `sshpass`:
     ```bash
     echo "password" > password.txt
     ```

3. **Automate Key Distribution**:
   - Use a loop to iterate over users (`ansible` and `root`), operating systems (`ubuntu` and `centos`), and instances (`1`, `2`, `3`):
        ```bash
        ansible@ubuntu-c:~$ cat key_distribution.sh 
        #!/bin/bash

        # Ensure the script is executed with proper permissions
        if [[ $EUID -ne 0 ]]; then
        echo "Please run this script as root or with sudo."
        exit 1
        fi

        # Ensure sshpass is installed
        if ! command -v sshpass &>/dev/null; then
        echo "sshpass is not installed. Installing it now..."
        apt update && apt install -y sshpass
        fi

        # Ensure the password file exists
        PASSWORD_FILE="password.txt"
        if [[ ! -f "$PASSWORD_FILE" ]]; then
        echo "Password file ($PASSWORD_FILE) not found. Please create it with the required password."
        exit 1
        fi

        # Specify the SSH key location explicitly
        USER_HOME="/home/ansible"
        SSH_KEY="$USER_HOME/.ssh/id_rsa"
        if [[ ! -f "$SSH_KEY" ]]; then
        echo "SSH private key ($SSH_KEY) not found. Please ensure the key exists or specify the correct path."
        exit 1
        fi

        # Loop through users, operating systems, and instances
        for user in ansible root; do
        for os in ubuntu centos; do
            for instance in 1 2 3; do
            HOST="${os}${instance}"
            echo "Configuring SSH key-based authentication for ${user}@${HOST}..."
            
            # Use sshpass with the specified SSH key
            sshpass -f "$PASSWORD_FILE" ssh-copy-id -i "$SSH_KEY.pub" -o StrictHostKeyChecking=no "${user}@${HOST}"
            if [[ $? -eq 0 ]]; then
                echo "Successfully configured ${user}@${HOST}."
            else
                echo "Failed to configure ${user}@${HOST}. Please check the connection or credentials."
            fi
            done
        done
        done

        echo "SSH key distribution completed."
        ```
4. **Clean Up**:
   - Remove the password file after completing the setup:
     ```bash
     rm password.txt
     ```

5. **Passwordless Connectivity**![connectivity](image-2.png)

#### Verifying Connectivity with Ansible

After configuring SSH, test connectivity with Ansible:

1. Use the `ping` module to check connectivity to all hosts:
   ```bash
   ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping

   The authenticity of host 'centos2 (172.22.0.9)' can't be established.
   ECDSA key fingerprint is SHA256:gZJ2Oo5nHsXb9M/eh7qGfkvADM5zrBfwLUq8iY3dP6c.
   This key is not known by any other names
   ```

2. Successful output will display a **pong** response from each host, indicating that Ansible can communicate with them.


#### Workaround

The issue you're encountering with `Ansible` stems from the SSH client not recognizing or trusting the ECDSA keys of the remote hosts. This is due to the `StrictHostKeyChecking` mechanism in SSH, which is enabled by default and asks for confirmation when connecting to a host for the first time.

---

### Solution: Automate Host Key Acceptance

To ensure smooth execution, configure `Ansible` or your SSH client to automatically accept unknown host keys. Here are the steps:

---

#### 1. **Disable StrictHostKeyChecking in Ansible Inventory**
You can pass SSH options in the inventory file or command to disable host key checking.

Add the following SSH options to your `ansible` command:
```bash
ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'"
```

Alternatively, create a custom inventory file (`inventory.ini`) with the following content:
```ini
[all]
ubuntu1 ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
ubuntu2 ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
ubuntu3 ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
centos1 ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
centos2 ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
centos3 ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
```

Then run:
```bash
ansible all -i inventory.ini -m ping
```

---

#### 2. **Pre-Add Host Keys to Known Hosts**
You can prepopulate the `~/.ssh/known_hosts` file with the remote hosts' keys. Use the `ssh-keyscan` command to retrieve and append their public keys:
```bash
ssh-keyscan -H ubuntu1 ubuntu2 ubuntu3 centos1 centos2 centos3 >> ~/.ssh/known_hosts
```

After this, run your `ansible` command again:
```bash
ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping
```

---

#### 3. **Update the SSH Config File**
Modify the SSH client configuration (`~/.ssh/config`) to disable `StrictHostKeyChecking` globally or for specific hosts.

Edit or create `~/.ssh/config`:
```bash
Host ubuntu1 ubuntu2 ubuntu3 centos1 centos2 centos3
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
```

This will prevent SSH from prompting for host key confirmation.

---

### Final Test
After applying one of these solutions, re-run the `ansible` command:
```bash
ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping
```
```bash
ansible@ubuntu-c:~$ ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping
ubuntu2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false,
    "ping": "pong"
}
ubuntu3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false,
    "ping": "pong"
}
ubuntu1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false,
    "ping": "pong"
}
centos1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": false,
    "ping": "pong"
}
centos2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": false,
    "ping": "pong"
}
centos3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": false,
    "ping": "pong"
}
```
---

### Importance of Cleanup

Cleaning up at the end of a process is essential for maintaining a secure and efficient environment. By removing specific host entries from the `~/.ssh/known_hosts` file, you can prevent potential conflicts caused by outdated or mismatched SSH keys. Additionally, securely deleting sensitive files, such as plaintext password files, minimizes the risk of unauthorized access and data exposure. Incorporating a cleanup step ensures that your system is tidy, secure, and prepared for future tasks, especially in scenarios involving automation or temporary configurations.

---

### `cleanup.sh`
```bash
#!/bin/bash

# List of hosts to remove from known_hosts
hosts=("ubuntu1" "ubuntu2" "ubuntu3" "centos1" "centos2" "centos3")

echo "Starting cleanup process..."

for host in "${hosts[@]}"; do
  if ssh-keygen -R "$host" 2>/dev/null; then
    echo "Removed $host from known_hosts."
  else
    echo "No entry found for $host in known_hosts."
  fi
done

# Cleanup password file (optional, uncomment if needed)
PASSWORD_FILE="password.txt"
echo "Cleaning up the password file for security."
if [[ -f "$PASSWORD_FILE" ]]; then
  rm -f "$PASSWORD_FILE"
  echo "Password file ($PASSWORD_FILE) deleted successfully."
else
  echo "Password file ($PASSWORD_FILE) not found."
fi

echo "Cleanup process completed."
```

---

This note combines the importance of cleanup with a reusable script, making it a comprehensive addition to your documentation! Let me know if you'd like to adjust anything further. 😊

---

### Conclusion

By configuring SSH key-based authentication, we’ve enabled Ansible to manage systems efficiently without manual password entry. In the next video, we’ll set up the course repository and continue building our Ansible lab.
