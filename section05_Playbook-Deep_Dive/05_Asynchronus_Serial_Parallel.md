#### **Introduction**
Welcome to this section on optimizing Ansible performance. This module will focus on methods to enhance playbook efficiency and execution through various features in Ansible. We'll analyze performance bottlenecks, asynchronous operations, serial execution, and advanced strategies such as the "free" strategy for task execution. By addressing inefficiencies, you'll gain a comprehensive understanding of how to leverage Ansible's capabilities to the fullest.

Key topics covered include:
- Playbook performance bottlenecks.
- Asynchronous operations and job handling.
- Serial and batch execution techniques.
- Alternative execution strategies such as "free."
- Practical examples with step-by-step revisions to improve runtime.

---

### **Revisions and Practical Insights**

#### **Revision 01: Initial Slow Playbook**

##### Scenario
We begin with a playbook named `slow_playbook.yaml`. It executes the `sleep` command for 5 seconds across 6 hosts using the default linear strategy.

```yaml
- hosts: linux
  tasks:
    - name: Task 1
      command: /bin/sleep 5
    - name: Task 2
      command: /bin/sleep 5
    - name: Task 3
      command: /bin/sleep 5
    - name: Task 4
      command: /bin/sleep 5
    - name: Task 5
      command: /bin/sleep 5
    - name: Task 6
      command: /bin/sleep 5
```

##### Execution Details
- The default linear strategy processes all tasks for one host before moving to the next task on subsequent hosts.
- Total execution time: ~76 seconds (including fact gathering).
- Observations: Tasks on the 6th host hold up the entire playbook.

**Takeaway**: The linear strategy results in significant delays when individual tasks are long-running.

---

#### **Revision 02: Limiting Execution to One Host**

##### Improvements
Modified the playbook to execute tasks on a single host at a time.

```yaml
- hosts: linux
  tasks:
    - name: Task 1
      command: /bin/sleep 5
      when: ansible_hostname == 'host1'
    - name: Task 2
      command: /bin/sleep 5
      when: ansible_hostname == 'host2'
```

**Result**: Execution time reduced to ~41 seconds. However, hosts are still waiting unnecessarily for others to complete.

---

#### **Revision 03: Asynchronous Execution with Polling**

##### Implementation
Introduced asynchronous task execution. Added the `async` and `poll` parameters to run tasks in the background and check their status.

```yaml
- name: Task 1
  command: /bin/sleep 5
  async: 10
  poll: 1
```

**Outcome**:
- Tasks execute asynchronously but still wait for status updates.
- Execution time improvement: Marginal.

---

#### **Revision 04: Fire and Forget**

##### Changes
Set `poll` to `0` for true fire-and-forget execution.

```yaml
- name: Task 1
  command: /bin/sleep 30
  async: 60
  poll: 0
```

**Observations**:
- Playbook finishes in ~12 seconds.
- Caveat: No immediate feedback on task completion; background tasks must be checked separately.

---

#### **Revision 05: Capturing Asynchronous Job IDs**

##### Objective
Capture the job IDs for tracking.

```yaml
- name: Capture Job IDs
  set_fact:
    jobids: >
      {% if item.ansible_job_id is defined -%}
        {{ jobids + [item.ansible_job_id] }}
      {% else -%}
        {{ jobids }}
      {% endif %}
  with_items: "{{ results }}"
```

**Insights**:
- Each task registers its job ID.
- Job IDs enable asynchronous status tracking.

---

#### **Revision 07: Status Checking with `async_status`**

##### Strategy
Utilized `async_status` module to periodically check background task completion.

```yaml
- name: Wait for Job IDs
  async_status:
    jid: "{{ item }}"
  with_items: "{{ jobids }}"
  register: job_results
  until: job_results.finished
  retries: 30
```

**Results**:
- Background tasks are properly tracked until completion.
- Execution aligns with task durations, providing accurate feedback.

---

#### **Revision 10: Adjusting Forks**

##### Configuration
Changed the `forks` setting in `ansible.cfg` to increase parallelism.

```ini
[defaults]
forks = 10
```

**Impact**:
- Parallel execution reduces total runtime significantly.
- Example: Runtime dropped from ~76 seconds to ~38 seconds.

---

#### **Revision 11: Serial Execution**

##### Approach
Introduced the `serial` keyword for batch execution.

```yaml
- hosts: linux
  serial: 2
  tasks:
    - name: Task 1
      command: /bin/sleep 5
```

**Use Case**: Rolling updates where tasks must run on a subset of hosts before proceeding.

---

#### **Revision 12: Incremental Batching**

##### Advanced Serial Execution
Specified batches as a list.

```yaml
- hosts: linux
  serial:
    - 1
    - 2
    - 3
```

**Behavior**: Executes tasks in stages: 1 host, then 2, then 3.

---

#### **Revision 13: Percentage-Based Serial Execution**

##### Flexibility
Used percentages to define batches.

```yaml
- hosts: linux
  serial:
    - 16%
    - 34%
    - 50%
```

**Advantages**: Adapts dynamically to host inventory size.

---

#### **Revision 15: Free Strategy**

##### Key Features
Set the `strategy` to `free` for fully parallel task execution.

```yaml
- hosts: linux
  strategy: free
  tasks:
    - name: Random Sleep
      command: "/bin/sleep {{ 10 | random }}"
```

**Outcome**:
- Tasks execute independently without waiting for others.
- Runtime: ~42 seconds (compared to ~76 seconds with the linear strategy).

---

### **Summary of Performance Enhancements**

| **Strategy**      | **Execution Time** | **Key Takeaways**                                        |
|--------------------|--------------------|---------------------------------------------------------|
| Linear (default)   | ~76 seconds        | Sequential execution; slowest host determines speed.    |
| Asynchronous       | ~41 seconds        | Background tasks with polling; better utilization.      |
| Fire and Forget    | ~12 seconds        | Fastest but lacks immediate task completion feedback.   |
| Adjusted Forks     | ~38 seconds        | Increased parallelism improves efficiency.              |
| Serial Execution   | Variable           | Controlled batch processing for safe rolling updates.   |
| Free Strategy      | ~42 seconds        | Fully parallel; fastest for independent tasks.          |

By employing these techniques, Ansible users can significantly improve task execution times, better utilize system resources, and tailor execution to specific requirements like rolling updates or independent parallel tasks.

