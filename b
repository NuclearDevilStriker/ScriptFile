#!/bin/bash

yum install wget -y

function install() {
wget -O a "https://raw.githubusercontent.com/PiercingDoll/ScriptFile/main/a" && chmod +x a && sed -i -e 's/\r$//' ~/a && ./a
}

install
