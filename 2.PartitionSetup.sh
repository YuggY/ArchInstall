#!/bin/bash +x

STEP1="Benchmark crypt"
STEP2="Fulldisk crypt(AES${AES_SIZE}) on ${R}/dev/${LOCATION}${C}"
STEP3="Setup LVM volumes on crypt [swap(${LVM_SWAP}B) /root(${LVM_ROOT}B) /home(rest)]"
STEP4="Mount filesystems on ${LVM_NAME}"
STEP5="Install arch base packages"

clear; echo -e "
${N}Arch Linux Setup - Part $(basename "$0" .sh)${L}

    ?  ${STEP1}
    ?  ${STEP2}
    ?  ${STEP3}
    ?  ${STEP4}
    ?  ${STEP5}
"
echo -e "\n${N}Press [${B}P${N}] to Proceed${N}"; read -srn1 key
if [ "$key" == 'P' ]; then

    echo -e "\n${N}Press [${B}b${N}] to ${STEP1}${L}"; read -srn1 key
    if [ "$key" == 'b' ]; then
        cryptsetup benchmark
    fi
    
    echo -e "${N}Your drives are as follows${L}"; lsblk /dev/${LOCATION} -no SIZE,NAME,TYPE
    echo -e "${N}Press [${B}f${N}] to ${STEP2}${L}"; read -srn1 key
    if [ "$key" == 'f' ]; then
        parted -s /dev/${LOCATION} mklabel msdos
        parted -a optimal -s /dev/${LOCATION} mkpart primary 2048s 100%
        cryptsetup --verbose --cipher aes-xts-plain64 --key-size ${AES_SIZE} --hash sha${AES_SIZE} --iter-time 2000 --use-random luksFormat /dev/${LOCATION}1
        cryptsetup luksOpen /dev/${LOCATION}1 crypt
    fi

    echo -e "${N}Your drives are as follows${L}"; lsblk /dev/${LOCATION} -no SIZE,NAME,TYPE
    echo -e "\n${N}Press [${B}s${N}] to ${STEP3}${L}"; read -srn1 key
    if [ "$key" == 's' ]; then
        pvcreate /dev/mapper/crypt
        vgcreate ${LVM_NAME} /dev/mapper/crypt
        lvcreate -L ${LVM_SWAP} ${LVM_NAME} -n swap
        lvcreate -L ${LVM_ROOT} ${LVM_NAME} -n root
        lvcreate -l +100%FREE   ${LVM_NAME} -n home
    fi

    echo -e "${N}Your drives are as follows${L}"; lsblk /dev/${LOCATION} -no SIZE,NAME,TYPE
    echo -e "\n${N}Press [${B}m${N}] to ${STEP4}${L}"; read -srn1 key
    if [ "$key" == 'm' ]; then
        mkswap -L swap /dev/${LVM_NAME}/swap
        mkfs.ext4 -F /dev/${LVM_NAME}/root
        mkfs.ext4 -F /dev/${LVM_NAME}/home
        mount /dev/${LVM_NAME}/root /mnt
        mkdir /mnt/home
        mount /dev/${LVM_NAME}/home /mnt/home
        swapon /dev/${LVM_NAME}/swap
    fi

    echo -e "${N}Your drives are as follows${L}"; lsblk /dev/${LOCATION} -no SIZE,NAME,TYPE,MOUNTPOINT
    echo -e "\n${N}Press [${B}i${N}] to ${STEP5}${L}"; read -srn1 key
    if [ "$key" == 'i' ]; then
        echo "KEYMAP=pt-latin1" > /etc/vconsole.conf
        echo "LANG=en_GB.UTF-8" > /etc/locale.conf
        echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
        export LANG=en_GB.UTF-8
        locale-gen

        pacstrap /mnt
        genfstab -U /mnt >> /mnt/etc/fstab
        cp ./* /mnt/root
    fi

    echo -e "
    ${L}TYPE...${N}
    arch-chroot /mnt
    cd ~
    ${L}...And Run Part 3 from inside your new machine${N}"
fi
echo -e "${N}"