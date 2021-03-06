# include range for all data
set autoscale

set xrange [820:] #820 because that is where data starts
   
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
set title "GEMTC - Image Convolution MFLOPS with Varied Input and Thread Count - K20"
set xlabel "Total Problem Size (bytes)"
set ylabel "GFLOPS"
set key outside

# set output file
set terminal png size 1600,900 enhanced font "Verdana,20"
   set output 'plots/imageconv_mflops_data_incl_raven_gemtc.png'

# plot data
plot "/lus/scratch/p01956/imageconv_G.dat" using 1:2 title '1 Thread' w linespoints
#   "logs/imageconv.dat" using 1:3 title '2 Threads' w linespoints, \
#   "logs/imageconv.dat" using 1:4 title '4 Threads' w linespoints, \
#   "logs/imageconv.dat" using 1:5 title '8 Threads' w linespoints, \
#   "logs/imageconv.dat" using 1:6 title '16 Threads' w linespoints, \
#   "logs/imageconv.dat" using 1:7 title '32 Threads' w linespoints, \
#  "logs/imageconv.dat" using 1:8 title '64 Threads' w linespoints, \
 #  "logs/imageconv.dat" using 1:9 title '128 Threads' w linespoints, \
#   "logs/imageconv.dat" using 1:10 title '256 Threads' w linespoints, \
#   "logs/imageconv.dat" using 1:11 title '512 Threads' w linespoints, \
#   "logs/imageconv.dat" using 1:12 title '1024 Threads' w linespoints
