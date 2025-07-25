#!/usr/bin/env bash
###########################
# Written by: Ron Negrov AKA RonTheSoul
# Date: 25/07/2025
# Purpose: A setup script to install NFS.
# Version: 0.0.1
###########################

LOGFILE=/var/log/nfs-setup.log
NFSFILE=/srv/nfs/shared
NULL=/dev/null

library=./lib/negbook.sh
mkdir -p ./lib
if [[ ! -f "$library" ]]; then
    curl -s -o "$library" https://raw.githubusercontent.com/ronthesoul/negbook/main/negbook.sh
fi
source "$library"

main() {
    title "📦 NFS Installation Script"

    logv2 info "Script started"
    logv2 info "Log file: $LOGFILE"

    start_task "Checking for root privileges"
    if ! check_root; then
        fail_task "Root check"
        logv2 error "Root check failed"
        exit 1
    fi
    end_task "Root check"
    logv2 success "Root privileges confirmed"

    start_task "Installing nfs-kernel-server"
    if distro_check_and_install nfs-kernel-server > "$NULL" 2>&1; then
        end_task "NFS server installation"
        logv2 success "NFS server was successfully installed"
    else
        fail_task "NFS server installation"
        logv2 error "NFS server installation failed"
        exit 1
    fi

    start_task "Creating shared directory at $NFSFILE"
    mkdir -p "$NFSFILE"
    end_task "Shared directory created"
    logv2 success "Created directory at $NFSFILE"

    start_task "Creating index.html file"
    echo "NFS StorageClass To Container" > "$NFSFILE/index.html"
    end_task "index.html created"
    logv2 success "index.html created at $NFSFILE"

    start_task "Exporting NFS share"
    if ! grep -q "$NFSFILE" /etc/exports; then
     echo "$NFSFILE *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports > /dev/null
    fi   
    sudo exportfs -rav >> "$LOGFILE" 2>&1
    end_task "NFS export configuration applied"
    logv2 success "Exported $NFSFILE to /etc/exports"

    start_task "Restarting nfs-kernel-server"
    sudo systemctl restart nfs-kernel-server >> "$LOGFILE" 2>&1
    end_task "NFS service restarted"
    logv2 success "NFS service restarted"

    logv2 success "✅ NFS setup complete!"
}

main "$@"
rm -rf "$library"
rmdir ./lib 2>/dev/null