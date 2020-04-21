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
# Program Name : provision_sqlserver_tc.sh
# Description  : Delphix API to provision a SQLServer VDB
# Author       : Alan Bitterman
# Created      : 2017-08-09
# Version      : v1.0.0
#
# Requirements :
#  1.) curl and jq command line libraries
#  2.) Populate Delphix Engine Connection Information . ./delphix_engine.conf
#  3.) Include ./jqJSON_subroutines.sh
#  4.) Change values below as required
#
# Usage: ./provision_sqlserver_jq.sh
#
#########################################################
#                   DELPHIX CORP                        #
# Please make changes to the parameters below as req'd! #
#########################################################

#########################################################
## Parameter Initialization ...

###. ./delphix_engine.conf
#
# Delphix Engine Configuration Parameters ...
#
##DMIP="172.16.160.195"             # include port if required, "172.16.160.195:80" or :443
#BaseURL="${1}"         #"http://${DMIP}/resources/json/delphix"
#DMUSER="${2}"          #delphix_admin
#DMPASS="${3}"          #delphix

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

#
# Required for Povisioning Virtual Database ...
#
# /Users/abitterman/tomcat/webapps/demoapp/api/provision_sqlserver_tc.sh "/Users/abitterman/tomcat/webapps/demoapp/jsonfiles/delphix_platforms.json" "Mac" "delphix_demo" "Vdelphix_demo" "Windows_Target" "Windows Host" "MSSQLSERVER"

SOURCE_SID="${3}"   	# "delphixdb"           # dSource name used to get db container reference value

VDB_NAME="${4}"   	# "Vdelphixdb"          # Delphix VDB Name
DELPHIX_GRP="${5}"   	# "Windows_Target"     	# Delphix Engine Group Name

TARGET_ENV="${6}"   	# "Windows Host"        # Target Environment used to get repository reference value 
TARGET_REP="${7}"   	# "MSSQLSERVER"         # Target Environment Repository / Instance name

#########################################################
#         NO CHANGES REQUIRED BELOW THIS POINT          #
#########################################################

#########################################################
## Subroutines ...

###  source ./jqJSON_subroutines.sh

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
## Session and Login ...

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
#if [ "${APIVAL}" == "" ]
#then
#   echo "Error: Delphix Engine API Version Value Unknown ${APIVAL} ..."
#else
#   echo "Delphix Engine API Version: ${APIVAL}"
#fi

#########################################################
## Get or Create Group 

STATUS=`curl -s -X GET -k ${BaseURL}/group -b "${COOKIE}" -H "${CONTENT_TYPE}"`
RESULTS=$( jqParse "${STATUS}" "status" )

#
# Parse out group reference ...
#
GROUP_REFERENCE=`echo ${STATUS} | jq --raw-output '.result[] | select(.name=="'"${DELPHIX_GRP}"'") | .reference '`
#echo "group reference: ${GROUP_REFERENCE}"

#########################################################
## Get database container

STATUS=`curl -s -X GET -k ${BaseURL}/database -b "${COOKIE}" -H "${CONTENT_TYPE}"`
RESULTS=$( jqParse "${STATUS}" "status" )

#
# Parse out container reference for name of $SOURCE_SID ...
#
CONTAINER_REFERENCE=`echo ${STATUS} | jq --raw-output '.result[] | select(.name=="'"${SOURCE_SID}"'") | .reference '`
#echo "container reference: ${CONTAINER_REFERENCE}"

#########################################################
## Get Environment reference  

STATUS=`curl -s -X GET -k ${BaseURL}/environment -b "${COOKIE}" -H "${CONTENT_TYPE}"`
#echo "Environment Status: ${STATUS}"
RESULTS=$( jqParse "${STATUS}" "status" )

# 
# Parse out reference for name of $TARGET_ENV ...
# 
ENV_REFERENCE=`echo ${STATUS} | jq --raw-output '.result[] | select(.name=="'"${TARGET_ENV}"'") | .reference '`
#echo "env reference: ${ENV_REFERENCE}"

#########################################################
## Get Repository reference  

STATUS=`curl -s -X GET -k ${BaseURL}/repository -b "${COOKIE}" -H "${CONTENT_TYPE}"`
#echo "Repository Status: ${STATUS}"
RESULTS=$( jqParse "${STATUS}" "status" )

# 
# Parse out reference for name of $ENV_REFERENCE ...
# 
#duplicate names produce more than one result#
#REP_REFERENCE=`echo ${STATUS} | jq --raw-output '.result[] | select(.instanceName=="'"${TARGET_REP}"'") | .reference '`
#echo "repository reference: ${REP_REFERENCE}"

REP_REFERENCE=`echo ${STATUS} | jq --raw-output '.result[] | select(.environment=="'"${ENV_REFERENCE}"'" and .instanceName=="'"${TARGET_REP}"'") | .reference '`
#echo "Source repository reference: ${REP_REFERENCE}"

#########################################################
## Provision a SQL Server Database ...

json="
{
    \"type\": \"MSSqlProvisionParameters\",
    \"container\": {
        \"type\": \"MSSqlDatabaseContainer\",
        \"name\": \"${VDB_NAME}\",
        \"group\": \"${GROUP_REFERENCE}\",
        \"sourcingPolicy\": {
            \"type\": \"SourcingPolicy\",
            \"loadFromBackup\": false,
            \"logsyncEnabled\": false
        },
        \"validatedSyncMode\": \"TRANSACTION_LOG\"
    },
    \"source\": {
        \"type\": \"MSSqlVirtualSource\","

#
# Version Specific JSON parameter requirement for Illium ...
#
if [ $APIVAL -ge 180 ]
then
json="${json}
        \"allowAutoVDBRestartOnHostReboot\": false,"
fi

json="${json}
        \"operations\": {
            \"type\": \"VirtualSourceOperations\",
            \"configureClone\": [],
            \"postRefresh\": [],
            \"postRollback\": [],
            \"postSnapshot\": [],
            \"preRefresh\": [],
            \"preSnapshot\": []
        }
    },
    \"sourceConfig\": {
        \"type\": \"MSSqlSIConfig\",
        \"linkingEnabled\": false,
        \"repository\": \"${REP_REFERENCE}\",
        \"databaseName\": \"${VDB_NAME}\",
        \"recoveryModel\": \"SIMPLE\",
        \"instance\": {
            \"type\": \"MSSqlInstanceConfig\",
            \"host\": \"${ENV_REFERENCE}\"
        }
    },
    \"timeflowPointParameters\": {
        \"type\": \"TimeflowPointSemantic\",
        \"container\": \"${CONTAINER_REFERENCE}\",
        \"location\": \"LATEST_SNAPSHOT\"
    }
}
"

# echo "JSON: ${json}" 

#echo "Provisioning VDB from Source Database ..."
STATUS=`curl -s -X POST -k --data @- $BaseURL/database/provision -b "${COOKIE}" -H "${CONTENT_TYPE}" <<EOF
${json}
EOF
`

echo "${STATUS}"
#echo "Database: ${STATUS}"
#RESULTS=$( jqParse "${STATUS}" "status" )

#########################################################
#
# Get Job Number ...
#
#JOB=$( jqParse "${STATUS}" "job" )
#echo "Job: ${JOB}"

#jqJobStatus "${JOB}"            # Job Status Function ...

############## E O F ####################################
#echo " "
#echo "Done ..."
#echo " "
exit 0

