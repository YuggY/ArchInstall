#!/bin/bash +x

STEP1="Setup Wifi"
STEP2="Setup Clock"
STEP3="${B}Wipe/Shred ${N}${LOCATION}"

clear; echo -e "
${N}Arch Linux Setup - Part $(basename "$0" .sh)${L}

      Set Mirrorlist (PT)
    ? ${STEP1}
    ? ${STEP2}
    ? ${STEP3}

${N}Press [${B}P${N}] to Proceed${N}"; read -srn1 key
if [ "$key" == 'P' ]; then

    if [ ! -f /etc/pacman.d/mirrorlist.old ]; then
        mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
    fi
    
    cat /etc/pacman.d/mirrorlist.old | grep -A1 Portugal | grep -ev '--' > /etc/pacman.d/mirrorlist
    cat /etc/pacman.d/mirrorlist.old >> /etc/pacman.d/mirrorlist
    
    echo -e "${N}Altered MirrorList file${L}"
    head -n8 /etc/pacman.d/mirrorlist | grep -v '^$\|^\s*\#'

    echo -e "\n${N}Press [${B}w${N}] to ${STEP1}${L}"; read -srn1 key
    if [ "$key" == 'w' ]; then
        wifi-menu
    fi

    echo -e "\n${N}Press [${B}c${N}] to ${STEP2}${L}"; read -srn1 key
    if [ "$key" == 'c' ]; then
        timedatectl set-ntp true
        timedatectl set-timezone Europe/Lisbon
        systemctl start ntpd
        timedatectl status
    fi

    echo -e "${N}\nYour drives are as follows${L}"; lsblk /dev/${LOCATION} -no SIZE,NAME
    echo -e "${N}Press [${B}W${N}] to ${STEP3}${L}"; read -srn1 key
    if [ "$key" == 'W' ]; then
        echo -e "${N}Press [${B}w${N}] for <00000...> or [${B}s${N}] for <Random...> (10x longer)${N}"; read -srn1 key
        if [ "$key" == 'w' ]; then
            shred --verbose -z --iterations=0 /dev/${LOCATION}
        elif [ "$key" == 's' ]; then
            shred --verbose --iterations=1 /dev/${LOCATION}
        fi
        echo -e "${N}\nYour drives are as follows${L}"; lsblk /dev/${LOCATION} -no SIZE,NAME
    fi
fi
echo -e "${N}"
