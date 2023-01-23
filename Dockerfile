FROM alpine:latest
LABEL org.opencontainers.image.authors="AG | MuirlandOracle"


# Add the entrypoint
COPY "docker-entrypoint.sh" .
RUN chmod +x docker-entrypoint.sh

WORKDIR /etc/ssh

# Install OpenSSH Server
RUN apk add --update --no-cache openssh-server &&\
    mkdir /var/run/sshd &&\
    ssh-keygen -A &&\
    sed -i 's/^\(UsePAM\|UseDNS\)/#\1/' sshd_config &&\
    echo "" > /etc/motd

# Configure SFTP Chroot
RUN chmod 755 /srv &&\
    addgroup sftpusers &&\
    sed -i 's/^\(Subsystem\tsftp\).*/\1\tinternal-sftp/' sshd_config &&\
    sed -i 's/^#\(PermitRootLogin\).*/\1 no/' sshd_config &&\
    sed -i 's/^\(AuthorizedKeysFile\t\).*/\1\/etc\/ssh\/authorized_keys/' sshd_config &&\
    echo "" >> sshd_config &&\
    echo "Match Group sftpusers" >> sshd_config &&\
    echo "ChrootDirectory /srv" >> sshd_config &&\
    echo "PermitTunnel no" >> sshd_config &&\
    echo "ForceCommand internal-sftp" >> sshd_config &&\
    echo "AllowTcpForwarding no" >> sshd_config &&\
    echo "X11Forwarding no" >> sshd_config


ENTRYPOINT ["/docker-entrypoint.sh"]