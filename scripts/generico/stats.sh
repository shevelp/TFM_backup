#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       SHELL SCRIPT: STATISTICAL ANALYSIS(POINTS)           #
#                                (STAT.F)                                    #
#                                                                            #
#                                                                            #
#                                                                            #
##############################################################################


# Select your work directories
#---------------------------------------------------------------------------

dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d2
datadir=${dirhome}/data/d2
plotsdir=${dirhome}/plots/d2
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran


# Going to your work directory and selecting point (SERIE)
#---------------------------------------------------------------------------

cd ${workdir}

file=$1
outfile=$2

echo " Seleccion de salida:
0.  Todas las variable
1.  medias
2.  medianas
3.  deviaciones
4.  pseud stand deviati
5.  quartile 1
6.  quartile 2
7.  interquartilic length
8.  maximum value
9.  minimum value
10.  number of missing
11.  number of existing"

read option

echo "Getting operation \n" 
${progsdirexec}/stat.f.out<<eof #modify program to your dimension
${workdir}/$file
${workdir}/$outfile
$option
eof
echo "Done\n"

#----------------------------------------------------------------------------
echo "Changing to ascii"
${progsdirexec}/origin2.f.out<<eof
${workdir}/$outfile
1.0
${workdir}/$3.dat
eof
echo "Done\n"

cat ${workdir}/$3.dat








