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

