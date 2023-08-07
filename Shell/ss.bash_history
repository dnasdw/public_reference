#passwd
#cp /etc/apt/sources.list /etc/apt/sources.list.bak
#sudo tee /etc/apt/sources.list << EOF
#deb https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
#deb-src https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
#
#deb https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
#deb-src https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
#
#deb https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
#deb-src https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
#
## deb https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
## deb-src https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
#
#deb https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
#deb-src https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
#EOF
wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh

sudo apt update && sudo apt upgrade -y && sudo apt autoremove
cat > /etc/apt/apt.conf.d/99force-ipv4 << EOF
Acquire::ForceIPv4 "true";
Acquire::Retries "100";
Acquire::http::Timeout "60";
EOF
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:fsgmhoward/shadowsocks-libev
sudo apt update
sudo apt install -y shadowsocks-libev simple-obfs haveged
RANDPASS=$(python3 -c "import random; import string; print(''.join([ random.choice(string.ascii_lowercase + string.ascii_uppercase) for i in range(8) ]))")
sudo tee /etc/shadowsocks-libev/config.json << EOF
{
    "server": ["::0", "0.0.0.0"],
    "server_port": 80,
    "local_port": 1080,
    "password": "$RANDPASS",
    "timeout": 60,
    "method": "chacha20-ietf-poly1305",
    "fast_open": true,
    "plugin": "obfs-server",
    "plugin_opts": "obfs=http;failover=127.0.0.1:8080;fast-open"
}
EOF
sudo systemctl enable shadowsocks-libev-server@config
sudo systemctl start shadowsocks-libev-server@config
sudo systemctl status -l shadowsocks-libev-server@config
sudo systemctl stop shadowsocks-libev-server@config
sudo apt-get install -y nginx
sudo sed -i 's/listen 80 default_server;/listen 127.0.0.1:8080 default_server;/g' /etc/nginx/sites-enabled/default
sudo sed -i 's/listen \[::\]:80 default_server;//g'  /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
sudo ss -anp | grep nginx
sudo systemctl start shadowsocks-libev-server@config
#dd if=/dev/urandom of=/var/www/html/100M.bin bs=1M count=100
sudo add-apt-repository ppa:damentz/liquorix && sudo apt-get update
sudo apt-get install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64
#sudo apt-mark hold linux-image-liquorix-amd64 linux-headers-liquorix-amd64
sudo tee -a /etc/sysctl.conf << EOF
# 优化网络，使用BBR，开启TCP fast open，开启ECN、cake


# max open files
fs.file-max = 1024000
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096
# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1


net.ipv4.tcp_allowed_congestion_control = cubic reno bbr


net.ipv4.tcp_congestion_control = bbr


# https://www.bufferbloat.net/projects/codel/wiki/CakeFAQ/
net.core.default_qdisc = cake


# ECN: 1 Enable ECN when requested by incoming connections and also request ECN on outgoing connection attempts.
net.ipv4.tcp_ecn = 1


# Enables Forward RTO-Recovery (F-RTO) defined in RFC5682. F-RTO is an enhanced recovery algorithm for TCP retransmission timeouts.
# It is particularly beneficial in networks where the RTT fluctuates (e.g., wireless).
# F-RTO is sender-side only modification. It does not require any support from the peer.
net.ipv4.tcp_frto = 2


# The values (bitmap) are
# 0x1: (client) enables sending data in the opening SYN on the client.
# 0x2: (server) enables the server support, i.e.,
# allowing data in a SYN packet to be accepted and passed to the application before 3-way handshake finishes.
net.ipv4.tcp_fastopen = 3


# Initial time period in second to disable Fastopen on active TCP sockets when a TFO firewall blackhole issue happens.
net.ipv4.tcp_fastopen_blackhole_timeout_sec = 0


# How many keepalive probes TCP sends out, until it decides that the connection is broken. Default: 9
net.ipv4.tcp_keepalive_probes = 3
EOF
sudo reboot
sysctl net.ipv4.tcp_congestion_control | grep bbr
#sudo apt-get install -y unattended-upgrades
#sudo dpkg-reconfigure --priority=low unattended-upgrades
#sudo tee /usr/local/bin/upgrade_ss << EOF
##!/bin/sh
#
#apt update
#apt upgrade -y
#apt autoremove -y
#systemctl restart shadowsocks-libev-server@config
#EOF
#sudo chmod +x /usr/local/bin/upgrade_ss
#sudo tee /etc/cron.daily/upgrade_ss << EOF
##!/bin/sh
#
#logger upgrading shadowsocks
#/usr/local/bin/upgrade_ss
#EOF
#sudo chmod +x /etc/cron.daily/upgrade_ss
sudo apt-get install -y sshguard
sudo tee /etc/rc.local << EOF
#!/bin/sh
PATH=$PATH:/usr/sbin
iptables -t nat -A PREROUTING -i eth0 -p tcp -m multiport --dports 8000:9000 -j REDIRECT --to-ports 80
EOF
sudo chmod +x /etc/rc.local
sudo tee /etc/systemd/system/rc-local.service << EOF
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local


[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99


[Install]
 WantedBy=multi-user.target
EOF
sudo systemctl enable rc-local
sudo reboot
