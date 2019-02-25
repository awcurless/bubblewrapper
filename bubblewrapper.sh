#!/bin/sh
source ./sandbox_install.sh

bubblewrapper-start() {
    NAMESPACE=$1
    sandboxed_shell
}
