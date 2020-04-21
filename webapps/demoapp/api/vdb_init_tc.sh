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
# Program Name : vdb_init.sh
# Description  : Delphix API calls to change the state of VDB's
# Author       : Alan Bitterman
# Created      : 2017-08-09
# Version      : v1.1
#
# Requirements :
#  1.) curl and jq command line libraries
#  2.) Populate Delphix Engine Connection Information . ./delphix_engine.conf
#  3.) Include ./jqJSON_subroutines.sh
#
# Initeractive Usage: ./vdb_init.sh
#
# Non-Interactive Usage: ./vdb_init.sh [start | stop | enable | disable | status | delete] [VDB_Name] 
#
# Delphix Doc's Reference: 
#    https://docs.delphix.com/docs/reference/web-service-api-guide/api-cookbook-common-tasks-workflows-and-examples/api-cookbook-stop-start-a-vdb
#
#########################################################
#         NO CHANGES REQUIRED BELOW THIS POINT          #
#########################################################

#########################################################
## Subroutines ...

#.  ./jqJSON_subroutines.sh

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

#. ./delphix_engine.conf

#
# Delphix Engine Configuration Parameters ...
# 
#####DMIP="172.16.160.195"             # include port if required, "172.16.160.195:80" or :443
#BaseURL="${1}"		#"http://${DMIP}/resources/json/delphix"
#DMUSER="${2}"           #delphix_admin
#DMPASS="${3}"           #delphix

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
## Get API Version Info ...

APIVAL=$( jqGet_APIVAL )
if [ "${APIVAL}" == "" ]
then
   echo "Error: Delphix Engine API Version Value Unknown ${APIVAL} ..."
#else
#   echo "Delphix Engine API Version: ${APIVAL}"
fi

#########################################################
#
# Command Line Arguments ...
#
# $3 = start | stop | disable | enable | status | delete

ACTION=$3
if [[ "${ACTION}" == "" ]] 
then
   echo "Usage: ./vdb_init.sh [start | stop | enable | disable | status | delete] [VDB_Name] "
   echo "---------------------------------"
   echo "start stop enable disable status delete"
   echo "Please Enter Init Option : "
   read ACTION
   if [ "${ACTION}" == "" ]
   then
      echo "No Operation Provided, Exiting ..."
      exit 1;
   fi
fi
ACTION=$(echo "${ACTION}" | tr '[:upper:]' '[:lower:]')


#########################################################
## Get database container

STATUS=`curl -s -X GET -k ${BaseURL}/database -b "${COOKIE}" -H "${CONTENT_TYPE}"`
RESULTS=$( jqParse "${STATUS}" "status" )
#echo "results> $RESULTS"

SOURCE_SID="$4"
if [[ "${SOURCE_SID}" == "" ]]
then

   VDB_NAMES=`echo "${STATUS}" | jq --raw-output '.result[] | .name '`
   echo "---------------------------------"
   echo "VDB Names: [copy-n-paste]"
   echo "${VDB_NAMES}"
   echo " "

   echo "Please Enter dSource or VDB Name (case sensitive): "
   read SOURCE_SID
   if [ "${SOURCE_SID}" == "" ]
   then
      echo "No dSource or VDB Name Provided, Exiting ..."
      exit 1;
   fi
fi;
export SOURCE_SID

#
# Parse out container reference for name of $SOURCE_SID ...
#
CONTAINER_REFERENCE=`echo ${STATUS} | jq --raw-output '.result[] | select(.name=="'"${SOURCE_SID}"'") | .reference '`
#echo "database container reference: ${CONTAINER_REFERENCE}"
if [[ "${CONTAINER_REFERENCE}" == "" ]]
then
   echo "Error: No container found for ${SOURCE_SID} ${CONTAINER_REFERENCE}, Exiting ..."
   exit 1;
fi

#########################################################
## Get source reference ... 

STATUS=`curl -s -X GET -k ${BaseURL}/source -b "${COOKIE}" -H "${CONTENT_TYPE}"`
RESULTS=$( jqParse "${STATUS}" "status" )
#echo "results> $RESULTS"

#
# Parse out source reference from container reference using jq ...
#
VDB=`echo ${STATUS} | jq --raw-output '.result[] | select(.container=="'"${CONTAINER_REFERENCE}"'") | .reference '`
#echo "source reference: ${VDB}"
if [ "${VDB}" == "" ]
then
  echo "ERROR: unable to find source reference in ... $STATUS"
  echo "Exiting ..."
  exit 1;
fi

#echo "${STATUS}"
#echo " "
VENDOR_SOURCE=`echo ${STATUS} | jq --raw-output '.result[] | select(.container=="'"${CONTAINER_REFERENCE}"'") | .type '`
#echo "vendor source: ${VENDOR_SOURCE}"


#########################################################
#
# start or stop the vdb based on the argument passed to the script
#
case ${ACTION} in
start)
;;
stop)
;;
enable)
;;
disable)
;;
status)
;;
delete)
;;
*)
  echo "Unknown option (start | stop | enable | disable | status | delete): ${ACTION}"
  echo "Exiting ..."
  exit 1;
;;
esac

#
# Execute VDB init Request ...
#
if [ "${ACTION}" == "status" ]
then


   # 
   # Get Source Status ...
   #
   STATUS=`curl -s -X GET -k ${BaseURL}/source/${VDB} -b "${COOKIE}" -H "${CONTENT_TYPE}"`
   #echo ${STATUS} | jq '.'
   #
   # Parse and Display Results ...
   #
   r=`echo ${STATUS} | jq --raw-output '.result.runtime.status'`
   #echo "API: $APIVAL"
   if [[ $APIVAL -lt 190 ]]
   then
      r1=`echo ${STATUS} | jq --raw-output '.result.enabled'`
   else
      r1=`echo ${STATUS} | jq --raw-output '.result.runtime.enabled'`
   fi
   #echo "Runtime Status: ${r}"
   #echo "Enabled: ${r1}"
   #echo "${STATUS}"
   echo "{
  \"RuntimeStatus\": \"${r}\",
  \"Enabled\": \"${r1}\"
}"


else


   # 
   # delete ...
   #
   if [ "${ACTION}" == "delete" ]
   then

      if [[ ${VENDOR_SOURCE} == Oracle* ]]
      then 
         deleteParameters="OracleDeleteParameters"
      else
         deleteParameters="DeleteParameters"
      fi
      #echo "delete parameters type: ${deleteParameters}"

      STATUS=`curl -s -X POST -k --data @- ${BaseURL}/database/${CONTAINER_REFERENCE}/${ACTION} -b "${COOKIE}" -H "${CONTENT_TYPE}" <<EOF
{
    "type": "${deleteParameters}"
}
EOF
`

   else

      # 
      # All other init options; start | stop | enable | disable ...
      #

      # NOTE: dSources require disable *> set type=OracleDisableParameters  SourceDisableParameters  
      #Delphix5240 source 'delphix_demo' disable *> set type=SourceDisableParameters
      #
      #=== POST /resources/json/delphix/source/MSSQL_LINKED_SOURCE-3/disable ===
      #{ "type": "SourceDisableParameters" }
      #
      #=== POST /resources/json/delphix/source/MSSQL_LINKED_SOURCE-3/enable ===
      #{ "type": "SourceEnableParameters" }

      #
      # Submit VDB init change request ...
      #
      STATUS=`curl -s -X POST -k ${BaseURL}/source/${VDB}/${ACTION} -b "${COOKIE}" -H "${CONTENT_TYPE}"`

   fi      # end if delete ...


   #########################################################
   #
   # Get Job Number ...
   #
   #JOB=$( jqParse "${STATUS}" "job" )
   #echo "Job: ${JOB}"
   echo "${STATUS}"

   #jqJobStatus "${JOB}"            # Job Status Function ...

fi     # end if $status

############## E O F ####################################
exit 0;

