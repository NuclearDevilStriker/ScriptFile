#!/usr/bin/bash

function modify_port() {
  read -rp "Please enter the port number (default：5666)：" UDP_PORT
  [ -z "$UDP_PORT" ] && UDP_PORT="5666"
  if [[ $UDP_PORT -le 0 ]] || [[ $UDP_PORT -gt 65535 ]]; then
    print_error "Please enter a value between 0-65535"
    exit 1
  fi
 }

modify_port
 
echo -e " \e[92m Hysteria Port:\e[0m \e[97m: $UDP_PORT\e[0m"
