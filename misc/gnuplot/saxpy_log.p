unset logscale
set logscale x
unset label
set title "SAXPY Runtime with Varied Input and Thread Count"
set xlabel "Vector Size (# of elements)"
set ylabel "Wall Time (microseconds)"
set terminal png size 1200,900 enhanced font "Helvetica,20"
set key outside
set output 'output.png'
plot "saxpy_log.dat" using 1:2 title '1 Thread' w linespoints, \
"saxpy_log.dat" using 1:3 title '2 Threads' w linespoints, \
"saxpy_log.dat" using 1:4 title '4 Threads' w linespoints, \
"saxpy_log.dat" using 1:5 title '8 Threads' w linespoints, \
"saxpy_log.dat" using 1:6 title '16 Threads' w linespoints, \
"saxpy_log.dat" using 1:7 title '32 Threads' w linespoints, \
"saxpy_log.dat" using 1:8 title '64 Threads' w linespoints, \
"saxpy_log.dat" using 1:9 title '128 Threads' w linespoints, \
"saxpy_log.dat" using 1:10 title '256 Threads' w linespoints
