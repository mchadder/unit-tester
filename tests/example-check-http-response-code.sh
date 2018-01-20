# Test 1 - Check if the http_code is 200 using brace expansion
# See http://wiki.bash-hackers.org/syntax/expansion/brace for examples
URL_PATTERN="${URL_PREFIX}/Party/{1..2}?fields={dob,lastname,firstname}"

EXPECTED_OUTPUT="200"

# Loop around each possible permutation (via brace expansion)
for OUTPUT_URL in $(eval echo "$URL_PATTERN");
do
  # Run curl against the generated URL
  CURL_OUTPUT=`curl -K "example-check-http-response-code.cfg" "$OUTPUT_URL"`
  # Output the response (CURL_OUTPUT) and whether it matches the expected output
  # The comment for this test is simply the URL
  check_output "$CURL_OUTPUT" "${EXPECTED_OUTPUT}" "$OUTPUT_URL"
done
