#!/bin/bash


source run-as-root.sh
if [ "$(whoami)" != "root" ]
then
	echo "This script must be run as root."
	exit
fi



echo ""
echo "+-------------------------+"
echo "| SSH Server Setup Script |"
echo "+-------------------------+"


echo ""
echo "Enter the port that should be used for new ssh connections."
read -p "shh Port: " sshPort

sshPort=$(echo "$sshPort" | sed 's/[^0-9]*//g')

if [ "$sshPort" == "" ]
then
	portLine="#Port 22"
else
	portLine="Port $sshPort"
fi



echo ""
echo "The script is now ready to setup the ssh configuration."

read -p "Type yes if you want to continue: " answer

answer=$(echo "$answer" | awk '{print tolower($0)}')

if [ "$answer" != "yes" ]
then
	echo "Script canceled."
	exit
fi


echo ""

groupName="ssh-grp"

groupExist=$(cat /etc/group | grep "$groupName:")
if [ "$groupExist" == "" ]
then
	groupadd -r $groupName
	echo "New group called $groupName created"
else
	echo "A group called $groupName does allready exist."
fi


echo "The entered user will be added to $groupName."
read -p "Enter username: " benutzername

if [ "$benutzername" != "" ]
then
	echo "This is not a valid username."
	exit
fi

usermod -a -G $groupName $benutzername





echo "#ssh config" > /etc/ssh/ssh_config
echo "" >> /etc/ssh/ssh_config

echo "Host *" >> /etc/ssh/ssh_config
echo "	KexAlgorithms curve25519-sha256@libssh.org" >> /etc/ssh/ssh_config
echo "	PasswordAuthentication no" >> /etc/ssh/ssh_config
echo "	ChallengeResponseAuthentication no" >> /etc/ssh/ssh_config
echo "	PubkeyAuthentication yes" >> /etc/ssh/ssh_config
echo "	HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa" >> /etc/ssh/ssh_config
echo "	Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/ssh_config
echo "	MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/ssh_config
echo "	UseRoaming no" >> /etc/ssh/ssh_config
echo "" >> /etc/ssh/ssh_config




echo "#sshd config" > /etc/ssh/sshd_config
echo "" >> /etc/ssh/sshd_config

echo $portLine >> /etc/ssh/sshd_config
echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config

echo "" >> /etc/ssh/sshd_config

echo "AllowGroups $groupName" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

echo "" >> /etc/ssh/sshd_config

echo "# Client authentication" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "UsePAM no" >> /etc/ssh/sshd_config
echo "printMotd yes # Print /etc/motd file" >> /etc/ssh/sshd_config

echo "" >> /etc/ssh/sshd_config

echo "# Server authentication" >> /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config
echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile      .ssh/authorized_keys #The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2" >> /etc/ssh/sshd_config

echo "" >> /etc/ssh/sshd_config

echo "# Key exchange" >> /etc/ssh/sshd_config
echo "KexAlgorithms curve25519-sha256@libssh.org" >> /etc/ssh/sshd_config
echo "# Github needs diffie-hellman-group-exchange-sha1 some of the time but not always." > /etc/ssh/ssh_config
echo "#Host github.com" >> /etc/ssh/ssh_config
echo "#    KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1" >> /etc/ssh/ssh_config

echo "" >> /etc/ssh/sshd_config

echo "# Symmetric ciphers" >> /etc/ssh/sshd_config
echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config

echo "" >> /etc/ssh/sshd_config

echo "# Message authentication codes" >> /etc/ssh/sshd_config
echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/sshd_config





echo ""
echo "Do you want to delete all host_keys from /etc/ssh and create new ones?"
read -p "Make new host_keys? [y/N] " answer

if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then
	cd /etc/ssh
	rm ssh_host_*key*

	echo ""
	ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N "" < /dev/null

	echo ""
	ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key -N "" < /dev/null
fi




echo ""
read -p "Enable sshd.service? [y/N] " answer

if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then
	systemctl enable sshd
fi


echo ""
echo "Restarting sshd.service"
systemctl restart sshd

echo ""
echo "Setup complete"
