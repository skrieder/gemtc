@dispatch=WORKER
(void s) hist(int i,int j) "hist" "0.0"
[ "set <<s>> [ hist <<i>> <<j>> ]" ];

main {
//	foreach i in [1:5] {
	  void s = hist(5,1);
//	}
}
