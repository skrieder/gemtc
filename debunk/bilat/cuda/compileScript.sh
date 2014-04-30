make
./filtering 4 10  > filtering.dat
gnuplot format_bilat_time_670.p
scp plots/bilat_time_670.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/bilat_time_670.png
make clean 
