# Temporary SFTP Server

Useful for allowing people to remotely access a contained system for securely transferring files

## Usage
The following command opens the server on TCP port 2222 of the host, mounting an SSH public key and the chroot directory. A user called `testUser` is created.
```
docker run --rm -itdp 2222:22 -v /home/user/.ssh/id_rsa.pub:/keys -v ${PWD}/data:/srv/sftp