ssh ubuntu1
exit
ssh ubuntu1
ls -a
cat ~/.ssh/known_hosts
ssh ubuntu1
ssh-keygen
cat .ssh/id_rsa.pub 
cat .ssh/id_rsa
ssh-copy-id ansible@ubuntu1
ssh ubuntu1
ssh-copy-id ansible@ubuntu2
sudo apt update
sudo apt install sshpass
echo "password" > password.txt
vi key_distribution.sh
cat key_distribution.sh 
chmod +x key_distribution.sh 
sudo ./configure_ssh_keys.sh
ls
ls -a
sudo ./key_distribution.sh 
vi key_distribution.sh 
sudo ./key_distribution.sh 
vi key_distribution.sh 
sudo ./key_distribution.sh 
vi key_distribution.sh 
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
ls -a
ls .ssh
sudo ./key_distribution.sh 
ls .ssh
cat key_distribution.sh 
vi key_distribution.sh 
sshpass -f password.txt ssh -o StrictHostKeyChecking=no ansible@ubuntu1
ls
sshpass -V
sudo apt update && sudo apt upgrade
sshpass -V
sudo sshpass -f password.txt ssh -o StrictHostKeyChecking=no ansible@ubuntu1
ls -al
sudo ./key_distribution.sh 
ls .ssh
ls /
vi key_distribution.sh 
sudo ./key_distribution.sh
cat key_distribution.sh 
ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping
ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'"
vi inventory.ini
ansible all -i inventory.ini -m ping
cat .ssh/known_hosts 
ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping
ansible -v
ansible -version
vi cleanup.sh
cat cleanup.sh 
vi cleanup.sh
chmod +x cleanup.sh
./cleanup.sh
ls
cat .ssh/known_hosts
ssh ubuntu2
ssh centos3
ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping
ansible all -i inventory.ini -m ping
ansible all -i "ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3," -m ping
ssh centos3
ssh centos2
ls -a
