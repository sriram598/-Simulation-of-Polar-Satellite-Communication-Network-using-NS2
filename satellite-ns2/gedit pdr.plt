set title "Packet Delivery Ratio vs Number of Nodes"
set xlabel "Number of Nodes"
set ylabel "PDR (%)"
set grid
plot "pdr.dat" using 1:2 with linespoints title "PDR"
pause -1

