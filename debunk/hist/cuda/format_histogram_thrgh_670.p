# include range for all data
set autoscale

set xrange [1024:] #820 because that is where data starts

# set log
unset logscale
set logscale x
#set logscale y

# Add commas
set decimal locale
set format x "%'g"
set format y "%'g"

# set labels
unset label
set title "Histogram - CUDA Version - Throughput"
set xlabel "Total Problem Size (bytes)"
set ylabel "Throughput MB/s"
set key outside

# set output file
set terminal png size 1600,900 enhanced font "Helvetica,20"
   set output 'plots/hist_throughput_670.png'

# plot data
plot "histogram.dat" using 1:2 title 'Throughput MB/s' w linespoints
