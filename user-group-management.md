## User accounts: `useradd, userdel, groupadd, usermod, groupdel, chage`
    
```bash
    sudo useradd john
    sudo passwd john #  set pwd for john
    
    # -e: expiry date
    # usermod: modify user account
    sudo usermod -e '' john # never expire
    
    # --system: Creates a system user. 
    # System users are typically used for running services and daemons on the system. They have no login privileges by default.
    sudo useradd --system apachedev
    
    # -s /bin/csh: Sets the ***login shell*** for the user to /bin/csh
    sudo useradd jack -s /bin/csh
    
    sudo useradd sam --uid 5322 -G soccer
    
    # userdel
    sudo userdel sam # only delete user but not /home/sam
    
    sudo usermod harry --home /home/school/harry # change home dir
    # verify user dir
    $ echo ~harry
    /home/school/harry
    
    # change a user shell 
    [bob@centos-host ~]$ sudo usermod --shell /bin/zsh smith
    
    # new user
    sudo chsh -s /bin/zsh smith
    
    # verify user shell
    grep smith /etc/passwd | cut -d: -f7
    
    # -g rugby: Specifies the new primary group for the user.
    sudo usermod -g rugby sam
    
    sudo usermod -L sam
    [bob@centos-host ~]$ usermod --help
    
    # chage: Command used to change user password expiry information.
    # --lastday 0: Sets the account's last password change date to 0, which indicates the current day.
    sudo chage --lastday 0 jane
    
    # warning at least 2 days before pwd expires
    sudo chage -W 2 jane
    
    # usermod: Command used to modify user account settings.
    # -a: This option appends the user to the specified group(s) without removing the user from other groups.
    # -G developers: Specifies the supplementary group "developers" to which the user "jane" should be added.
    sudo usermod -a -G developers jane
    
    # add user smith to a group called whell
    sudo usermod -aG wheel smith
    
    # Lock pwd
    bob@centos-host ~]$ sudo passwd -l employee2
    Locking password for user employee2.
    passwd: Success
    [bob@centos-host ~]$ sudo passwd -u employee1
    Unlocking password for user employee1.
    passwd: Success
    
    # Resource limit for user
    # ulimit = user limit
    [bob@centos-host ~]$ sudo su - jane
    [jane@centos-host ~]$ ulimit -u 30
    [jane@centos-host ~]$ logout
    # verify 
    ulimit -a
    
    # verify group wheel users
    # awk -F: '{print $4}' extracts the fourth field from the group entry, 
    # which contains a comma-separated list of users in the group.
    getent group wheel | awk -F: '{print $4}'
    
    # groupadd: Command used to create a new group.
    # cricket: The name of the new group being created.
    # -g 9875: Specifies the GID (Group ID) for the new group, setting it to 9875.
    sudo groupadd cricket -g 9875
    
    # groupmod: Command used to modify group account settings
    sudo groupmod -n soccer cricket
    
    sudo groupdel
    
    # remove user from group wheel
    sudo gpasswd -d jack wheel
    # verify which group user in
    groups jack
    # check user and group permission
    id jack
    # verify user permission
    sudo cat /etc/sudoers
```
    
## System wide environment profile: `/etc/profile.d, /etc/environment`
    
```bash
    printenv # print all env
    
    echo $HOME
    
    cat .bashrc
    
    # globally env file
    sudo vi /etc/environment 
    source /etc/environment
    
    # modify skelton dir, so that every new user will have a READMEfile
    # created
    cd /etc/skel/
    sudo touch README
    
    # this command gets executed for any user that logs in to the system
    sudo vi /etc/profile.d/lastlogin.sh
    bob@centos-host ~]$ sudo vi /etc/profile.d/welcome.sh
    
    echo "Your last login was at: " > $HOME/lastlogin
    date >> $HOME/lastlogin
    
    logout
    ls
    cat lastlogin
```
    
## Template user environment: `/etc/skel/`
    
```bash
    # inform new user default policy
    # /etc/skel directory is often referred to as the "skeleton directory."
    # This directory contains default configuration files and directories that are used as a template when creating a new user's home directory.
    
    sudo vim /etc/skel/README # this policy will be in new user trinity
    sudo useradd trinity
    sudo ls -a /home/trinity
    
    sudo vi /home/trinity/.bashrc
```
    
## User resource limit: `/etc/security/limits.conf`
    
```bash
    /etc/security/limits.conf
    sudo vi /etc/security/limits.conf
    # domain: trinity/@developers(**groupname**) 
    # gropuname: @ 
    @developers      -       maxlogins       5
    # type: soft(can be slightly increased), hard(can't be overwroten, max limit), - (soft and hard)
    # item: nproc, fsize, cpu(cpu time) , what's limit for,  # man limits.conf
    # value
    
    sudo -iu trinity
    ps | less
    ulimit -a # check current user limit
    ulimit -u 5000
    # bydefault, user can only lower process limit
    
    sudo vi /etc/security/limits.conf
    jane hard nproc 30
```
    
## User privileges: `/etc/sudoers`
    
```bash
    sudo
    sudo gpasswd -a trinity wheel 
    
    sudo gpasswd -d trinity wheel
    sudo visudo sudoers # /etc/sudoers
    
    trinity ALL=(ALL) ALL
    %developers ALL=(ALL) ALL
    trinity ALL=(aaron,john) ALL
    trinity   ALL=(sam)   ALL # run sudo commands as the user sam
    trinity ALL=(ALL) /bin/ls, /bin/stat
    trinity    ALL=(ALL)   NOPASSWD: ALL
    
    sudo -u trinity ls /home/trinity
    
    # Examples
    john.doe ALL=(ALL:ALL) /sbin/ifup, /sbin/ifdown
    
    # Breaking down your example:
    
    # john.doe
    ALL=
    (ALL:ALL)
    /sbin/ifup, /sbin/ifdown
    (1) The user john.doe can 
    (2) regardless of the machine name 
    (3) pretend to be any (ALL) user-id, 
    or belong to any (:ALL) group for the purposes of running 
    (4) these commands. 
    So, for instance, john.doe run the /sbin/ifup command as any user he wishes:
    
    # username ALL=(ALL:ALL) NOPASSWD: /path/to/command
    $ sudo -u vahid2015 /sbin/ifdown eth0
    and you'd get the blame!
```
    
## Manage access to root account
    
```bash
    sudo --login = sudo -i # login as root
    su - = su -l = su --login
    sudo passwd root
    
    sudo passwd --unlock root = sudo passwd -u root
    su -
    sudo passwd --lock root = sudo passwd -l root # only 
    
    # if user has root privilege, change root pwd
    sudo passwd root
    
    # unlock root account
    sudo passwd -u root
    
    # change root pwd
    sudo passwd root
    
    # type new pwd twice
```
    
## Config PAM: `/etc/pam.d`
    
```bash
    su 
    # ask for pwd
    
    # PAM: plugin authentication module
    
    # pam conf file: 
    /etc/pam.d
    man pam.conf
    
    # restrict access to certain PAM-authenticated services to users who are members of the wheel group
    auth    required  pam_wheel.so use_uid
    #auth: Specifies that this configuration is for the authentication service.
    #required: Specifies that this PAM module is required for authentication. If the module fails, authentication will not succeed.
    #pam_wheel.so: Refers to the PAM module named pam_wheel.so. This module is commonly used to restrict access to certain users or groups based on membership in the wheel group.
    #use_uid: This is an option for pam_wheel.so that instructs the module to check the user's UID (User ID) rather than the username. It means that the specified group (typically the wheel group) will be granted special privileges based on the UID rather than the username.
```
    
## LDAP