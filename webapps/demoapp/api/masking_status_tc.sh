#!/bin/bash
#

# /Users/abitterman/tomcat/webapps/demoapp/api/masking_status_tc.sh "/Users/abitterman/tomcat/webapps/demoapp/jsonfiles/delphix_platforms.json" "Mac2" "332"

#########################################################
## Subroutines ...

#########################################################
## Parameter Initialization ...

##. ./delphix_engine.conf

#
# Delphix Engine Configuration Parameters ...
#
################ DMIP="${1}"    #"172.16.160.195"             # include port if required, "172.16.160.195:80" or :443
CONFIG_FILE="${1}"              #delphix_platforms.json"
CONFIG="${2}"
PARAMS=`cat "${CONFIG_FILE}" | jq ".engines[] | select (.enginename == \"${CONFIG}\") "`
PROTO=`echo "${PARAMS}" | jq --raw-output ".protocol"`
DMIP=`echo "${PARAMS}" | jq --raw-output ".hostname"`
DMUSER=`echo "${PARAMS}" | jq --raw-output ".username"`
DMPASS=`echo "${PARAMS}" | jq --raw-output ".password"`

#
# Check for last character, :8282/dmsuite/
#
LAST="${DMIP:${#DMIP}-1:1}"
LEN2=7
if [[ "${LAST}" == '/' ]]
then
   LEN2=8
fi
LEN=${#DMIP}
DMIP2=${DMIP::$LEN-$LEN2}

#
# Build Masking API URL ...
#
DMURL="${PROTO}://${DMIP2}masking/api"
COOKIE="~/cookies.txt"            # or use /tmp/cookies.txt
COOKIE=`eval echo $COOKIE`
CONTENT_TYPE="Content-Type: application/json"
HEADER_ACCEPT="Accept: application/json"
DELAYTIMESEC=10
DT=`date '+%Y%m%d%H%M%S'`

#########################################################
## Command Line Arguments ...

JOB=${3}
MONITOR=${4}           # YES or other ...
if [[ "${5}" != "" ]]
then
   DELAYTIMESEC=${5}
fi

#########################################################
## Host Operating System Application Variables ...

#
# Set GDT Environment Variable for GNU Date if exists ...
#
which gdate 1> /dev/null 2> /dev/null
if [ $? -eq 0 ]
then
   GDT=gdate
else
   GDT=date
fi
export GDT
#echo "Date Command: ${GDT}"

#
# Operating System ...
#
case "$OSTYPE" in
  solaris*) OS="SOLARIS" ;;
  darwin*) OS="MAC" ;;
  linux*) OS="LINUX" ;;
  bsd*) OS="BSD" ;;
  aix*) OS="AIX" ;;
  msys*) OS="WIN" ;;
  *) echo "unknown: $OSTYPE" ;;
esac
#echo "OSTYPE: $OSTYPE ... OS: $OS"

#########################################################
##         No Changes Required Below This Line         ##
#########################################################

#########################################################
## Begin Process ...

if [[ "${DMURL}" != "" ]] && [[ "${DMUSER}" != "" ]] && [[ "${DMPASS}" != "" ]]
then

#########################################################
## Authentication ...

STATUS=`curl -s -X POST --header "${CONTENT_TYPE}" --header "${HEADER_ACCEPT}" -d "{ \"username\": \"${DMUSER}\", \"password\": \"${DMPASS}\" }" "${DMURL}/login"`
#echo ${STATUS} | jq "."
#echo "${STATUS}"

KEY=`echo "${STATUS}" | jq --raw-output '.Authorization'`
##echo "Authentication Key: ${KEY}"

else
   echo "Error: Missing Connection Parameters ... $CONFIG ... $CONFIG_FILE ... $DMURL .. $DMUSER ... $DMPASS"
fi

#########################################################
## Job Information ...

if [ "${JOB}" != "" ]
then

   if [[ "${MONITOR}" == "YES" ]]
   then
      echo "{ \"results\": ["
   fi

   #######################################################################
   #
   # Execution Status ...
   #
   STATUS=`curl -s -X GET --header "Accept: application/json" --header "Authorization: ${KEY}" "${DMURL}/executions/${JOB}"`
   echo ${STATUS} | jq "."
   EXID=`echo "${STATUS}" | jq --raw-output ".executionId"`
   #echo "Execution Id: ${EXID}"
   JOBSTATUS=`echo "${STATUS}" | jq --raw-output ".status"`
         
   #
   # Monitor ...
   #
   if [[ "${MONITOR}" == "YES" ]]
   then

      while [[ "${JOBSTATUS}" == "RUNNING" ]]
      do
         sleep ${DELAYTIMESEC}     # for long running jobs ..
         STATUS=`curl -s -X GET --header "Accept: application/json" --header "Authorization: ${KEY}" "${DMURL}/executions/${JOB}"`
         echo ",${STATUS}"
         JOBSTATUS=`echo "${STATUS}" | jq --raw-output ".status"`
         #echo "${JOBSTATUS}"

      done

      #########################################################
      ##  Producing final status

      if [ "${JOBSTATUS}" != "SUCCEEDED" ]
      then
         echo "Error: Delphix Job Did not Complete, please check GUI ${JOBSTATUS}"
         #exit 1
      fi

      echo "]}"

   fi      # end if $MONITOR

fi 	# end if $JOB

############## E O F ####################################
exit 0;

