#!/bin/sh
# TODO: remove hardcoded options
SANDBOX_DIRECTORY=~/.sandboxes

source ./package_manager_configuration.sh

# Setups up a new sandbox with the BASE_PACKAGES and the specified packages
# installed.
sandboxed_setup() {
    mkdir -p $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman
    mkdir -p $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc
    mkdir -p ${SANDBOX_DIRECTORY}/${NAMESPACE}/files/usr/bin
    mkdir -p ${SANDBOX_DIRECTORY}/${NAMESPACE}/files/usr/lib

    cp /etc/pacman.conf $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf
    fakechroot fakeroot $PACKAGER $UPDATE_ARGS \
        --root $SANDBOX_DIRECTORY/${NAMESPACE}/files\
        --dbpath $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman  \
        --config $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf \
        $BASE_PACKAGES $@
}

sandboxed_install() {
    echo $@
    fakechroot fakeroot $PACKAGER $UPDATE_ARGS \
        --root $SANDBOX_DIRECTORY/${NAMESPACE}/files\
        --dbpath $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman  \
        --config $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf \
        $@
}

sandboxed_shell() {
set -euo pipefail
(exec bwrap --ro-bind /usr /usr \
      --dir /tmp \
      --dir /var \
      --symlink ../tmp var/tmp \
      --symlink usr/bin /bin \
      --symlink usr/lib /lib \
      --symlink usr/lib /lib64 \
      --symlink usr/bin /sbin \
      --proc /proc \
      --dev /dev \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --chdir / \
      --unshare-all \
      --die-with-parent \
      --dir /run/user/$(id -u) \
      --setenv XDG_RUNTIME_DIR "/run/user/`id -u`" \
      --setenv PS1 "${NAMESPACE}> " \
      sh) \
}
