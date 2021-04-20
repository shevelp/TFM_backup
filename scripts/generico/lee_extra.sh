
#! /bin/sh
#helpini
# _______________________________________________________________________
#
#    
#     Muestra en pantalla contenido de ficheros en formato extra (binario)
#     
# _______________________________________________________________________
#helpfin
#
#
dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d2
datadir=${dirhome}/data/d2
plotsdir=${dirhome}/plots/d2
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran

#########################################################################
#cd ${progsdir}
#
#${scriptsdir}/generico/compila.sh /ponasci.f   #Compilar solo una vez!!!
#
#########################################################################


cd ${workdir}

${progsdirexec}/ponasci.f.out<<m1
$1
$2
m1

exit
