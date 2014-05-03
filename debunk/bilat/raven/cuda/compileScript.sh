#!/bin/bash

# Karthik Balasubramanian
# kbalasu3@hawk.iit.edu
# Illinois Institute of Technology

mv /lus/scratch/p01956/filtering.dat filtering.dat
gnuplot format_bilat_time_raven.p
scp plots/bilat_time_raven.png karthik@datasys.cs.iit.edu:/home/karthik/public_html/bilat_time_raven.png
rm filtering
rm GeMTC*
