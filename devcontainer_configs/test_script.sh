#!/bin/bash
sudo ssh-keygen -A 
curl https://github.com/neevparikh.keys -o /home/$USERNAME/.ssh/authorized_keys
#
# Set SSH port from environment variable
if [ ! -z "$SSH_PORT" ]; then
  sudo sed -i "/^#*Port /d;\$a Port $SSH_PORT" /etc/ssh/sshd_config
fi

echo "Starting SSH server on port ${SSH_PORT:-22}"
# Start SSH service in foreground
exec sudo /usr/sbin/sshd -D -o LogLevel=VERBOSE
