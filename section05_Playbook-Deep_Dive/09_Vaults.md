## **Introduction to Ansible Vault**

### **Why Use Ansible Vault?**
In the course of Ansible development, it becomes essential to handle and secure sensitive information, such as passwords, private keys, or API tokens. While maintaining security, the goal is to ensure that these credentials remain functional within your workflows.

This is where **Ansible Vault** becomes invaluable. As its name suggests, Vault allows you to **encrypt**, **decrypt**, and **re-encrypt** sensitive data in your Ansible projects. By securing data, you reduce the risk of exposing confidential information to unintended parties.

In this video, we will cover:
1. Encrypting and decrypting variables.
2. Encrypting and decrypting files.
3. Rekeying (re-encrypting with a new password).
4. Using multiple vaults for fine-grained control over secrets.

---

## **Scenario 1: Encrypting Variables**

Let's start with an example: managing the `ansible_become_pass` variable.

### **Step 1: The Problem**
Previously, we stored `ansible_become_pass` in plaintext in `group_vars`. This worked but exposed sensitive information. If we attempt to execute an Ansible command now without the password stored, we would encounter errors.

### **Step 2: Encrypting a Variable**
To address this, we will create a vault entry for `ansible_become_pass`.

```bash
ansible-vault encrypt_string
```

- **Command Options:**
  - `encrypt_string`: Encrypts a single variable as a string.
  - `--ask-vault-pass`: Prompts for the vault password interactively.
  
**Example:**
```bash
ansible-vault encrypt_string --ask-vault-pass --name 'ansible_become_pass' 'password'
```

- When prompted:
  - Enter a value for the variable (e.g., `password`).
  - Provide a vault password (e.g., `vaultpass`).

**Result:**
```yaml
New Vault password: 
Confirm New Vault password: 
Encryption successful
ansible_become_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          38343532333233616235316161653137303361323035343665333566633933306462323463613464
          3434643266323264613335663664643539323937363339620a326535306265353862616666376664
          33333438333436306564393135393430303332633139646332653237313666656131306164393732
          6639363439343665650a623934653463623134623536633166333739623035343566383030303533
          3638
```

### **Step 3: Using the Vaulted Variable**
Copy the encrypted variable into your `group_vars` file. For example:

```yaml
# group_vars/all.yaml
ansible_become_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          <ENCRYPTED_STRING>
```

When running Ansible, use the `--ask-vault-pass` flag to provide the vault password.

**Example:**
```bash
ansible-playbook site.yaml --ask-vault-pass
ansible --ask-vault-pass ubuntu -m ping -o
Vault password: 
ubuntu1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.10"},"changed": false,"ping": "pong"}
ubuntu2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.10"},"changed": false,"ping": "pong"}
ubuntu3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3.10"},"changed": false,"ping": "pong"}
```

---

## **Scenario 2: Encrypting Files**

### **Step 1: Encrypting a Variables File**
To encrypt an external variables file, use the `encrypt` action:

```bash
ansible-vault encrypt external_vars.yaml
```

- When prompted, enter a vault password (e.g., `vaultpass`).

The encrypted file will look like this:
```yaml
$ cat external_vault_vars.yaml 
$ANSIBLE_VAULT;1.1;AES256
62363239663131366231336235666130373933393965666537333565393166303666323235303736
3638336363363434323238353362353537613532303366370a393134316637653363366239363836
63643562303262643265313664373962663538623733393535376665643166333637663933643237
6431653435343538380a336539363462343366393230376638663231343463346630653563663938
32353465383466323862303266663130653538376433623731653161316434396530316632373831
6236383636613835353863343366616637663162376330373332
```

### **Step 2: Using the Encrypted File in a Playbook**
Reference the encrypted file in your playbook:

```yaml
# playbook.yaml
- hosts: linux
  vars_files:
    - external_vars.yaml
  tasks:
    - name: Show external variable
      debug:
        var: external_var
```

Run the playbook with:
```bash
ansible-playbook vault_playbook.yaml --ask-vault-pass
```

### **Step 3: Decrypt & Encrypt**
```bash
$ ansible-vault decrypt external_vault_vars.yaml 
Vault password: 
Decryption successful
```

```bash
$ ansible-vault encrypt external_vault_vars.yaml 
New Vault password: 
Confirm New Vault password: 
Encryption successful
```


---

## **Scenario 3: Rekeying (Password Rotation)**

Sometimes, you may need to rotate passwords. Ansible Vault simplifies this with the `rekey` action.

### **Example: Rekeying a File**
1. Current password: `vaultpass`.
2. New password: `vaultpass2`.

```bash
ansible-vault rekey external_vault_vars.yaml
Vault password: 
New Vault password: 
Confirm New Vault password: 
Rekey successful
```

- Provide the current password. `vaultpass`
- Enter and confirm the new password. `vaultpass2`

---

## **Scenario 4: Viewing Encrypted Content**

To view encrypted content without decrypting the file:

```bash
ansible-vault view external_vault_vars.yaml --ask-vault-pass
```

---

## **Scenario 5: Automating Vault Password Management**

### **Using a Password File**
Create a file to store the vault password:
```bash
echo "vaultpass2" > password_file
```

Use the `--vault-password-file` option to reference this file:
```bash
ansible-vault view external_vault_vars.yaml --vault-password-file password_file
```

### **Using Named Vaults**
Named vaults allow for managing multiple vaults in a single project.
```bash
ansible-vault view external_vault_vars.yaml --vault-id @prompt  
Vault password (default): 
external_vault_var: Example External Vault Var

ansible-vault view external_vault_vars.yaml --vault-id @password_file  
external_vault_var: Example External Vault Var
```

#### **Decrypting Vault**
```bash
ansible-vault decrypt external_vault_vars.yaml 
Vault password: 
Decryption successful
```


#### **Encrypting with a Named Vault**
```bash
ansible-vault encrypt view external_vault_vars.yaml --vault-id vars@prompt
```

- `varspass` as password
- `vars`: Name of the vault.
- `@prompt`: Prompts for the password.

**Output:**
```bash
cat external_vault_vars.yaml 
$ANSIBLE_VAULT;1.2;AES256;vars
32653766613237636264646363323565316666383236336230623937313532613330646233386332
6132393761656563636635643161616234316137303565320a356464313930653861626436383230
39626261613665653638356530393134376137633563343064306239396461383832356166653030
6339623435336239360a393336356136343664613134306132366235363061343166346231663336
65353862396137633263333662656337343237393338656430346131626163643135363963363965
6364336533373561336362326461626333613161643135313033
```

#### **Vault-String**
```bash
ansible-vault encrypt_string --vault-id ssh@prompt --name 'ansible_become_pass' 'password'
New vault password (ssh): 
Confirm new vault password (ssh): 
Encryption successful
ansible_become_pass: !vault |
          $ANSIBLE_VAULT;1.2;AES256;ssh
          35623134366136646661306166656539393431316262636661356334626461353866303137383761
          3632333038316338323661386261643934323061333465310a643931306638343735353466383730
          66343762373834343333353839643764373064643762303666343136666134633866353938626466
          6665303136363134650a646462653862363664343865333739653236316265333234326431626565
          3966
```
- `sshpass` as password

#### **Referencing Multiple Vaults**
For a playbook requiring multiple vaults:
```bash
ansible-playbook vault-playbook.yaml \
  --vault-id vars@prompt \
  --vault-id ssh@password_file
```

```bash
$ ansible-playbook --vault-id vars@prompt --vault-id ssh@prompt vault_playbook.yaml 
Vault password (vars): 
Vault password (ssh): 

PLAY [linux] *******************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************************************************************
ok: [centos1]
ok: [centos2]
ok: [centos3]
ok: [ubuntu1]
ok: [ubuntu2]
ok: [ubuntu3]

TASK [Show external_vault_var] *************************************************************************************************************************************************************************************************************
ok: [centos1] => {
    "external_vault_var": "Example External Vault Var"
}
ok: [centos2] => {
    "external_vault_var": "Example External Vault Var"
}
ok: [centos3] => {
    "external_vault_var": "Example External Vault Var"
}
ok: [ubuntu1] => {
    "external_vault_var": "Example External Vault Var"
}
ok: [ubuntu2] => {
    "external_vault_var": "Example External Vault Var"
}
ok: [ubuntu3] => {
    "external_vault_var": "Example External Vault Var"
}

PLAY RECAP *********************************************************************************************************************************************************************************************************************************
centos1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
centos2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
centos3                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu3                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

---

## **Scenario 6: Encrypting Entire Playbooks**

You can also encrypt entire playbooks for additional security:

```bash
ansible-vault encrypt vault_playbook.yaml --vault-id playbook@prompt
```

- `playbookpass` as password

Run the playbook by providing the vault password:
```bash
ansible-playbook --vault-id vars@prompt --vault-id ssh@prompt --vault-id playbook@prompt vault_playbook.yaml 
Vault password (vars): varspass
Vault password (ssh):  sshpass
Vault password (playbook): playbookpass
```

---

## **Conclusion**

In this video, we explored:
1. How to encrypt variables, files, and playbooks.
2. Using multiple named vaults.
3. Managing vault passwords for automation and security.

Stay tuned for the next section: **Structuring Ansible Playbooks**.

--- 

### **Additional Examples**

#### **Encrypting Environment Variables**
```bash
ansible-vault encrypt_string --ask-vault-pass --name DB_PASSWORD
```

#### **Encrypting Files in Bulk**
Encrypt all YAML files in a directory:
```bash
for file in *.yaml; do
    ansible-vault encrypt "$file" --vault-id default@prompt
done
```

#### **Dynamic Password Rotation**
Automate password rekeying:
```bash
ansible-vault rekey --vault-id old@prompt --new-vault-id new@prompt *.yaml
```
