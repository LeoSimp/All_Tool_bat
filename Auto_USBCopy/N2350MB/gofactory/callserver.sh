#!/bin/sh
MECHINE_INFO="/tmp/mechine_info.tmp"
EXCEPTION_TABLE="/tmp/exception.table"
EXCEPTION_TABLE_TMP="/tmp/exception.table.tmp"
WGETPATH="/tmp"
LOGPATH="/logfs/factory"
MODULE_NAME="Factory_v2"
WGET_RETRY=10

MODELNAME=`awk '/^MODELNAME/{print $2}' /proc/thecus_io`
MBTYPE=`awk '/^MBTYPE/{print $2}' /proc/thecus_io`
MBTYPE_MAJOR=`echo $MBTYPE | head -c 2`

if [ $MBTYPE_MAJOR -eq 40 ];then
  WGET="/etc/gofactory/wget"
  HEXDUMP="/etc/gofactory/hexdump"
elif [ $MBTYPE_MAJOR -eq 80 ];then
  WGET="/usr/bin/wget"
  HEXDUMP="/etc/gofactory/hexdump"
else
  WGET="/opt/bin/wget"
  HEXDUMP="hexdump"
fi

if [ ! -f $EXCEPTION_TABLE ];then
  touch $EXCEPTION_TABLE
fi

function genrandkey() {
  filerand="/tmp/randkey.bin"
  filesource="/dev/urandom"
  dd if=$filesource of=$filerand bs=1 count=10
  ${HEXDUMP} $filerand|/usr/bin/head -1|awk '{printf("%s%s%s%s%s",$2,$3,$4,$5,$6)}'
}

function get_basicinfo() {
  MAC1=`awk -F'=' '/MAC1/{print $2}' $MECHINE_INFO`
  MAC2=`awk -F'=' '/MAC2/{print $2}' $MECHINE_INFO`
  MAC3=`awk -F'=' '/MAC3/{print $2}' $MECHINE_INFO`
  WANIP=`awk -F'=' '/WANIP/{print $2}' $MECHINE_INFO`
  FACTORY_VERSION=`awk -F'=' '/FACTORY_VERSION/{print $2}' $MECHINE_INFO`
  FW_VERSION=`awk -F'=' '/FW_VERSION/{print $2}' $MECHINE_INFO`
  BIOS_VERSION=`awk -F'=' '/BIOS_VERSION/{print $2}' $MECHINE_INFO`
  LCD_VERSION=`awk -F'=' '/LCD_VERSION/{print $2}' $MECHINE_INFO`
  MMODEL=`awk -F'=' '/MMODEL/{print $2}' $MECHINE_INFO`
  MPRODUCER=`awk -F'=' '/MPRODUCER/{print $2}' $MECHINE_INFO`
  SERVERIP=`route -n|awk '{if (($8=="eth0")&&($4=="UG")) print $2}'`
  TYPE=`awk -F'=' '/TYPE/{print $2}' $MECHINE_INFO`
  MBTYPE=`awk '/^MBTYPE:/{print $2}' /proc/thecus_io`
  MBTYPE_MAJOR=`echo ${MBTYPE} | tail -c 2`
  D2B=({0,1}{0,1}{0,1}{0,1})  # Convert decimal to 4 bits binary
  if [ ${MBTYPE_MAJOR} -gt "15" ];then
	D2B=({0,1}{0,1}{0,1}{0,1}{0,1})  # Convert decimal to 5 bits binary
  fi
  MBTYPE_ID=`echo ${D2B[${MBTYPE_MAJOR}]}`
}

function addlog2server() {
  SESSIONKEY=$1
  TESTID=$2
  RESULT=$3
  MESSAGE=$4
  
  get_basicinfo
  
  ${WGET} --post-data "cmdsql=INSERT INTO \`testlog\` (\`gettime\`,\`targetmac\`,\`targetip\`,\`sessionkey\`,\`test_version\`,\`fw_version\`,\`model\`,\`producer\`,\`testid\`,\`result\`,\`message\`) VALUES (NOW(),'$MAC1','$WANIP','$SESSIONKEY','$FACTORY_VERSION','$FW_VERSION','$MMODEL','$MPRODUCER','$TESTID','$RESULT','$MESSAGE');&noshow=1" http://$SERVERIP/modules/${MODULE_NAME}/www/sqlcmd.php
}

function maintain_exception() {
  TESTID=$1
  RESULT=$2
  
  strExec="awk '/\\\"$TESTID\\\"/{count=count+1}END{printf(\"%d\",count)}' $EXCEPTION_TABLE"
  ecount=`eval "$strExec"`
  if [ $RESULT -eq 3 ];then
    if [ $ecount -eq 0 ];then
      echo "\"$TESTID\"" >> $EXCEPTION_TABLE
    fi
  fi
  if [ $RESULT -eq 0 ] || [ $RESULT -eq 2 ] || [ $RESULT -eq 4 ];then
    if [ $ecount -gt 0 ];then
      grep -v "\"$TESTID\"" $EXCEPTION_TABLE > $EXCEPTION_TABLE_TMP
      mv $EXCEPTION_TABLE_TMP $EXCEPTION_TABLE
    fi
  fi
    
}

save2log() {
  INMESSAGE=$1
  if [ ! -d $LOGPATH ];then
    mkdir -p $LOGPATH
  fi
  logfile="$LOGPATH/$MAC1.log"
  if [ ! -f $logfile ];then
    rm -r $LOGPATH/*.log
  fi
  echo "$INMESSAGE" >> $logfile
}

function report2server() {
  SESSIONKEY=$1
  TESTID=$2
  RESULT=$3
  MESSAGE=$4
  USBID=`cat /etc/gofactory/USBID`

  get_basicinfo
  MMODEL_enc=`echo $MMODEL | awk '{sub(/\+/,"\%2B");print}'`
  maintain_exception $TESTID $RESULT
  
  exceptionlist=""
  if [ $TESTID -eq 12 ];then
    exceptionlist=`cat $EXCEPTION_TABLE`
    exceptionlist="&exceptionlist=$exceptionlist"
  fi

  if [ ! "$MAC2" = "" ];then
    mac2data="&targetmac2=$MAC2"
  fi
  if [ ! "$MAC3" = "" ];then
    mac3data="&targetmac3=$MAC3"
  fi
  postdata="type=$TYPE&targetmac=$MAC1$mac2data$mac3data&targetip=$WANIP&sessionkey=$SESSIONKEY&test_version=$FACTORY_VERSION&fw_version=$FW_VERSION&bios_version=$BIOS_VERSION&lcd_version=$LCD_VERSION&model=$MMODEL_enc&producer=$MPRODUCER&testid=$TESTID&result=$RESULT&message=$MESSAGE$exceptionlist&usbid=$USBID&mbtypeid=$MBTYPE_ID"
  

  ${WGET} --post-data "$postdata" http://$SERVERIP/modules/${MODULE_NAME}/www/client_report.php -O $WGETPATH/client_report.php
  ret=$?

  for (( j=0;j<${WGET_RETRY};j=j+1 ))
  do
    if [ $ret -eq 0 ];
    then
      break
    else
      ${WGET} --post-data $postdata http://$SERVERIP/modules/${MODULE_NAME}/www/client_report.php -O $WGETPATH/client_report.php
      ret=$?
    fi
  done

}
