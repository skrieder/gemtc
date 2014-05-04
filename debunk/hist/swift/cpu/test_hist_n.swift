@dispatch=WORKER
(void s) hist(int i) "hist" "0.0"
[ "set <<s>> [ hist <<i>> ]" ];

main {
	foreach i in [1:5] {
	  void s = hist(1);
	}
}
