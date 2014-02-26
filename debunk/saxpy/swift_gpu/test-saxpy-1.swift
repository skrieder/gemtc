@dispatch=WORKER
  (int sum) cuda_saxpy_launcher(int i1) "saxpy" "0.0"
  [ "set <<sum>> [ cuda_saxpy_launcher <<i1>> ]" ];

import io;
import sys;

main {
  int sleepTime = toint(argv("sleepTime"));
  int sum = cuda_saxpy_launcher(sleepTime);
}
