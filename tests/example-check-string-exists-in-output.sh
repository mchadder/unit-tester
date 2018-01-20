# Test 3 - Check if the output contains specific HTML
URL="${URL_PREFIX}"
LOOK_FOR="</body>"
CURL_OUTPUT=`curl -K "example-check-string-exists-in-output.cfg" "${URL}" | grep -o "$LOOK_FOR"`
check_output "$CURL_OUTPUT" "$LOOK_FOR" "${URL}"
