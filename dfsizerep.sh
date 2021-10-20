#!/bin/bash

# $mounts defaults to a calculated array of all possible fs

# note: uses the --output option to GNU df 
# ...used to defensively give output same as default (as of coreutils 8.30)
# This has not been tested on any alternative df (including historic GNU version)
# ...any alternate df which outputs that same format and silently ignores --output should work

if [ -n "$1" ] ; then
    mounts=$@
    # bad params will fail the `grep` test in the loop below
else
    mounts=$(join <(lsblk -n -o MOUNTPOINT | sort | uniq) <(findmnt -O rw -l | cut -d ' ' -f 1 | sort | uniq) | grep .)
fi

date=$(date +\%F\ \%H:\%M:00)
cachedir=/var/cache/dfsizerep
# TODO: if I'm root then test/create $cachedir

for mount in $mounts ; do
    outfile=${mount}/dfsizerep.history     # default design is write logs
    [ $UID -ne 0 ] && outfile=/dev/stdout   # non-root users get results to stdout
    mount | grep -q " $mount " && ( \
        echo -n "$date," ; df -B1048576 --output=source,size,used,avail,pcent,target $mount \
            | grep -v Filesystem \
            | tr -s ' ' \
            | while read dev size used avail pct Mount ; do
                # two possible percentages
                # they differ because of the hidden reserved blocks. 
                # In real world, I'm finding ACTUAL df gives an answer between these two!
                # df code for future review: https://git.savannah.gnu.org/cgit/coreutils.git/tree/src/df.c
                pctcalc1=$(echo "scale=2;$used*100/$size" | bc)
                pctcalc2=$(echo "scale=2;($size-$avail)*100/$size" | bc)
                echo "$dev,$size,$used,$avail,$pctcalc2,$HOSTNAME:$mount"
            done ) >> $outfile
    if [ $UID -eq 0 ] ; then
        # if we're running as a system job... 
        # (this should perhaps also test for terminal/cronjob too?)
        # ...then save a copy to a cache
        cachefile=$(echo "$outfile" | tr / _)
        # this ensures we have a full history of the dfsizerep per *mountpoint*
        # ...this is distinct from the report on-disk which is per-disk. 
        # ...I mainly use this for /backup/disk which is a mountpoint that rotates between multiple disks. 
        # Primary cache kept within /root for cross-system longevity
        # TODO: test/create /root/$cachedir
        cat $outfile /root/$cachedir/$cachefile | sort -g | uniq > /root/$cachedir/$cachefile.tmp && mv /root/$cachedir/$cachefile.tmp /root/$cachedir/$cachefile
        # ...and copied to system cache for access by other users
        cp -a /root/$cachedir/$cachefile $cachedir/$cachefile
    fi
done

