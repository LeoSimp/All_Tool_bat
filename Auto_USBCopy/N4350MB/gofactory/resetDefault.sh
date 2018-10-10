#!/bin/sh 
touch /app/ResetDefault
/bin/sync

if [ "`/img/bin/check_service.sh nvr`" = "1" ];then
    ############################################################### 
    #   record old surveillance icon stat 
    ############################################################### 
    sur_icon=`/opt/bin/sqlite /app/cfg/conf.db "select v from conf where k='surveillance'"` 
    if [ "$sur_icon" != "" ] && [ $sur_icon -eq 1 ]; then 
	echo "1" >/app/sur_icon 
    fi 
fi

#clear the quota limit
/img/bin/rc/rc.user_quota reset_quota

#service stop
/app/bin/service stop
#erase log file
if [ `/bin/mount | /bin/grep sdaaa4 | /bin/grep -c rw` -eq 1 ];then
	/bin/cat /dev/null > /syslog/error
	/bin/cat /dev/null > /syslog/information
	/bin/cat /dev/null > /syslog/warning
	rm /syslog/upgrade.log
	rm -f /syslog/error_dist
else
	/bin/cat /dev/null > /var/log/error
	/bin/cat /dev/null > /var/log/information
	/bin/cat /dev/null > /var/log/warning
	rm -f /raid/sys/error_dist
fi
#delete winbindd temp file
/bin/rm -rf /opt/samba/var/locks/winbindd_idmap.tdb
/bin/rm -rf /opt/samba/var/locks/winbindd_cache.tdb
#delete share folder
#/bin/rm -rf /raid/share*
/bin/rm -rf /raid/tmp/*
rm -rf /etc/mediaserver.conf

cp -f /img/www/shortcut.db /etc/cfg/shortcut.db

#disable user module
if [ -f /raid/data/module/cfg/module.db ];then
        mods=`/opt/bin/sqlite /raid/data/module/cfg/module.db "select name from module where enable = 'Yes'"`
        for mod in $mods
        do
                /raid/data/module/"$mod"/shell/enable.sh "$mod" Yes
        done
        /opt/bin/sqlite /raid/data/module/cfg/module.db "update module set enable = 'No' where enable = 'Yes'"
fi

if [ -f "/syslog/sys_log.db" ];then
    /opt/bin/sqlite /syslog/sys_log.db "delete from sysinfo"
fi

/opt/bin/sqlite /etc/cfg/stackable.db "delete from stackable"
/img/bin/smbdb.sh resetDefault
old_master_id=`ls -la /raid |awk -F\/ '{print $3}' | awk -F'raid' '{print $2}'`
/img/bin/set_masterraid.sh $old_master_id
rm /etc/cfg/quota.db
rm /etc/cfg/backup.db

