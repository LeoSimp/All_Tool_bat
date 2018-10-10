#!/bin/sh
###################################
### For Factory Test With Server 
###################################
## Must use folder gofactory

## Get IP from Factory Server
VERSION=2.0.1
WORKPATH="/etc/gofactory"
TMPPATH="/tmp"
FUDHCP="fudhcp_script.sh"
DWANIP="172.168.1.100"
DLANIP="172.168.2.254"
FSCRIPT="factory.sh"
FSCRIPTURL="factory_script.php"
MODEL="SWRD2_PCBA"
TYPE="PCBA"
TRYTIME=20
MODULE_NAME="Factory_v2"

FAIL=0
DHCPLOG="/tmp/getdhcp"
DHCPRETRY=10
sleep_sec=5

MODELNAME=`awk '/^MODELNAME/{print $2}' /proc/thecus_io`
MBTYPE=`awk '/^MBTYPE/{print $2}' /proc/thecus_io`
MBTYPE_MAJOR=`echo $MBTYPE | head -c 2`

if [ $MBTYPE_MAJOR -eq 40 ];then
  WGET="${WORKPATH}/wget"
elif [ $MBTYPE_MAJOR -eq 80 ];then
  WGET="/usr/bin/wget"
else
  WGET="/opt/bin/wget"
fi

MAX_TRAY=`awk '/^MAX_TRAY/{print $2}' /proc/thecus_io`

i=0
while [ "$i" != "${MAX_TRAY}" ]
do
  i=$(($i+1))
  sleep 1
  echo "S_LED ${i} 2" > /proc/thecus_io
done

sleep 1
echo "U_LED 2" > /proc/thecus_io
sleep 1
echo "UF_LED 2" > /proc/thecus_io

##Check wheather get DHCP from Factory Server
chkudhcp() {
	while [ ! -f ${DHCPLOG} ] && [ ${DHCPRETRY} -gt 0 ]
	do
		sleep ${sleep_sec}
		DHCPRETRY=`expr ${DHCPRETRY} - 1`
	done
	if [ ! -f "${DHCPLOG}" ];
	then
	  echo "set default ip"
	  /sbin/ifconfig eth0 up
	  /sbin/ifconfig eth0 $DWANIP netmask 255.255.255.0 broadcast +
	  dhcp_pid=`/bin/ps | grep "/sbin/udhcpc -s $WORKPATH/$FUDHCP" | grep -v grep | awk -F' ' '{print $1}'`
	  kill -9 ${dhcp_pid}
	  FAIL=1
	fi
}

remove_workpath(){
	rm -rf ${WORKPATH}
	exit
}


if [ -f "$WORKPATH/$FUDHCP" ];then
	sleep 10
	/sbin/ifconfig eth0 up
	/sbin/ifconfig eth0 mtu 1500
	/sbin/udhcpc -s $WORKPATH/$FUDHCP -b -h `hostname` -i eth0 > /dev/null 2>&1
	chkudhcp
fi

if [ $FAIL -eq 1 ];then
	remove_workpath
	sleep 5
	exit
fi

## Get Factory Server IP
SERVERIP=`route -n|awk '{if (($8=="eth0")&&($4=="UG")) print $2}'`
if [ "$SERVERIP" == "" ];then
	remove_workpath
	sleep 5
	exit
fi

## Get Factory Script from Factory Server
##Retry 20 time
GETTIME=0
	
${WGET} http://$SERVERIP/modules/${MODULE_NAME}/www/$FSCRIPTURL?model=${MODEL}\&type=${TYPE} -O $TMPPATH/$FSCRIPT
    
result=$?
script_size=`ls -al $TMPPATH/$FSCRIPT | awk '{print $5}'`
while [ ! $result -eq 0 ] && [ $TRYTIME -gt 0 ];do
	sleep 1
	TRYTIME=$[TRYTIME-1]
	GETTIME=$[GETTIME+1]
	echo "get script time [$GETTIME]" > /tmp/factory_gettime.log
	${WGET} http://$SERVERIP/modules/${MODULE_NAME}/www/$FSCRIPTURL?model=${MODEL}\&type=${TYPE} -O $TMPPATH/$FSCRIPT
	result=$?
done

if [ ! $result -eq 0 ] && [ ! $TRYTIME -gt 0 ];then
	remove_workpath
	sleep 3
	exit
fi

if [ $result -eq 0 ] && [ $script_size -le 1000 ];
then
	remove_workpath
	sleep 3
	exit
fi

chmod +x $TMPPATH/$FSCRIPT

if [ `find / -name bash | wc -l` -eq 0 ];then
  rm -rf /tmp/bash*

  ${WGET} http://$SERVERIP/modules/${MODULE_NAME}/www/factory/${MODEL}/get_bash.php?model=${MODEL}\&type=${TYPE}\&modelname=${MODELNAME} -O $TMPPATH/bash.tar

  mkdir /tmp/bash
  tar xzvpf $TMPPATH/bash.tar -C /tmp/bash
  sleep 3
  if [ -f "/tmp/bash/bash" ];then
    rm /bin/bash
    ln -sf $TMPPATH/bash/bash /bin/bash

    if [ $MBTYPE_MAJOR -eq 40 ];then
      ln -sf $TMPPATH/bash/libintl.so.8 /lib/libintl.so.8
      ln -sf $TMPPATH/bash/libncurses.so.5 /lib/libncurses.so.5
    fi
  fi
fi

cd /tmp/
##Running Factory Script
bash -x $TMPPATH/$FSCRIPT > /tmp/factory.log 2>&1

i=0
while [ "$i" != "${MAX_TRAY}" ]
do
  i=$(($i+1))
  echo "S_LED ${i} 0" > /proc/thecus_io
done
