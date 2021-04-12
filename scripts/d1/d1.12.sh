#!/bin/sh


###########################################################################
#
#     China Summer Temperature Analysis: Sergio Lopez Padilla
#
###########################################################################

#---Switches -----#
switch1=1 #Preparing the data
switch2=1 #Ploting map
switch3=1 #Summer cycle
switch4=0 #Removing files from workdir

#---Directories---#
dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d1
datadir=${dirhome}/data/d1
plotsdir=${dirhome}/plots/d1
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran


#----------------------------------------------> Switch1
if [ ${switch1} -eq 1 ] ; then

cd ${workdir}

#cp used Fortran programs
cp ${cajondir}/selmonF.f         ${progsdir}
cp ${cajondir}/medanu.f          ${progsdir}
cp ${cajondir}/mean.f            ${progsdir}
cp ${cajondir}/meantime.f        ${progsdir}

#Compiling programs
${scriptsdir}/generico/compila.sh	selmonF.f
${scriptsdir}/generico/compila.sh       medanu.f
${scriptsdir}/generico/compila.sh       mean.f
${scriptsdir}/generico/compila.sh       meantime.f
${scriptsdir}/generico/compila.sh       origin2.f


#Copiying data to workdir
cp ${datadir}/cru_ts3.23.1901.2014.tmp.dat_1_70-145E_15-55N.ext		${workdir}

#selecting summermonths
echo "Selecting summer months\n"
${progsdirexec}/selmonF.f.out<<eof
cru_ts3.23.1901.2014.tmp.dat_1_70-145E_15-55N.ext
summer_china.ext
6,8
eof

#annual mean
echo "Calculating annual mean\n"
${progsdirexec}/medanu.f.out<<eof
summer_china.ext
3
annual_mean.ext
eof

#special mean
echo "Calculating special mean\n"
${progsdirexec}/mean.f.out<<eof
annual_mean.ext
temperature.ext
eof

fi

#----------------------------------------------> Switch2
echo "Plotting map\n"
#Plotting
if [ ${switch2} -eq 1 ] ; then

${scriptsdir}/d1/gmt_gridded.sh temperature.ext
mv cru1.0_temp_china.ps ${plotsdir}/China_summer-map.ps
fi

#----------------------------------------------> Switch3
echo "Plotting Annual Temperature Cycle\n"
#Plotting
if [ ${switch3} -eq 1 ] ; then

#generating summer cycle data
${progsdirexec}/meantime.f.out<<eof
annual_mean.ext
cycle.ext
eof

#from ext to dat format
${progsdirexec}/origin2.f.out<<eof
cycle.ext
1.0
cycle.dat
eof

#ploting
${scriptsdir}/d1/gn_summer-cycle.sh cycle.dat
mv plot.ps ${plotsdir}/China_summer-cycle.ps

fi

echo "PROCESS DONE"

#----------------------------------------------> Switch4
#Removing files from workdir
#Plotting
if [ ${switch4} -eq 1 ] ; then
rm *
fi

#_______________________________________________________
exit
