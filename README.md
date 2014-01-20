Bash Command Installer
======================
This tool facilitates the installation/uninstallation of custom commands.    

How to install
--------------
> When installed to a directory available from `$PATH`, you can use the command alias `bcinst`    
    
**requirement for all the following installation types**    
clone this repo `git clone https://github.com/eviweb/bash-commands-installer`    
### local use from the cloned repository
simply run the command `bash-commands-installer/install.sh`    
### install in $HOME/bin
run the command `bash-commands-installer/install.sh bin`    
### install in /usr/local/bin
run the command `sudo bash-commands-installer/install.sh bin /usr/local/bin`    
    
    
**For the following topics, I presume you've installed the command alias, so `bcinst` is available.**    

How to uninstall
----------------
### uninstall from $HOME/bin
run the command `bcinst -r bin`    
### uninstall from /usr/local/bin
run the command `sudo bcinst -r bin /usr/local/bin`    

What are commands ?
-------------------
Commands are exectutable files.    

What are types ?
----------------
Types are directories containing commands.    

Conventions
-----------
* _TYPE_: represents the type name    
* _DEST_: represents the command installation directory    
* _SRC_: represents the source directory providing command files    

How to register a new type
--------------------------
run the command `bcinst -a TYPE SRC`    

How to unregister a type
------------------------
run the command `bcinst -d TYPE`    

How to list available types
---------------------------
run the command `bcinst -l`    

How to install commands of a type
---------------------------------
run the command `bcinst TYPE DEST`    

How to uninstall commands of a type
-----------------------------------
run the command `bcinst -r TYPE DEST`    

_Help and version related information are available respecitely by using `-h` and `-V` options._    

License information
-------------------
Please see [License](LICENSE)    

Contribute
----------
Feel free to fork and ask for pull requests.    
