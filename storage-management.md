## Partition： `lsblk, fdisk, cfdisk`
    
 ```bash
    man fdisk
    sudo fdisk --list /dev/sda # partition utility

    # create/update/delete primary/extend partitions
    sudo fdisk /dev/vdb 
    
    # plan new partitions we wanna, size, type
    sudo cfdisk /dev/sdb # Display or manipulate a disk partition table.

    # active swap
    sudo swapon /dev/sdXn # enable swap on 
    sudo mkswap /swap
    sudo swapon --verbose /swap

    # list
    $ swapon --show 
    
    # disable swap file
    sudo swapoff /swapfile

    # check and repair
    sudo fsck /dev/vde 
```
    
## Create and config filesystem: `mkfs.xfs, tune2fs`
    
```bash
    man mkfs.xfs
    man mke2fs 
    
    # Create an xfs filesystem with the label "DataDisk" on /dev/vdb.
    sudo mkfs.xfs -L "DataDisk" /dev/vdb

    # Create an ext4 filesystem with a number of 2048 inodes on /dev/vdc.
    sudo mkfs.ext4 -N 2048 /dev/vdc
    
    sudo tune2fs -L "BackupVolume" -N 5000 /dev/xvda
    
    # fix ext4 file /dev/vde1
    # e2fsck: The ext2 filesystem consistency check and repair utility.
    sudo e2fsck -n /dev/vde1 # check file, -n: no changes
    sudo e2fsck -y /dev/vde1
    
    # Mount filesystems while boot
    sudo mount /dev/xvda1/ /mnt/
    sudo umount 

    # backup/mount automatically when reboot
    sudo vim /etc/fstab 
    # /dev/vdc /test ext4 defaults 0 2
    
    # check file type
    blkid /dev/examVG/examLV
    ## /dev/examVG/examLV: UUID="87e3dc74-a1f9-444d-a90b-f5d4ca642f8d" BLOCK_SIZE="512" TYPE="xfs"
    
    # Configure the system to automatically use /dev/vdb as swap when it boots up.
    /dev/vdb none swap defaults 0 0
    #
    # 0: never errors
    # 1
    # 2
    sudo systemctl reboot
    
    # Change the label for /dev/vdb filesystem to SwapFS
    sudo xfs_admin -L "SwapFS" /dev/vdb
    # verify label
    blkid /dev/vdb3

    # mount on demand: utility autofs
    sudo dnf install nfs-utils
    sudo systemctl start nfs-server.service
    sudo systemctl enable nfs-server.service
    sudo systemctl reload nfs-server
    # tell nfs what dir needds to share
    sudo vi /etc/exports
    /etc 127.0.0.1 (ro)
    
    sudo vi /etc/auto.master
    # timeout=400
    
    sudo vi /etc/auto.shares
    # how did this happen?
    
    # Basic file
    findmnt 
    
    findmnt -t xfs,ext4
    TARGET   SOURCE            FSTYPE OPTIONS
    /        /dev/xvda1 ext4   rw,relatime,discard,errors=remount-ro
    
    sudo mount -o ro /dev/vdb2 /mnt # readonly permission
    sudo mount -o rw,noexec,nosuid /dev/vdb2 /mnt
    sudo mount -o remount,rw,noexec,nosuid /dev/vdb2 /mnt
    
    /dev/vdb1 /mnt ext4 defaults,ro 0 2  # ro permission
```

## NFS: `exportfs`
```bash
    # exporting direc to share
    NFS server
    NFS client
    
    **# server**
    sudo apt install nfs-kernel-server
    sudo vi /etc/exports
    
    /srv/homes hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
    # can also be ipaddress, CIDR range, domain
    # /nfs/disk1/backups
    # sync writes, async writes
    # allow clients to rw, ro
    # no_root_squash - allow root user to have root privileges
    
    # share to ip
    /etc/127.0.0.0(ro)
    
    # apply change
    sudo exportfs -r # re-export, refresh based on this file
    sudo exportfs -v # verbose, detailed output
    
    /etc *.example.com # share /etc to all hostname end with .example.com
    
    /etc *(ro,sync,no_subtree_check) # to share with any client
    
    man exports
    
    # **client**
    sudo apt install nfs-common
    
    # general syntax to mount a remote NFS share is
    sudo mount IP_or_hostname:/path/to/remote/dir /path/to/local/dir
    
    sudo vi /etc/fstab
    
    # add line
    127.0.0.1:/etc /mnt nfx deafults 0 0 # no need to check for errors
    
```
    
## Network block devices: `NBD`
    
```bash
    NBD client
    NBD server
    
    # Server
    sudo apt install nbd-server
    lsblk
    #share vda1
    # open defautl conf file
    sudo vi /etc/nbd-server/config # run as user nbd
       user = nbd
       group = nbd
       includedir = /etc/ndb-server/conf.d
       allowlist = true
    # end of file
    [partition1]
       exportname = /dev/vda1
    
    sudo systemctl restart nbd-server.service
    man 5 nbd-server
    
    # client
    sudo apt install nbd-client
    sudo modprobe nbd # module
    sudo vi /etc/modules-load.d/modules.conf
    nbd
    sudo nbd-client <ipaddress> -N partition1 (partition name) # nbd0 /dev/nbd1
    ip add
    
    sudo mount /dev/nbd0 /mnt
    ls /mnt
    # detach, umount first
    sudo nbd-client -d /dev/nbd0
    lsblk
    # nbd0 size 0B now, before was 24GB
    sudo nbd-client remote-server -N partition1
    sudo nbd-client ip -l # list server partition
```
    
## Storage monitoring: `iostat, pidstat`, `iotop`, `top`
    
```bash
    # Display linux real-time process
    top

    # cross-platform process viewer
    htop

    # simple top-like I/O monitor
    iotop
    # only processes actually doing I/O
    iotop -o
    iotop -ao

    # iostat: report CPU statistics for devices/processes
    tps: transfer per second # read or write something
    iostat -d # display
    iostat -h # human readable
    iostat -p ALL
    iostat 1 # last one second

    # vmstat: virtual memory statistics

    # starce: trace system calls

    # pidstat: process ID statistics
    pidstat -d 1 # real time check every second
    ps 2999 #PID, check what command run the processes
    kill 2999 # shut down
    kill  -9 2999 # force kill

```
    
## Manage and config LVM storage: `pv, vg, lv`
    
```bash
    sudo dnf install lvm2
    
    PV: physical volume
    sudo lvmdiskscan
    
    sudo pvcreate /dev/sdc /dev/sdd # create physical volume
    
    sudo pvs # pv 
    sudo vgcreate my_volume /dev/sdc /dev/sdd # volume group, virtual disk, treat one sigle 
    
    # expend vg
    sudo pvcreate /dev/sde
    
    # add pv to the vg
    sudo vgextend my_volume /dev/sde
    
    sudo vgs # volume groups
    
    # remove
    sudo vgreduce my_volume /dev/sde
    
    # remove pv
    sudo pvremove /dev/sde
    
    # create logical volume
    sudo lvcreate --size 2G --name partition1 my_volume # volume group
    sudo vgs
    
    # 2nd vgs
    sudo lvcreate --size 6G --name partition2 my_volume
    
    sudo lvs # list logical volumes
    sudo lvresize --extents 100%VG my_volume/parition1
    
    # shrink
    sudo lvresize --size 2G my_volume/partition1
    
    sudo lvdisplay # show all info
    
    sudo mkfs.xfs /dev/my_volume/partition1 # create a filesystem
    
    sudo lvresize --resizefs --size 3G my_volume/parition1
    
    man lvm # see all commands
    
    vg # tab x2
    
```
    
## Encrypted storage: `cryptsetup`
    
```bash
    # plain & luks modes
    
    # one step to open
    sudo cryptsetup --verify-passphrase open --type plain /dev/vde mysecuredisk
    
    sudo cryptsetup close mysecuredisk
    
    sudo cryptsetup luksFormat /dev/vde # F capital
    cryptsetup tab x2
    
    sudo cryptsetup luksChangeKey /dev/vde # easy to change pwd
    sudo cryptsetup open /dev/vde mysecuredisk 
    sudo mkfs.xfs /dev/vde/mysecuredisk
    
    # /dev/vde1 encrypted
    # /dev/vde2 
    # if need to encrypt sepcific disk, need to specify
```
    
## Create  and manage RAID device: `mdadm`
    
```bash
    # level 0 RAID: see as a single storage
    # Redundant array of independent disks
    # levl 1 RAID: same data in diff disks
    # level 5 RAID: small backup (back up in one disk), if lose one disk, still have some on other disks
    # data recoverable
    # level 6: back up in 2 disks
    # level 10 RAID:
    
    sudo vgremove --force my_volume
    
    sudo pvremove /dev/vdc /dev/vdd /dev/vde
    
    sudo mdadm --create /dev/md0 --level=0 --raid-devices=3 /dev/vdc /dev/vdd /dev/vde
    
    sudo mkfs.ext4 /dev/md0
    
    sudo mdadm --stop /dev/md0
    
    sudo mdadm --zero-superblock /dev/vdc /dev/vdd /dev/vde
    
    # add spare disk
    sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/vdc /dev/vdd --spare-device /dev/vdd
    
    cat /proc/mdstat # check raid personalities, unused devices
    sudo mdadm --manage /dev/md0 --remove /dev/vdc # remove 
    
```
    
## Advanced filesystem: `setfacl,getfacl`
    
```bash
    ls -l 
    
    # file access control list
    echo "lfcs" > testfile
    sudo chown adm:ftp testfile
    ls -l testfile
    # others only have read, how can he/aaron write?
    # exception for one user aaron - others
    
    sudo setfacl --modify user:aaron:rw testfile
    # can verify
    rw-rw-r--+ : + for aaron
    # mask: maximum rw-, not execute
    getfacl testfile
    
    sudo setfacl --modify mask:r testfile
    getfacl testfile # check file permissions
    
    # mask: r
    # aaron unable to write
    
    sudo setfacl --modify group:wheel:rw testfile
    sudo setfacl --modify user:aaron:--- testfile # aaron do nothing on file
    sudo setfacl --remove user:aaron testfile
    sudo setfacl --remove user:john specialfile
    sudo setfacl --modify group:mail:rx specialfile
    
    # Use the setfacl command recursively, 
    # so that ACL entries are modified on the directory itself
    # but also all the files and subdirectories it may contain.
    setfacl --recursive --modify user:john:rwx collection/
    
    setfacl --recursive -m user:aaron:rw
    
    # Remove the file called newfile from your home directory. 
    # You will notice that not even sudo rm can remove this file. 
    # That's because the file is currently immutable. 
    # Remove the immutable flag from it and then delete the file.
    
    sudo chattr -a newfile # remove the "append only" attribute from a file
    sudo chattr +i newfile # immutable, cann't changed in any way, even root
    # -------i---------- newfile
    # remove att immutable
    sudo chattr -i newfile
    man attr

```