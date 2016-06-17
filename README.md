#Arch Install, my way!

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
 * `cd ~`
 * `mkdir cli`
 * `sshfs [MacUserName]@[MacIP]:/CLI cli`
 * `cd cli`
 * `./0.ConfigureInstall.sh`
 
###Simple as Kittehs
 ![Kitteh](http://i296.photobucket.com/albums/mm188/Eternityheart/kitteh.jpg)
