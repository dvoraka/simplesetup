#!/bin/bash
#
# setup.sh
#

# SSH username
USER='user'

# SSH host address
HOST='localhost'

#HOSTS='localhost'

# project directory
PDIR='projectroot'

# virtual env. directory name
VIRT_ENV='test222'

# virtual environments directory
VE_DIR='virtenvs'

C="ssh $USER@$HOST"


function create_remote_virtenv() {
    # create remote virtual environment

    if $C "test -d ~/$VE_DIR"
    then
        echo ' + Remote virtualenv root directory exists.'
    else
        echo ' * Creating remote virtual env. root dir...'
        $C "mkdir ~/$VE_DIR"
        echo ' + Done.'
    fi

    if $C "test -d $VE_DIR/$VIRT_ENV"
    then
        echo ' + Remote virtual env. already exists'
        # ve dir exists
        return 2
    else
        echo ' * Creating remote virtual env...'
        if $C "test -f /usr/bin/virtualenv"
        then
            $C "virtualenv ~/$VE_DIR/$VIRT_ENV"
            echo ' + Done.'
            return $?
        else
            echo ' ! You have to install virtualenv package.'
            # no virtualenv package
            return 3
        fi
    fi

    return 1
}

function create_virtenv() {
    # create local virtual environment

    if [ -d ~/$VE_DIR ]
    then
        echo 'Virtualenv root directory exists.'
        echo ''
    else
        echo 'Creating virtual env. root dir...'
        mkdir ~/$VE_DIR
        echo 'Done.'
        echo ''
    fi
}

function install_hard_deps() {
    # install necessary dependencies

    deps='pip distribute'

    for dep in $deps
    do
        echo pip install --upgrade $dep
    done

    echo ''
}

function activate_ve() {
    # active virtual environment

    echo source ~/$VE_DIR/$VIRT_ENV/bin/activate

    echo 'Done.'
    echo ''
}

function deactivate_ve() {
    # deactivate virtual environment

    deactivate
}

function install_remote_deps() {

    echo ' * Installed packages:'
    $C "\
    source ~/$VE_DIR/$VIRT_ENV/bin/activate;\
    pip freeze"
    echo ' + Done.'

    if $C "test -d ~/$PDIR"
    then
        echo " + Project directory (~/$PDIR) already exists."
        echo -n 'Do you want to continue? [y|n]: '
        read ans
        if [ $ans == 'n' ]
        then
            # project dir already exists
            return 2
        fi
    else
        echo " * Creating new project dir (~/$PDIR)..."
        $C "mkdir ~/$PDIR"
        echo ' + Done.'
    fi

    if [ -f requirements.txt ]
    then
        echo ' * Read dependecies...'
        echo ' + Done.'
        echo ' * Copying requirements.txt to server...'
        scp requirements.txt "$USER@$HOST:~/$PDIR/"
        echo ' + Done.'
    else
        echo " ! You don't have requirements.txt file"
        # no requirements file
        return 3
    fi

    echo ' * Installing dependencies...'
    $C "\
    source ~/$VE_DIR/$VIRT_ENV/bin/activate &&\
    cd $PDIR &&\
    pip install -r requirements.txt\
    "

    if [ $? -eq 0 ]
    then
        echo ' + Done.'
    else
        # install problems
        return 4
    fi
}

function install_remote_hard_deps() {

    echo ' * Installed packages:'
    $C "\
    source ~/$VE_DIR/$VIRT_ENV/bin/activate &&\
    pip freeze\
    "
    echo ' + Done.'
    
    echo ' * Installing necessary dependencies...'
    deps='pip setuptools'
    for dep in $deps
    do
        $C "\
        source ~/$VE_DIR/$VIRT_ENV/bin/activate &&\
        pip install --upgrade $dep\
        "
    done
    echo ' + Done.'
}

function install_deps() {

    if [ -f ./requirements.txt ]
    then
        
        pip install -r ./requirements

    fi
}

function sync_remote() {

    echo ' * Data syncing...'
    if $C "which rsync > /dev/null"
    then
        echo ' + Remote rsync installed.'
    else
        echo ' ! You have to install rsync on remote machine.'
        return 1
    fi

    if [ -f exclude ]
    then
        echo ' + Find exclude file.'
    else
        echo " ! You don't have exclude file."
        echo -n 'Is it OK? [y/n]: '
        read ans
        if [ $ans != 'y' ]
        then
            # no exclude file
            return 2
        else
            touch exclude
        fi
    fi

    rsync -av --exclude-from ./exclude ./* $USER@$HOST:~/$PDIR/

    if [ $? -eq 0 ]
    then
        echo ' + Done.'
    fi
}

function gen_exclude() {

    echo ' * Genereating exclude file...'
    echo '' >> exclude
    find . -name \* | grep -v '/\.' | cut -c 3- >> exclude
    echo ' + Done.'

}

function show_menu() {

    echo '----'
    echo '  1) create remote virtual env'
    echo '  2) install remote hard dependencies'
    echo '  3) create and install remote virtual env'
    echo '  4) install remote dependencies'
    echo '  5) sync remote files'
    echo '  8) generate exclude file'
    echo '  9) quit'
    echo ''

}

function proccess_input() {

    read -p 'Enter choice: ' choice
    #echo $choice

    echo ''
    case $choice in

        1)
            create_remote_virtenv
        ;;
        2)
            install_remote_hard_deps
        ;;
        3)
            create_remote_virtenv
            install_remote_hard_deps
        ;;
        4)
            install_remote_deps
        ;;
        5)
            sync_remote
        ;;
        8)
            gen_exclude
        ;;
        9)
            exit 0
        ;;

        *)
            echo 'neumime'
        ;;
    esac

    echo ''

}

# main loop
function run() {

    while true
    do
        show_menu
        proccess_input
    done

}

# start program
run

exit 0
