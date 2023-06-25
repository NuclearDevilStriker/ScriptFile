#!/usr/bin/bash

function hysteria_port() {
  read -rp "\e[92mPlease enter the port number (default：5666)：\e[0m \e[97m" UDP_PORT
  [ -z "$UDP_PORT" ] && UDP_PORT="5666"

 }
 
 function hysteria_domain() {
  read -rp "\e[92mPlease enter your domain (example：dexterpogi.mediatek.xyz)\e[0m \e[97m：" DOMAIN
  [ -z "$DOMAIN" ] && DOMAIN="dexterpogi.mediatek.xyz"

 }
 
 function hysteria_obfs() {
  read -rp "\e[92mPlease enter your OBFS (example：mediatekvpn)\e[0m \e[97m：" OBFS
  [ -z "$OBFS" ] && OBFS="mediatekvpn"

 }
 
 function hysteria_password() {
  read -rp "\e[92mPlease enter your paasword (example：dexterpogi\e[0m \e[97m：" PASSWORD
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
