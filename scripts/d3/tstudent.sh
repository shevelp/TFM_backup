#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       SHELL SCRIPT: STATISTICAL ANALYSIS(POINTS)           #
#                                T-STUDENT:                   	             #
#                                1) PREPARATION 2) TSTUDENT                  #
#                                                                            #
#                                                                            #
##############################################################################

#---Switches -----# 
switch0=0 #Copying data to workdir and checking dates
switch1=1 #Calculating diary mean
switch2=1 #Stats Tstudent
switch3=1 #Tstudent
switch4=0 #Removing files from workdir

# Select your work directories
#---------------------------------------------------------------------------

dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d3
datadir=${dirhome}/data/d2
plotsdir=${dirhome}/plots/d3
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran

cd ${workdir}

#----------------------------------------------> Switch0
if [ ${switch0} -eq 1 ] ; then

#Copiying data to workdir
cp ${datadir}/$1               	        ${workdir}
cp ${datadir}/$2			${workdir}
cp ${datadir}/lat_lon_GReatModelS.dat   ${workdir}

#Checking dates and format
echo "Checking dates and format\n"
${progsdirexec}/fechas2.f.out<<eof
$1
eof

#This generates a file, to check data:
head -1 fechas
tail -1 fechas


#Selecting correct period
#gfortran -g -fcheck=all -Wtabs selper.f
#Deleting tabs and changing parameter nn to 101178
echo "Selecting dates"
${progsdirexec}/selper.f.out<<eof
$1
dated.ext
1990010100,1991123123
eof
echo "Done!"

echo "Checking new dates\n"
${progsdirexec}/fechas2.f.out<<eof
dated.ext
eof

head -1 fechas
tail -1 fechas

echo "Dates corrected!\n"

fi

#----------------------------------------------> Switch1
if [ ${switch1} -eq 1 ] ; then

#Diary mean
echo "Calculating diary mean\n"
${progsdirexec}/med_day.f.out<<eof
dated.ext
0
diary_mean.ext
eof
echo "Done\n"

#Diary mean
echo "Calculating diary mean\n"
${progsdirexec}/med_day.f.out<<eof
$2
0
diary_mean2.ext
eof
echo "Done\n"

fi
#----------------------------------------------> Switch2
if [ ${switch2} -eq 1 ] ; then

echo "PRE-Tstudent file 1"
${progsdirexec}/stat-diftst.f.out<<eof
diary_mean.ext
file1_stats.ext
eof
echo "Done\n"


echo "PRE-Tstudent file 2"
${progsdirexec}/stat-diftst.f.out<<eof
diary_mean2.ext
file2_stats.ext
eof
echo "Done\n"
fi

#----------------------------------------------> Switch3
if [ ${switch3} -eq 1 ] ; then

echo "Tstudent"
${progsdirexec}/diftst.f.out<<eof
file1_stats.ext
file2_stats.ext
tstudent.ext
eof
echo "Done\n"

fi

#---------------------------------------------> Switch4
if [ ${switch4} -eq 1 ] ; then
rm *
fi
