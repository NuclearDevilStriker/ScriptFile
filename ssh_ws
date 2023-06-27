#!/bin/bash
ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config &> /dev/null
#change this according to your database details
RED='\033[01;31m';
RESET='\033[0m';
GREEN='\033[01;32m';
WHITE='\033[01;37m';
YELLOW='\033[00;33m';
fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "  \033[1;33mSSH\033[1;37m- \033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "  \033[1;33mSSH \033[1;37m- \033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m INSTALLED !\033[1;37m"
tput cnorm
}
fun_bar2 () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "  \033[1;33mPACTHING AUTH \033[1;37m- \033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "  \033[1;33mPACTHING AUTH \033[1;37m- \033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}


show_menu () {
echo -e "                $GREEN

██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║              

$RESET"
}
install(){
# Updating Repositories
yum update -y
# Installing Required Packages.
yum install epel-release -y
yum install wget -y
yum install mysql squid nano -y
yum install iptables iptables-services -y
yum install nc lsof screen -y
yum install NetworkManager -y
MYIP=$(wget -qO- ipv4.icanhazip.com);
# Installing Dropbear and Stunnel

yum -y install stunnel dropbear &> /dev/null
#sudo mkdir /var/run/stunnel &> /dev/null
#sudo chown nobody:nobody /var/run/stunnel &> /dev/null
cat << EOF > /etc/sysconfig/dropbear
OPTIONS=" -p 444 -p 441"
EOF

cat <<EOF >/etc/stunnel/stunnel.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAuyrnC0X1e5LsyPVtB0nOj/RPUXJ1jbv+8PcSrAdyvmwq/H3p
eIKEmZ756XMMPKZuS5+FaYV7Qw6lntj0mYwdwO2dzV84XZrFPC/rioSjka9rLsIH
wFK6Zb4rmRbmfEjcoZ22aejbbXlVzScUMRAN3NpvLPcsRH8OPzLR7j5P0CnnBQnS
EKRlwvEqNEqa6qir8DbMnfPh7Lo0V6g15R70ae/VR0MPA5+5Ce0slNt8SQdFmaD5
NL8n+bvkVtJfawfcugdZ5J45rcAc/zBdrtmvmnbVoPLnazDQVkd2u2zfBQtEwZmX
3juAL4Iqb9mh3YIAVqeXVR+pmbcDtHJiKBJxuwIDAQABAoIBAQC3+A6LTSNiaGMn
j9yv2kMXyfqgwtF7E/sdnK0UvGlzdFy4O4bddeSiHtnkNbokby5gVJbMxnAG1IHE
ZdnehxPDy4tdDygXEYamhy+Mwp0IGJVQq1T1HBus38R4wEKijPeYP63J4iC0NRw5
/xxgsTf/ChFW8Ejptr0pL2mbNFI89xRs6Ibgd4MTwLpLi/Pt5dG29iBVXWBBFYkN
wWVDObgR1HevWCOdyQhYIpkfbiMrf5/Kq81pIVT6XR4iYsatLdk2ZGmXoKhskFeh
blMc5DEEQcncQEGlq/mBcDi3o/i7CvXjM/qMuW/mhK16InDYJ3PuMykFmu493d6N
lMmbDdjxAoGBAODa9cDRdXa6jzdwPSWiBpRrxLFXHXLmFHzqzCxZKf5TO5cqUceX
0+AzRS2RG6q4B4yum3wuDyXNNCZCc/TlGIntJCuNwP9rDxZ/pvs6TewXmj4rns4w
59tVhAv4rM+aCxpwZWEFExgqK1sEZKy7EGaqc3jDnA5dzKr5ZTKMDScTAoGBANUX
l04dPzSdQ+x6SsvsfpjAkArVeTLeO0P68qt1D+eQq9XZYiXR//Bog5y4D7g4k2w9
j68CO8wYc+LJUG9ZEa+cVE3TdJPFvA+KSWtQC+rGCGXSUncxFRwyrNwA4fU3dSzZ
GmAm/6tUmbDDpYZzCJF7wUFDZzlTJckf4plFB5e5AoGAEjRoFTZgJj6wfbKOoM9f
bQDUqe79qWHLYtm3shd9+ONQPcrlWB2Iv+wmu6u167p+kftJB2LLQyo8AKT8smUh
+XjDpusRJxzJ2e533Hs599VpXYM2lkcLXoyr5jQ5+YzlPTzAWHyKsTgoznOqmvmC
OG2wb6SWq+sYOPd8I/2GyxUCgYBIh94dXYEdBIaRIFMDND0m+yxMM7ssIE5l5i3h
RFgkhq6mfHaWzvLhvoFFv7TCDKfJSO72L7lwz8XqJIG3VMbbUkezsczVW5GWbIhu
+XEE+WD0X3FoVpGL5ofF3psKn1TH7iG3Jq8RfxtM+lsF93OsKUZvU2T4MyACZFL5
vnBGKQKBgQDZtaNicrnrlu9iP5Eaj0Py2+2MUiP6miB2tARU9yAVQbp3zptjysZG
90eT3stwpNoFz8pidC+TsLvc6+Co941piRoT8zH8ezqxcHvjy2ITTrGOq4tJBPr6
euRNREMSAo3j/2P2kOWK2uHbqkEI2x8epWs/gqAFbuM5Gkk3XfM74g==
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIID8TCCAtmgAwIBAgIJAJtwwttWENtAMA0GCSqGSIb3DQEBCwUAMIGOMQswCQYD
VQQGEwJQaDERMA8GA1UECAwIQmF0YW5nYXMxETAPBgNVBAcMCEJhdGFuZ2FzMQ8w
DQYDVQQKDAZDb2RlUGgxFDASBgNVBAsMC0NvZGVQaCBUZWFtMREwDwYDVQQDDAhK
aG9lIFhpaTEfMB0GCSqGSIb3DQEJARYQY29kZXBoQGdtYWlsLmNvbTAeFw0yMDAz
MTkwOTU3MThaFw0yMzAzMTkwOTU3MThaMIGOMQswCQYDVQQGEwJQaDERMA8GA1UE
CAwIQmF0YW5nYXMxETAPBgNVBAcMCEJhdGFuZ2FzMQ8wDQYDVQQKDAZDb2RlUGgx
FDASBgNVBAsMC0NvZGVQaCBUZWFtMREwDwYDVQQDDAhKaG9lIFhpaTEfMB0GCSqG
SIb3DQEJARYQY29kZXBoQGdtYWlsLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEP
ADCCAQoCggEBALsq5wtF9XuS7Mj1bQdJzo/0T1FydY27/vD3EqwHcr5sKvx96XiC
hJme+elzDDymbkufhWmFe0MOpZ7Y9JmMHcDtnc1fOF2axTwv64qEo5Gvay7CB8BS
umW+K5kW5nxI3KGdtmno2215Vc0nFDEQDdzabyz3LER/Dj8y0e4+T9Ap5wUJ0hCk
ZcLxKjRKmuqoq/A2zJ3z4ey6NFeoNeUe9Gnv1UdDDwOfuQntLJTbfEkHRZmg+TS/
J/m75FbSX2sH3LoHWeSeOa3AHP8wXa7Zr5p21aDy52sw0FZHdrts3wULRMGZl947
gC+CKm/Zod2CAFanl1UfqZm3A7RyYigScbsCAwEAAaNQME4wHQYDVR0OBBYEFHWI
km1tRz5tBz9nZYRK0cR/qm8dMB8GA1UdIwQYMBaAFHWIkm1tRz5tBz9nZYRK0cR/
qm8dMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAIgxWkM0Y/HF5Cjy
JoLyGkuXwvMKQeBgZ8Pp8eD/5dcRmAETxRwDUROy138IHFXaF8a+UB0cOAzBIiGw
NQt50aU2gx+gasQGuEFqyF8SeBOEKqkjCLMve9heum8fHix2KcD8FDWqXfeuaiFW
uIF6F/1g5+4ZGRWvDD2d3ivh0kRfvCMkWXYp969yBAgVDApuF9PaMPcJiCcWz5a5
hQE5NF7hMpYUagqnr5bryqpcps4j9KkQ+RdM9ZwW9WIDKg3gEBgbKUEAvVjv1bY2
lQ15l8h2WoFxzpP7BTzIic1gLhxh6/YsM2RU6WUPmhUPzUP3xUpx7f+LEdFpuoAs
PYeNUPo=
-----END CERTIFICATE-----
EOF


cat <<EOF >/etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[stunnel]
connect = 127.0.0.1:444
accept = 443
[dropbear]
connect = 127.0.0.1:441
accept = 445
EOF

cat << XYZZY > /etc/systemd/system/stunnel.service
[Unit]
Description=SSL tunnel for network daemons
After=syslog.target

[Service]
ExecStart=/usr/bin/stunnel
Type=forking

[Install]
WantedBy=multi-user.target
XYZZY

chmod 600 /etc/stunnel/stunnel.pem

echo "/sbin/nologin" >> /etc/shells
# Configuring httpd
sed -i "s/#ServerName www.example.com:80/ServerName localhost:80/g" /etc/httpd/conf/httpd.conf
printf "\nAllowUsers root" >> /etc/ssh/sshd_config

#configuring http socks proxy

wget --no-check-certificate -O /etc/ssl/socks.py https://raw.githubusercontent.com/mediatekvpn/EskalarteDexter/main/444.py -q
wget --no-check-certificate -O /etc/ssl/socks2.py https://raw.githubusercontent.com/mediatekvpn/EskalarteDexter/main/441.py -q
/bin/cat <<"EOM" >/root/vpn
nc -zv 127.0.0.1 8001 && sudo kill $( sudo lsof -i:8001 -t )
nc -zv 127.0.0.1 445 && sudo kill $( sudo lsof -i:445 -t )
nc -zv 127.0.0.1 441 && sudo kill $( sudo lsof -i:441 -t )
nc -zv 127.0.0.1 80 && sudo kill $( sudo lsof -i:80 -t )
nc -zv 127.0.0.1 444 && sudo kill $( sudo lsof -i:444 -t )
nc -zv 127.0.0.1 443 && sudo kill $( sudo lsof -i:443 -t )
screen -dmS proxy python /etc/ssl/socks.py
screen -dmS proxy python /etc/ssl/socks2.py
sudo sync; echo 3 > /proc/sys/vm/drop_caches
swapoff -a && swapon -a
echo "Ram Cleaned!"
service crond restart
service dropbear restart
service stunnel restart
clear
netstat -tpln
EOM
chmod +x /root/vpn
chmod +x /etc/ssl/socks.py
chmod +x /etc/ssl/socks2.py
#service_start
service sshd restart
systemctl enable NetworkManager
systemctl start NetworkManager
service network start
systemctl enable dropbear.service &> /dev/null
service dropbear start
systemctl enable stunnel &> /dev/null
systemctl start stunnel
service crond restart
mkdir -p /usr/sbin/jho
yum install php php-mysqli php-mysql php-gd php-mbstring -y
wget -O /usr/local/sbin/ssh.php https://raw.githubusercontent.com/mediatekvpn/EskalarteDexter/main/auth_prem.sh -q
/bin/cat <<"EOM" >/usr/sbin/jho/xii.sh
php /usr/local/sbin/ssh.php
chmod +x /root/active.sh
chmod +x /root/inactive.sh
bash /root/inactive.sh
bash /root/active.sh
EOM
cat << EOF > /var/spool/cron/root	
*/15 * * * * /bin/bash /usr/sbin/jho/xii.sh >/dev/null 2>&1
EOF
bash vpn
}



install_done()
{
  echo -e "$GREEN   WEBSOCKET SSH SERVER $RESET"
   echo -e "$GREEN   IP ADDRESS : $(curl -s https://api.ipify.org)$RESET"
   echo -e "$RED   DROPBEAR port : 444 $RESET"
   echo -e "$RED   SSL port : 443 $RESET"
   echo -e "$RED   SSH WEBSOCKET port : 80 $RESET"
   echo -e "$YELLOW   DROPBEAR port : 441 $RESET"
   echo -e "$YELLOW   SSL port : 445 $RESET"
   echo -e "$YELLOW   WEBSOCKET port : 8001 $RESET"
   echo 
  echo
rm -rf *sh &> /dev/null
chmod +x .bash_history
cat /dev/null > ~/.bash_history && history -c && history -w
~/.bash_history && history -c && history -w
  
}

clear
show_menu
fun_bar 'install'
install_done
