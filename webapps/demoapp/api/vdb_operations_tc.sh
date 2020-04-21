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
# Program Name : vdb_operations.sh
# Description  : API calls to perform basic operations on a VDB
# Author       : Alan Bitterman
# Created      : 2017-08-09
# Version      : v1.0.0
#
# Requirements :
#  1.) curl and jq command line libraries
#  2.) Populate Delphix Engine Connection Information . ./delphix_engine.conf
#  3.) Include ./jqJSON_subroutines.sh
#
# Interactive Usage: ./vdb_operations.sh
# 
# Non-Interactive Usage: ./vdb_operations [sync | refresh | rollback] [VDB_Name]
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
   if [[ "${FND}" == "status" ]] && [[ "${RESULTS}" != "OK" ]]
   then
      echo "Error: Invalid Status, please check code ... ${STR}"
      exit 1
   elif [[ "${RESULTS}" == "" ]]
   then 
      echo "Error: No Results ${FND}, please check code ... ${STR}"
      exit 1
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
        "minor": 10,
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

   if [[ "$apival" == "" ]]
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
if [[ "${RESULTS}" != "OK" ]]
then
   echo "Error: Exiting ..."
   exit 1;
fi

#echo "Session and Login Successful ..."

#########################################################
#
# Command Line Arguments ...
#
ACTION=$3
if [[ "${ACTION}" == "" ]] 
then
   echo "Usage: ./vdb_operations [sync | refresh | rollback] [VDB_Name]"
   echo "---------------------------------"
   echo "sync refresh rollback"
   echo "Please Enter Operation: "
   read ACTION
   if [[ "${ACTION}" == "" ]]
   then
      echo "No Operation Provided, Exiting ..."
      exit 1;
   fi
fi;
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
   if [[ "${SOURCE_SID}" == "" ]]
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

#
# Parse out container type ...
#
CONTAINER_TYPE=`echo ${STATUS} | jq --raw-output '.result[] | select(.name=="'"${SOURCE_SID}"'") | .type '`

#########################################################
## Get provision source database container

STATUS=`curl -s -X GET -k ${BaseURL}/database/${CONTAINER_REFERENCE} -b "${COOKIE}" -H "${CONTENT_TYPE}"`
RESULTS=$( jqParse "${STATUS}" "status" )
#echo "results> $RESULTS"

#echo "${STATUS}"
PARENT_SOURCE=`echo ${STATUS} | jq --raw-output '.result | select(.reference=="'"${CONTAINER_REFERENCE}"'") | .provisionContainer '`
#echo "provision source container: ${PARENT_SOURCE}"

#########################################################
#
# start or stop the vdb based on the argument passed to the script
#
if [[ "${CONTAINER_TYPE}" == "OracleDatabaseContainer" ]]
then
   SYNC_TYPE="OracleSyncParameters"
   REFRESH_TYPE="OracleRefreshParameters"
   ROLLBACK_TYPE="OracleRollbackParameters"
fi
if [[ "${CONTAINER_TYPE}" == "MSSqlDatabaseContainer" ]]
then
   # MSSqlExistingMostRecentBackupSyncParameters  
   # MSSqlExistingSpecificBackupSyncParameters
   # MSSqlNewCopyOnlyFullBackupSyncParameters
   SYNC_TYPE="MSSqlExistingMostRecentBackupSyncParameters"
   REFRESH_TYPE="RefreshParameters"
   ROLLBACK_TYPE="RollbackParameters"
fi
case ${ACTION} in
sync)
json="{
   \"type\": \"${SYNC_TYPE}\"
}"
;;
refresh)
json="{
    \"type\": \"${REFRESH_TYPE}\",
    \"timeflowPointParameters\": {
        \"type\": \"TimeflowPointSemantic\",
        \"container\": \"${PARENT_SOURCE}\"
    }
}"
;;
rollback)
json="{
    \"type\": \"${ROLLBACK_TYPE}\",
    \"timeflowPointParameters\": {
        \"type\": \"TimeflowPointSemantic\",
        \"container\": \"${CONTAINER_REFERENCE}\"
    }
}"
;;
*)
  echo "Unknown option (sync | refresh | rollback): ${ACTION}"
  echo "Exiting ..."
  exit 1;
;;
esac

#echo "json> ${json}"

#
# Submit VDB operations request ...
#
STATUS=`curl -s -X POST -k --data @- ${BaseURL}/database/${CONTAINER_REFERENCE}/${ACTION} -b "${COOKIE}" -H "${CONTENT_TYPE}" <<EOF
${json}
EOF
`

#########################################################
#
# Get Job Number ...
#
JOB=$( jqParse "${STATUS}" "job" )
#echo "Job: ${JOB}"
echo "${STATUS}"

#jqJobStatus "${JOB}"            # Job Status Function ...

############## E O F ####################################
exit 0;

