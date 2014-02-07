# include range for all data
set autoscale

#unset xrange [800:] #800 because that is where data starts
   
# set log
unset logscale
unset logscale x
unset logscale y

# Add commas
#unset decimal locale
#unset format x "%'g"
#unset format y "%'g"

# set labels
unset label
set title "SAXPY MFLOPS with Varied Input and Thread Count - GTX 460"
set xlabel "Total Problem Size (bytes)"
set ylabel "MFLOPS"
set key outside

# set output file
set terminal png size 1600,900 enhanced font "Helvetica,20"
   set output 'plots/saxpy_mflops_data_incl_460.png'

# plot data
plot "logs/saxpy_log.dat" using 1:2 title '1 Thread' w linespoints, \
   "logs/saxpy_log.dat" using 1:3 title '2 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:4 title '4 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:5 title '8 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:6 title '16 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:7 title '32 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:8 title '64 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:9 title '128 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:10 title '256 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:11 title '512 Threads' w linespoints, \
   "logs/saxpy_log.dat" using 1:12 title '1024 Threads' w linespoints
