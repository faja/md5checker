Script allow to create and check md5 checksums of files.
You can choose which files should be checked by defining:
* file - select files to be checked
* directory - all files in that directory will be checked
* package - all files installed by package will be checked



After creating md5checker.out file, put it on secured website.
Once a day you can run './md5checker.rb check' command,
which will download result file from your website, compare md5 values and let you know if some sums are wrong.   

###Requirements
* ruby 
* gems: colored, mail

###Configuration
Configuration is straight forward.   
Create options:
* 'package-manager' - set it to 'rpm' for RedHat/CentOS, or to 'dpkg' for Debian/Ubuntu
* 'packages' - list of packages
* 'packages-only-bin' - if you want to check only files in *bin* directory set it to 'true'
* 'path' - list of paths
* 'path-only-bin' - if you want to check only files in *bin* directory set it to 'true'
* 'files' - set list of files   

Check options:
* 'notification-from' - 'FROM' email address for notification (comment it out to disable email notification)
* 'notification-to' - 'TO' email address for notification (comment it out to disable email notification)
* 'md5sum-file-url' - url of the result file


###Usage
to create file with md5 checksums:
```
# ./md5checker.rb create
# ./md5checker.rb create -h
```

to check md5 checksums
```
./md5checker.rb check
./md5checker.rb check -h
```
