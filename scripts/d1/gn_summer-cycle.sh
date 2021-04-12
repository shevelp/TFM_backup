#! /bin/sh

cat>plot.1<<m1

set size 1,1

set xlabel "Time (Months)"
set ylabel "Temperature (°C)"

set style line 1 lt 1 lw 6 pt 1 ps 1.5

plot '$1' u (\$1) title 'Temp'  w lines linestyle 1

set output "plot.ps"
set term post landscape color solid  "Times-Roman" 23
replot
m1
gnuplot< plot.1

