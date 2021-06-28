#!/bin/bash

version="2021.06.28"
scriptName=$(basename $BASH_SOURCE)

function fnc_version()
{
	echo $version
	exit
}

function fnc_help()
{
	echo "Description: A Setup-wizard for ssh."
	echo "Usage: $scriptName [Option]..."
	echo ""
	echo " -h,--help		prints this help message"
	echo " -v,--version		prints script version"
	echo ""
	exit
}

#get parameters
option_version=false
option_help=false

paramArray=( "$@" )
paramCount=${#paramArray[@]}

for (( index=0; $index<$paramCount; index++ ))
do
	thisParam="${paramArray[$index]}"
	
	if [ "$thisParam" == "-h" ] || [ "$thisParam" == "--help" ]
	then
		option_help=true
	elif [ "$thisParam" == "-v" ] || [ "$thisParam" == "--version" ]
	then
		option_version=true
	else
		echo "error: invalid option $thisParam"
		echo ""
		fnc_help
		exit
	fi
done

if [ $option_version == true ]
then
	fnc_version
	exit
fi


echo "$scriptName version $version"
echo "by Ugga the Caveman"
echo ""


if [ $option_help == true ]
then
	fnc_help
	exit
fi



if [ "$(whoami)" != "root" ]
then
	echo "This script can only be run as root."
	exit
fi



if [ ! -d "/etc/ssh" ]
then
	echo "Error: /etc/ssh does not exist."
	exit
fi


if [ -e "/root/ssh-backup" ]
then
	echo "Error: backup-directory allready exist."
	echo "       Delete /root/ssh-backup and try again."
	exit
fi




echo ""
echo "Enter the port for new ssh connections."
read -p "Port: " sshPort

sshPort=$(echo "$sshPort" | sed 's/[^0-9]*//g')

if [ "$sshPort" == "" ]
then
	portLine="#Port 22"
else
	portLine="Port $sshPort"
fi



enableService=false

echo ""
echo "Do you want to enable the sshd.service after the setup is complete?"
read -p "Change service state? [y/N] " answer

if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then
	enableService=true
fi



groupName="ssh-grp"



echo ""
echo "The script is about to move the content of /etc/ssh into /root/ssh-backup."
echo "After that it will create new configuration and key files."

read -p "Type yes and press enter, if you want to continue: " answer

answer=$(echo "$answer" | awk '{print tolower($0)}')

if [ "$answer" != "yes" ]
then
	echo "Script canceled."
	exit
fi


cp -r /etc/ssh /root/ssh-backup

rm -r /etc/ssh/*


cd /etc/ssh


echo "#ssh_config" > /etc/ssh/ssh_config
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


echo ""
echo "New ssh_config created."



echo "#sshd_config" > /etc/ssh/sshd_config
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
echo "New sshd_config created."



ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N "" < /dev/null >> /dev/null

ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key -N "" < /dev/null >> /dev/null

echo ""
echo "New host_keys created."




groupExist=$(cat /etc/group | grep "$groupName:")

echo ""

if [ "$groupExist" == "" ]
then
	groupadd -r $groupName
	echo "New group called $groupName created"
else
	echo "A group called $groupName does allready exist."
	echo "Warning: Make sure that all members of that group are allowed to connect over ssh."
fi



echo ""
if [ $enableService ]
then
	systemctl enable sshd
else
	systemctl status sshd
fi



echo ""
echo "+------------------+"
echo "| IMPORTANT NOTICE |"
echo "+------------------+"
echo ""
echo "Only member of $groupName can connect over ssh."
echo "You cannot use root, so make sure that at least one ssh-user has sudo privileges."
echo "example:"
echo "#gpasswd -a <username> $groupName"
echo ""
echo "Do not close your current connection!"
echo "Make sure you can connect, before restarting sshd.service!"




