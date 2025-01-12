## **1. Services Section**

The `services` section defines all containers that will be run as part of this application stack. Each service has attributes like `image`, `hostname`, `ports`, `volumes`, `networks`, and others that dictate how it behaves.

### **Control Node (ubuntu-c)**

```yaml
  ubuntu-c:
    hostname: ubuntu-c
    container_name: ubuntu-c
    image: spurin/diveintoansible:ansible
    ports: 
     - ${UBUNTUC_PORT_SSHD}:22
     - ${UBUNTUC_PORT_TTYD}:7681
    privileged: true
    volumes:
     - ${CONFIG}:/config
     - ${ANSIBLE_HOME}/shared:/shared
     - ${ANSIBLE_HOME}/ubuntu-c/ansible:/home/ansible
     - ${ANSIBLE_HOME}/ubuntu-c/root:/root
    networks:
     - diveinto.io
```

#### **Explanation**
1. **`hostname`**: 
   - Assigns the hostname `ubuntu-c` to the container. This name is visible within the container's network and is often used for DNS-based communication between services.

2. **`container_name`**:
   - Sets the container's name explicitly to `ubuntu-c`. This makes it easier to identify when you run `docker ps` or `docker logs`.

3. **`image`**:
   - Pulls the `spurin/diveintoansible:ansible` image, which is a custom image tailored for Ansible operations. You can replace this with your own image in a similar setup.

4. **`ports`**:
   - `22` (SSH) and `7681` (web terminal) from the container are mapped to host machine ports dynamically using environment variables (`${UBUNTUC_PORT_SSHD}` and `${UBUNTUC_PORT_TTYD}`). This ensures flexibility in choosing ports.

5. **`privileged`**:
   - This enables the container to access host-level resources, such as managing network settings. Use it sparingly, as it can introduce security risks.

6. **`volumes`**:
   - Mounts specific directories from the host to the container:
     - `${CONFIG}:/config`: Share configuration files.
     - `${ANSIBLE_HOME}/shared:/shared`: A shared directory accessible by multiple containers.
     - `${ANSIBLE_HOME}/ubuntu-c/ansible:/home/ansible`: Ansible user home directory.
     - `${ANSIBLE_HOME}/ubuntu-c/root:/root`: Root user files for customization.

7. **`networks`**:
   - Adds the container to the custom network `diveinto.io`. This enables inter-container communication.

---

### **Generic Nodes (ubuntu1, ubuntu2, ubuntu3)**

```yaml
  ubuntu1:
    hostname: ubuntu1
    container_name: ubuntu1
    image: spurin/diveintoansible:ubuntu
    ports: 
     - ${UBUNTU1_PORT_SSHD}:22
     - ${UBUNTU1_PORT_TTYD}:7681
    privileged: true
    volumes:
     - ${CONFIG}:/config
     - ${ANSIBLE_HOME}/shared:/shared
     - ${ANSIBLE_HOME}/ubuntu1/ansible:/home/ansible
     - ${ANSIBLE_HOME}/ubuntu1/root:/root
    networks:
     - diveinto.io
```

#### **Key Differences from `ubuntu-c`**
- **`image`:** Uses `spurin/diveintoansible:ubuntu`, which likely contains a lightweight Ubuntu setup for general testing, unlike `ubuntu-c`, which is tailored for Ansible.
- **Volume Mapping:** Paths are specific to `ubuntu1`, `ubuntu2`, or `ubuntu3`. This ensures data isolation between the nodes while still sharing certain directories like `/shared`.

---

### **CentOS Nodes (centos1, centos2, centos3)**

```yaml
  centos1:
    hostname: centos1
    container_name: centos1
    image: spurin/diveintoansible:centos_stream
    ports: 
     - ${CENTOS1_PORT_SSHD}:22
     - ${CENTOS1_PORT_TTYD}:7681
    privileged: true
    volumes:
     - ${CONFIG}:/config
     - ${ANSIBLE_HOME}/shared:/shared
     - ${ANSIBLE_HOME}/centos1/ansible:/home/ansible
     - ${ANSIBLE_HOME}/centos1/root:/root
    networks:
     - diveinto.io
```

#### **Differences from Ubuntu Nodes**
- **Image:** Uses `spurin/diveintoansible:centos_stream`, tailored for CentOS. This allows testing with multiple Linux distributions (e.g., Ubuntu and CentOS).
- **Naming and Volumes:** Similar to Ubuntu nodes but segregated for CentOS-specific use cases.

---

### **Docker-in-Docker (docker)**

```yaml
  docker:
    hostname: docker
    container_name: docker
    image: spurin/diveintoansible:dind
    privileged: true
    volumes:
     - ${ANSIBLE_HOME}/shared:/shared
    networks:
     - diveinto.io
```

#### **Purpose**
- Provides a Docker environment inside the container. The `spurin/diveintoansible:dind` image supports Docker-in-Docker (`dind`) functionality.
- It allows testing and running Docker commands as if inside a host system.

---

### **Portal (portal)**

```yaml
  portal:
    hostname: portal
    container_name: portal
    image: spurin/diveintoansible:portal
    environment:
     - NGINX_ENTRYPOINT_QUIET_LOGS=1
    depends_on:
     - centos1
     - centos2
     - centos3
     - ubuntu1
     - ubuntu2
     - ubuntu3
    ports:
     - "1000:80"
    networks:
     - diveinto.io
```

#### **Details**
1. **Web Portal:** This container provides a central interface for managing or monitoring the stack.
2. **Depends On:**
   - Ensures all the CentOS and Ubuntu nodes are running before starting the portal.
3. **Port Mapping:**
   - Maps port `80` (default HTTP) inside the container to port `1000` on the host.
4. **NGINX Logs:**
   - The environment variable `NGINX_ENTRYPOINT_QUIET_LOGS=1` suppresses NGINX entry-point logs for a cleaner output.

---

## **2. Networks Section**

```yaml
networks:
  diveinto.io:
    name: diveinto.io
```

- **Purpose:** Creates a custom bridge network named `diveinto.io`, allowing the services to communicate seamlessly.
- **Benefit:** Ensures all containers can find each other by hostname (e.g., `ubuntu1` can reach `centos1` by simply using its hostname).

---

## **3. Key Concepts for Rebuilding**

If you want to build a similar setup, follow these steps:

1. **Identify Use Cases:**
   - Do you need multiple Linux distributions (e.g., Ubuntu, CentOS)?
   - Are you testing with tools like Ansible or Docker?

2. **Design the Services:**
   - Decide on the images to use (you can create custom Dockerfiles if needed).
   - Define ports and volumes:
     - Ports: Ensure no conflicts on the host system.
     - Volumes: Share data between the host and containers or among containers.

3. **Network Configuration:**
   - Use a custom bridge network for better container communication.

4. **Dynamic Configuration:**
   - Use environment variables (`${VARIABLE}`) in the Compose file to make it portable and customizable.

5. **Security Considerations:**
   - Avoid `privileged: true` unless absolutely necessary.
   - Limit access to sensitive directories when using `volumes`.

6. **Test & Iterate:**
   - Start small (e.g., a single Ubuntu and CentOS node) and expand once the setup works.

Would you like a practical example to try building a basic setup yourself?