@dispatch=WORKER
  (int sum) g(int i1, int i2) "g" "0.0"
  [ "set <<sum>> [ g <<i1>> <<i2>> ]" ];

  (blob b) saxpy(int n, float a, float *x, float *y) "saxpy" "0.0"
  [ "set <<b>> [ saxpy <<n>> <<a>> <<*x>> <<*y>> ]"];


import sys;

main {

  n = 1;
  a = 2;

  x = [1,2];

  y = [3,4];

  blob b = saxpy(n, a, x, y);
}
