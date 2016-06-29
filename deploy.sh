#!/bin/bash +x

#loadkeys (PT)
loadkeys /usr/share/kbd/keymaps/i386/qwerty/pt-latin1.map.gz

##################################################################### Config

export LOCATION="sda"
export AES_SIZE="256"
export LVM_NAME="lvm"
export LVM_SWAP="100M"
export LVM_ROOT="1800M"
export HOSTNAME="dave"
export USERNAME="yuggy"
export COUNTRYN="Portugal"

# Presentation: 30=grey,31=red,32=green,33=yellow,34=blue,35=purple,36=cyan,37=white
export W='\033[1;31m' #Warning
export B='\033[1;37m' #Bold
export N='\033[0m'    #Normal
export D='\033[1;30m' #Dark

##################################################################### Functions

function ask {
    tmp=${1//[[/[${B}}
    out=${tmp//]]/${N}]}
    echo -e "${N}$out${D}"  
    read -srn1 k
}

function ShowDrives {
    echo -e "${B}Your Drives${N}"
    lsblk -o SIZE,NAME,TYPE,MOUNTPOINT -ne 11,7
}

export HDD_SIZE=$(lsblk /dev/${LOCATION} -rnso SIZE)
export LocationWarn="${W}${LOCATION}${N}(${HDD_SIZE}B)"

##################################################################### Start

clear; echo -e "
${B}Arch Linux Setup${N}

  This will install Arch on a AES${AES_SIZE} encrypted LVM containing
  swap(${LVM_SWAP}B), /root(${LVM_ROOT}B) and /home(Free) on disk ${LocationWarn}
"
ShowDrives 
echo -e "
${B}Current Config${N}
  LOCATION=${LocationWarn}
  AES_SIZE=${AES_SIZE}
  LVM_NAME=${LVM_NAME}
  LVM_SWAP=${LVM_SWAP}
  LVM_ROOT=${LVM_ROOT}
  HOSTNAME=${HOSTNAME}
  USERNAME=${USERNAME}
  COUNTRYN=${COUNTRYN}

${B}Edit this file and CHECK that all the install suit your needs!${N}
"



ask "Press [[b]] to benchmark cryto, [[w]] to setup wifi [[P]] to proceed"
if [ "$k" == 'b' ]; then
    cryptsetup benchmark;
elif [ "$k" == 'w' ]; then
    wifi-menu
elif [ "$k" == 'P' ]; then


    ask "1. Press [[W]] to wipe <0000...> or [[S]] to shred <r4Nd0m...> your ${LocationWarn}";
    if [ "$k" == 'W' ]; then
        shred --verbose -z --iterations=0 /dev/${LOCATION}
    elif [ "$k" == 'S' ]; then
        shred --verbose --iterations=1 /dev/${LOCATION}
    fi


    ask "2. Press [[s]] to set mirrors to ${COUNTRYN} and clock";
    if [ "$k" == 's' ]; then
        if [ ! -f /etc/pacman.d/mirrorlist.old ]; then
            mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
        fi

        cat /etc/pacman.d/mirrorlist.old | grep -A1 ${COUNTRYN} | grep -ev '--' > /etc/pacman.d/mirrorlist
        cat /etc/pacman.d/mirrorlist.old >> /etc/pacman.d/mirrorlist

        echo -e "${N}Top 8 mirrors on the MirrorList:${D}"
        head -n8 /etc/pacman.d/mirrorlist | grep -v '^$\|^\s*\#'
        
        timedatectl set-ntp true
        timedatectl set-timezone Europe/Lisbon
        systemctl start ntpd
        timedatectl status
    fi


    ask "3. Press [[s]] to encrypt(AES${AES_SIZE}) ${LocationWarn}, set LVM, and mount"
    if [ "$k" == 's' ]; then
        parted -s /dev/${LOCATION} mklabel msdos
        parted -a optimal -s /dev/${LOCATION} mkpart primary 2048s 100%
        cryptsetup --verbose --cipher aes-xts-plain64 --key-size ${AES_SIZE} --hash sha${AES_SIZE} --iter-time 2000 --use-random luksFormat /dev/${LOCATION}1
        cryptsetup luksOpen /dev/${LOCATION}1 crypt
        
        pvcreate /dev/mapper/crypt
        vgcreate ${LVM_NAME} /dev/mapper/crypt
        lvcreate -L ${LVM_SWAP} ${LVM_NAME} -n swap
        lvcreate -L ${LVM_ROOT} ${LVM_NAME} -n root
        lvcreate -l +100%FREE   ${LVM_NAME} -n home

        mkswap -L swap /dev/${LVM_NAME}/swap
        mkfs.ext4 -F /dev/${LVM_NAME}/root
        mkfs.ext4 -F /dev/${LVM_NAME}/home
        mount /dev/${LVM_NAME}/root /mnt
        mkdir /mnt/home
        mount /dev/${LVM_NAME}/home /mnt/home
        swapon /dev/${LVM_NAME}/swap
        ShowDrives
    fi



    ask "4. Press [[s]] to install arch base packages and chroot"
    if [ "$k" == 's' ]; then
        echo "KEYMAP=pt-latin1" > /etc/vconsole.conf
        echo "LANG=en_GB.UTF-8" > /etc/locale.conf
        echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
        export LANG=en_GB.UTF-8
        locale-gen

        pacstrap /mnt
        genfstab -U /mnt >> /mnt/etc/fstab


        head -n40 deploy.sh > /mnt/root/inception.sh
        cat inception.sh >> /mnt/root/inception.sh
        chmod +x /mnt/root/inception.sh

        arch-chroot /mnt /root/inception.sh
   
        echo -e "    ${B}Welcome back to LiveOS${N}"
    fi



    ask "9. Press [[s]] to unmount and reboot"
    if [ "$k" == 's' ]; then   
        rm /mnt/root/inception.sh    
        umount -R /mnt/home
        umount -R /mnt/boot
        umount -R /mnt
        swapoff -a
        vgchange -an ${LVM_NAME}
        cryptsetup close crypt
        reboot
    fi
fi