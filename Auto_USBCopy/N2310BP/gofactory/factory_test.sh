#!/bin/sh
extra_N2310(){
     rm -rf /mnt2/gofactory /etc/gofactory
     MNT=/mnt
     mkdir -p /dev/shm/gofactory
     mkdir -p /etc/gofactory
     for x in `cat /proc/scsi/scsi |grep Thecus |awk '{print $3}'|cut -d: -f2`; do
        echo "dev=[$x]"
        USB_PATH=/dev/"$x"1
        mount $USB_PATH $MNT
        [ $? -ne 0 ] && continue
        if [ -d $MNT/gofactory ]; then
                echo "$x has a subdir gofactory, use it"
                cp -a $MNT/gofactory/* /dev/shm/gofactory
    
                cp -a $MNT/gofactory/* /etc/gofactory/
                DEV=$x
                break
        else
                umount $MNT
         fi
     done

     mount --bind /dev/shm/ /mnt2
}


init_env(){
	cd /etc/gofactory
	ARCH=`uname -m`
	[ "$ARCH" = "x86_64" ] && ARCH=i686
	export CHROOT=root
	grep "NON_NAS" /proc/cmdline > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    mv /etc/gofactory/manifest.txt /etc
	fi

}

prepare_chroot(){
	mkdir $CHROOT
	mount -t tmpfs tmpfs $CHROOT
	tar xvfz $MNT/img-$ARCH.tgz -C $CHROOT > /dev/null 
	mount -t proc proc $CHROOT/proc
	mkdir $CHROOT/dev
	mount --bind /dev $CHROOT/dev
}

prepare_test(){
	mkdir -p $CHROOT/etc/gofactory
        grep "NON_NAS" /proc/cmdline > /dev/null 2>&1
        if [ $? -eq 0 ]; then
	     mount --bind /etc/gofactory $CHROOT/etc/gofactory
        else
	     mount --bind /mnt2/gofactory $CHROOT/etc/gofactory
        fi
	# cp -avf /mnt2/gofactory/* $CHROOT/etc/gofactory
	# copy some required version files
	cp -a /etc/manifest.txt /etc/version $CHROOT/etc
}

start_dropbear(){
	mount -t devpts none $CHROOT/dev/pts
	chroot $CHROOT dropbear -r /etc/dropbear/rsa.key -p 1022
}

main(){	
	prepare_chroot
	prepare_test
	start_dropbear
	# Now, run the test 
	chroot $CHROOT sh -x /etc/gofactory/rc.chroot 	
}

clean_up(){
	ps | grep  dropbear |grep -v grep |awk '{print $1}'|xargs kill
        ps | grep  udhcpc |grep -v grep |awk '{print $1}'|xargs kill
        cp -a /etc/gofactory/$CHROOT/dev/shm/* /tmp/

	umount -f $CHROOT/dev/shm
	umount -f $CHROOT/dev/pts
	umount -f $CHROOT/dev
	umount -f $CHROOT/proc 
	umount -f $CHROOT/etc/gofactory
	umount -f $CHROOT
	umount -a

	[ -f /tmp/pass ] && poweroff -f
       #	reboot 
       #	[ $? -ne 0 ] && sync && reboot -f
}

MODEL_name=`awk '/^MODELNAME/{print $2}' /proc/thecus_io`
[ "$MODEL_name" == "N2310" -o "$MODEL_name" == "N4310" ] && extra_N2310
init_env "$@"
main     "$@"
clean_up
