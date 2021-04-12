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

echo "What variable are u working with?"
read var

echo "What unit?"
read unit

echo "Abreviature:"
read abr

#Preprocessing: If not annual
#----------------------------------------------------------------------------

file_name=$1
echo $file_name

#adding white row if its not annual series
if [ "${file_name}" != "anu.dat" ]; then
awk '{print} NR=='"$y"'{print " "}' ${1}|sponge ${1}
fi

#Plotting
#----------------------------------------------------------------------------
cat>plot.1<<m1

#Size
set size 1,1

#Title
set title "$var analysis"

#Tics & labels
set xtics font ",9"
set xtics out offset -1,-1.5 rotate by 60
set tic scale 0
set xlabel "Date"
set ylabel "$var ($unit)"

#set arrow from '$y',graph(0,0) to '$y',graph(1,1) nohead
set style line 1 lt 1 lw 6 pt 1 ps 1.5 linecolor 'red'

#Plot with labels column 2 each 25
plot '$1' \
	using 4:xtic(int(\$0)%30 ? " " : strcol(2)) title "$abr" w lines linestyle 1


#Final
set output "plot.ps"
set term post landscape color solid  "Times-Roman" 23
replot
m1
gnuplot< plot.1

#---------------------------------------------------------------------------
