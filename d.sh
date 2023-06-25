#!/usr/bin/bash

function hysteria_port() {
  read -rp "Please enter the port number (default：5666)：" UDP_PORT
  [ -z "$UDP_PORT" ] && UDP_PORT="6666"

 }
 
 function hysteria_domain() {
  clear
  read -rp "Please enter your Host DNS：" DOMAIN
  [ -z "$DOMAIN" ] && DOMAIN="dexterpogi.mediatek.xyz"

 }
 
 function hysteria_obfs() {
  clear
  read -rp "Please enter your OBFS：" OBFS
  [ -z "$OBFS" ] && OBFS="mediatekvpn"

 }
 
 function hysteria_password() {
  clear
  read -rp "\e[92mPlease enter your password：" PASSWORD
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
