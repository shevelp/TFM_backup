#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       SHELL SCRIPT: RAZON DE VARIANZA                      #
#                                Mean + RESTA = BIAS                         #
#                                 BIAS + PLOT                                #
#                                                                            #
#                                                                            #
##############################################################################

#---Switches -----# 
switch0=0 #Copying data to workdir and checking dates
switch1=0 #Calculating rvar
switch2=1 #Plotting map rvar
switch3=0 #Removing files from workdir

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
cp ${datadir}/$1                        ${workdir}
cp ${datadir}/$2                        ${workdir}
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

echo "Calculating diary mean\n"
${progsdirexec}/med_day.f.out<<eof
dated.ext
0
med_day1.ext
eof
echo "Done\n"

#Diary mean
echo "Calculating diary mean\n"
${progsdirexec}/med_day.f.out<<eof
$2
0
med_day2.ext
eof
echo "Done\n"
fi

#------------------------------------------------------------------------> Switch 1
if [ ${switch1} -eq 1 ] ; then

#Calculamos la desviación típica del fichero de medias diarias-------------SIM1
${progsdirexec}/stat.f.out<<EOF
med_day1.ext
desv1.ext
3
EOF
#Calculamos la varianza de la simulación
${progsdirexec}/trans.f.out<<EOF
3
desv1.ext
2
var1.ext
EOF

#Elevamos a -1 la simulación
${progsdirexec}/trans.f.out<<EOF
3
var1.ext
-1
var1-1.ext
EOF

#Calculamos la desviación típica del fichero de medias diarias----------- SIM2
${progsdirexec}/stat.f.out<<EOF
med_day2.ext
desv2.ext
3
EOF
#Calculamos la varianza de la simulación
${progsdirexec}/trans.f.out<<EOF
3
desv2.ext
2
var2.ext
EOF

#Multiplicamos los dos ficheros para obtener la razón de varianzas
${progsdirexec}/trans.f.out<<EOF
7
var2.ext
var1-1.ext
1
rvar.ext
EOF

fi

#--------------------------------------------------------------------------> Switch 2

if [ ${switch2} -eq 1 ] ; then

#plot map
echo "Calculating spatial mean 2"
${progsdirexec}/mean.f.out<<eof
rvar.ext
rvar_map.ext
eof
echo "Done\n"


echo "Plotting bias map"
${scriptsdir}/d3/gmt_med_rvar.sh rvar_map.ext
ps2eps -f cont_analysis.ps
mv cont_analysis.eps ${plotsdir}/rvar_map.ps

fi

#################################################################################
exit
