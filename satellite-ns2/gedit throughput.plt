set title "Throughput vs Number of Nodes"
set xlabel "Number of Nodes"
set ylabel "Throughput (kbps)"
set grid
plot "throughput.dat" using 1:2 with linespoints title "Throughput"
pause -1

