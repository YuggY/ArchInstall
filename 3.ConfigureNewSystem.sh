#!/bin/bash +x

STEP0="Setup root password"
STEP1="Configure language and time"
STEP2="Install basic packages and create user"
STEP3="Patch kernel for decryption"
STEP4="Configure grub"

clear; echo -e "
${N}Arch Linux Setup - Part $(basename "$0" .sh)${L}

       Setup Hostname
       Setup Swappiness
    ?  ${STEP1}
    ?  ${STEP2}
    ?  ${STEP3}
    ?  ${STEP4}

${N}MAKE SURE${L} you are running this script ${N}AFTER CHROOT${L}\n"

echo -e "\n${N}Press [${B}P${N}] to Proceed${N}"; read -srn1 key
if [ "$key" == 'P' ]; then

	echo ${HOSTNAME} > /etc/hostname
    echo -e "${N}Hostname${L}"
    cat /etc/hostname

    echo "vm.swappiness = 5" > /etc/sysctl.d/sysctl.conf
    echo -e "${N}Swappiness${L}"
    cat /etc/sysctl.d/sysctl.conf

    echo -e "\n${N}Press [${B}p${N}] to ${STEP0}${L}"; read -srn1 key
    if [ "$key" == 'p' ]; then
        passwd
    fi
    
    echo -e "\n${N}Press [${B}c${N}] to ${STEP1}${L}"; read -srn1 key
    if [ "$key" == 'c' ]; then
        if [ ! -f /etc/locale.gen.old ]; then
            mv /etc/locale.gen /etc/locale.gen.old
        fi
        echo "KEYMAP=pt-latin1" > /etc/vconsole.conf
        echo "LANG=en_GB.UTF-8" > /etc/locale.conf
        echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
        export LANG=en_GB.UTF-8
        locale-gen

        ln -s /usr/share/zoneinfo/Europe/Lisbon /etc/localtime
        hwclock --systohc --utc
    fi
   
    echo -e "\n${N}Press [${B}i${N}] to ${STEP2}${L}"; read -srn1 key
    if [ "$key" == 'i' ]; then
        pacman -S --noconfirm sudo grub-bios os-prober iw wpa_supplicant dialog git zsh grml-zsh-config
        useradd -m -g users -G wheel,games,power,optical,storage,scanner,lp,audio,video -s /usr/bin/zsh ${USERNAME}
        echo -e "\n${N}Set a password for ${USERNAME}${L}"
        passwd ${USERNAME}
        
        echo -e "\n${N}On nano, press F6, type 'wheel', and uncomment '%wheel ALL=(ALL) ALL'${L}"; read -srn1
        EDITOR=nano visudo
    fi
  
    echo -e "\n${N}Press [${B}p${N}] to ${STEP3}${L}"; read -srn1 key
    if [ "$key" == 'p' ]; then
        if [ ! -f /etc/mkinitcpio.conf.old ]; then
            mv /etc/mkinitcpio.conf /etc/mkinitcpio.conf.old
        fi
        echo -e "\n${N}Generating /.key file${L}"
        dd bs=1024 count=4 if=/dev/urandom of=/.key
        chmod 000 /.key
        chmod -R g-rwx,o-rwx /boot

        echo -e "\n${N}Add /.key file as an internal unlock, do provide crypt password:${L}"
        cryptsetup luksAddKey /dev/${LOCATION}1 /.key
        
        sed -e 's/^HOOKS="base udev autodetect modconf block filesystems keyboard fsck"/HOOKS="base udev autodetect modconf block encrypt lvm2 resume filesystems keyboard fsck"/g' /etc/mkinitcpio.conf.old > /etc/mkinitcpio.mid
        sed -e 's/^FILES=""/FILES="\/.key"/g' /etc/mkinitcpio.mid > /etc/mkinitcpio.conf
        rm /etc/mkinitcpio.mid
        
        cat /etc/mkinitcpio.conf | grep -e "^HOOKS"
        cat /etc/mkinitcpio.conf | grep -e "^FILES"
        echo -e "\n${N}Confirm HOOKS 'encrypt lvm2 resume' and FILES './key' are set${L}"; read -srn1
        mkinitcpio -p linux
    fi


    echo -e "\n${N}Press [${B}m${N}] to ${STEP4}${L}"; read -srn1 key
    if [ "$key" == 'm' ]; then
        if [ ! -f /etc/default/grub.old ]; then
            mv /etc/default/grub /etc/default/grub.old
        fi
        UUID=$(blkid -o value -s UUID /dev/${LOCATION}1)
        sed -e 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=UUID='"${UUID}"':'"${LVM_NAME}"' root=\/dev\/'"${LVM_NAME}"'\/root resume=\/dev\/'"${LVM_NAME}"'\/swap"\nGRUB_ENABLE_CRYPTODISK=y/g' /etc/default/grub.old > /etc/default/grub
        cat /etc/default/grub | grep -e "^GRUB_CMDLINE_LINUX="
        cat /etc/default/grub | grep -e "^GRUB_ENABLE_CRYPTODISK="        
        echo -e "\n${N}Confirm GRUB_CMDLINE_LINUX and GRUB_ENABLE_CRYPTODISK are set${L}\n"; read -srn1
        echo -e "\n${N}Warnings about failure to connect to lvmetad are OK${L}"
        grub-install --recheck /dev/${LOCATION}
        grub-mkconfig -o /boot/grub/grub.cfg
        echo -e "\n${N}Warnings about failure to connect to lvmetad are OK${L}"
    fi

    echo -e "
    ${N}TYPE...${L}
    exit
    ${N}...And Run Part 4 from the LiveOS${L}"
fi
echo -e "${N}"