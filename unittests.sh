#!/bin/bash
#
SCRIPT_NAME="Unit-Tester"
SCRIPT_VERSION="0.5"
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
  # $1 - Actual Output, $2 - Expected Output, $3 - Test Name.
  STATE=""
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
    echo "\"${FILENAME}\",\"${STATE}\",\"$1\",\"$2\",\"$3\""
  fi
}

dbg "Start Script"
read_config
dbg "Read Config"
check_dependencies
dbg "Checked Dependencies"

export -f check_output

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
