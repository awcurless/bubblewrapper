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

    fakechroot fakeroot $PACKAGER \
        --root $SANDBOX_DIRECTORY/${NAMESPACE}/files \
        --dbpath $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman  \
        --config $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf \
        --cachedir ${SANDBOX_DIRECTORY}/${NAMESPACE}/files/var/cache/pacman \
        $UPDATE_ARGS $BASE_PACKAGES
}

sandboxed_install() {
    echo $@
    fakechroot fakeroot $PACKAGER \
        --root $SANDBOX_DIRECTORY/${NAMESPACE}/files \
        --dbpath $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman  \
        --config $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf \
        --cachedir ${SANDBOX_DIRECTORY}/${NAMESPACE}/files/var/cache/pacman \
        $UPDATE_ARGS $@
}

sandboxed_uninstall() {
    fakechroot fakeroot $PACKAGER \
        --root $SANDBOX_DIRECTORY/${NAMESPACE}/files \
        --dbpath $SANDBOX_DIRECTORY/${NAMESPACE}/files/var/lib/pacman  \
        --config $SANDBOX_DIRECTORY/${NAMESPACE}/files/etc/pacman.conf \
        --cachedir ${SANDBOX_DIRECTORY}/${NAMESPACE}/files/var/cache/pacman \
        $UNINSTALL_ARGS $@
}

# Update namespace. If a namespace is not specifed, update everything.
sandboxed_update() {
    if [[ -z ${NAMESPACE} ]]; then
        for namespace in ${SANDBOX_DIRECTORY}/*; do
            name=${namespace##*/}
            NAMESPACE=$name
            sandboxed_install;
        done
    else
        sandboxed_install;
    fi
}

sandboxed_shell() {
    set -euo pipefail
    (exec bwrap --ro-bind /usr /usr \
      --bind ${SANDBOX_DIRECTORY}/${NAMESPACE}/files/ / \
      --dir /tmp \
      --dir /var \
      --ro-bind ${SANDBOX_DIRECTORY}/${NAMESPACE}/files/usr /usr \
      --proc /proc \
      --dev /dev \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --chdir / \
      --unshare-all \
      --hostname ${NAMESPACE} \
      --die-with-parent \
      --dir /run/user/$(id -u) \
      --setenv XDG_RUNTIME_DIR "/run/user/`id -u`" \
      --setenv PS1 "${NAMESPACE}> " \
      /usr/bin/sh) \
}

sandboxed_destroy() {
    rm -rf ${SANDBOX_DIRECTORY}/${NAMESPACE}
}
