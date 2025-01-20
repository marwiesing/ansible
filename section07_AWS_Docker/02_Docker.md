### **Section Overview: Docker with Ansible**

In this section, we’ll explore managing Docker using Ansible. This involves automating tasks such as pulling Docker images, creating containers, customizing images, connecting to running containers, and performing cleanup. Our lab environment has a well-organized directory structure, as shown below:

```plaintext
Using Ansible with Cloud Services and Containers
└── Docker with Ansible
    ├── 01 (Base setup)
    ├── 02 (Add containers)
    ├── 03 (Basic customization)
    ├── 04 (Advanced customization)
    ├── 05 (Connect to containers)
    └── 06 (Cleanup)
```

Each folder corresponds to a specific stage in the progression, with playbooks and configurations evolving to meet the requirements of that step.

---

### **Step 1: Base Setup**

The first step ensures our environment is ready for Docker and Ansible integration. Key actions include:

1. **Install Required Components**:
    - Docker (`docker.io`) for managing containers.
    - Python Docker libraries for Ansible to interact with Docker.
    - Set up the `DOCKER_HOST` environment variable to point Ansible to a remote Docker instance.

#### **Key Files in `01`**:
- **`install_docker.sh`**:
   Installs Docker and Python dependencies:
   ```bash
   apt update && apt install -y docker.io
   pip3 install docker
   ```
- **`envdocker`**:
   Sets the `DOCKER_HOST` variable for remote Docker control:
   ```bash
   export DOCKER_HOST=tcp://docker:2375
   ```

---

### **Step 2: Pulling Docker Images**

Using Ansible’s `docker_image` module, we automate the retrieval of images needed for our experiments. This is defined in the `docker_playbook.yaml` file under `02`.

#### **Key Task**:
Pull multiple images, including:
- CentOS
- Ubuntu
- Redis
- Nginx
- Funbox (large image, >1GB)

#### **Playbook Snippet**:
```yaml
- name: Pull Docker images
  hosts: ubuntu-c
  tasks:
    - name: Pull images
      docker_image:
        docker_host: tcp://docker:2375
        name: "{{ item }}"
        source: pull
      with_items:
        - centos
        - ubuntu
        - redis
        - nginx
        - wernight/funbox
```

Run the playbook:
```bash
ansible-playbook 02/docker_playbook.yaml
```

Verify:
```bash
docker images
```

---

### **Step 3: Creating Containers**

In `02`, we also create an **Nginx container**:
- **Name**: `containerwebserver`
- **Ports**: Host `80:80` mapped to container `80`.

#### **Playbook Snippet**:
```yaml
- name: Create an nginx container
  docker_container:
    docker_host: tcp://docker:2375
    name: containerwebserver
    image: nginx
    ports:
      - "80:80"
```

Verify:
```bash
docker ps
```

---

### **Step 4: Customizing Docker Images**

We customize Docker images in `03` and `04` by building images from Dockerfiles.

#### **Basic Customization (Dockerfile):**
A simple Dockerfile adds a basic `index.html` file:
```Dockerfile
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
```

#### **Advanced Customization:**
In `04`, a more complex Dockerfile adds a custom webpage:
```Dockerfile
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
```

#### **Playbook to Build Custom Images:**
```yaml
- name: Build a customized image
  docker_image:
    docker_host: tcp://docker:2375
    name: nginxcustomised:latest
    source: build
    build:
      path: /shared
      pull: yes
    state: present
    force_source: yes
```

Verify:
```bash
docker images
```
> **Outcome**: `nginxcustomised:latest` image created.

---

### **Step 5: Connecting to Running Containers**

In `05`, Ansible treats running containers as remote hosts by specifying `ansible_connection: docker`.

#### **Playbook to Connect to Containers:**
```yaml
- name: Connect to running containers
  hosts: containers
  tasks:
    - name: Ping containers
      ping:
```

#### **Dynamic Inventory Configuration**:
```yaml
all:
  hosts:
    python1:
      ansible_connection: docker
    python2:
      ansible_connection: docker
    python3:
      ansible_connection: docker
```

Run the playbook:
```bash
ansible-playbook -i inventory.yml ping_containers.yml
```

> **Outcome**: Successful communication with running containers.

---

### **Step 6: Cleanup**

In `06`, we use Ansible to remove:
1. **Containers**: `containerwebserver`, `python1`, `python2`, `python3`.
2. **Images**: All pulled or built images.
3. **Temporary Files**: `Dockerfile`, `index.html`.

#### **Cleanup Playbook**:
```yaml
- name: Clean up Docker resources
  hosts: ubuntu-c
  tasks:
    - name: Remove old containers
      docker_container:
        docker_host: tcp://docker:2375
        name: "{{ item }}"
        state: absent
      with_items:
        - containerwebserver
        - python1
        - python2
        - python3

    - name: Remove images
      docker_image:
        docker_host: tcp://docker:2375
        name: "{{ item }}"
        state: absent
      with_items:
        - centos
        - ubuntu
        - redis
        - nginx
        - wernight/funbox
        - nginxcustomised
        - python:3.8.5

    - name: Remove files
      file:
        path: "{{ item }}"
        state: absent
      with_items:
        - /shared/Dockerfile
        - /shared/index.html
```

---

### **Key Learnings**

1. **Remote Docker Management**: Using `DOCKER_HOST` to interact with remote Docker hosts.
2. **Modular Ansible Playbooks**: Incremental improvement across revisions (`01` to `06`).
3. **Customizing Images**: Dockerfile integration for image personalization.
4. **Dynamic Inventory**: Treating containers as Ansible-managed hosts.
5. **Automation**: Cleanup and lifecycle management with Ansible.

---

### **Next Steps**

In the next section, we’ll explore creating **Ansible modules and plugins**, allowing us to extend Ansible’s functionality for specific needs. Stay tuned!