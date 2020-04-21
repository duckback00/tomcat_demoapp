#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright (c) 2017 by Delphix. All rights reserved.
#
# Program Name : 
# Description  : 
# Author       : Alan Bitterman
# Created      : 2017-08-09
# Version      : v1.0.0
#
# Requirements :
#  1.) curl and jq command line libraries
#
# Delphix Docs Reference:
#   https://docs.delphix.com/docs/reference/web-service-api-guide
#
#########################################################
#         NO CHANGES REQUIRED BELOW THIS POINT          #
#########################################################

#########################################################
## Subroutines ...

#. ./jqJSON_subroutines.sh

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

## Session and Login ...

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

#. ./delphix_engine.conf

#
# Delphix Engine Configuration Parameters ...
# 
#BaseURL="${1}"  #"http://${DMIP}/resources/json/delphix"
################ DMIP="${1}" 	#"172.16.160.195"             # include port if required, "172.16.160.195:80" or :443
#DMUSER="${2}"	#delphix_admin
#DMPASS="${3}"	# delphix

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
###### BaseURL="http://${DMIP}/resources/json/delphix"
DT=`date '+%Y%m%d%H%M%S'`

if [[ "${BaseURL}" != "" ]] && [[ "${DMUSER}" != "" ]] && [[ "${DMPASS}" != "" ]] 
then

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

#echo "Session and Login Successful ..."

#########################################################
## Get database container

STATUS=`curl -s -X GET -k ${BaseURL}/database -b "${COOKIE}" -H "${CONTENT_TYPE}"`
RESULTS=$( jqParse "${STATUS}" "status" )
echo "${STATUS}" | jq "."

#VDB_NAMES=`echo "${STATUS}" | jq --raw-output '.result[] | .name'`
#echo "${VDB_NAMES}" | jq -R -s -c 'split("\n")'

else 
   echo "Error: Missing Connection Parameters ..."
fi	 # end if DMIP, DMUSER, etc.
exit 0;
