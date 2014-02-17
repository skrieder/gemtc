@dispatch=WORKER
  (int sum) sleep_wrapper(int i1) "sleep" "0.0"
  [ "set <<sum>> [ sleep_wrapper <<i1>> ]" ];

import io;
import sys;

main {
  int sleepTime = toint(argv("sleepTime"));
  int sum = sleep_wrapper(sleepTime);
}
