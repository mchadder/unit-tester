# Bash-based Unit Testing script

Allows an arbitrary set of shell script tests to be placed in the tests subfolder. The location can be changed in unittests.cfg via the TESTS_FOLDER
parameter

Essentially, this script runs other scripts, simple as that. It just provides a mechanism for auto-running lots of scripts serially and outputting to stdout.
It is intended to be a URL test framework and will validate that curl is installed. This can be disabled in unittests.cfg by unsetting CHECK_CURL_INSTALLED.

Each script is assumed to be largely self-contained and there is no guarantee of script execution order.

All test scripts have to exist in the folder defined by TESTS_FOLDER, defaulting the "tests". The "tests" folder is assumed to be a peer of where unittests.sh is currently residing. The only requirement is that the test script has to end in ".sh", i.e. test1.sh. You can name the test scripts what you want. Disabling a test script should be done by renaming the file, e.g. test.sh.disabled.

You can run a test script singly by specifying the name of the script on the command line. Not specifying a test script will run the full set of defined tests.

Bash brace-expansion is supported.

## Command Line Options

The command line options are:
```
unittests.sh [<test_script_name.sh>]
```
e.g.

```
$ ./unittest.sh test1.sh
$ ./unittest.sh
```

## Example Test Script

A test script can be as simple or as complicated as required. The only requirement is that the success or failure of a given test
in the script is reported back by use of the check_output() function which has the syntax of:
 check_output <Actual Output> <Expected Output> <Comments>
e.g.
 check_output "$CURL_OUTPUT" "$LOOK_FOR" "$OUTPUT_URL"

Here is a simple example of a cURL-based test script that issues curl and checks to see if a string exists in the output.
```
URL="${URL_PREFIX}"
LOOK_FOR="</body>"
CURL_OUTPUT=`curl -K "example-check-string-exists-in-output.cfg" "${URL}" | grep -o "$LOOK_FOR"`
check_output "$CURL_OUTPUT" "$LOOK_FOR" "${URL}"
```

## Example Output

The output is in CSV format for easy importing into spreadsheets or parsing and is of the following format:

"TEST_SCRIPT_NAME","STATUS","ACTUAL_OUTPUT","EXPECTED_OUTPUT","OUTPUT_URL"

```
"test1.sh","FAIL","000","200","http://localhost:8000/Party/1?fields=dob"
"test1.sh","FAIL","000","200","http://localhost:8000/Party/1?fields=lastname"
"test1.sh","FAIL","000","200","http://localhost:8000/Party/1?fields=firstname"
"test1.sh","FAIL","000","200","http://localhost:8000/Party/2?fields=dob"
"test1.sh","FAIL","000","200","http://localhost:8000/Party/2?fields=lastname"
"test1.sh","FAIL","000","200","http://localhost:8000/Party/2?fields=firstname"
```

# BASH Script Mechanisms and Solutions

* [Advanced BASH Scripting Guide](http://www.tldp.org/LDP/abs/html)
* [BASH Brace Expansion](http://wiki.bash-hackers.org/syntax/expansion/brace)
* [Validating JSON from BASH](http://xmodulo.com/validate-json-command-line-linux.html)
* [Validating XML from BASH](https://linux.die.net/man/1/xmllint)

## Example using xmllint

```
echo "<valid_xml/>" | xmllint -
echo "not_valid_xml" | xmllint -
```
