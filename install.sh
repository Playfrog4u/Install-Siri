#!/bin/bash


check_Git () {
    echo "Checking git"
    if ! which git > /dev/null; then
        echo "Installing git"
        sudo apt-get -y install git git-core
        clear
    else
        echo "Git already installed"
    fi
}

check_Easy () {
    echo "Checking easy_install"
    if ! which easy_install > /dev/null; then
        echo "Installing easy_install"
        sudo apt-get -y install python-setuptools
        clear
    else
        echo "easy_install already installed"
    fi
}

check_libspeex () {
  echo "Checking Libspeex"
  if [ "$(locate libspeex)" != "" ]; then 
    echo "Libspeex is already installed, proceeding to next step"
  else 
    echo "Installing Libspeex"
    sudo apt-get -y install libspeex1 
    clear
  fi
}

check_flac () {
  echo "Checking Flac"
  if [ "$(locate flac)" != "" ]; then 
    echo "FLAC is already installed, proceeding to next step"
  else 
    echo "Installing flac"
    sudo apt-get -y install libflac8 
    clear
  fi
}

check_biplist () {
  echo "Checking biplist"
  if [ "$(locate biplist)" != "" ]; then 
    echo "biplist is already installed, proceeding to next step"
  else 
    echo "Installing biplist"
    sudo easy_install biplist
    clear
  fi
}
check_M2Crypto () {
  echo "Checking M2Crypto"
  if [ "$(locate M2Crypto)" != "" ]; then 
    echo "M2Crypto is already installed, proceeding to next step"
  else 
    echo "Installing M2Crypto"
    sudo apt-get install python-M2Crypto
    clear
  fi
}

check_jsonrpclib () {
  echo "Checking jsonrpclib"
  if [ "$(locate jsonrpclib)" != "" ]; then 
    echo "jsonrpclib is already installed, proceeding to next step"
  else 
    echo "Installing jsonrpclib ... "
    sudo easy_install jsonrpclib
    wait
    clear
  fi
}

check_wordnik () {
  echo "Checking wordnik"
  if [ "$(locate wordnik)" != "" ]; then 
    echo "wordnik is already installed, proceeding to next step"
  else 
    echo "Installing wordnik ... "
    sudo easy_install wordnik
    wait
    clear
  fi
}

clone () {
  echo "Cloning SiriServer from Github... "
  sudo git clone git://github.com/Playfrog4u/SiriServer.git
 /SiriServer/
  clear
}

certificate () {
  cd SiriServer/gen_certs/
  chmod +x ./gen_certs.sh
  clear
  IPGUESS=`hostname -I | awk '{print $1}'`
  echo "Time to generate SSL-certs, what is the IP of the Siriserver (this computer) [possibly $IPGUESS]?"
  read IP
  ./gen_certs.sh $IP
  clear
  echo "Certificate generated, now you need to transfer the ca.pem file to your iOS device"
  echo "The easiest way is to email it to yourself and open it on your iOS device"
  echo "The settings page on Spire should now use this url: https://$IP:444"
  read -p "Press [ENTER] to continue"
  clear
}

startup_script () {
  cd SiriServer/
  clear
  sudo python siriServer.py -p 444
}

edit_conf () {
  nano SiriServer/apiKeys.conf
}

edit_db () {
  nano SiriServer/db.py
}

update () {
  cd SiriServer/
  PID=`ps -ef | awk '/[s]iriServer/ { print $2 }'`
  if [ "$PID" != "" ]; then 
    echo "Killing SiriServer..."
    sudo kill $PID
  fi
  echo "Updating ..."
  chmod +x ./updateServer.sh
  sudo ./updateServer.sh
  clear
  echo "Update finished."
}

### PRESENT MENU ###
SiriServer_Menu (){
    
    clear
    echo "
  ###################################################################
  |   #####              #####                                      |
  |  #     # # #####  # #     # ###### #####  #    # ###### #####   |
  |  #       # #    # # #       #      #    # #    # #      #    #  |
  |   #####  # #    # #  #####  #####  #    # #    # #####  #    #  |
  |        # # #####  #       # #      #####  #    # #      #####   |
  |  #     # # #   #  # #     # #      #   #   #  #  #      #   #   |
  |   #####  # #    # #  #####  ###### #    #   ##   ###### #    #  |
  |                                                                 |
  ######## Debian/Ubuntu version ########### script by Playfrog4u ###
     
     "
 
    show_Menu () {

        echo "1. Install SiriServer"
        echo "2. Install plugin dependencies"
        echo "3. Update SiriServer"
        echo "4. Generate certificates"
        echo "5. Edit API's"
        echo "6. Edit Database File"
        echo "7. Start Server on port 444"
        echo 
        echo 
        echo "Q. Quit"

        read SELECT

        case "$SELECT" in

            # Install SiriServer
            1)
                check_Git
                check_Easy
                check_libspeex
                check_flac
                check_biplist
                check_M2Crypto
                echo -e "Would you like to install all the plugin dependencies? [y/n] "
                read answer
                if [ "$answer" == "y" ]; then 
                  check_wordnik
                  check_jsonrpclib
                else
                  echo "Note that when not installing those dependencies, some plugins might not work as expected"
                  read -p "Press [ENTER] to continue"
                  clear
                fi
                clone
                echo -e "Would you like to put your API keys now? [y/n] "
                read answer
                if [ "$answer" == "y" ]; then 
                  edit_conf
                else
                  echo "This can be done later by editing the apiKeys.conf file in your siriServer folder"
                  read -p "Press [ENTER] to continue"
                  clear
                fi                
                certificate
                echo -e "Would you like to have SiriServer start on boot? [y/n] "
                read answer
                if [ "$answer" == "y" ]; then 
                  startup_script
                  START=1
                else
                  START=0
                fi
                echo "You are now finished installing, you should find your installation on SiriServer/"
                echo "To use your siriserver you can use the following command(s):"
                if [ "$START" -eq 1 ]; then
                  echo "sudo service siriserver start"
                  echo "sudo service siriserver stop"
                  echo "sudo service siriserver restart"
                else
                  echo "cd SiriServer"
                  echo "sudo python siriServer.py"
                fi
                ;;
                
            # Install plugin dependencies
            2)
                check_wordnik
                check_jsonrpclib
                ;;

            # Update SiriServer
            3)
                update
                ;;

            # Generate certificate
            4)
                certificate
                ;;

            # Edit apiKeys.conf file
            5)
                edit_conf
                ;;

            # Edit db.py file
            6)
                edit_db
                ;;

            7)
                startup_script
                ;;

            [Qq]) exit ;;

            *)
                echo "Please make a selection (e.g. 1)"
                show_Menu
                ;;
        esac

    # give time to read output from above installprocess before returning to menu
    echo 
    read -sn 1 -p "Press a key to continue"
    SiriServer_Menu
    }
    show_Menu
}

SiriServer_Menu
