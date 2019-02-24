#!/bin/sh
# TODO: remove hardcoded options
SANDBOX_DIRECTORY=~/.sandboxes
NAMESPACE=$1

source ./package_manager_configuration.sh

mkdir -p $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman
mkdir -p $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc
cp /etc/pacman.conf $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf

sandboxed_setup() {
fakechroot fakeroot $PACKAGER $UPDATE_ARGS \
    --root $SANDBOX_DIRECTORY/${NAMESPACE}/files\
    --dbpath $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman  \
    --config $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf \
    $BASE_PACKAGES
}

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
set -euo pipefail
(exec bwrap --ro-bind /usr /usr \
      --dir /tmp \
      --dir /var \
      --symlink ../tmp var/tmp \
      --proc /proc \
      --dev /dev \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --symlink usr/lib /lib \
      --symlink usr/lib64 /lib64 \
      --symlink usr/bin /bin \
      --symlink usr/sbin /sbin \
      --chdir / \
      --unshare-all \
      --unshare-net \
      --die-with-parent \
      --dir /run/user/$(id -u) \
      --setenv XDG_RUNTIME_DIR "/run/user/`id -u`" \
      --setenv PS1 "${NAMESPACE}> " \
      /bin/sh) \
}

# sandboxed_install $2
sandboxed_shell
