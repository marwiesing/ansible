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