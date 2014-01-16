This directory is a new/cleaned up version of all working tests within gemtc.

Please add new tests in their own folder like:

gemtc/tests/sleep

gemtc/tests/matrix_multiply

gemtc/tests/black_sholes

Then within each test dir:
 *.cu - Should be the test file.
 compile*.sh - Should build the test.
 bin/*.exe - Should run the test within the bin dir.

