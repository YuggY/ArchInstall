#!/bin/bash +x

STEP1="Unmount and reboot"

clear; echo -e "
${N}Arch Linux Setup - Part $(basename "$0" .sh)${L}

    ?  ${STEP1}
 
${N}MAKE SURE${L} you are running this script ${N}Back on LiveOS${L}\n"

echo -e "\n${N}Press [${B}u${N}] to ${STEP1}${L}"; read -srn1 key
if [ "$key" == 'u' ]; then
    cd ~
    umount -R /mnt/home
    umount -R /mnt/boot
    umount -R /mnt
    swapoff -a
    vgchange -an ${LVM_NAME}
    cryptsetup close crypt
    reboot
fi