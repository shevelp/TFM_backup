#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       SHELL SCRIPT: MEAN BIAS ANALYSIS (POINTS)            #
#                                (BIAS.F)                                    #
#                                                                            #
#                                                                            #
#                                                                            #
##############################################################################


# Select your work directories
#---------------------------------------------------------------------------

dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d3
datadir=${dirhome}/data/d2
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec


# Going to your work directory and calculating mean bias.
#---------------------------------------------------------------------------
cd ${workdir}

file=$1
file2=$2
outfile=$3


echo "calcularing bias \n" 
${progsdirexec}/bias.f.out<<eof #modify your parameters
${datadir}/$file
${datadir}/$file2
$outfile
eof
echo "Done\n"
