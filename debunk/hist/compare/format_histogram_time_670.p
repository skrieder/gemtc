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
set title "Histogram - CUDA vs GemTC - Time"
set xlabel "Total Problem Size (bytes)"
set ylabel "Time (s)"
set key outside

# set output file
set terminal png size 1600,900 enhanced font "Helvetica,20"
set output 'hist_time_both_670.png'

# plot data
plot "../cuda/histogram.dat" using 1:3 title 'CUDA' w linespoints, \
 "../gemtc/histogram.dat" using 1:3 title 'GemTC' w linespoints  
