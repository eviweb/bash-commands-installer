#! /bin/bash
# bash command installer
#

# root directory
DIR=$(dirname $(readlink -f $0))

# script version
if [ -f $DIR/VERSION ]; then
    VERSION=`cat $DIR/VERSION`
else
    VERSION="0.1.0-DEV"
fi

# define a variable content using heredoc
function define()
{
    IFS=$''
    read -d '' ${1} || true; 
}

# Help message
define Usage << "HELP"
 
Usage:
        ./install.sh TYPE [DEST]
        ./install.sh -r TYPE DEST
        ./install.sh -a TYPE SRC
        ./install.sh -d TYPE
        ./install.sh -l

Options:
    -h              display this message
    -V              show version
    -r              remove TYPE from DEST
    -a              register a new TYPE from SRC
    -d              unregister a TYPE
    -l              list available types

TYPE: command type
DEST: destination directory (default: $HOME/TYPE)
SRC : source directory

The installer create symlinks to command files from TYPE in DEST.
You need to run this script as a user having write permissions on DEST.
HELP

# print a header
function header()
{
    clear
    echo ""
    echo "+-----------------------------+"
    echo "|  BASH Commands - Installer  |"
    echo "+-----------------------------+"
}

# print the help message
function usage()
{
    header
    echo -e "$Usage"
}

# display version number
function showVersion()
{
    header
    echo ""
    echo -e "version: $VERSION"
    echo ""
}

# print a message
function msg()
{
    echo -e "$1"
}

# print a message
function error()
{
    msg "ERROR: $1"
    echo ""
    exit 1
}

# list command types
function listTypes()
{
    local dir="$1"
    header
    echo ""
    echo "Available types:"
    echo ""
    for file in $dir/*
    do
        if [ -d $(readlink -f $file) ]; then
            msg "\t - ${file##*/}"
        fi
    done
    echo ""
}

# add command type
function addType()
{
    local type="$1"
    local path="$DIR/$1"
    local src="$2"
    header
    echo ""
    if [ -z "$type" ]; then
        error "TYPE cannot be empty."
    fi
    if [ -e "$path" ]; then
        error "TYPE: $type already exists."
    fi
    if [ ! -d "$src" ]; then
        error "SRC: $src must be a valid directory."
    fi
    ln -s $(readlink -f "$src") "$path"
    msg "TYPE: $type was correctly added."
    echo ""
}

# delete command type
function deleteType()
{
    local type="$1"
    local path="$DIR/$1"
    local realpath=$(readlink -f "$path")
    header
    echo ""
    if [ -z "$type" ]; then
        error "TYPE cannot be empty."
    fi
    if [ "${path/$DIR\//}" != "$1" ]; then
        error "TYPE: $type must be a subdirectory of $DIR."
    fi
    if [ -d "$path" ] || [ -h "$path" ]; then
        rm -rf "$path"
    fi
    msg "TYPE: $type was correctly removed."
    echo ""
}

# check if a file is a command
function isCommand()
{
    local cmd="$1"
    local type="$2"
    local path="$DIR/$type/${cmd##*/}"
    if [ -h "$cmd" ] && ( [ $(readlink -f "$cmd") == "$path" ] || [ $(readlink "$cmd") == "$path" ] ); then
        return 0
    fi
    return 1
}

# install commands
function installCommands()
{
    local type="$1"
    local path="$DIR/$1"
    local dest="$2"
    if [ -z "$dest" ]; then
        dest="$HOME/$1"
    fi
    header
    echo ""
    echo "Install commands of type: $type in $dest"
    echo ""
    if [ -z "$type" ]; then
        error "TYPE cannot be empty."
    fi
    if [ ! -d "$path" ] && [ ! -h "$path" ]; then
        error "TYPE: $type is not valid."
    fi
    if [ ! -d "$dest" ]; then
        error "DEST: $dest must be a valid directory."
    fi
    for file in $path/*
    do
        if [ -f "$file" ] && [ -x "$file" ]; then
            local cmd="${file##*/}"
            local destfile="$dest/$cmd"
            if [ ! -e "$destfile" ]; then
                ln -s "$file" "$destfile"
                if [ $? ]; then
                    msg "Command: $cmd was correctly installed."
                else
                    msg "INFO:\n> Cannot create symlink from $file to $destfile"
                fi
            else
                if isCommand "$destfile" "$type"; then
                    msg "INFO:\n> Command: $cmd is already installed."
                else
                    msg "INFO:\n> Command: $cmd cannot be installed."
                fi
            fi
        fi
    done
    echo ""
    echo "Done."
    echo ""
}

# uninstall commands
function uninstallCommands()
{
    local type="$1"
    local path="$DIR/$1"
    local dest="$2"    
    if [ -z "$dest" ]; then
        dest="$HOME/$1"
    fi
    header
    echo ""
    echo "Uninstall commands from $dest"
    echo ""
    if [ -z "$type" ]; then
        error "TYPE cannot be empty."
    fi
    if [ ! -d "$path" ] && [ ! -h "$path" ]; then
        error "TYPE: $type is not valid."
    fi
    if [ ! -d "$dest" ]; then
        error "DEST: $dest must be a valid directory."
    fi
    for file in $dest/*
    do
        if isCommand "$file" "$type"; then
            local cmd="${file##*/}"
            unlink "$file"
            if [ $? ]; then
                msg "Command: $cmd was correctly uninstalled."
            else
                msg "INFO:\nCommand: $cmd cannot be uninstalled."
            fi
        fi
    done
    echo ""
    echo "Done."
    echo ""
}

# default command line options
OPTIONS=":hVradl"

# get command line options
while getopts $OPTIONS option
do
    case $option in
        r) uninstallCommands $2 $3 && exit 0;;
        a) addType $2 $3 && exit 0;;
        d) deleteType $2 && exit 0;;
        l) listTypes $DIR && exit 0;;
        h) usage && exit 0;;
        V) showVersion && exit 0;;
        *) usage && exit 1;;
    esac
done
shift $(($OPTIND - 1 ))

if [ -z "$1" ]; then
    usage && exit 1
fi

installCommands "$1" "$2"

exit 0


