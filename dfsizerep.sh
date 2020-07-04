#!/bin/bash

# $mounts defaults to a calculated array of all possible fs

if [ -n "$1" ] ; then
    mounts=$@
    # bad params will fail the `grep` test in the loop below
else
    mounts=$(join <(lsblk -n -o MOUNTPOINT | sort | uniq) <(findmnt -O rw -l | cut -d ' ' -f 1 | sort | uniq) | grep .)
fi

date=$(date +\%F\ \%H:\%M:00)


for mount in $mounts ; do
    mount | grep -q " $mount " && ( \
        echo -n "$date," ; df -B1048576 $mount \
            | grep -v Filesystem \
            | tr -s ' ' , \
            | sed -e "s^,$mount^,$HOSTNAME:$mount^g"
    ) >> /${mount}/dfsizerep.history
done

