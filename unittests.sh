#!/bin/bash
#
SCRIPT_NAME="Unit-Tester"
SCRIPT_VERSION="0.5"
COPYRIGHT_NOTICE="(c) Chadders 2018"

CONFIG_FILE="unittests.cfg"

function read_config() {
  if [ -f "${CONFIG_FILE}" ]
  then
    while read p; do
      eval export $p
    done <"${CONFIG_FILE}"
  fi
}

function script_head() {
  echo "$SCRIPT_NAME $SCRIPT_VERSION - $COPYRIGHT_NOTICE"
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

# Check to see if curl is installed. Do this using the built-in hash command.
if hash curl 2>/dev/null; then
  read_config

  export -f check_output

    # The tester can run a specific test script via $1
    # Need to check if the script exists first, error otherwise
  if [ "$1" != "" ]
  then
    FULL_FILENAME="${TESTS_FOLDER}/$1"

    if [ -f "${FULL_FILENAME}" ]
    then
      echo ${FILENAME}
      export FILENAME="$1"
      # Run the command in a subshell to ensure that it does not need to know
      # the folder context (e.g. for curl config files etc)
      (cd "$TESTS_FOLDER"; ./"${FILENAME}")
    else
      script_head
      echo "${FULL_FILENAME} does not exist!"
      exit 1
    fi
  else
    cd "${TESTS_FOLDER}"
    for filename in *.sh; do
      #echo "Running ${filename}"
      export FILENAME="${filename}"
      ./"${FILENAME}"
    done
    cd ..
  fi
else
  script_head
  # Output a message because the dependencies are not present.
  echo "Cannot run. This script requires the curl command to execute."

  # Exit with failure
  exit 1
fi

exit 0
