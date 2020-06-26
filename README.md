# dfsizerep
df size report

Generates and logs to each mountpoint the output of df for that mountpoint

Useful for immediate on-machine quicker-than-finding-metrics view of long term fs trends.

At one line per day, grows approx 1.5k/month - no rotation likely


# Sample output:
root@galactica:~# tail /home/dfsizerep.history
2020-06-24 00:00:00,/dev/md1,3096237,1548598,1240947,56%,galactica:/home
2020-06-25 00:00:00,/dev/md1,3096237,1553799,1235745,56%,galactica:/home
2020-06-26 00:00:00,/dev/md1,3096237,1557712,1231833,56%,galactica:/home


# Usage
Run from cron. Params can be given to specify mountpoints, but not required
0 0     * * * /root/bin/dfsizerep.sh

Default mountpoints are found by joining the output of two commands
* `lsblk -l`
* `findmnt -O rw -l`
thus:
* `join <(lsblk -n -o MOUNTPOINT | sort | uniq) <(findmnt -O rw -l | cut -d ' ' -f 1 | sort | uniq) | grep .`


# Compatibility
Tested and working on
* centos 6, 7
* debian 7 through 10


# Bugs
* failed to work in debian8 on openvz
