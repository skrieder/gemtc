make
./filtering 1 1 1 1 > filtering.dat
gnuplot format_bilat_time_GeMTC_670.p
scp plots/bilat_time_GeMTC_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/bilat_time_GeMTC_670.png
make clean 
