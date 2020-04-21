#!/bin/bash
#

#########################################################
## Subroutines ...

##. ./jqJSON_subroutines.sh

################################################################
## This code requires the jq Linux/Mac JSON parser program ...
 
jqParse() {
   STR=$1                  # json string
   FND=$2                  # name to find
   RESULTS=""              # returned name value
   RESULTS=`echo $STR | jq --raw-output '.'"$FND"''`
   #echo "Results: ${RESULTS}"
   if [ "${FND}" == "status" ] && [ "${RESULTS}" != "OK" ]
   then
      echo "Error: Invalid Satus, please check code ... ${STR}"
      exit 1;
   elif [ "${RESULTS}" == "" ]
   then 
      echo "Error: No Results ${FND}, please check code ... ${STR}"
      exit 1;
   fi   
   echo "${RESULTS}"
}  

#
# Session and Login ...
#
RestSession() {
  DMUSER=$1               # Username
  DMPASS=$2               # Password
  BaseURL=$3              #
  COOKIE=$4               #
  CONTENT_TYPE=$5         #

   STATUS=`curl -s -X POST -k --data @- $BaseURL/session -c "${COOKIE}" -H "${CONTENT_TYPE}" <<EOF
{
    "type": "APISession",
    "version": {
        "type": "APIVersion",
        "major": 1,
        "minor": 9,
        "micro": 0
    }
}
EOF
`

   #echo "Session: ${STATUS}"
   RESULTS=$( jqParse "${STATUS}" "status" )

   STATUS=`curl -s -X POST -k --data @- $BaseURL/login -b "${COOKIE}" -c "${COOKIE}" -H "${CONTENT_TYPE}" <<EOF
{
    "type": "LoginRequest",
    "username": "${DMUSER}",
    "password": "${DMPASS}"
}
EOF
`

   #echo "Login: ${STATUS}"
   RESULTS=$( jqParse "${STATUS}" "status" )

   echo $RESULTS
}

#########################################################
## Get API Version Info ...

jqGet_APIVAL() {

   #echo "About API "
   STATUS=`curl -s -X GET -k ${BaseURL}/about -b "${COOKIE}" -H "${CONTENT_TYPE}"`
   #echo ${STATUS} | jq "."

   #
   # Get Delphix Engine API Version ...
   #
   major=`echo ${STATUS} | jq --raw-output ".result.apiVersion.major"`
   minor=`echo ${STATUS} | jq --raw-output ".result.apiVersion.minor"`
   micro=`echo ${STATUS} | jq --raw-output ".result.apiVersion.micro"`

   let apival=${major}${minor}${micro}
   #echo "Delphix Engine API Version: ${major}${minor}${micro}"

   if [ "$apival" == "" ]
   then
      echo "Error: Delphix Engine API Version Value Unknown $apival, exiting ..."
      exit 1;
   #else
   #   echo "Delphix Engine API Version: ${major}${minor}${micro}"
   fi
   echo $apival
}

#########################################################
## Parameter Initialization ...

##. ./delphix_engine.conf

#
# Delphix Engine Configuration Parameters ...
# 
###DMIP="172.16.160.195"             # include port if required, "172.16.160.195:80" or :443
#BaseURL="${1}" 		#"http://${DMIP}/resources/json/delphix"
#DMUSER="${2}"          	#delphix_admin
#DMPASS="${3}"          	#delphix

CONFIG_FILE="${1}"              #delphix_platforms.json"
CONFIG="${2}"
PARAMS=`cat "${CONFIG_FILE}" | jq ".engines[] | select (.enginename == \"${CONFIG}\") "`
PROTO=`echo "${PARAMS}" | jq --raw-output ".protocol"`
DMIP=`echo "${PARAMS}" | jq --raw-output ".hostname"`
DMUSER=`echo "${PARAMS}" | jq --raw-output ".username"`
DMPASS=`echo "${PARAMS}" | jq --raw-output ".password"`

BaseURL="${PROTO}://${DMIP}/resources/json/delphix"


COOKIE="~/cookies.txt"            # or use /tmp/cookies.txt 
COOKIE=`eval echo $COOKIE`
CONTENT_TYPE="Content-Type: application/json"
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
## Authentication ...

#echo "Authenticating on ${BaseURL}"

RESULTS=$( RestSession "${DMUSER}" "${DMPASS}" "${BaseURL}" "${COOKIE}" "${CONTENT_TYPE}" )
#echo "Results: ${RESULTS}"
if [ "${RESULTS}" != "OK" ]
then
   echo "Error: Exiting ..."
   exit 1;
fi

#########################################################
## Job Information ...

if [ "${JOB}" != "" ]
then

JOB_STATUS=`curl -s -X GET -k ${BaseURL}/job/${JOB} -b "${COOKIE}" -H "${CONTENT_TYPE}"`
RESULTS=$( jqParse "${JOB_STATUS}" "status" )
#echo "json> $JOB_STATUS"
#echo "${JOB_STATUS}" | jq "."

#########################################################
#
# Get Job State from Results, loop until not RUNNING  ...
#
JOBSTATE=$( jqParse "${JOB_STATUS}" "result.jobState" )
PERCENTCOMPLETE=$( jqParse "${JOB_STATUS}" "result.percentComplete" )
#echo "Current status as of" $(date) ": ${JOBSTATE} ${PERCENTCOMPLETE}% Completed"
STARTTIME=$( jqParse "${JOB_STATUS}" "result.startTime" )
UPDATETIME=$( jqParse "${JOB_STATUS}" "result.updateTime" )
#
# Format Start/End Timestamps ...
#
str3=${STARTTIME:0:19}
str3=${str3//T/ }
str4=${UPDATETIME:0:19}
str4=${str4//T/ }
#
# Compute Timestamp Difference ...
#
if [[ "${OS}" == "MAC" ]]
then
   secs=$(((`date -jf "%Y-%m-%d %H:%M:%S" "${str4}" +%s` - `date -jf "%Y-%m-%d %H:%M:%S" "${str3}" +%s`)))
else
secs=$((( $(${GDT} --date="${str4}" +%s) - $(${GDT} --date="${str3}" +%s) )))
fi
MINS=$(echo "scale=2; ( $secs )/(60) " | bc)
if [[ "${MONITOR}" == "YES" ]]
then
   echo "{ \"results\": ["
fi

#
# Individual Job Request returns a single JSON object ...
#
echo "{ 
  \"job\": \"${JOB}\",
  \"startTime\": \"${STARTTIME}\",
  \"updateTime\": \"${UPDATETIME}\",
  \"durationTimeSecs\": \"${secs}\",
  \"durationTimeMins\": \"${MINS}\",
  \"JobState\": \"${JOBSTATE}\",
  \"PercentComplete\": \"${PERCENTCOMPLETE}\"
}"

#
# Monitor ...
#
if [[ "${MONITOR}" == "YES" ]]
then
   while [ "${JOBSTATE}" == "RUNNING" ]
   do
      sleep ${DELAYTIMESEC}
      JOB_STATUS=`curl -s -X GET -k ${BaseURL}/job/${JOB} -b "${COOKIE}" -H "${CONTENT_TYPE}"`
      JOBSTATE=$( jqParse "${JOB_STATUS}" "result.jobState" )
      PERCENTCOMPLETE=$( jqParse "${JOB_STATUS}" "result.percentComplete" )
      #echo "Current status as of" $(date) ": ${JOBSTATE} ${PERCENTCOMPLETE}% Completed"
      STARTTIME=$( jqParse "${JOB_STATUS}" "result.startTime" )
      UPDATETIME=$( jqParse "${JOB_STATUS}" "result.updateTime" )
      #
      # Format Start/End Timestamps ...
      #
      str3=${STARTTIME:0:19}
      str3=${str3//T/ }
      str4=${UPDATETIME:0:19}
      str4=${str4//T/ }
      #
      # Compute Timestamp Difference ...
      #
      if [[ "${OS}" == "MAC" ]]
      then
         secs=$(((`date -jf "%Y-%m-%d %H:%M:%S" "${str4}" +%s` - `date -jf "%Y-%m-%d %H:%M:%S" "${str3}" +%s`)))
      else
         secs=$((( $(${GDT} --date="${str4}" +%s) - $(${GDT} --date="${str3}" +%s) )))
      fi
      MINS=$(echo "scale=2; ( $secs )/(60) " | bc)
      echo ",{
  \"job\": \"${JOB}\",
  \"startTime\": \"${STARTTIME}\",
  \"updateTime\": \"${UPDATETIME}\",
  \"durationTimeSecs\": \"${secs}\",
  \"durationTimeMins\": \"${MINS}\",
  \"JobState\": \"${JOBSTATE}\",
  \"PercentComplete\": \"${PERCENTCOMPLETE}\"
}"
   done

   #########################################################
   ##  Producing final status

   if [ "${JOBSTATE}" != "COMPLETED" ]
   then
      echo "Error: Delphix Job Did not Complete, please check GUI ${JOB_STATUS}"
      #exit 1
   fi

   echo "]}"

fi      # end if $MONITOR

fi 	# end if $JOB

############## E O F ####################################
exit 0;

