#!/bin/ksh
# $Id: ports_profiles.sh 1794 2015-02-14 08:35:21Z gburns $

#######################################################
#
# Subroutines ...
#
check_port() {
   CPORT=$1
   RESULTS=""
   let i="0"
   while [ $i -le 10 ]
   do
      let CPORT=${CPORT}+${i}
      RESULTS=`netstat -an | grep ":${CPORT}"`
      RESULTS=`eval echo ${RESULTS}`
      if [ "${RESULTS}" == "" ] 
      then 
         echo ${CPORT}
         return
      fi
      let i=${i}+1
   done
   echo ${CPORT}
   return
}

#######################################################
#
# Main Code ...
#
echo "------------------------------------------------------------"
echo "--------------- Tomcat Ports Configuration  ----------------"
echo "------------------------------------------------------------"
echo "Description: "
echo "Tomcat Ports values configuration"
echo " " 

#
# Variables ...
# 
DT=`date '+%Y%m%d%H%M%S'`
TMP=`pwd`
PINC=1

#
# Get Installation Path ...
#
while true
do
  echo ""
  echo "Please enter the installation path for Tomcat [$TMP]: "
  read TOMCAT_PATH
  if [ "$TOMCAT_PATH" = "" ]
  then
    TOMCAT_PATH=$TMP
  fi
  #
  # Verify that the Path/server.xml exists ... 
  #
  if [ -f "${TOMCAT_PATH}/conf/server.xml" ]
  then
    echo " "
    echo "Backing up server.xml to server.xml_${DT} ..."
    cp "${TOMCAT_PATH}/conf/server.xml" "${TOMCAT_PATH}/conf/server.xml_${DT}"
    # 
    # Restore Original ...
    #
    if [ -f "${TOMCAT_PATH}/conf/server.xml_orig" ]
    then
      echo " "
      echo "Restoring Original server.xml ... "
      cp ${TOMCAT_PATH}/conf/server.xml_orig ${TOMCAT_PATH}/conf/server.xml
    else 
      if [ -f server.xml_orig ]
      then
        cp server.xml_orig ${TOMCAT_PATH}/conf/server.xml_orig
        cp server.xml_orig ${TOMCAT_PATH}/conf/server.xml   
      else
        echo "Error: Missing Original server.xml file(s), please verify default ports manually."
        echo "Exiting ..."
        exit 1
      fi
    fi
    break
  fi
  echo "${TOMCAT_PATH}/conf/server.xml missing, please re-try ..."
done


#
# Default Ports in server.xml_orig ...
# 
PORT1=8005
PORT2=8009
PORT3=8080
PORT4=8443

#
# Check if Default Ports are being used ...
#
PORTS=`netstat -an | grep -E "${PORT1}|${PORT2}|${PORT3}|${PORT4}"`
PORTS=`eval echo $PORTS`
echo " "
echo "Checking Ports via netstat command ..."
echo " "
netstat -an | grep -E "${PORT1}|${PORT2}|${PORT3}|${PORT4}"

# 
# Tomcat Ports ... 
#
if [ "${PORTS}" == "" ]
then
  echo "Default Ports Available ..."
else 
  echo " "
  echo "The Default Ports $PORT1, $PORT2, $PORT3 and $PORT4  may not be available. "
  echo "Please manaully check the output or provide another set of ports to check."
  echo "Incrementing Default Ports by $PINC to try..."
  while true
  do
    echo " "
    let PORT1=${PORT1}+${PINC}
    PORT1=$(check_port ${PORT1})
    echo "Tomcat Shutdown Port [${PORT1}]: "
    read XP
    if [ "${XP}" != "" ]
    then
       PORT1=${XP}
    fi
    let PORT2=${PORT2}+${PINC}
    echo "AJP 1.3 Connector Port [${PORT2}]: "
    read XP 
    if [ "${XP}" != "" ]
    then 
       PORT2=${XP}
    fi 
    let PORT3=${PORT3}+${PINC}
    echo "HTTP Connector Port [${PORT3}]: "
    read XP
    if [ "${XP}" != "" ]
    then
       PORT3=${XP}
    fi
    let PORT4=${PORT4}+${PINC}
    echo "HTTPS Connector Port [${PORT4}]: "
    read XP
    if [ "${XP}" != "" ]
    then
       PORT4=${XP}
    fi
    echo "Perform netstat -an to see if ports are available ..."
    echo " "
    echo "Scanning for \"${PORT1}|${PORT2}|${PORT3}|${PORT4}\" "
    netstat -an | grep -E "${PORT1}|${PORT2}|${PORT3}|${PORT4}"
    echo " "
    echo "Okay to Update server.xml with current values [Y]: "
    read YN
    if [ "$YN" == "" ]
    then 
       YN="Y"
    fi
    if [ "$YN" == "Y" ] || [ "$YN" == "y" ]
    then
      break
    fi
  done
fi

#
# Updating the Tomcat server.xml file with defined ports ...
#
echo " "
echo "Update server.xml ..."
cd ${TOMCAT_PATH}/conf
find . -type f -name server.xml -exec sed -i -e "s/8005/${PORT1}/g; s/8009/${PORT2}/g; s/8080/${PORT3}/g; s/8443/${PORT4}/g;" {} \;
echo "server.xml updated ..."
cd $TMP
echo " "


echo " " 
echo "==============================================================="
echo " "
echo "Tomcat Ports Configuration Completed"
echo " "
echo "Start Tomcat"
echo "------------"
echo "cd ${TOMCAT_PATH}/bin"
echo "./startup.sh"
echo " "
echo "Verify Tomcat is running ..."
echo "----------------------------"
echo "netstat -an | grep ${PORT3}"
echo " "
echo "Verify Tomcat Test Page is working ..."
echo "--------------------------------------"
echo "Open a new web browser window and enter the following test URL ..."
echo "http://127.0.0.1:${PORT3}/xxlpr/"
echo " "
echo " ... or use other available IP Addresses ... "
echo " " 
ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
echo " "
echo " " 
echo "Done ..."
exit 0

