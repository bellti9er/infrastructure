#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update system
sudo apt-get update -y

# Create docker group
sudo addgroup docker

cat > users.txt <<EOF
bellti9er
EOF

# Create users and give them proper permissions
while IFS= read -r username
do
  sudo useradd -m -g docker -s /bin/bash -G sudo -p $(openssl passwd -1 password) $username
  cd /home/$username/
  sudo mkdir -p .ssh
  sudo chmod 700 .ssh
  sudo touch .ssh/authorized_keys
  sudo chmod 600 .ssh/authorized_keys
  sudo wget -O .ssh/authorized_keys https://github.com/$username.keys
  sudo chown -R $username:docker .ssh
  echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
done < users.txt

## Install Docker
sudo apt-get update -y
sudo apt-get install docker.io -y

## Install Java
sudo apt-get install openjdk-11-jre -y

## Update the ca-certificates
sudo apt-get install ca-certificates -y
sudo update-ca-certificates

## Install Jenkins
curl -fsSL http://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] http://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

## After Jenkins is installed, the user jenkins is created
## which needs to be added to the docker group
sudo usermod -a -G docker jenkins

## Start Jenkins
sudo systemctl start jenkins
sudo systemctl restart jenkins

## Remove the default ubuntu user for strengthen server security
rm users.txt
sudo deluser --remove-home ubuntu
