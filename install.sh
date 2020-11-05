partition()
{
    mount -o remount,rw /media/mmcblk0p1
    touch /media/mmcblk0p1/stage2
    umount -l /dev/mmcblk0p1    # unmount sdcard
    (
    echo d # delete partition
    echo n # Add a new partition
    echo p # Primary partition
    echo 1 # Partition number
    echo 2048 # First sector. hopefully all formats will be the same
    echo +256M
    echo t # set type
    echo c # set to FAT
    echo n # new partition
    echo p # primary partition
    echo 2 # partition 2
    echo 526336 #
    echo   # use remaining disk space
    echo a # make bootable
    echo 1 # partition 1
    echo w # Write changes
    ) | fdisk /dev/mmcblk0
    sleep 1
    reboot
    exit # just in case haha
}


main()
{
    # Setup variables
    VERSION="0.0.5"

    echo "  ___           ___         _        _ _ ";
    echo " / __|_  _ ___ |_ _|_ _  __| |_ __ _| | |";
    echo " \__ \ || (_-<  | || ' \(_-<  _/ _\` | | |";
    echo " |___/\_, /__/ |___|_||_/__/\__\__,_|_|_|";
    echo "      |__/                               ";
    echo
    echo "Version ${VERSION}"
    echo
    echo

    if [ ! -f "/media/mmcblk0p1/stage2" ]; then
        partition
    fi

    
    # prepare for install
    echo "Checking for network connectivity..."
    if nc -zw1 google.com 443; then
        echo "Network is already configured. Skipping..."
    else
        setup-interfaces            # setup network in case the script is running
                                    # from disk
        service networking restart	# restart networking
    fi
    setup-ntp -c chrony             # setup chrony ntp client
    setup-apkrepos -1               # setup CDN repository
    apk add e2fsprogs               # not sure if this is needed
    

    # install alpine
    echo "Remounting boot partition..."
    mount -o remount,rw /media/mmcblk0p1        # remount fat16 partition for
                                                # changes
    
    echo "Formatting partition 2..."
    mkfs.ext4 /dev/mmcblk0p2

    echo "Mounting system partition..."
    mount /dev/mmcblk0p2 /mnt                   # mount system partition

    echo "Installing Alpine Linux..."
    setup-disk -m sys /mnt                      # install alpine to system
                                                # partition
    
    echo "Configuring boot..."
    echo "  [+] rm /mnt/boot/boot"
    rm /mnt/boot/boot                           # remove boot directory symbolic
                                                # link
                                            
    echo "  [+] mv /mnt/boot/* /media/mmcblk0p1/boot/"
    mv /mnt/boot/* /media/mmcblk0p1/boot/       # move boot files to boot
                                                # partition

    echo "  [+] rm -Rf /mnt/boot"
    rm -Rf /mnt/boot                            # remove boot files from system
                                                # partition

    echo "  [+] mkdir /mnt/media/mmcblk0p1"
    mkdir /mnt/media/mmcblk0p1                  # create mount point for boot
                                                # partition

    echo "  [+] ln -s /mnt/media/mmcblk0p1/boot /mnt/boot"
    ln -s /mnt/media/mmcblk0p1/boot /mnt/boot   # create symbolic link of boot
                                                # on system partition

    # Post-installation
    echo -e "/dev/mmcblk0p1\t/media/mmcblk0p1\tvfat\tdefaults\t0 0" >> /mnt/etc/fstab
    echo "`cat /media/mmcblk0p1/cmdline.txt` root=/dev/mmcblk0p2" > /media/mmcblk0p1/cmdline.txt
    reboot
}


main    # wrapped in a function so that the shell script does not begin
        # execution until it is finished downloading when piped through cURL.