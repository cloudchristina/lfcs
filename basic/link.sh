# Create links with a source file

# Hard links
sudo ln /source/file/path /to/file/path

# example
sudo link /cc/source/file  /dest/file
# verify with inodes
sudo ls -i /cc/source.file /dest/file
# output inodes numbers will be the same