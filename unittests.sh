#!/bin/bash
SCRIPT_NAME="Unit-Tester"
SCRIPT_VERSION="0.7"
COPYRIGHT_NOTICE="(c) Chadders 2018"

CONFIG_FILE="unittests.cfg"

function dbg() {
  if [ "$UNITTESTS_DEBUG" == "Y" ]
  then
    echo "$1"
  fi
}

function script_head() {
  echo "$SCRIPT_NAME $SCRIPT_VERSION - $COPYRIGHT_NOTICE"
  if [ "$1" != "" ]
  then
    echo "$1"
  fi
}

function read_config() {
  if [ -f "${CONFIG_FILE}" ]
  then
    while read p; do
      if [[ "$p" != "" && "${p:0:1}" != "#" ]]
      then
        eval export $p
      fi
    done <"${CONFIG_FILE}"
  fi
}

function check_dependencies() {
  if [ "$CHECK_CURL_INSTALLED" == "Y" ]
  then
    if ! hash curl 2>/dev/null; then
      script_head "Cannot execute. curl is not available"
      exit 1
    fi
  fi
}

function check_output() {
  # $1 - Actual Output, $2 - Expected Output, $3 - Test Name, $4 - Elapsed Time, $5 - Comment
  local STATE=""

  if [[ "$1" == "$2" ]]
  then
    if [ "$SHOW_PASSES" == "Y" ]
    then
      STATE="PASS"
    fi
  else
    if [ "$SHOW_FAILURES" == "Y" ]
    then
      STATE="FAIL"
    fi
  fi

  # Output in CSV style
  if [ "$STATE" != "" ]
  then
    echo "\"${FILENAME}\",\"${STATE}\",\"$1\",\"$2\",\"$3\",\"$4\",\"$5\""
  fi
}

# Example call:
# curl_test "${TEST_RESOURCE}/1" "415" "http_code" "application/chadders" "Invalid Accept Header"
function curl_test() {

# TEST_CURL_CONFIG is set by a given test

local TEST_URL_PATTERN="${URL_PREFIX}/$1"
local TEST_CURL_RESPONSE="$2"
local TEST_CURL_WRITEOUT="$3"
local TEST_ACCEPT_HEADER="$4"
local TEST_COMMENT="$5"

if [ "${TEST_CURL_RESPONSE}" == "" ]
then
  TEST_CURL_RESPONSE="200"
fi

if [ "${TEST_CURL_WRITEOUT}" == "" ]
then
  TEST_CURL_WRITEOUT="http_code"
fi

# Loop around each field (via brace expansion)
for TEST_OUTPUT_URL in $(eval echo "${TEST_URL_PATTERN}");
do
  local TEST_START=`date +%s`

  if [ "${TEST_ACCEPT_HEADER}" == "" ]
  then
    TEST_CURL_OUTPUT=`curl -K "${TEST_CURL_CONFIG}" -w "%{${TEST_CURL_WRITEOUT}}" "${TEST_OUTPUT_URL}" -o /dev/null`
  else
    TEST_CURL_OUTPUT=`curl -K "${TEST_CURL_CONFIG}" -H "Accept: ${TEST_ACCEPT_HEADER}" -w "%{${TEST_CURL_WRITEOUT}}" "${TEST_OUTPUT_URL}" -o /dev/null`
  fi

  local TEST_END=`date +%s`
  local TEST_RUNTIME=$((TEST_END-TEST_START))

  check_output "${TEST_CURL_OUTPUT}" "${TEST_CURL_RESPONSE}" "${TEST_OUTPUT_URL}" \
               "${TEST_RUNTIME}" "Test on ${TEST_CURL_WRITEOUT} returns ${TEST_CURL_RESPONSE} ${TEST_COMMENT}"
done
}

dbg "Start Script"
read_config
dbg "Read Config"
check_dependencies
dbg "Checked Dependencies"

export -f check_output
export -f curl_test

# The tester can run a specific test script via $1
# Need to check if the script exists first, error otherwise
dbg "RUNNING: $1"
if [ "$1" != "" ]
then
  FULL_FILENAME="${TESTS_FOLDER}/$1"

  if [ -f "${FULL_FILENAME}" ]
  then
    export FILENAME="$1"
    # Run the command in a subshell to ensure that it does not need to know
    # the folder context (e.g. for curl config files etc)
    dbg "Subshelling: ${FULL_FILENAME}"
    (cd "$TESTS_FOLDER"; ./"${FILENAME}")
  else
    script_head "${FULL_FILENAME} does not exist!"
    exit 1
  fi
else
  for filename in "${TESTS_FOLDER}"/*.sh; do
    export FILENAME=`basename ${filename}`
    dbg "Subshelling $filename"
    (cd "$TESTS_FOLDER"; ./"${FILENAME}")
  done
fi

exit 0
