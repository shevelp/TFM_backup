#! /bin/sh

##############################################################################
#									     #
#									     #
#									     #
#			GNUPLOT: PLOTTING SERIES			     #
#									     #
#									     #
#									     #
##############################################################################


#Checking values
#---------------------------------------------------------------------------

x=$(wc -l < "$1")
years=2
y=$(($x/$years))


echo "'$x' Total Days"
echo "'$y' Division"

#Data Definition: Variable, Unit and Abreviature
#----------------------------------------------------------------------------

echo "YLABEL:"
read var

echo "What unit?"
read unit

echo "period:"
read period

#Preprocessing: If not annual
#----------------------------------------------------------------------------

file_name=$1
echo $file_name

#adding white row if its not annual series
#if [ "${file_name}" != "anu.dat" ]; then
#awk '{print} NR=='"$y"'{print " "}' ${1}|sponge ${1}
#fi

if [ "${file_name}" != "anu.dat" ]; then

#Plotting option 1
#----------------------------------------------------------------------------
cat>plot.1<<m1

#Size
set size 1,1

#Title
set title "$title"

#Tics & labels
set xtics font ",18"
set ytics font ",20"
set xtics out offset -2.5,-3 rotate by 60
set tic scale 0.1
set ylabel "$var ($unit)"
set xlabel "Date" offset 0,-2,0

set style line 1 lt 1 lw 3 lc rgb '#FF6347'

#Plot with labels column 2 each 25
plot '$1' using 4:xtic(int(\$0)%25 ? " " : strcol(2)) title "$period" w lines linestyle 1;


#Final
set output "plot.ps"
set term post landscape color solid  "Times-Roman" 23
replot
m1
gnuplot< plot.1

fi
#---------------------------------------------------------------------------


#Plotting option 2 (anu)
#----------------------------------------------------------------------------
if [ "${file_name}" = "anu.dat" ]; then

freq=30

cat>plot.1<<m1

#Size
set size 1,1

#Title
set title "$title"

#Tics & labels
set xtics font ",18"
set ytics font ",20"
set xtics out offset -2.5,-3 rotate by 60
set tic scale 0.1
set ylabel "$var ($unit)"
set xlabel "Date" offset 0,-2,0

set style line 1 lt 1 lw 3 lc rgb '#6495ED'
set style line 2 lt 1 lw 2 pt 13 ps 1 lc rgb '#FF6347'


#Plot with labels column 2 each 25
plot '$1' using 4:xtic(int(\$0)%$freq ? " " : strcol(2)) title "$period" w lines linestyle 1,\
     '$2' using 1 axes x2y1 t 'monthly mean' w linespoints linestyle 2;

#Final
set output "plot.ps"
set term post landscape color solid  "Times-Roman" 23
replot
m1
gnuplot< plot.1
fi
#---------------------------------------------------------------------------
