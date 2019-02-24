#!/bin/sh
# TODO: remove hardcoded options
SANDBOX_DIRECTORY=~/.sandboxes
NAMESPACE=$1

mkdir -p $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman
mkdir -p $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc
cp /etc/pacman.conf $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf

fakechroot fakeroot pacman -Syu \
    --root $SANDBOX_DIRECTORY/${NAMESPACE}/files\
    --dbpath $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman  \
    --config $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf \
    base fakeroot

sandboxed_install() {
    bwrap \
        --bind $SANDBOX_DIRECTORY/${NAMESPACE}/files/ / \
        --ro-bind /etc/resolv.conf /etc/resolv.conf \
        --tmpfs /tmp \
        --proc /proc \
        --dev /dev \
        --chdir /
}

sandboxed_shell() {
(exec bwrap \
    --ro-bind $SANDBOX_DIRECTORY/${NAMESPACE}/files / \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --tmpfs /tmp \
    --proc /proc \
    --dev /dev \
    --die-with-parent \
    --unshare-ipc \
    --unshare-cgroup \
    --chdir / \
    sh)
}

# sandboxed_install $2
sandboxed_shell
