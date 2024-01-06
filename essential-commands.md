## Man sections: `man man`
    1. Shell commands and applications (1), 
    2. Basic kernel services (2), 
    3. Library information (3), 
    4. Network services (4), 
    5. Standard file formats (5), 
    6. Games (6), 
    7. Miscellaneous files and documents (7), 
    8. System administration and maintenance commands (8) 
    9.  Obscure kernel specs and interfaces (9).

## Basic commands: `chmod, chgrp, man, ssh, hostname`
    
```bash
    man man

    # check current os
    uname -a

    # apropos
    ## grep confi file of NFS mounts
    apropos "NFS mounts"
    
    # ssh
    man ssh
    ssh -V  # display the ssh version
    ssh -v # verbose mode, output progress & for debugging
    
    # The -l option stands for "long format" 
    ls -a # Show all files & directories & hidden files
    ls -lah  # human readable
    ls -la # long output plus hidden files
    ls -lR # long output recursive (show subdirectories content)
    ls -lt # long output sorted by modification time
    ls -ld /etc # show the directory properties and not its content
    
    cd # change directory
    .. # parent directory/current
    cd - # previous dir
    cd # home dir

    cp -r # recursive all dir & contents
    cp # copy files
    mv # move & rename, no need -r
    
    # remove dir needs -r
    rm -r invo/ # recursive remove all files & dir.

    # change file to group wheel
    chgrp wheel family_dog.jpg 
    groups # check groups
    
    # Recursive: ownership is changed for **dir itself** along with files/dirs it contains
    sudo chown -R bob:bob /opt/databases/
    
    # owner & group & others
    r # read file
    w # write file
    x # execute
    - # no permission
    
    # u+[list of permissions]
    user    u+ u+w/u+rw/u+rwx
    group   g+ g+w/g+rw/g+rwx
    others  o+ o+w/o+rw/o+rwx
    chmod u+w family_dog.jpg. # grant user aaron write permission
    
    # u=[list of permissions]
    chmod g=r family_dog.jpg # allow group only read permission to file
    chmod g=rw family_dog.jpg # disable execute permission
    chmod g= family_dog.jpg # no permission to this group =g-rwx
    
    # example: 
    # user (r+w), group only read, others no permission
    chmod u+rw,g=r,o= /file/path
    
    # remove SETUID, execution permissions on file
    sudo chmod u-s,u-x databases/file3594
    
    # 110100000 = binary decimal r=4, w=2, x=1 = 640
    rw- r-- --- 
    chmod 640 family_dog.jpg
    
    # SUID & SGID & stickybit
    # run file as fileowner not terminal user
    chmod 4664 # 4 is user id leading number, 6=S (upper case) not executed permission
    chmod 2674 # 2 is group id, 7=s (lowercase) executed permission
    chmod 1777 stickydir # 1 is 
    
    # add sticky bit
    # means only owner/superuser of file can rename/delete the dir/file
    chmod +t /opt/sticky
    ls -ld /opt/sticky # check dir permission
    # see "t" 
    # direc with sticky bit set, users can create/modify/delete their own files within dir
    # but they cannot delete or rename files owneed by others
    drwxrwxrwt 2 owner group 4096 Jan 1 10:00 /opt/sticky
    
    # change dir permi
    chmod 700 /opt/database/
    # verify
    ls -ld /opt/database
    
    # change files under this di
    find /opt/databases/ -type f -exec chmod 640 {} \;
    # verify file permission
    sudo ls -l /opt/databases/

    mkdir -p dir/dir2
    
    # Link
    # Soft link: an actual link to the original file, 
    # hard link: is a mirror copy of the original file

    # hard link
    sudo ln /from/file /to/file 
    # verify with inode number
    ls -i /file/path /destination/file/path
    
    # soft link/symbolic link
    ln -s {source-filename} {symbolic-filename}
    # To verify new soft link run:
    ls -l file1 link1

```
    
## Search files: `find`
        
```bash
        # find path-to-dir search-para
        find /bin/ -name file1.text 
        find -name file.text # no path search current dir
        find -iname felix # insensitive with case
        find -name "f*"
        
        # modified minute
        find -mmin [minute]
        find -mmin -5 # only find last 5 min modified file
        find -mmin +5 # find modified files 5 min ago
        
        find -mtime 2 # 24-hour periods, find files modified two days ago
        find -cmin 5
        
        # find -size [size]
        fid -size 512k
        find -size -512k # file below 512k size
        find -size +512k
        
        find -name "f*" -size 512k # AND 
        find -name "f*" -o -size 512k #OR operator
        find -not -name "f*" # Not operator
        find \! -name "f*" # alternate NOT operator
        find -perm 664 # find file with exactly 644 permission
        find -perm -664 # fine file with at least 664 permissions
        find -perm /664 # find files with any of these permissions
        find -perm -100
        find \! -perm -o=r #find files others cannot read, only owner and group can read
        
        # find group write permission
        # find others no read and write
        sudo find /var/log/ -perm -g=w ! -perm /o=rw 
        
        # find "or"
        find /home/bob -size 213k -o -perm 402

        sudo find /var -type f -size 20M | wc -l
        sudo find /usr/ -type f -size +5M -size -10M # find file 5M<file<10M
        
        # list exact time file was modified
        ls --full-time

        # \ is with -exec
        # \ ensure -exec properly terminated
        -exec cp {} /opt/ \;
        sudo find /opt/findme/ -type f -size +1k -exec cp {} /opt/ \;
        
        # find SITUID enabled and delete
        sudo find /opt/findme/ -type f -perm /4000 -exec rm -f {} \;

```
        
## File content: `sed`, `cut`, `uniq`, `sort`, `tac`, `tail`, `head`, `diff`
    
```bash
    cat
    tac
    tail -n 20 # last 20 lines of log file
    head -n 20 # first 20 lines of log file
    
    # replace all same word
      # s: substitute/search
      # g: global
      # -i: in-place
    sed -i 's/canda/canada/g' filename
    sed -i '500,2000s/enabled/disabled/g' filename # replace all from line 500-2000
    
    # replace a set of characters between a-e with _
    sed 's/[A-Ea-e]/_/g' file.txt # without g, it replaced only the first match

    # d: delimiter ,
    # -f: field
    # 1: first letter
    # cut -d delimiter -f column
    cut -d ',' -f 3 abc.txt # extract 3rd collum info
    
    # uniq:remove duplicates
    uniq countries.txt # remove repeated lines

    # sort: order file content
    sort contries.txt | uniq 
    
    # diff
    diff file1 file2
    diff -c file1 file2  # c: contexts
    diff -y file1 file2 # side by side = sdiff file1 file2

```
    
## Pagers: `less, more, vi`
    
```bash
    less /var/log/dnf.log
    # user up down arrow keys 

    vim editor 
    # search: /key (/this\c) case insensitive when searching "this"
    :3 # cursor goes to line 3

    # copy entire line text
    command mode -> v key to select text -> y key to copy -> p key to paste
                 -> d key to delete -> 

    # search: /key (/syslog)
    # n: move to next occurrence, N: move to previous, 
    # :q!: exit without save.
    # :wq!: quit with save.
    # u: undo
    # ctrl + r: redo
    # gg: go to file begin
     
    # move cursor
    # normal mode
    page number 1000G-> dd-> 8G-> p (paster after line 8)

```
    
## Search file: `grep, wc`
    
```bash

    # -i: case-insensitive matching.
    # -w: Match only whole words.
    # -o: Show only the part of the line that matches the pattern.
    # -v: Invert the match=exclude, i.e., show lines that do not contain the pattern.
    grep -iwov 'red' /etc/

    
    # ^: the line begins with
    # $: the line ends with
    # *: match the previous element 0 or more times
    # let* = lettt/let/lett # 0 t or 1 t or 2+
    grep '^h.*sam$' file1  # start with 'h', and end with 'sam'
    
    # . match any one character
    grep -r 'c.t' /etc/ # match any contains c.t(cat, cut etc)
    grep -wr 'c.t' /etc/ # match any word match c.t
    
    # \: escape for special character
    grep '\.' /etc/login.dfs # look for regular period 

    # > /dev/null: command discarded and won't see on terminal
    
    # -E: Extended regular expressions
    grep -Er '0+' /etc/ = egrep -r '0+' /etc/ # grep number 0 in the dir
    
    # {}: previous elements can exist "this many" times
    egrep -r '0{3,}' /etc/  # 0 exist at least 3 times
    egrep -r '10{,3}' /etc/ # maximum 3 times
    egrep -r '0{3}' /etc/ # 0 exist exact 3 times
    
    # ?: make the previous element optional
    egrep -r 'disabled?' /etc/ # disable, disabled,disables all match
    
    # |: match one thing or the other
    # [a-z]: ranges or sets
    egrep -r 'c[au]t' /etc/ # middle character match a-u 
    
    egrep -r '/dev/[a-z]*[0-9]?' /etc/  #match lower case 0 or more times, numbers are optional
    # above expression only happen once, so ttp0p0 not match

    # find 5 digits number
    egrep '[0-9]{5}' tet.txt
    
    # wc: count the number of lines, words, and characters in a file or a set of files
    # -l : list
    wc -l text.file # output: 42 lines in this text.file

```
    
## Archive & Backup & Compress : `tar, gzip`
    
```bash
    # tar = tape archieve # packer
    # gzip: -j
    # bzip: -z
    # -x : extract
    # -C : specified directory
    # -v : Verbosely show the .tar file progress.
    # -f : filename of archive file
    tar --list --file achive.tar = tar tf archive.tar
    tar --create --file archieve.tar files1 = tar cf archive.tar file1
    tar --extract --file archive.tar = tar xf archive.tar
    tar --extract --file archive.tar --directory /tmp/ = tar xf archive.tar -C /tmp/

    sudo tar -xzvf backup.tar.gz -C /opt/restoredgz/ # extract .gz
    
    # Compress with gzip
    gzip file1
    gunzip file1.gz
    
    # create an archive file
    sudo tar -czf /opt/manyfiles.tar.gz -C /opt/manyfiles
    
    sudo unzip backup.zip -d /opt/restoredzip/ # extract .zip = unzip
    
    bzip2 file2
    bunzip file2.bz2
    
    # display file
    tar tf manyfiles.tar.gz 
    or cat import001.tar.bz2_list | sha512sum
    ls -lh
    
```
    
## Input-Output: `>, >>`
    
```bash
    # > : redirection & overwrite
    # >>: redirection & redirect & append

    # stdin, stdout, stderr
    # terminal & errors.txt
    stdin<file.txt
    # Execute wc using the content of file as input
    wc < file

    stdout 1>terminal
    stderr 2>errors.txt
    
    grep -r '^The' /etc/ 2>/dev/null (location to errors, discarded)
    
    grep -r '^The' /etc/ 1>>output.txt 2>>>errors.txt # append
    
    #1: stdout
    #2: stderr
    # 2&1: std error goes to stdout
    # > all_output.txt: redirect stdout to file
    # 2>&1: This part redirects the standard error (stderr) to the same location as stdout. 
    # >&1 means "send it to the same place as stdout.
    grep -r '^the' /etc/ > all_output.txt 2>&1

    # save all outputs (stdout & stderr)
    grep -r '^the' /etc/ 1>all_output.txt 2>&1  
    
```
    
## SSL: `openssl`
    
```bash
    man openssl
    man openssl-req
    man openssl x509
    
    # base64 coded
    # decode existing certs 
    # openssl x509: subcommand
    openssl x509 --help
    openssl x509 -text -in mycert.crt
    openssl x509 -in cert.pem -noout -subject
    
    # generate csr, crt and output using req
    openssl req -x509 -noenc -newkey rsa:4096 -days 365 -keyout myprivate.key -out mycertificate.crt
    
```
