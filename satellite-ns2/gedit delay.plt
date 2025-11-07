set title "Average Delay vs Number of Nodes"
set xlabel "Number of Nodes"
set ylabel "Average Delay (s)"
set grid
plot "delay.dat" using 1:2 with linespoints title "Average Delay"
pause -1

