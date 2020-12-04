#!/bin/bash

source run-as-root.sh
if [ "$(whoami)" != "root" ]
then
        echo "This script must be run as root."
        exit
fi


echo ""
echo "+-------------------------------+"
echo "| iptables Configuration Script |"
echo "+-------------------------------+"
echo ""
echo "This script will setup a simple stateful firewall configuration."
echo ""



sshPort=$(cat /etc/ssh/sshd_config | grep Port | sed 's/[^0-9]*//g')

if [ "$sshPort" == "" ]
then
        sshPort="22"
fi

echo "Using port $sshPort for ssh"


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


#alle eingehenden packete aktzeptieren, die zu einer verbindung gehören, die schon aufgebaut ist.
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT


#The next rule will accept all new incoming ICMP echo requests, also known as pings.
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT


#Now we attach the TCP and UDP chains to the INPUT chain to handle all new incoming connections.
#Once a connection is accepted by either TCP or UDP chain, it is handled by the RELATED/ESTABLISHED traffic rule.

iptables -N TCP
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP

iptables -N UDP
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP



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


#alle eingehenden packete aktzeptieren, die zu einer verbindung gehören, die schon aufgebaut ist.

ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT


#The next rule will accept all new incoming ICMP echo requests, also known as pings.

ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 128 -m conntrack --ctstate NEW -j ACCEPT


#Now we attach the TCP and UDP chains to the INPUT chain to handle all new incoming connections.
#Once a connection is accepted by either TCP or UDP chain, it is handled by the RELATED/ESTABLISHED traffic rule.

ip6tables -N TCP
ip6tables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP

ip6tables -N UDP
ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP


#We reject TCP connections with TCP RESET packets and UDP streams with ICMP port unreachable messages if the ports are not opened.
#This imitates default Linux behavior (RFC compliant), and it allows the sender to quickly close the connection and clean up.

ip6tables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
ip6tables -A INPUT -p udp -j REJECT --reject-with icmp6-adm-prohibited


#For other protocols, we add a final rule to the chain to reject all remaining incoming traffic with icmp protocol unreachable messages.
#This imitates Linux's default behavior.

ip6tables -A INPUT -j REJECT --reject-with icmp6-adm-prohibited

#---



echo "Setting up SSH configuration..."



iptables -N SSH
iptables -A TCP -p tcp --dport $sshPort -j SSH
iptables -A SSH -j ACCEPT


ip6tables -N SSH
ip6tables -A TCP -p tcp --dport $sshPort -j SSH
ip6tables -A SSH -j ACCEPT





echo "Setting default policies..."


iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT


ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT



echo "Setup complete."



echo ""
echo "Keep in Mind, that you must save the configuration to make it persistent."
