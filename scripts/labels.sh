#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       SHELL SCRIPT: SEPARATE MULTILAYER		     #
#				VARIABLES(SEL-IA3)		             #
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


# Going to your work directory and selecting layers
#---------------------------------------------------------------------------

cd ${workdir}

file=$1
outfile=$2

echo "What layer do you want?(number,unit,etc)"
read layer

echo "Getting files\n" 
${progsdirexec}/sel-ia3.f.out<<eof #modify program to your dimension
${datadir}/$file
${datadir}/$outfile
$layer
eof
echo "Done\n"

#----------------------------------------------------------------------------

