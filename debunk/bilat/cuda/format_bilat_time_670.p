# include range for all data
set autoscale

set xrange [1048576:] #820 because that is where data starts

# set log
unset logscale
#set logscale x
#set logscale y

# Add commas
set decimal locale
set format x "%'g"
set format y "%'g"

# set labels
unset label
set title "Bilateral Filtering - CUDA Version - Time taken"
set xlabel "MegaPixels"
set ylabel "Time (s)"
set key outside

# set output file
set terminal png size 1600,900 enhanced font "Helvetica,20"
   set output 'plots/bilat_time_670.png'

# plot data
plot "filtering.dat" using 1:2 title 'Time (s)' w linespoints
