#Arch install, my way!

This will install Arch on a AES256 encrypted LVM
containing swap, /root and /home

##Share Folders between OSX and LiveOS

###On Your Mac

* Terminal
 * `mkdir /CLI`
* Move all these config files to /CLI
 
*  System Preferences
 * Sharing / Remote Login = ON
 * Security / Firewall / SSH = Allow incoming
    
###On your LiveOS

* Terminal
 * `mkdir cli`
 * `sshfs [MacUserName]@[MacIP]:/CLI cli`
 * `cd cli`
 * `./deploy.sh`
 
###Simple as Kittehs
 ![Kitteh](http://i296.photobucket.com/albums/mm188/Eternityheart/kitteh.jpg)
