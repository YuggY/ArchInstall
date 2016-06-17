#!/bin/bash +x

#loadkeys (PT)
loadkeys /usr/share/kbd/keymaps/i386/qwerty/pt-latin1.map.gz

export LOCATION="sda"
export AES_SIZE="256"
export LVM_NAME="lvm"
export LVM_SWAP="100M"
export LVM_ROOT="3G"
export HOSTNAME="dave"
export USERNAME="yuggy"

# Just some presentation color
# 30=grey,31=red,32=green,33=yellow,34=blue,35=purple,36=cyan,37=white
export W='\033[1;33m' #Warning
export B='\033[1;37m' #Bright
export N='\033[0m'    #Normal
export L='\033[1;30m' #Default

export HDD_SIZE=$(lsblk /dev/${LOCATION} -rnso SIZE)
clear; echo -e "
${N}Arch Linux Setup - Part $(basename "$0" .sh)${L}

This will install Arch on a AES${AES_SIZE} encrypted LVM containing
swap(${LVM_SWAP}B), /root(${LVM_ROOT}B) and /home on HDD ${LOCATION}(${HDD_SIZE}B) \033

${N}Your Drives${L}"
  
lsblk -o SIZE,NAME -ne 11,7

echo -e "
${N}Current Config${N}
  ${L}LOCATION=${B}${LOCATION}(${HDD_SIZE}B)${L}
  ${L}AES_SIZE=${AES_SIZE}
  ${L}LVM_NAME=${LVM_NAME}
  ${L}LVM_SWAP=${LVM_SWAP}
  ${L}LVM_ROOT=${LVM_ROOT}
  ${L}HOSTNAME=${HOSTNAME}
  ${L}USERNAME=${USERNAME}
  
${N}YOU MUST check that all the install files suit your needs
"
bash -i

