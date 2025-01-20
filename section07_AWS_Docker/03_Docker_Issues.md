### Summary: Fixing Docker Issues by Modifying `/lib/systemd/system/docker.service`

If Docker encounters issues (e.g., not listening on desired endpoints, failing to start after changes to `/etc/docker/daemon.json`), here is a step-by-step guide to resolve the problem by editing `/lib/systemd/system/docker.service`:

---

#### **1. Backup the Original Configuration**
Always create a backup of the file before making changes:

```bash
sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
```

Verify the backup exists:

```bash
ls -l /lib/systemd/system/docker.service.bak
```

---

#### **2. Edit the Docker Service File**
Open the file for editing:

```bash
sudo vi /lib/systemd/system/docker.service
```

Modify the `ExecStart` line to include the desired endpoints. Example to enable both **TCP** (`127.0.0.1:2375`) and the **Unix socket**:

```ini
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock -H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock
```

---

#### **3. Add Hostname Resolution for `docker`**
If your playbooks or scripts refer to `tcp://docker:2375`, ensure the hostname `docker` resolves to `127.0.0.1`. Add this to `/etc/hosts`:

```bash
echo "127.0.0.1 docker" | sudo tee -a /etc/hosts
```

Verify the resolution:

```bash
ping docker
```

---

#### **4. Apply Changes**
Reload the systemd daemon and restart Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

#### **5. Verify the Configuration**
1. Check if Docker is running:
   ```bash
   sudo systemctl status docker
   ```

2. Verify Docker is listening on the desired endpoints:
   - For TCP:
     ```bash
     sudo netstat -tuln | grep 2375
     ```
   - For the Unix socket:
     ```bash
     ls -l /var/run/docker.sock
     ```

3. Test Docker commands:
   ```bash
   docker -H tcp://127.0.0.1:2375 ps
   docker -H unix:///var/run/docker.sock ps
   ```

---

#### **6. Update Ansible Playbooks**
If your Ansible playbooks use `docker_host: tcp://docker:2375`, update them to match the new configuration:

Before
```bash
$ cat */*.yaml | grep tcp://docker
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
        docker_host: tcp://docker:2375
```

```bash
sed -i 's/tcp:\/\/docker:2375/tcp:\/\/127.0.0.1:2375/g' */*.yaml
```

Verify the changes:

```bash
grep 'docker_host:' */*.yaml
```

---

#### **7. Fix Permission Issues (Optional)**
If accessing the Unix socket gives a `permission denied` error, add your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

#### **8. Rollback if Needed**
If Docker fails to start after the changes, revert to the original file:

```bash
sudo mv /lib/systemd/system/docker.service.bak /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

This summary provides a clear and repeatable process to troubleshoot and fix Docker-related issues by modifying the systemd service file, updating hostname resolution, and ensuring Ansible playbooks align with the changes.



---
---
---
---


Here’s how to proceed carefully with the required changes:

---

### Step 1: Backup the Existing File

Before making any changes, create a backup of the file:

```bash
sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
```

Verify the backup exists:

```bash
ls -l /lib/systemd/system/docker.service.bak
```

---

### Step 2: Suggested Changes to `/lib/systemd/system/docker.service`

Modify the `ExecStart` line to include both the TCP endpoint and the Unix socket. The modified file should look like this:

```ini
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket
Wants=containerd.service

[Service]
Type=notify
# Modify the ExecStart line to enable TCP and Unix socket
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock -H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

---

### Step 3: Reload Systemd and Restart Docker

Apply the changes:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

### Step 4: Verify Changes

Check if Docker is running and listening on both the TCP and Unix sockets:

1. **Verify TCP Endpoint**:
   ```bash
   sudo netstat -tuln | grep 2375
   ```

   You should see a line like this:
   ```
   tcp        0      0 127.0.0.1:2375          0.0.0.0:*               LISTEN
   ```

2. **Test Docker Commands**:
   ```bash
   docker -H tcp://127.0.0.1:2375 ps
   docker -H unix:///var/run/docker.sock ps
   ```

---

### Step 5: Rollback If Needed

If Docker fails to start after the changes, rollback to the original configuration:

```bash
sudo mv /lib/systemd/system/docker.service.bak /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

It looks like the configuration is now working as expected. Docker is listening on both the TCP endpoint (`127.0.0.1:2375`) and the Unix socket (`/var/run/docker.sock`). Here’s a summary of the situation and next steps:

---

### **Summary**

1. **TCP Endpoint Works:**
   - The command `docker -H tcp://127.0.0.1:2375 ps` runs successfully, confirming the TCP endpoint is operational.

2. **Unix Socket Requires Root Permissions:**
   - The command `docker -H unix:///var/run/docker.sock ps` gives a `permission denied` error because your user lacks permissions to access the Unix socket.

3. **Unix Socket Works with `sudo`:**
   - The command `sudo docker -H unix:///var/run/docker.sock ps` runs successfully, confirming the Unix socket works when run as root.

---

### **Fixing Unix Socket Permissions**

If you want to avoid using `sudo` for Unix socket commands, add your user to the `docker` group:

1. **Add User to the Docker Group:**
   ```bash
   sudo usermod -aG docker $USER
   ```

2. **Reload the User Session:**
   Log out and log back in for the changes to take effect, or run:

   ```bash
   newgrp docker
   ```

3. **Verify Permissions:**
   Test the Unix socket without `sudo`:

   ```bash
   docker -H unix:///var/run/docker.sock ps
   ```

---

### **Testing Docker Commands**

Now that both endpoints are operational:

1. **Test TCP Connection:**
   ```bash
   docker -H tcp://127.0.0.1:2375 ps
   ```

2. **Test Unix Socket:**
   ```bash
   docker -H unix:///var/run/docker.sock ps
   ```

3. **Run a Container:**
   ```bash
   docker -H tcp://127.0.0.1:2375 run -it busybox sleep 100
   ```

4. **List Running Containers:**
   ```bash
   docker -H tcp://127.0.0.1:2375 ps
   ```

---

### **Notes**

- **TCP Warning:** The warning about `tcp://127.0.0.1:2375` being insecure is expected because it doesn’t use TLS. This is fine for local testing but should not be exposed to external networks.
- **`ping docker` Fails:** This is because the `docker` hostname is not defined. If required, add it to `/etc/hosts`:

   ```bash
   echo "127.0.0.1 docker" | sudo tee -a /etc/hosts
   ```

   Then, test:
   ```bash
   ping docker
   ```

Let me know if there’s anything else you'd like to configure or troubleshoot! 🚀