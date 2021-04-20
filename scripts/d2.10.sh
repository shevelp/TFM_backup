#!/bin/sh


###########################################################################
#
#     Simulaciones GreatModelS: Sergio Lopez Padilla
#
###########################################################################

#Downloading files from server:

#1) scp guest@xirimiri.fis.ucm.es:/home/guest/GReatModelS/out/b1.01/t2_d01.ext /home/sergiolp/Work/TFM/data/d2
#2) scp guest@xirimiri.fis.ucm.es:/home/guest/GReatModelS/out/latlon/lat_lon_GReatModelS.dat /home/sergiolp/Work/TFM/data/d2

#---Switches -----# 
switch0=0 #Copying data to workdir 
switch1=1 #Preprocessing (checking and changing dates)
switch2=1  #Wave + anomalies + Mean analysis + season analysis + temporal mean + spatial mean
switch3=1 #Plotting series
switch4=1 #Plotting map
switch5=0 #Removing files from workdir


#---Directories---#
dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d2
datadir=${dirhome}/data/d2
plotsdir=${dirhome}/plots/d2
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran

cd ${workdir}


#----------------------------------------------> Switch0
if [ ${switch0} -eq 1 ] ; then

#Copiying data to workdir
cp ${datadir}/$1               	        ${workdir}
cp ${datadir}/lat_lon_GReatModelS.dat   ${workdir}

fi

#----------------------------------------------> Switch1

if [ ${switch1} -eq 1 ] ; then


#cp used Fortran programs
cp ${cajondir}/fechas2.f         ${progsdir}
cp ${cajondir}/selper.f          ${progsdir}
cp ${cajondir}/med_day.f         ${progsdir}
cp ${cajondir}/selmon_ia10.f     ${progsdir}
cp ${cajondir}/meantime.f        ${progsdir}
cp ${cajondir}/mean.f        	 ${progsdir}
cp ${cajondir}/anomal-p.f        ${progsdir}
cp ${cajondir}/origin-gn.f	 ${progsdir}
cp ${cajondir}/genfechas-1h.f    ${progsdir}
cp ${cajondir}/ondanual.f        ${progsdir}
cp ${cajondir}/runmean.f         ${progsdir}
cp ${cajondir}/trans.f           ${progsdir}
cp ${cajondir}/stat.f            ${progsdir}


#Compiling programs
${scriptsdir}/generico/compila.sh       fechas2.f
${scriptsdir}/generico/compila.sh       selper.f
${scriptsdir}/generico/compila.sh       med_day.f
${scriptsdir}/generico/compila.sh       selmon_ia10.f
${scriptsdir}/generico/compila.sh       meantime.f
${scriptsdir}/generico/compila.sh       mean.f
${scriptsdir}/generico/compila.sh       origin-gn.f
${scriptsdir}/generico/compila.sh       anomal-p.f
${scriptsdir}/generico/compila.sh       genfechas-1h.f
${scriptsdir}/generico/compila.sh       ondanual.f
${scriptsdir}/generico/compila.sh       runmean.f
${scriptsdir}/generico/compila.sh       trans.f
${scriptsdir}/generico/compila_v7.sh    stat.f
$${scriptsdir}/generico/compila.sh      ponasci.f
exit

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

# Trabajamos con el fichero dated para calcular la acumulada

# Como hace med_day.f.out?

# Una vez generado el programa .f se utilizará un if para que se utilice solo cuando se trabaje con prec


#----------------------------------------------> Switch2
if [ ${switch2} -eq 1 ] ; then

#Diary mean
echo "Calculating diary mean\n"
${progsdirexec}/med_day.f.out<<eof
dated.ext
0
diary_mean.ext
eof
echo "Done\n"

#Wave, moving average
sh ${scriptsdir}/generico/ondanual_s.sh diary_mean.ext anom.ext

#Anomalies: change NN: use anomalies_p
#------------------------------------
#echo "Calculating anomalies"
#${progsdirexec}/anomal-p.f.out <<eof
#diary_mean_wave.ext
#anom.ext
#eof

#-----------------------------------
#Seasson selection
echo "Seasson selection:Winter\n" #Special:### Se recorta el periodo para que empiece por 
#diciembre y así tener meses de un mismo invierno 
${progsdirexec}/selper.f.out<<eof
anom.ext
winter_anom.ext
1990120100,1991113000
eof

${progsdirexec}/selmon_ia10.f.out<<eof
winter_anom.ext
def.ext
12,2
eof
echo "Done\n"

echo "Seasson selection:Spring\n"
${progsdirexec}/selmon_ia10.f.out<<eof
anom.ext
mam.ext
3,5
eof
echo "Done\n"

echo "Seasson selection:Summer\n"
${progsdirexec}/selmon_ia10.f.out<<eof
anom.ext
jja.ext
6,8
eof
echo "Done\n"

echo "Seasson selection:Autumn\n"
${progsdirexec}/selmon_ia10.f.out<<eof
anom.ext
son.ext
9,11
eof
echo "Done\n"

echo "Seasson selection:Anual\n"
${progsdirexec}/selmon_ia10.f.out<<eof
anom.ext
anu.ext
1,12
eof
echo "Done\n"
#------------------------------------

#Temporal mean
#changing ns
echo "Calculating temporal mean:Winter\n"
${progsdirexec}/meantime.f.out<<eof
def.ext
def_mean.ext
eof
echo "Done\n"

echo "Calculating temporal mean:Spring\n"
${progsdirexec}/meantime.f.out<<eof
mam.ext
mam_mean.ext
eof
echo "Done\n"

echo "Calculating temporal mean:Summer\n"
${progsdirexec}/meantime.f.out<<eof
jja.ext
jja_mean.ext
eof
echo "Done\n"

echo "Calculating temporal mean:Autumn\n"
${progsdirexec}/meantime.f.out<<eof
son.ext
son_mean.ext
eof
echo "Done\n"

echo "Calculating temporal mean:Anual\n"
${progsdirexec}/meantime.f.out<<eof
anu.ext
anu_mean.ext
eof
echo "Done\n"

#--------------------------------------------
#Spatial mean
#changing parameter ns to 101178
echo "Calculating spatial mean:Winter\n"
${progsdirexec}/mean.f.out<<eof
def.ext
def_spatial_mean.ext
eof
echo "Done\n"


echo "Calculating spatial mean:Spring\n"
${progsdirexec}/mean.f.out<<eof
mam.ext
mam_spatial_mean.ext
eof
echo "Done\n"

echo "Calculating spatial mean:Summer\n"
${progsdirexec}/mean.f.out<<eof
jja.ext
jja_spatial_mean.ext
eof
echo "Done\n"

echo "Calculating spatial mean:Autumn\n"
${progsdirexec}/mean.f.out<<eof
son.ext
son_spatial_mean.ext
eof
echo "Done\n"


echo "Calculating spatial mean:Anual\n"
${progsdirexec}/mean.f.out<<eof
anu.ext
anu_spatial_mean.ext
eof
echo "Done\n"
fi

#----------------------------------------------> Switch3 MODIFICAR EL SCRIPT THE GNUPLOT
if [ ${switch3} -eq 1 ] ; then

echo "Plotting series: Winter"
#from ext to dat format
${progsdirexec}/origin-gn.f.out<<eof
def_mean.ext
1.0
def.dat
eof

#ploting
${scriptsdir}/d2/gn_cycle.sh def.dat $2
mv plot.ps ${plotsdir}/def_series.ps

echo "Plotting series: Spring"
#from ext to dat format
${progsdirexec}/origin-gn.f.out<<eof
mam_mean.ext
1.0
mam.dat
eof

#ploting
${scriptsdir}/d2/gn_cycle.sh mam.dat $2
mv plot.ps ${plotsdir}/mam_series.ps

echo "Plotting series: Summer"
#from ext to dat format
${progsdirexec}/origin-gn.f.out<<eof
jja_mean.ext
1.0
jja.dat
eof

#ploting
${scriptsdir}/d2/gn_cycle.sh jja.dat $2
mv plot.ps ${plotsdir}/jja_series.ps

echo "Plotting series: Autumn"
#from ext to dat format
${progsdirexec}/origin-gn.f.out<<eof
son_mean.ext
1.0
son.dat
eof

#ploting
${scriptsdir}/d2/gn_cycle.sh son.dat $2
mv plot.ps ${plotsdir}/son_series.ps

echo "Plotting series: Anual"
#from ext to dat format
${progsdirexec}/origin-gn.f.out<<eof
anu_mean.ext
1.0
anu.dat
eof

#ploting
${scriptsdir}/d2/gn_cycle.sh anu.dat $2
mv plot.ps ${plotsdir}/anu_series.ps
fi


#----------------------------------------------> Switch4


echo "Plotting maps\n"
#Plotting
if [ ${switch4} -eq 1 ] ; then

echo "DEF"
${scriptsdir}/d2/gmt_med.sh def_spatial_mean.ext #gmt_IP.sh includes transpon.f and origin2.f to generates dataset, transpon.f have modified the parameters to work!
ps2eps -f cont_analysis.ps 
mv cont_analysis.eps ${plotsdir}/def-map.ps

echo "MAM"
${scriptsdir}/d2/gmt_med.sh mam_spatial_mean.ext #gmt_IP.sh includes transpon.f and origin2.f to generates dataset, transpon.f>
ps2eps -f cont_analysis.ps 
mv cont_analysis.eps ${plotsdir}/mam-map.ps

echo "JJA"
${scriptsdir}/d2/gmt_med.sh jja_spatial_mean.ext
ps2eps -f cont_analysis.ps 
mv cont_analysis.eps ${plotsdir}/jja-map.ps

echo "SON"
${scriptsdir}/d2/gmt_med.sh son_spatial_mean.ext
ps2eps -f cont_analysis.ps 
mv cont_analysis.eps ${plotsdir}/son-map.ps

echo "ANU"
${scriptsdir}/d2/gmt_med.sh anu_spatial_mean.ext
ps2eps -f cont_analysis.ps 
mv cont_analysis.eps ${plotsdir}/anu-map.ps
fi

#----------------------------------------------> Switch5
#Removing files from workdir
if [ ${switch5} -eq 1 ] ; then
rm *
fi

#_______________________________________________________
exit
