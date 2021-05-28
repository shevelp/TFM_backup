#! /bin/sh
#helpini
# _______________________________________________________________________
#
#    
#     Saca la media diaria de un fichero
#     
# _______________________________________________________________________
#helpfin
#
#
dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d3
datadir=${dirhome}/data/d2
plotsdir=${dirhome}/plots/d2
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran

###########################################################

cd ${workdir}

#Diary mean
echo "Calculating diary mean\n"
${progsdirexec}/med_day.f.out<<eof
$1
0
$2
eof
echo "Done\n"

exit
