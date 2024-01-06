## IPV4 & IPV6: `ip link, ip route, ip addr, ip -c addr`
    
```bash
    CIDR notation: Classless inter-domain routing
    /24: prefix
    192.168.1: network prefix
    .101: device on the network
    
    +39: Italy country prefix
    192.168.1.0-255
    198.168.2.0-255
    192.168./16 0.0-255.255
    
    IPV6:128 bits
    IPV4: 32 bits
    
    IPV6
    not decimal format, in hexadecimal format
    0-9, A-F
    number separted by :
    network prefix: /64 first 8 groups
    
    ip link
    # lo: virtual loop
    # enpo3: interface
    ip address = ip a = ip addr
    ip -c address # -c needs to be infront
    
    sudo ip link set dev enp08 up # name of interface
    # add address
    # add ipv6
    sudo ip address delete 192.168.5.55/24 dev eth0
    sudo ip address add 192.168.5.55/24 dev eth0
    # only temporary, once reboot, will all disappear
    
    # assign ip to current devices
    # amazon linux network config path
    sudo ls /etc/sysconfig/network-scripts/
    
    dhcp: auto config/assign IP to devices
    
    ls /etc/netplan
    # netplan get
    vi 00-installer-config.yaml
    sudo netplan try/apply
    ip -c addr
    # new ips added when server rebooted, and it's consistent
    
    ip route
    resolvectl status
    
    # hostname & ip
    sudo vi /etc/host # add ip with hostname
    ping hostname
    
    man netplan 
    # search with: /default
    
    hostname -I | awk '{print $1; exit}' # get IP from hostname
    
    echo $USER
    
    ip route show default | awk '{print $3; exit}' # get default gateway from ip route
```
    
    
## Checking Network services: `ss, netstat, lsof`
    
  ```bash
    
    # chronyd: a daemon for maintaining the accuracy of the system clock on Unix-like operating systems.sshd

    chronyc sources
    sudo systemctl disable/enable chronyd.service # disable from root

    # lsof: list open files
    sudo lsof -p 2564
    
    # normally use 2 utilities
    ss: mondern
    netstat # old

    # listening, tcp, udp, neumeric value, processes connections
    ss -help
    sudo ss -tunlp # easy to remember
    
    # Identify the PID of the process listening on port 22.
    ss -natp |grep 22
    
```
    
## Bridge & bonding: `netplan try/apply`

```bash
    # 6 bonding modes
    # default: mode 0 round-robin
    mode 1: active-backup
    mode 2: XOR
    mode 3: Broadcast # all sent to interfaces at once
    mode 4
    mode 5: lB 
    mode 6: adaptive LB
    
    bridge: 2 or more network interfaces
    bond: 2 or more network in one network
    
    sudo cp /urs/share/doc/examples/bridge/bond.yaml /etc/netplan/bridge/bond.yaml
    sudo vi /etc/netplan/bridge/bond.yaml
    sudo netplan try
    ip -c link
    ip -c addr
    ip route
    sudo rm /etc/netplan/bridge/bond.yaml
    sudo ip link delete br0 # delete bridge
    
    sudo ip link set dev bond0 down
    
    # add an IP address to the network interface bond0 on a Linux system
    sudo ip addr add dev bond0 10.0.0.15/16 
```
    
## Firewalls and Packet filtering: `ufw`
    
```bash
    # attack  network packet  machine
    # set a network packet filter firewall
    
    types:
    application firewall
    
    # Amazon Linux does not come with the Uncomplicated Firewall (UFW) tool installed by default. 
    # UFW is more commonly associated with Debian-based distributions, such as Ubuntu, where it's used as a simplified interface for managing iptables rules.
    # On Amazon Linux, you would typically use **iptables** directly or other tools like **firewalld**, which is a dynamic firewall manager available in Red Hat-based distributions.
    
    sudo ufw status
    sudo ufw allow 22
    sudo ufw enable
    sudo ufw allow from 10.11.12.0/24 to any port 22
    sudo ufw status numbered
    
    # rule goes line by line, from 1,2,3,4, then 2nd rule not applied
    # in this case, need to put deny rule first
    sudo ufw allow from 10.11.12.0/24 # rule 1
    sudo ufw deny from 10.11.12.100. # rule 2
    
    # fix it
    sudo ufw delete 2
    ufw --help # assign a rule number
    sudo ufw insert 1 deny from 10.11.12.100
    # verify rules
    sudo ufw status numbered
    
    # a server can have multiple network cards
    # apply rules, need to find interfaces
    ip link
    etc, enp0s3
    ping -c 4 8.8.8.8 # ping 4 times
    sudo ufw deny out on enp0s3 to 8.8.8.8
    ping -c 4 8.8.8.8 # get blocked
    sudo ufw status numbered # check rules
    
    # get an ip to machine
    ip add
    
    # add allow rules
    sudo ufw allow in on enp0s3 from 192.168.1.60 (sender ip) to 192.168.1.81 port 80 proto tcp
    
    # add out rules
    sudo ufw allow out on enp0s3 192.168.1.81 to 192.168.1.60 port 80 proto tcp
    
    # verify rules
    sudo ufw status numbered
    
    # List all firewall rules
    # append the file not overwritten
    sudo firewall-cmd --list-all >> /opt/rules.txt
```

## Port redirection & NAT: `iptable`
    
```bash
    # enable IP forwarding
    sysctl.conf
    /etc/sysctl.d/99-sysctl.conf
    
    # internet-> public network translation-> internal network
    
    # output
    net.ipv4.ip_forward=1
    net.ipv6.conf.all.forwarding=1
    # save
    # validate
    sudo sysctl --system
    sudo systctl -a | grep forward
    
    # every data/network handled by kernel
    # netfilter framework: nft and iptables(modern distributions)
    # auto translated to nft mode
    
    # iptables use tables and chains
    
    sudo nft list ruleset # very complex
    ubuntu already convert nft rules to iptables
    
    sudo apt install iptables-persistent
    sudo ufw allow 22 
    sudo ufw enable
    sudo ufw route allow from 10.0.0.0/24 to 192.168.0.5
    
    -i enp1s0 # input
    -o enp1s0 # output
    
    man ufw-framework
    sudo iptables -t nat
    
    sudo iptables --list-rules --table nat
    sudo iptables --flush --table nat
    
```
   
## Reverse Proxies: `nginx`
    
```bash
    # in front of web server
    user-> proxy -> web server -> proxy -> user
    
    # why
    # web server: more CPU, memory
    # DNS propagation
    
    Pros:
    # filtering web traffic: no server is overload
    # caching pages
    # direct traffic
    
    # LB: reverse proxy
    
    # Create a reverse proxy
    Nginx # still function as a webserver
    apache, etc
    
    sudo apt install nginx
    sudo vi /etc/nginx/sites-available/proxy.conf
    
    /etc/nginx/sites-enabled
    
    sudo nginx -t # check errors
    sudo systemctl reload nginx.service # apply new settings we simply reload nginx
    
    # Create a load balancer
    sudo rm /etc/nginx/sites-enabled/proxy.conf
    sudo vi /etc/nginx/sites-available/lb.conf
    
    upstream mywebservers{
      least__conn; # pick the server with least active connections from this list
      server 1.2.3.4:8081 wight=3 down; # assign weights to server who can handle more traffic
      server 5.6.7.8;    # inactive: down option; on specfic port 8081
      server 10.20.30.40 backup; #  only use when necessary         
    }
    
    server {
      listen 80;
      location /{
         proxy_pass https://mywebservers;
      }
    }
    
    # link file to sites-enabled directory
    sudo ln -s /etc/nginx/sites-available/lb/conf /etc/nginx/sites-enabled/lb.conf
    
    # test configuration
    sudo nginx -t
    
    # nginx settings should be reloaded with
    sudo systemctl reload nginx.service
```
    
## Packet filtering: `firewall-cmd`
    
```bash
    # internet and prog process
    # internet and program not processed
    
    # firewall: filter what packets are allowed
    FirewallD: every interface
    # zone
    # wireless: drop
    # wired: trusted network
    
    firewall-cmd --get-default-zone
    firewall-cmd --set-default-zone=public
    
    # List all firewall rules
    sudo firewall-cmd --list-all
    
    sudo firewall-cmd --add-service=http = sudo firewall-cmd --add-port=80/tcp # only one
    sudo firewall-cmd --remove-service=http
    
    # temporary rules
    sudo firewall-cmd --add-source=10.0.0.0/24 --zone=trusted
    success
    ubuntu@ip-172-31-6-11:~$ firewall-cmd --get-active-zones
    trusted
      sources: 10.0.0.0/24
    
    # command to make rules permanent = work after reboot
    sudo firewall-cmd --runtime-to-permanent
    sudo firewall-cmd --add-port=12345/tcp --permanent
    
    # add new firewall rules
    [root@node01 ~]# sudo firewall-cmd --add-port=80/tcp
    success
    [root@node01 ~]# sudo firewall-cmd --add-port=80/tcp --permanent
    success
    [root@node01 ~]# sudo firewall-cmd --reload
    success
    # verify
    [root@node01 ~]# sudo firewall-cmd --list-all
    public (active)
      target: default
      icmp-block-inversion: no
      interfaces: eth0 eth1
      sources: 
      services: cockpit dhcpv6-client ssh
      ports: 80/tcp
      protocols: 
      masquerade: no
      forward-ports: 
      source-ports: 
      icmp-blocks: 
      rich rules: 
    [root@node01 ~]#

```

## IP route: `ip route add/del, sudo ss -tunlp, hostnamectl, netstat`
  ```bash
    nmcli connection show. # network manager connection
    
    # temp route traffic 192.168.0.* network through the device that has the IP 172.28.128.100
    sudo ip route add 192.168.0.0/24 via 172.28.128.100
    
    # permanently route all traffic that must reach the 192.168.0.* network through the device that has the IP 172.28.128.100
    sudo nmcli connection modify enp0s3 +ipv4.routes "192.6.6.168 10.0.0.100"
    sudo nmcli device reapply eth1
    
    # delete
    sudo nmcli connection modify eth1 -ipv4.routes "192.168.0.0/24 172.28.128.100"
    sudo nmcli device reapply eth1 # tell the NetworkManager to apply the network settings we just changed:
    
    sudo nmcli device reapply enp0s3
    
    # verify ip route tem
    ip route show # check gateway
    
    sudo nmtui
    
    # Add new ip to network interface
    sudo ip a add 10.0.0.50/24 dev eth1 # a for address
    # Re-apply network settings with below given command if needed:
    sudo nmcli device reapply eth1
    
    # based on port number check process name
    sudo netstat -natp | grep :8080
    # ttyd: process name
    
    # netstat  - Print network connections, routing tables, interface statistics, masquerade
           # connections, and multicast memberships
    # Get the list of all incoming open ports on this system
    sudo netstat -tunlp | grep LISTEN
    
    # add new nameserver
    sudo vi /etc/resolv.conf
    # nameserver 8.8.8.8
    
    # check transient hostname
    hostnamectl 
    
    # update static hostname
    sudo hostnamectl set-hostname dev-host01

  ```  

## Sync time using time servers: `timedatectl`
  ```bash

     # timedatectl: querying and changing system clock settings.
     # NTP server: network time protocol

     # chrony is an implementation of the Network Time Protocol (NTP). 
     # It is a software package for synchronizing the system clock across a network.
     # After installation and configuration, chrony will work in the background to keep your system's clock synchronized with the selected time sources.

      # Start the chrony service
      sudo systemctl start chronyd

      # Enable chrony to start on boot
      sudo systemctl enable chronyd

      # check if system is configured to automatically synchronise its time through chrony, in the below given command output you should see NTP=yes
      sudo timedatectl show

      timedatectl # output timezone,ntp info
      timedatectl list-timezones
      timedatectl set-timezone America/New_York

      # sets the system to use local time for the RTC. 
      # This is an option specifying that you want to set the Real Time Clock to use local time instead of Coordinated Universal Time (UTC).

      # 1: set the RTC to use local time.
      # When the RTC is set to use local time, it means that the hardware clock (RTC) is configured to store the time in the local time zone of the system. 
      # 0: if the RTC is set to use UTC, it stores the time in Coordinated Universal Time.
      sudo timedatectl set-local-rtc 1

      # timesyncd.conf
      man timesyncd.conf

      # timesyncd.conf file
      sudo vi /etc/systemd/timesyncd.conf
      # add ntpdate 0.pool.ntp.org
      sudo service systemd-timesyncd start/status/enable # reload

      # manually sync time with NTP server
      # ntp.conf: ntp daemon conf file
      apt install ntp
      ntpdate -u ntp_server_ip
      service ntpd start

  ```