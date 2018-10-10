#!/bin/sh
WORK_PATH="/etc/gofactory"
NOREPORT2S=0
. $WORK_PATH/callserver.sh

#led_light="/img/bin/model/led_light.sh"

MODELNAME=`awk '/^MODELNAME/{print $2}' /proc/thecus_io`
MBTYPE=`awk '/^MBTYPE:/{print $2}' /proc/thecus_io`
MBTYPE_MAJOR=`echo $MBTYPE | head -c 2`

sysdown="/img/bin/sys_halt"

function kill_proc(){
  ps_ether=`ps | grep ether-wake | grep -v 'grep' | awk '{print $1}'`
  kill -9 ${ps_ether}
  
  sh_proc=`ps | grep factory.sh | grep -v 'grep' | awk '{print $1}'`
  if [ "${sh_proc}" != "" ];then
    kill -9 ${sh_proc}
  fi
  
  killall factory.sh
  
  #rm -rf ${WORK_PATH}
}

####################################
#for M3800 & N3200PRO
####################################
function pwbtn_m3800_n3200pro(){
  event="PWR"
  if [ -f /proc/thecus_event ];then
    thecus_event_proc=`ps | grep btn_dispatche | grep -v 'grep' | awk '{print $1}'`
    kill -9 ${thecus_event_proc}
        
    thecus_event_proc=`ps | grep thecus_event | grep -v 'grep' | grep -v 'thecus_eventc' | awk '{print $1}'`
    kill -9 ${thecus_event_proc}

    while [ true ]
    do
      btnPOWER=`cat /proc/thecus_event | grep ON | cut -d" " -f1`
    
      if [ "${btnPOWER}" = "${event}" ];
      then
        echo "Buzzer 1" > /proc/thecus_io
        sleep 5
        kill_proc
        FACTORYKEY=`genrandkey`
        report2server "$FACTORYKEY" "46" "1" "Power Off Machine" "${NOREPORT2S}"
        sleep 1
        #rm -rf ${WORK_PATH}
        echo "power OFF ..."
        #${led_light} Busy 1
        ${sysdown}
      fi
    done
  fi
}

function pwbtn_n2200_n0204(){
  event="1"
  if [ ! -f /tmp/reboot_flag ];then
    echo "0" > /tmp/boot_flag
    if [ ! -d /img/bin ];then
      mkdir /img/bin/
    fi
    touch /img/bin/btn_power
    chmod +x /img/bin/btn_power
    echo '#!/bin/sh
    echo "1" > /tmp/boot_flag' > /img/bin/btn_power
  fi
  
  while [ true ]
  do
    btnPOWER=`cat /tmp/boot_flag`

    if [ "${btnPOWER}" = "${event}" ];
    then
      echo "Buzzer 1" > /proc/thecus_io
      sleep 5
      kill_proc
      FACTORYKEY=`genrandkey`
      report2server "$FACTORYKEY" "46" "1" "Power Off Machine" "${NOREPORT2S}"
      sleep 1
      rm -rf ${WORK_PATH}
      echo "power OFF ..."
      #${led_light} Busy 1
      echo "UF_LED 2" > /proc/thecus_io
      /sbin/ifconfig eth0 0.0.0.0 down
      /sbin/poweroff
    fi
  done
}

function pwbtn_n16000_n12000(){
  cp $WORK_PATH/callserver.sh /tmp/
  FACTORYKEY=`genrandkey`
  echo '#!/bin/sh
echo 0 0 STARTWD > /var/tmp/oled/pipecmd
NOREPORT2S=0
. /tmp/callserver.sh
report2server "'$FACTORYKEY'" "46" "1" "Power Off Machine" "${NOREPORT2S}"'>> /tmp/btn_power
  cat /etc/bin/btn_power >> /tmp/btn_power
  dd if=/dev/zero of=/tmp/bin bs=1K count=7000
  loop=`losetup -f`
  losetup $loop /tmp/bin
  mke2fs -m 0 $loop
  mount -t ext2 $loop /mnt
  cp -rdp /img/bin/* /mnt/
  umount /mnt
  mount $loop /img/bin/
  chmod +x /tmp/btn_power
  cp /tmp/btn_power /img/bin/
}

if [ $MBTYPE_MAJOR -eq 40 ];then
  pwbtn_n2200_n0204
elif [ "${MODELNAME}" == "M3800" ] || [ "${MODELNAME}" == "N3200PRO" ];then
  pwbtn_m3800_n3200pro
else
  pwbtn_n16000_n12000
fi
