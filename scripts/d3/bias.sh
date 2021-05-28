#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       SHELL SCRIPT: STATISTICAL ANALYSIS(POINTS)           #
#                                Mean + RESTA = BIAS                   	     #
#                                 BIAS + PLOT                                #
#                                                                            #
#                                                                            #
##############################################################################

#---Switches -----# 
switch0=1 #Copying data to workdir and checking dates
switch1=1 #Calculating diary mean
switch2=1 #Calculating spatial mean
switch3=1 #Calculating bias
switch4=1 #Plotting map (change palette)
switch5=1 #Plotting series (abso + anomalies)
switch6=1 #Plotting diference between series
switch7=0 #Removing files from workdir

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

#Diary mean  PARA TODAS EXCEPTO LA PRECIPITACION
#------------------------------------
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


#Acumulative mean PARA LA PRECIPITACION
#-------------------------------------
#${progsdirexec}/sum_day.f.out<<eof
#dated.ext
#0
#diary_mean.ext
#eof

#${progsdirexec}/sum_day.f.out<<eof
#$2
#0
#diary_mean2.ext
#eof
fi

#----------------------------------------------> Switch2


if [ ${switch2} -eq 1 ] ; then

#anomalies
#sh ${scriptsdir}/generico/ondanual_s.sh diary_mean.ext diary_mean_anom1.ext
#sh ${scriptsdir}/generico/ondanual_s.sh diary_mean2.ext diary_mean_anom2.ext

#suavizado
#------------------------------------
echo "Calculating anomalies"
${progsdirexec}/anomal-p.f.out <<eof
diary_mean_anom1.ext
anom1.ext
eof

#------------------------------------
echo "Calculating anomalies"
${progsdirexec}/anomal-p.f.out <<eof
diary_mean_anom2.ext
anom2.ext
eof

fi

#----------------------------------------------> Switch3

if [ ${switch3} -eq 1 ] ; then

echo "Calculating spatial mean"
${progsdirexec}/mean.f.out<<eof
diary_mean.ext
file1_spatial_mean.ext
eof
echo "Done\n"


echo "Calculating spatial mean 2"
${progsdirexec}/mean.f.out<<eof
diary_mean2.ext
file2_spatial_mean.ext
eof
echo "Done\n"
fi


# -----------------------------------------------> Switch4

if [ ${switch4} -eq 1 ] ; then

# Calculating bias = substraction

#### Saco serie sin onda anual:
${progsdirexec}/trans.f.out<<eof
6
file1_spatial_mean.ext
file2_spatial_mean.ext
-1 #multiplicar por un factor -1 para que sea una resta
bias.ext
eof

fi

#------------------------------------------------> Switch5
#Plotting
if [ ${switch5} -eq 1 ] ; then

echo "Plotting bias map"
${scriptsdir}/d3/gmt_med_bias.sh bias.ext  
ps2eps -f cont_analysis.ps
mv cont_analysis.eps ${plotsdir}/bias-map.ps

fi

#------------------------------------------------> Switch6
#from ext to dat format
if [ ${switch6} -eq 1 ] ; then

echo "Calculating temporal mean:Anual\n"
${progsdirexec}/meantime.f.out<<eof
diary_mean.ext
d1.ext
eof
echo "Done\n"

echo "Calculating temporal mean:Anual\n"
${progsdirexec}/meantime.f.out<<eof
diary_mean2.ext
d2.ext
eof
echo "Done\n"

${progsdirexec}/origin-gn.f.out<<eof
d1.ext
1.0
d1.dat
eof

${progsdirexec}/origin-gn.f.out<<eof
d2.ext
1.0
d2.dat
eof

#Plotting diference

cat d1.dat | awk '{ print $4 }' > file1.dat
cat d2.dat | awk '{ print $4 }' > file2.dat

paste file1.dat file2.dat > comb.dat

awk '{a=$1-$2;print $0,a;}' comb.dat > comb1.dat

awk '{ $3 = $1 - $2 } 1' comb1.dat > comb2.dat

cat d1.dat | awk '{ print $1,$2,$3 }' > dates.dat 
cat comb2.dat | awk '{ print $3 }' >  diferencia.dat

paste dates.dat diferencia.dat > plot.dat


#ploting diferential serie

${scriptsdir}/d2/gn_cycle.sh plot.dat
mv plot.ps ${plotsdir}/bias_dif.ps


#ploting
${scriptsdir}/d3/gn_cycle_bias.sh d1.dat d2.dat
mv plot.ps ${plotsdir}/bias_series.ps

echo "Calculating temporal mean ANOM:Anual\n"
${progsdirexec}/meantime.f.out<<eof
anom1.ext
d11.ext
eof
echo "Done\n"

echo "Calculating temporal mean:Anual\n"
${progsdirexec}/meantime.f.out<<eof
anom2.ext
d22.ext
eof
echo "Done\n"

${progsdirexec}/origin-gn.f.out<<eof
d11.ext
1.0
d11.dat
eof

${progsdirexec}/origin-gn.f.out<<eof
d22.ext
1.0
d22.dat
eof

#ploting
${scriptsdir}/d3/gn_cycle_bias.sh d11.dat d22.dat
mv plot.ps ${plotsdir}/bias_series_ANOM.ps

fi


fi

#----------------------------------------------> Switch7
#Removing files from workdir
if [ ${switch7} -eq 1 ] ; then
rm *
fi

#_______________________________________________________
exit
