#!/bin/sh
#chkbtn=`grep -n "Copy button: ON" /proc/thecus_io|wc -l`
WORK_PATH="/etc/gofactory"
factory_file="$WORK_PATH/factory_test.sh"

MODELNAME=`awk '/^MODELNAME/{print $2}' /proc/thecus_io`

#MBTYPE=`awk '/^MBTYPE:/{print $2}' /proc/thecus_io`
#led_light="/img/bin/model/led_light.sh"
interval=3

. $WORK_PATH/callserver.sh

####################################
#  Monitor reset btn
####################################
function rst_btn_M3800(){
  event="ON"
  while [ true ]
  do 
    sleep 5
    chkbtn=`awk '/^Soft/{print $3}' /proc/thecus_io`
  
    if [ "${chkbtn}" == "${event}" ];then
      #FACTORYKEY=`genrandkey`
      #report2server "$FACTORYKEY" "43" "3" "Start LED Test"
      #sleep 1
      
      #/img/bin/beep -t 10000 -f  3900 &

      echo "Buzzer 1" > /proc/thecus_io
      sleep ${interval}
      echo "Buzzer 0" > /proc/thecus_io

      #${led_light} Busy 1
      #${led_light} Copy 1
      #${led_light} Fail 1
      #sleep 10
      #${led_light} Busy 0
      #${led_light} Copy 0
      #${led_light} Fail 0
      #report2server "$FACTORYKEY" "43" "4" "End LED Test"
      #sleep 1
    fi
  done
}

function rst_btn_N2200(){
  event="1"
  while [ true ]
  do
    sleep 5
    chkbtn=`awk '/^RESET_BTN/{print $2}' /proc/thecus_io`

    if [ "${chkbtn}" == "${event}" ];then
      #FACTORYKEY=`genrandkey`
      #report2server "$FACTORYKEY" "43" "3" "Start LED Test"
      #sleep 1

      #/img/bin/beep -t 10000 -f  3900 &

      echo "Buzzer 1" > /proc/thecus_io
      sleep ${interval}
      echo "Buzzer 0" > /proc/thecus_io

      #${led_light} Busy 1
      #${led_light} Copy 1
      #${led_light} Fail 1
      #sleep 10
      #${led_light} Busy 0
      #${led_light} Copy 0
      #${led_light} Fail 0
      #report2server "$FACTORYKEY" "43" "4" "End LED Test"
      #sleep 1
    fi
  done
}

case "$MODELNAME" in                                                        
M3800 | N3200PRO)
  rst_btn_M3800
;;                                                                
N2200 | N0204)
  rst_btn_N2200
;;
*)
  # Default is "start", for backwards compatibility with previous   
  # Slackware versions.  This may change to a 'usage' error someday.
  echo "Usage : { M3800 | N3200PRO | N2200 | N0204 }"
esac 
