#!/bin/bash
#
## Subroutines ...

#########################################################
## Parameter Initialization ...

#
# Delphix Engine Configuration Parameters ...
# 
################ DMIP="${1}" 	#"172.16.160.195"             # include port if required, "172.16.160.195:80" or :443
CONFIG_FILE="${1}"  		#delphix_platforms.json"
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

if [[ "${DMURL}" != "" ]] && [[ "${DMUSER}" != "" ]] && [[ "${DMPASS}" != "" ]] 
then

#########################################################
## Authentication ...

STATUS=`curl -s -X POST --header "${CONTENT_TYPE}" --header "${HEADER_ACCEPT}" -d "{ \"username\": \"${DMUSER}\", \"password\": \"${DMPASS}\" }" "${DMURL}/login"`
#echo ${STATUS} | jq "."
echo "${STATUS}"

KEY=`echo "${STATUS}" | jq --raw-output '.Authorization'`
#echo "Authentication Key: ${KEY}"

else
   echo "Error: Missing Connection Parameters ... $CONFIG ... $CONFIG_FILE ... $DMURL .. $DMUSER ... $DMPASS"
fi
exit 0;
