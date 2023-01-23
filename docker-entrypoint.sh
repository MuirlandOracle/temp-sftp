#!/usr/bin/env sh

usage() {
    echo "Usage: -u USERNAME {-k KEYFILE | -p PASSWORD}" >&2
}

while getopts ':u:kp:' OPTION; do
    case "$OPTION" in
        u)
            user="${OPTARG}"
            ;;
        k)
            method="k"
            ;;
        p)
            method="p"
            password="${OPTARG}"
            ;; 
        ?)
            usage
            exit 1;
            ;;
    esac
done
shift "$(($OPTIND -1))"

if [ -z "${user}" ] || ([ "${method}" != "p" ] && [ "${method}" != "k" ]); then
    usage;
    exit 1;
fi

adduser -s /sbin/nologin -D -h /srv/upload ${user};
addgroup ${user} sftpusers
if [ "${method}" == "p" ]; then
    newPass="${password}"
elif [ ! -f "/keys" ]; then
    echo "No Keys mounted. Please mount an authorized_keys file to /keys" >&2;
    exit 1;
elif ! ssh-keygen -lf "/keys" 2>&1 &>/dev/null; then
    echo "Keyfile is not valid" >&2;
    exit 1;
else
    newPass=$(head /dev/urandom | sha256sum | head -c 32) # Password must be set to *something*
    cp /keys /etc/ssh/authorized_keys
    chown root:root /etc/ssh/authorized_keys
fi
echo "${user}:${newPass}" | chpasswd 2>&1 &>/dev/null; # Create password for user
echo "Starting server..."

/usr/sbin/sshd -D