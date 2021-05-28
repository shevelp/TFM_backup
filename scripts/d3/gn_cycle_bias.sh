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
#---------------------------------------------------------------------------
echo "VAR"
read var

echo "What unit?"
read unit

echo "file1:"
read file1

echo "file2:"
read file2

#Preprocessing: If not annual
#----------------------------------------------------------------------------

file_name=$1
echo $file_name

#Plotting 2 series
#----------------------------------------------------------------------------

freq=30

cat>plot.1<<m1

#Size
set size 1,1

#Tics & labels
set xtics font ",18"
set ytics font ",20"
set xtics out offset -2.5,-3 rotate by 60
set tic scale 0.1
set ylabel "$var ($unit)"
set xlabel "Date" offset 0,-2,0

set style line 1 lt 1 lw 3 lc rgb '#6495ED'
set style line 2 lt 1 lw 2 lc rgb '#FF6347'


#Plot with labels column 2 each $fre
plot '$1' using 4:xtic(int(\$0)%$freq ? " " : strcol(2)) title "$file1" w lines linestyle 1, \
     '$2' using 4:xtic(int(\$0)%$freq ? " " : strcol(2)) title "$file2" w lines linestyle 2;

#Final
set output "plot.ps"
set term post landscape color solid  "Times-Roman" 23
replot
m1
gnuplot< plot.1
#---------------------------------------------------------------------------
