#!/bin/sh


###########################################################################
#
#     Pintar ciclo anual temperaturas China con Gnuplot (http://www.gnuplot.info/)
#
###########################################################################

switch1=1 #Grafica 
switch2=1 #Limpiar

#_________________________________________________________________________
    
    #   Directorios   #

dirhome=/Users/elena/entra/people/TFM/TFM2018/TFM2018

workdir=${dirhome}/work/d1
datadir=${dirhome}/data/d1
plotsdir=${dirhome}/plots/d1

progsdir=${dirhome}/progs
scriptsdir=${dirhome}/scripts/d1

#----------------------------------------------> Switch1
if [ ${switch1} -eq 1 ] ;  then

cd ${workdir}

file1=${datadir}/annual_cycle_china.dat

${scriptsdir}/gn_ann-cycle.sh ${file1}
mv plot.ps ${plotsdir}/China_ann-cycle.ps

fi

#----------------------------------------------> Switch2
if [ ${switch2} -eq 1 ] ;  then

rm plot.1

fi
#_________________________________________________________________________

exit
