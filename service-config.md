## Caching DNS server
`BIND, dig, named.service`
- BIND： Berkeley internet name domain, widely used DNS software on internet.
    - Software package that implements DNS protocol, allow computers translate domains into IPs.
    - when bind server doesn't have dns data in own cache, need to query on other dns server by editing dns conf file: recursion yes.

1. Install the bind and bind-utils packages:
```sudo apt install bind9 dnsutils -y```

2. DNS server configure file

```bash
  man named.conf 
  /etc/named.conf

  # Verify the syntax of the /etc/named.conf file:
  # If the command displays no output, the syntax is correct.
  named-checkconf
```

3. Bind configuration file:

```bash
options {
        listen-on port 53 { 127.0.0.1; 192.168.0.0/24; };
		...
        allow-query        { localhost; 192.168.0.0/24; };
        allow-query-cache  { localhost; 192.168.0.0/24; };
		...
        recursion yes;
        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
		...
};

zone "test.com." IN {
        type master;
        file "/var/named/test.com.zone";
};

zone "0.168.192.in-addr.arpa" IN {
        type master;
        file "/var/named/rev.test.com.zone";
}
```

4. Enable System Services

```bash

# Update the firewalld rules to allow incoming DNS traffic:
firewall-cmd --permanent --add-service=dns
firewall-cmd --reload

# Start and enable BIND
sudo systemctl start named.service
sudo systemctl enable named.service

```
5. Verify and Query DNS server: `dig`

   - Retrieve infor about DS, IPs, DNS records
   - ANY option here which will retrieve all records, including MX, TXT etc.
Reference: <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/managing_networking_infrastructure_services/assembly_setting-up-and-configuring-a-bind-dns-server_networking-infrastructure-services#proc_configuring-bind-as-a-caching-dns-server_assembly_setting-up-and-configuring-a-bind-dns-server>.


```bash
# Use the newly set up DNS server to resolve a domain:
dig @localhost www.example.org
...
www.example.org.    86400    IN    A    198.51.100.34

;; Query time: 917 msec
...

# Repeat the previous query
dig @localhost www.example.org
...
www.example.org.    85332    IN    A    198.51.100.34

;; Query time: 1 msec
...

# update TTL value
sudo vi /var/named/example.com.zone
# In the beginning of the file change $TTL value from 1H to 2H
$TTL 2H
sudo systemctl restart named.service
# verify changes
dig @localhost -q example.com # TTL 7200s

```

## Maintain a DNS Zone
    
 ```bash
    sudo ls /var/named
    sudo cp --perserve=ownership /var/named/named.localhost /var/named/example.com.zone
    # store all zone files in /var/named
    
    # DNS server use named.conf file
    # /etc/named.conf: listen on 53, query, ip
    # query, zone option
    
    # /var/named/example.com.zone: zone record
    DNS server read zone file # edit /etc/named.conf, add zone

```
    
## Email: `imap, imaps, dovecot, postfix, mailx, aliases,`
```bash
sudo dnf install postfix mailx -y # store mails
sudo systemctl start postfix
sudo systemctl enable postfix
sendmail @@@localhost <<< "Hellos"

#v /var/spool/mail/contact
sudo vi /etc/aliases # add eamil aliases
# advertising: aaron
# contact: aaron,john,jane

# -s: subject
echo "This is the body of the email" | mailx -s "Subject" recipient@example.com

mailx -s "Subject" recipient@example.com < filename.txt

# check new email
mailx

sudo newaliases # inform email daemon email aliases changed

# IMAP & IMAPS
/etc/dovecot/conf.d/10-mail.conf
#   mail_location = maildir:~/Maildir
    mail_location = mbox:~/mail:INBOX=/var/mail/%u # user placeholder for user email
#   mail_location = mbox:/var/mail/%d/%1n/%n:INDEX=/var/indexes/%d/%1n/%n
#
# ~/mail: create mail folder in user directory

# secure 
/etc/dovecot/conf.d/10-ssl.conf 
# SSL/TLS support: yes, no, required. <doc/wiki/SSL.txt>
# enabled both imap and imaps
ssl = yes # allow us to connect to daemons for testing with unencryted 
# real case, should be set "required"

# tell dovecot where to find the key
ssl_cert = </etc/dovecot/private/dovecot.pem
ssl_key = </etc/dovecot/private/dovecot.key

sudo vi /etc/dovecot/conf.d/10-master.conf

# Find out the IP address of eth0 interface on this system:
ip a | grep eth0

sudo vi /etc/dovecot/dovecot.conf
# listen to only one ip
listen = 10.0.0.5

service imap-login {
  inet_listener imap {
    #port = 143
  }
  inet_listener imaps {
    #port = 993
    #ssl = yes
  }
  ```

    
## Config dir: `/etc/`
    
    Here are some common subdirectories and types of files found in the **`/etc`** directory:
    
    1. **Configuration Files:** Many system configuration files are stored in **`/etc`**. These files control the behavior of various system components and applications. Examples include **`/etc/network/interfaces`** for network 
    configuration on Linux and **`/etc/ssh/sshd_config`** for SSH server configuration.

    2. **System Scripts:** Some system-wide scripts and startup/shutdown files are located in **`/etc`**. For example, **`/etc/init.d`** or **`/etc/systemd/system`** might contain startup scripts for different services.

    3. **Package Configuration:** When you install software packages on a Unix-like system, their configuration files are often stored in the **`/etc`** directory. For instance, **`/etc/apt`** contains configuration files for the Advanced Package Tool (APT) on Debian-based systems.

    4. **Default Settings:** The **`/etc/default`** directory often contains default settings for various services or system components.
    
    5. **Security Settings:** Security-related configurations, such as user authentication settings (**`/etc/passwd`**, **`/etc/shadow`**) and group information (**`/etc/group`**), are typically found in **`/etc`**.

## SSH server & clients： `ssh_config, sshd_config`
    
```bash
    **# ssh: ssh client ./ssh
    # sshd: ssh server**
    # ssh_config — OpenSSH client configuration file
    sudo vi /etc/ssh/ssh_config
    sudo vi /etc/ssh/sshd_config
    
    man sshd_config
    # AddressFamily
                 Specifies which address family should be used by sshd(8).  Valid arguments are any (the default), inet (use IPv4 only),
                 or inet6 (use IPv6 only).
    
    Port 988
    AddressFamily inet
    ListenAddress 10.11.12.9
    # PasswordAuthentication no
    Match User aaron
      PasswordAuthentication yes # enable for single user
    # PermitRootLogin yes
    # X11Forwarding no
    
    sudo systemctl reload sshd.service
    
    ssh-keygen
    # id_rsa # private key
    # id_rsa.pub #pub
    
    ./ssh/authorized_keys
    
    # copies the public key of the current user to the specified user's home directory on the remote server.
    ssh-copy-id username@10.1.10.9
    
    # ssh password
    # ssh key
    
    **# Squid**
    sudo apt install squid -y
    sudo systemctl start squid
    sudo systemctl enable squid
    sudo firewall-cmd --add-service=squid
    sudo firewall-cmd --add-service=squid --permanent
    sudo vi /etc/squid/squid.conf
    # acl
    # localnet
    # src: source type
    
    acl localnet src ipaddress
    acl external src ip
    scl SSL_ports port 443
    acl Safe_ports port 80
    acl youtube dstdomain .youtube.com # will include all subdomain
    
    http_access allow localnet !youtube
    # deny requests to certain unsafe ports
    http_access deny !Safe_ports # exclude port, above 80 and 443, so rest ports will be excluded
    http_access deny to_localhost # deny 
    # also can deny domain
    http_access deny youtube
    
    # local access is explicitly allowed and that external access is only allowed if it doesn't match a more specific rule for localhost
    http_access allow localhost 
    # allow external reach proxy
    http_access allow external 
    
    # apply changes
    sudo systemctl reload squid.service
    
```
    
## Config HTTP server
    
```bash
    # mod_ssl package
    sudo journalctl -xe | grep apache2 # Systemd Journal
    sudo apache2ctl configtest # check syntax
    
    sudo dnf install mod_ssl -y
    httpd -M  | grep ssl # verify module
    
    # verify port
    sudo netstat -tulpn | grep :80
    sudo netstat -tulpn | grep :443
    
    sudo vi /etc/httpd/conf/httpd.conf
    man httpd.conf
    
    man htpasswd
    
    # enable pwd protection for httpd
    <Directory "/var/www/html/admin/">
        AuthType Basic
        AuthBasicProvider file
        AuthName "Secret admin page"
        AuthUserFile /etc/httpd/passwords
        Require valid-user
    </Directory>
    
    # create password file 
    sudo htpasswd -c /etc/httpd/passwords john
    # Create the password file i.e /etc/httpd/passwords and add the user called john with password john123 in the same.
    
    # delete
    sudo htpasswd -D /etc/httpd/passwords john
    
    # %v: used to log the name of the virtual host that is serving the request
```
    
## Config DB server: `mariadb`
    
```bash
    sudo apt update & install mariadb-server -y
    sudo apt install firewalld -y
    sudo firewall --add-service=mysql
    sudo firewall --add-service=mysql --permanent
    sudo mysql_secure_installation
    mysql -u root # will get rejected
    
    # login
    mysql -u root -p # jump to mysql console
    
    # configure files of mariadb
    cat /etc/my.cnf
    sudo vi /etc/my.cnf.d/mariadb-server.cnf
    
    [mysqld]
    socket # app talk to app via socket
    datadir=
    socket=
    log-error=
    pid-file=
    port=3308
    
    bind-address=0.0.0.0 # listen to any ip from internet, allow remote access
    
    /etc/my.cnf.d/mysql-server.cnf # config db server
    
    # manage db containers
    Daemon & config file & logs & DB
    
    # add user to docker group
    docker --help
    docker search nginx
    docker pull nginx
    docker pull ubuntu/nginx
    docker pull nginx:1.22.1
    
    docker images # show all images
    docker rmi nginx:1.22.1
    # sudo docker run nginx
    sudo docker run --detach --publish 8080:80 --name mywebserver nginx
    sudo docker ps
    sudo docker ps -a
    nc localhost 8080
    docker stop container
    docker rm container
    docker rmi nginx
    docker run --detach --publish 8081:80 --restart always --name my2 nginx
     
    sudo netstat -tulpn | grep 8080 # check if port 8080 is listening
    
    sudo docker run --detach --publish 8081:80 --restart always --name my3 john/customnginx:1.0
    
    sudo docker run --detach --publish 9000:80 --name my4 john/customnginx:1.0
    a60fee2f39c3f6e811a69be93849d9fc7d2030f7c4594fd1d7900b4423d11a7d
    ubuntu@ip-172-31-14-145:~$ nc localhost 9000
    
    # First check if that image is being used by any running container, if so then first stop that container and remove it
    export CONTAINER_ID=281d405affb8
    sudo docker images
    sudo docker ps -a
    sudo docker stop $CONTAINER_ID
    sudo docker rm $CONTAINER_ID
    # Now remove the image
    sudo docker rmi $IMAGE_ID
```
    
## Manage and config VM: `virsh`
    The **`virsh`** command-line tool is used for managing and interacting with virtual machines on a host that runs the libvirt hypervisor management library. 
    It provides a variety of commands for tasks such as starting, stopping, managing virtual machine configurations, and more.
    
```bash
    sudo apt install libvert qemu-kvm -y
    vi text.html
    
    virsh help
    
    vi text-vm.xml
    virsh define text-vm.xml
    # Domain 'TestMachine' defined from text-vm.xml
    
    ubuntu@ip-172-31-14-145:~$ <domain type="qemu">
            <name>TestMachine</name>
            <memory unit="GiB">1</memory>
            <vcpu>1</vcpu>
            <os>
                     <type arch='x86_64'>hvm</type>
            </os>
    </domain>
    
    virsh list # only show active domains
    virsh list --all
    virsh start TestMachine
    virsh reboot/reset TestMachine
    virsh shutdown TestMachine
    virsh destroy TestMachine # poweroff
    virsh undefine TestMachine # not delete data
    virsh help undefine
    virsh autostart VM
    virsh autostart --disable TestMachine
    virsh dominfo TestMachine
    virsh set # double tab
    virsh help setvcpus
    virsh setvcpus TestMachine 2 --config --maximum
    virsh setmaxmem TestMachine 2048M --config
    
    sudo virsh setmaxmem VM2 80M --config
    sudo virsh setmem VM2 80M --config
```
    
## Create VM: `virt-install, qemu`
```bash
man virt-install
virt-install --help

sudo apt install virt-manager -y
wget https://
qemu-img infor ubuntu.img
qemu-img resize ubuntu.img 10G # increase vm size

virt-install --osinfo list # check supported os
# Create a vm around an existing disk image
# --import 
# disk image already have os installed
sudo virt-install \
  --name=vm1 \
  --memory=1024 \
  --vcpus=1 \
  --disk path=/my/vm/image/.dmg \
  --import \
  --noautoconsole \
  --graphics=vnc \
  --os-variant=linux

sudo virsh list --all
```