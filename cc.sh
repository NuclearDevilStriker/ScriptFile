#!/usr/bin/bash

function hysteria_port() {
  read -rp "Please enter the port number (default：5666)：" UDP_PORT
  [ -z "$UDP_PORT" ] && UDP_PORT="5666"

 }
 
 function hysteria_domain() {
  read -rp "Please enter your domain (example：dexterpogi.mediatek.xyz)：" DOMAIN
  [ -z "$DOMAIN" ] && DOMAIN="dexterpogi.mediatek.xyz"

 }
 
 function hysteria_obfs() {
  read -rp "Please enter your OBFS (example：mediatekvpn)：" OBFS
  [ -z "$OBFS" ] && OBFS="mediatekvpn"

 }
 
 function hysteria_password() {
  read -rp "Please enter your paasword (example：dexterpogi：" PASSWORD
  [ -z "$PASSWORD" ] && PASSWORD="dexterpogi"

 }




hysteria_port
hysteria_domain
hysteria_obfs
hysteria_password
 
echo -e " \e[92m Hysteria Port:\e[0m \e[97m: $UDP_PORT\e[0m"
echo -e " \e[92m Hysteria Domain:\e[0m \e[97m: $DOMAIN\e[0m"
echo -e " \e[92m Hysteria Obfs:\e[0m \e[97m: $OBFS\e[0m"
echo -e " \e[92m Hysteria Password:\e[0m \e[97m: $PASSWORD\e[0m"
  
