#!/bin/bash

version="2021.01.31"
scriptName=$(basename $BASH_SOURCE)


function fnc_help()
{
	echo "Description: Setting up ipv4 and ipv6 iptables."
	echo ""
	echo "Usage: $scriptName [Option]..."
	echo ""
	echo "Options:"
	echo " -h,--help		prints this help message"
	echo " -v,--version		prints script version"
	echo ""
	exit
}


function fnc_version()
{
	echo $version
	exit
}



#Title
echo "+-------------------------------+"
echo "| iptables Configuration Script |"
echo "+-------------------------------+"
echo "version $version"
echo "by Ugga the Caveman"
echo ""




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
		fnc_version
		exit
	else
		echo "error: invalid option $thisParam"
		echo ""
		fnc_help
		exit
	fi
done





if [ $option_help == true ]
then
	fnc_help
	exit
fi



if [ "$(whoami)" != "root" ]
then
        echo "error: This script must be run as root."
        exit
fi




#get port for ssh
sshPort=""

echo "Reading sshd configuration for ssh port..."
if [ -f /etc/ssh/sshd_config ]
then	
	sshPort=$(cat /etc/ssh/sshd_config | grep Port | sed 's/[^0-9]*//g')
	
	if [ "$sshPort" == "" ]
	then
		echo "/etc/ssh/sshd_config does not define ssh port."
		sshPort="22"
	fi

else
	echo "/etc/ssh/sshd_config does not exist."
fi

echo "ssh port: $sshPort"





echo ""
echo "The script is about to override iptables now."
read -p "Type yes if you want to continue: " answer

answer=$(echo "$answer" | awk '{print tolower($0)}')

if [ "$answer" != "yes" ]
then
        echo "Script canceled."
        exit
fi




echo ""
echo "Setting up IPv4 configuration..."



iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT


#loopback verbindungen auf dem loopbackdevice erlauben
iptables -A INPUT -i lo -j ACCEPT


#ICMPv6 Neighbor Discovery packets will always be classified "INVALID" though they are not corrupted or the like.
#Accept them before dropping traffic with an "INVALID" state match.
#iptables -A INPUT -p 41 -j ACCEPT


#DROP traffic with an "INVALID" state match.
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP


iptables -N CUSTOM
iptables -A INPUT -j CUSTOM


#alle eingehenden packete aktzeptieren, die zu einer verbindung gehören, die schon aufgebaut ist.
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT


#Now we attach the NEW chain to the INPUT chain to handle all new incoming connections.
#Once a connection is accepted by either TCP or UDP chain, it is handled by the RELATED/ESTABLISHED traffic rule.

iptables -N NEW
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j NEW
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j NEW


#We reject TCP connections with TCP RESET packets and UDP streams with ICMP port unreachable messages if the ports are not opened.
#This imitates default Linux behavior (RFC compliant), and it allows the sender to quickly close the connection and clean up.

iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable


#For other protocols, we add a final rule to the chain to reject all remaining incoming traffic with icmp protocol unreachable messages.
#This imitates Linux's default behavior.

iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable

#---


echo "Setting up IPv6 configuration..."


ip6tables -F
ip6tables -X
ip6tables -t nat -F
ip6tables -t nat -X
ip6tables -t mangle -F
ip6tables -t mangle -X
ip6tables -t raw -F
ip6tables -t raw -X
ip6tables -t security -F
ip6tables -t security -X


ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT


#loopback verbindungen auf dem loopbackdevice erlauben

ip6tables -A INPUT -i lo -j ACCEPT


#ICMPv6 Neighbor Discovery packets will always be classified "INVALID" though they are not corrupted or the like.
#Accept them before dropping traffic with an "INVALID" state match.

ip6tables -A INPUT -p 41 -j ACCEPT


#DROP traffic with an "INVALID" state match.

ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP


ip6tables -N CUSTOM
ip6tables -A INPUT -j CUSTOM


#alle eingehenden packete aktzeptieren, die zu einer verbindung gehören, die schon aufgebaut ist.

ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT



#Now we attach the NEW chains to the INPUT chain to handle all new incoming connections.
#Once a connection is accepted by either TCP or UDP chain, it is handled by the RELATED/ESTABLISHED traffic rule.

ip6tables -N NEW
ip6tables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j NEW
ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -j NEW


#We reject TCP connections with TCP RESET packets and UDP streams with ICMP port unreachable messages if the ports are not opened.
#This imitates default Linux behavior (RFC compliant), and it allows the sender to quickly close the connection and clean up.

ip6tables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
ip6tables -A INPUT -p udp -j REJECT --reject-with icmp6-adm-prohibited


#For other protocols, we add a final rule to the chain to reject all remaining incoming traffic with icmp protocol unreachable messages.
#This imitates Linux's default behavior.

ip6tables -A INPUT -j REJECT --reject-with icmp6-adm-prohibited




#The next rule will accept all new incoming ICMP echo requests, also known as pings.
iptables -A CUSTOM -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A CUSTOM -p ipv6-icmp --icmpv6-type 128 -m conntrack --ctstate NEW -j ACCEPT




echo "Creating SSH chain..."

iptables -N SSH
iptables -A NEW -p tcp --dport $sshPort -j SSH
iptables -A SSH -j ACCEPT


ip6tables -N SSH
ip6tables -A NEW -p tcp --dport $sshPort -j SSH
ip6tables -A SSH -j ACCEPT




echo "Setting default policies..."


iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT


ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT



echo "iptables setup completed."

