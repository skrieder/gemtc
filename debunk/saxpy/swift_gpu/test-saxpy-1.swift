@dispatch=WORKER
  (int sum) c_saxpy(int i1, int i2) "saxpy" "0.0"
  [ "set <<sum>> [ c_saxpy <<i1>> <<i2>> ]" ];

import io;
import sys;

main {
  int num_elements = toint(argv("num_elements"));
  int num_threads = toint(argv("num_threads"));
  int sum = c_saxpy(num_elements, num_threads);
}
