## Reboot & Shutdown
`reboot, shutdown, start, get-default`
1. Boot process diagram
   - helpful link: https://blog.bytebytego.com/p/ep88-linux-boot-process-explained
   - Systemd is the default init process in CentOS
   - Systemd starts services. Last service started will be a shell
2. Systemd
    
```bash
    shutdown -h now
    shutdown -r now
    sudo shutdown 02:00
    sudo shutdown +15 # shutdown 15min later
    
    sudo systemctl reboot
    sudo systemctl poweroff
    sudo systemctl reboot --force #also can pass forcex2
    
    # It shows all available targets
    systemctl list-units --type target --all
    
    # represent the node in which the system starts 
    sudo systemctl set-default multi-user.target
    sudo systemctl set-default graphical.target
    
   # emergency for debugging
    sudo systemctl isolate emergency.target

   # drop to root shell for rescue
    sudo systemctl isolate rescue.target 
    
```
    
## Install & Config & troubleshooting
    
```bash
# boot from installation, boot process
chroot /mnt/sysroot

# os file stored on /root/file
# dnf: package manager for centos
dnf reinstall grub2-efi grub2-efi-modules shim

# /dev/vda: virtual disk
# install GRUB -> update GRUB config 
# apply changes to the boot manu configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# default bootloader: Grub2
# GRUB: bootloader on the specfied disk
# bootloader configuration: /etc/default/grub
# kernel boot parameter
    man 7 bootparam
    
```
    
## Automation script: `user-data.sh`
    
 ```bash
    #!/bin/bash  
    #! shebang: full path of interpreter
    
    # user execute access
    chmod u+x script.sh
    
    # group &user, executable
    chmod +x script.sh 
    
    help if
    help test
    
```
    
## Startup process: `systemctl`
systemctl command used to manage servers. In Linux servers often are called daemons

```bash
    man systemd.service
    sudo systemctl status sshd.service
    
    # List all systemd units object available
    systemctl list-unit-files 
    
    sudo systemctl edit --full sshd.service
    sudo systemctl revert sshd.service
    sudo systemctl status sshd.service. # enabled
    sudo systemctl stop sshd.service
    sudo systemctl start sshd.service
    sudo systemctl restart sshd.service
    sudo systemctl reload sshd.service
    ...............reload-or-restart sshd.service
    
    # when unit file edited, need to reload
    sudo systemctl daemon-reload 

    # enable:  daemon will be executed automatically at the next reboot
    sudo systemctl enable sshd.service 
    sudo systemctl start sshd.service
    sudo systemctl enable --now sshd.service  
    
    # disabled: daemon won't be executed automatically at the next reboot
    sudo systemctl disable sshd
    
    # system stuck
    # mask, remember to unmask otherwise atd not work
    sudo systemctl mask atd.service 
    
    # if enable service, wont work as it's masked
    # have to unmask first
    sudo systemctl unmask atd.service
    
```
    
## Processes: `ps, top, nice, renice, lsof`

    - Process-related information including:
        - PID: Process ID
        - USER: Owner of the process
        - PR: Priority
        - NI: Nice value
        - VIRT: Virtual memory usage
        - RES: Resident set size (non-swapped physical memory used)
        - SHR: Shared memory
        - S: Process status (S: Sleeping, R: Running, I: Idle)
        - %CPU: Percentage of CPU usage
        - %MEM: Percentage of memory usage
        - TIME+: Total CPU time
        - COMMAND: Command or process name
    
```bash
    man ps
    # ps: process status

    # list all running processes
    ps -A
    ps -e

    # all process associated with terminal
    ps -T

    # view all current processes execute
    ps ax 

    # view all current process with BSD format
    # BSD: Log-Structured File System
    ps aux
    
    # view a full format listing run
    ps -ef
    ps -ef  | grep systemd

    # filter process with user
    ps -u user

    # all process run by root
    ps -U root -u root
   
    # print real-time information about system processes. 
    top 
    
    # narrow down the processes
    ps 1 # process id

    # pgrep: listing process IDs (PIDs) based on various criteria.
    pgrep systemd
    
    # identify the CPU and Memory usage by only the process having PID 1
    # u: user-orientated,providing a more detailed output.
    # When you run this command, 
    # it will show detailed information about the process with PID 1. 
    # This information typically includes the user, PID, %CPU (CPU usage), %MEM (memory usage), VSZ (virtual memory size), RSS (resident set size), TTY (controlling terminal), STAT (process status), START (start time), TIME (total accumulated CPU time), and COMMAND (command and its arguments).
    ps u 1 

    # all, processID
    pgrep -a syslog 
    
    # nice: influence the scheduling priority of a process when launching.
    # renice: alter the scheduling priority of a running process. 
    # The priority range is typically from -20 to 19,
    # where lower values indicate higher priority.
    #as a regular user, can only renice process once
    nice -n 10

    sudo renice number pid
    sudo renice 7 8209 #PID

    **## Signal**
    # see a list of signals we can send
    # need root permission
    kill -L
    kill -SIGHUP
    
    # forcelly terminate a process
    kill -9 # **sign process number**
    
    pgrep -a zsh/bash
    pkill -KILL bash # kill bash process
    
    **#Examples:**
    # kill: Sends a signal to a process.
    # -SIGHUP: Specifies the hangup signal. Signals are identified by names or numbers, and in this case, 
    # SIGHUP has the number 1.
    # 936: The PID of the process to which the signal is sent.
    # This signal is often used to instruct a process to reload its configuration or to restart gracefully.
    sudo kill -SIGHUP 936

    # find sshd PID
    systmctl status sshd.service --no-pager 
    
    sleep 

    # list open file for this bash process 8481
    lsof -p 8481 
    lsop -p 1 

```
    
## Logging Daemons: `-F, journalctl`
    
```bash
    # default all logs in /var/log
    ls /var/log

    # look for logs contain "ssh" in /var/log
    grep -r 'ssh' /var/log/ 
    
    #search for all files containing the reboot string
    sudo grep -r 'reboot' /var/log/ 
    
    # live logs
    # -F: follow mode
    # track logs = journalctl command
    tail -F /var/log/secure
    
    # journalctl: query and display messages from the system journal, 
    # which is a centralized logging system managed by systemd
    
    # how to find what the team did
    # journal daemon analysis log more efficiently
    which sudo
    /bin/sudo

    # open pagers
    journactl /bin/sudo 

    # display logs generated by ssh daemon
    journalctl -u sshd.service 
    
    # follow logs or live
    # continuously display new log entries in real-time.
    journalctl -f 
   
    # view the end of the journal
    journalctl -e

    # -p: prioprity
    # Analyze the error logs through journalctl with the priority flag
    journalctl -p err # find errors
    
    # tip
    journalctl -p <space with tab>
    
    # Analyze the info priority logs through journalctl 
    # that begin with letter 6
    journalctl -p infor -g '^b'
    
    # Specifies the start time for displaying logs. 
    # In this example, it starts showing logs from 2:00 AM.
    journalctl -S 02:00
    
    journalctl -S 01:00 -U 02:00 # -U
    journalctl -S '2021-11-16 12:04:55'
    journalctl -b 0 # boot 0, current boot
    journalctl -b -1 # last boot logs
    # need root permission
    journalctl 
    
    **# Examples:** 
    #sudo: Runs the command with superuser privileges.
    #journalctl: Command for querying and displaying messages from the journal.
    #-u sshd.service: Specifies the unit name, indicating that you want to see logs related to the SSH daemon.
    #-n 20: Limits the output to the last 20 log entries.
    #--no-pager: Prevents the use of a pager, displaying the logs directly in the terminal without additional navigation features.
    # find out IP address last connected to ssh daemon
    # with message "sshd[1790]: Accepted publickey for root from ...."
    sudo journalctl -u sshd.service -n 20 --no-pager
    
    last # see who logged in
    lastlog # who logged in last time

    journalctl --user -u bash -n 20 --no-pager
    
```
        
## Schedule tasks: `cron,crontab, anacron, at`
    
```bash
    # default system crontab
    # syntax to create cronjob
    cat /etc/crontab # get cron job examples

    * = match all possible values
      , = match multiple values(i.e., 15,45)
        - = range of values (i.e., 2-4)
          / = specifies steps(i.e., */4) # only this hour field
    
    which touch
    
    sudo systemctl status crond | grep Active
    crontab -e 
    crontab -l
    sudo crontab -l
    
    # cron job as a user
    sudo crontab -e -u jane # only root have permission to add user
    crontab -r # remove
    sudo crontab -r -u jane # remove crontab as diff user
    
    # daily task
    /etc/cron.daily/
    /etc/cron.hourly/
    /ect/cron.weekly/
    
    # shell script should have no extension if wanna used as a cronjob
    # no .sh
    touch shell
    sudo cp shell /etc/cron.hourly
    sudo chmod +rx /etc/cron.hourly/shell
    sudo rm /etc/cron.hourly/shell
    
    # anacron: run at a regular 3 days
    sudo vi /etc/anacron
    anacron -T # test

```
    
## Verify completion of scheduled jobs: `at, anacron`
    
```bash
    **# crontab**
    
    sudo crontab -l # see root crontab
    crontab -e

    sudo vi /opt/script.sh
    chmod +x /opt/script.sh 

     # Open the crontab file for user 
    crontab -e -u james # -e: open file

    # no crontab for user - using an empty one
    # crontab: installing new crontab
    crontab -u james -l
    
    # add below
    * * * * * /bin/echo "just testing cron jobs"
    # verify cron job logs
    cat /var/log/cron
    
    # remove cronjob
    crontab -r
    CMD # output

    **# anacron**
    sudo vi /etc/anacrontab
    # /etc/anacrontab: configuration file for anacron
    
    # See anacron(8) and anacrontab(5) for details.
    
    SHELL=/bin/sh
    PATH=/sbin:/bin:/usr/sbin:/usr/bin
    MAILTO=root
    # the maximal random delay added to the base delay of the jobs
    RANDOM_DELAY=45
    # the jobs will be started during the following hours only
    START_HOURS_RANGE=3-22
    
    #period in days   delay in minutes   job-identifier   command
    1       5       cron.daily              nice run-parts /etc/cron.daily
    7       25      cron.weekly             nice run-parts /etc/cron.weekly
    @monthly 45     cron.monthly            nice run-parts /etc/cron.monthly
    ~
    
    # run now
    sudo anaron -n # now
    sudo grep anacron /var/log/cron # verify logs in /var/log/cron
    sudo anacron -n -f # force rerun all jobs now
    sudo grep anacron /var/log/cron | less
    sudo grep atd /var/log/cron
    
    **atd**
    # Viewing the job queue with atq command:
    atq
    
    # Removing a job with atrm command:
    atrm jobid
    
    # at command to schedule jobs
    at 'now + 1 minute'
    echo "" | systemd-cat --identifier=a 
    # ctl + D to exit
    # check system log
    journalctl | grep a # verify logs in system logs
    
```
    
## Package management: `dnf`
    
```bash
    sudo apt update
    sudo apt update && sudo apt upgrade
    
    dpkg --listfiles nginx
    
    sudo yum list files nginx
    
    # install yum utility repoquery
    sudo yum install yum-utils
    
    # find path of all nginx files
    repoquery -l nginx or rpm -ql nginx
    
    sudo yum provides /usr/share/nginx
    sudo yum search nginx
    sudo yum search nginx module image
    sudo yum autoremove nginx # remove nginx and dependencies
    
    # how to config repo of the package manager: yum
    cd /etc/yum.repos.d
    #check out one of the config file
    # baseurl: repo
    # gpg key
    #
    sudo yum update
    sudo yum install nginx/others
    
    # enable nginx & open firewall
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo systemctl status nginx
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --reload
    
    # centOs package manager Fedora-based linux system
    sudo dnf config-manager --enable powertools 
    
    dnf provides /bin/top # provide package for /top program
    
    # list all files contain nginx
    dnf repoquery --list nginx | grep nginx-logo.npg 
    
    # check packages can be upgraded
    sudo dnf check-upgrade
    
    # check repo list on verbose mode
    sudo dnf repolist
    
    # search packages related to Apache HTTP server
    sudo dnf search "Apache HTTP Server" 
    
    # find package name for dir
    sudo dnf provides /etc/samba
```
    
## Install software by compiling source code
    
```bash
    make # compile file
    make clean
    sudo make install # 
    usr/local/bin # install file in this location, so no need to config path anymore
    
    # How do we know disk usage?
    df
    
    tempfs # can ignore, virtual file, only on memory, not on disk usage 
    /dev/vda1 # file system boot file stored
    
    du -sh /bin/ #summarize usage, h: human readable format
    
    # memory used
    free -h
    
    # heavily used by CPU running on server
    uptime
    # 6, 7, 8: means more CPU is used
    lscpu
    
    lspci # system running
    
    sudo xfs_repair -v /dev/vdb1/ 
    
    sudo fsck.ext4 -v -p /dev/vdb2 # -p problem
    
    systemctl list-dependencies 
    # green lights: current running
    # red light: once run
    
    sudo pkill chronyd
    
    systemctl status chronyd.service
    
```
 
## Kernel runtime parameter: `sysctl`
    
```bash
    # sysctl: allocate network, memory
    # config kernel parameters at runtime
    man sysctl.d
    sudo sysctl -a 

    # enable temporary
    sudo sysctl -w net.ipv6.conf.lo.seg6_enabled=1

    # change conf permanently
    sudo vi /etc/sysctl.conf
    # add line
    net.ipv6.conf.lo.seg6_enabled = 1
    # apply for change, 'p' for process
    sudo sysctl -p

    # disable ipv6
    # -w: write a value to a sysctl parameter
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

```

## SELinux: `-Z, roles, types`
    
```bash
    # enabled by default
    # how to make decisions to run process?
    # SELinux User (system_u): It represents the SELinux user associated with a process.
    # SELinux Role: It represents the SELinux role associated with a process.
    
    # user - role - type - level
    unconfined_u:object_r:user_home_t:s0
    
    # SELinux User Roles & types
    # -Z: security contexts of files on linux os
    # The first column represents the file permissions.
    # The second and third columns represent the user and group owners of the file.
    # The fourth column shows the SELinux security context, which includes the SELinux user, role, type, and sensitivity label.
    
    # In the example:
    # unconfined_u: SELinux user (unconfined)
    # object_r: SELinux role (object_r)
    # user_home_t: SELinux type (user_home_t)
    # s0: SELinux sensitivity label (s0)
    ls -Z /bin/sudo

    # chcon - change file SELinux security context
    # using httpd_sys_content_t as the SELinux label for HTML files allows the Apache HTTP Server to access and serve those files.
    sudo chcon -t httpd_sys_content_t /var/index.html

    # setenforce - modify the mode SELinux is running in
    # Use Enforcing or 1 to put SELinux in enforcing mode.
    # Use Permissive or 0 to put SELinux in permissive mode
    sudo setenforce 0
    # verify
    getenforce  # check if Selinux enabled or accessess login
    # Enforcing

    # semanage - SELinux Policy Management tool
    # list SELinux user mappings on a system
    sudo semanage login -l
    sudo semanage login -l | grep x_guest_r # grep roles
    
    # Grep process SELinux label
    $ ps -eZ | grep httpd
    system_u:system_r:httpd_t:s0      33312 ?        00:00:00 httpd
    
```
    
## MAC SELinux: `semanage, chcon,restorecon`

## Kernel runtime parameter: sysctl

```bash
# sysctl: command to config kernel parameters at runtime, read and modify /proc/sys/
sudo sysctl -a 
man sysctl.d

# A vm.swappiness value of 60 means that the kernel will try to 
# keep a balance between using swap space and keeping processes in physical memory.  
# In other words, the system is configured to use the swap space when the physical memory is 60% full.
sysctl -a | grep vm
vm.swappiness = 60 

# 0: false
# 1: true
# IPv6 (Internet Protocol version 6) is enabled for the default network configuration on your system.
net.ipv6.conf.default.disable_ipv6 = 0 

# temporary disable ipv6
# -w: write a value to a sysctl parameter
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# reboot, parameter will be reset to 0 again, very inconsistent
# make consistent change
vi /etc/sysctl.conf
# add line 
net.ipv6.conf.default.disable_ipv6=1
# apply changes
sudo sysctl -p

# low value will try to not use this 
# make change consistent
sudo vi /etc/sysctl.d/swap-less.conf # /etc/sysctl.d/*.conf
vm.swappiness = 30

sudo sysctl -p /etc/sysctl.d/swap-less.conf

```