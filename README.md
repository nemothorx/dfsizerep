# dfsizerep
df size report

Generates and logs to each mountpoint the output of df for that mountpoint

Useful for immediate on-machine quicker-than-finding-metrics view of long term fs trends.

At one line per day, grows approx 1.5k/month - no rotation likely


# Sample output:
root@galactica:~# tail /home/dfsizerep.history 
2021-03-01 00:00:00,/dev/md1,3096237,1850870,938675,69.68,galactica:/home
2021-03-02 00:00:00,/dev/md1,3096237,1851168,938376,69.69,galactica:/home
2021-03-03 00:00:00,/dev/md1,3096237,1851585,937959,69.70,galactica:/home



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
