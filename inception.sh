echo -e "${B}    You are now inside your new install${N}"
    ask "5. Press [[s]] to set Hostname, swappiness, lang, time, and ROOT password"
    if [ "$k" == 's' ]; then
        echo ${HOSTNAME} > /etc/hostname
        echo -e "${N}Hostname${D}"
        cat /etc/hostname

        echo "vm.swappiness = 1" > /etc/sysctl.d/sysctl.conf
        echo -e "${N}Swappiness${D}"
        cat /etc/sysctl.d/sysctl.conf

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
        
        passwd
    fi


    ask "6. Press [[s]] to install basic packages and create user"
    if [ "$k" == 's' ]; then
        pacman -S --noconfirm sudo grub-bios os-prober iw wpa_supplicant dialog git zsh grml-zsh-config

        useradd -m -g users -G wheel,games,power,optical,storage,scanner,lp,audio,video -s /usr/bin/zsh ${USERNAME}
        echo -e "\n${N}Set a password for ${USERNAME}${D}"
        passwd ${USERNAME}

        ask "On nano, press F6, type 'wheel', and uncomment '%wheel ALL=(ALL) ALL'"
        EDITOR=nano visudo
        clear
    fi



    ask "7. Press [[s]] to patch the kernel for decryption"
    if [ "$k" == 's' ]; then
        if [ ! -f /etc/mkinitcpio.conf.old ]; then
            mv /etc/mkinitcpio.conf /etc/mkinitcpio.conf.old
        fi

        echo -e "\n${N}Generating /.key file${D}"
        dd bs=1024 count=4 if=/dev/urandom of=/.key
        chmod 000 /.key
        chmod -R g-rwx,o-rwx /boot

        echo -e "\n${N}Add /.key file as an internal unlock, do provide crypt password:"
        cryptsetup luksAddKey /dev/${LOCATION}1 /.key

        sed -e 's/^HOOKS="base udev autodetect modconf block filesystems keyboard fsck"/HOOKS="base udev autodetect modconf block encrypt lvm2 resume filesystems keyboard fsck"/g' /etc/mkinitcpio.conf.old > /etc/mkinitcpio.mid
        sed -e 's/^FILES=""/FILES="\/.key"/g' /etc/mkinitcpio.mid > /etc/mkinitcpio.conf
        rm /etc/mkinitcpio.mid

        cat /etc/mkinitcpio.conf | grep -e "^HOOKS"
        cat /etc/mkinitcpio.conf | grep -e "^FILES"
        ask "\n${N}Confirm HOOKS='blablabla ${B}encrypt lvm2 resume${N} blablabla'\nConfirm FILES=${B}'./key'${N} are ok${D}"
        mkinitcpio -p linux
    fi



    ask "8. Press [[s]] to configure grub"
    if [ "$k" == 's' ]; then
        if [ ! -f /etc/default/grub.old ]; then
            mv /etc/default/grub /etc/default/grub.old
        fi

        sed -e 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=\/dev\/'"${LOCATION}"'1:'"${LVM_NAME}"' root=\/dev\/'"${LVM_NAME}"'\/root resume=\/dev\/'"${LVM_NAME}"'\/swap cryptkey=rootfs:\/.key"\nGRUB_ENABLE_CRYPTODISK=y/g' /etc/default/grub.old > /etc/default/grub

        cat /etc/default/grub | grep -e "^GRUB_CMDLINE_LINUX="
        cat /etc/default/grub | grep -e "^GRUB_ENABLE_CRYPTODISK="        
        ask "\n${N}Confirm GRUB_CMDLINE_LINUX and GRUB_ENABLE_CRYPTODISK are set${D}\n"

        echo -e "\n${N}Warnings about failure to connect to lvmetad are OK${D}"
        grub-install --recheck /dev/${LOCATION}
        grub-mkconfig -o /boot/grub/grub.cfg
        echo -e "\n${N}Warnings about failure to connect to lvmetad are OK${D}"
    fi