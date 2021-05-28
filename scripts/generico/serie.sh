#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       SHELL SCRIPT: SEPARATE SERIES (POINTS)               #
#                               ON MAP (SACSER)                              #
#                                                                            #
#                                                                            #
#                                                                            #
##############################################################################


# Select your work directories
#---------------------------------------------------------------------------

dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d3
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

echo "What point  do you want?(1,N) N= number of points"
read point

echo "Getting files\n" 
${progsdirexec}/sacser.f.out<<eof #modify program to your dimension
${datadir}/$file
$point
$outfile
eof
echo "Done\n"

#----------------------------------------------------------------------------

