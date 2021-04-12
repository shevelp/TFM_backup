#!/bin/sh


###########################################################################
#
#     Simulaciones GreatModelS: Sergio Lopez Padilla
#
###########################################################################

#---Directories---#
dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d2
datadir=${dirhome}/data/d2
plotsdir=${dirhome}/plots/d2
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran

#in&out

cd ${workdir}

echo "Calculating diary mean\n"
${progsdirexec}/med_day.f.out<<eof
$1
0
$2
eof
echo "Done\n"

