@dispatch=WORKER
  (int sum) g(int i1, int i2) "g" "0.0"
  [ "set <<sum>> [ g <<i1>> <<i2>> ]" ];
  (int sum2) mdproxy_wrapper(int i1, int i2, float d1) "g" "0.0"
  [ "set <<sum2>> [ mdproxy_wrapper <<i1>> <<i2>> <<d1>>]" ];

import sys;

main {
  //  foreach i in [0:5] {
  //  int sum = g(i, 5-i);
  //}
  int num_sims = toint(argv("num_sims"));
  int np = toint(argv("np"));
  int nd = toint(argv("nd"));
  float mass = tofloat(argv("mass"));
  
  foreach i in [0:num_sims] {
    int sum = mdproxy_wrapper(np, nd, mass);
  }

}
