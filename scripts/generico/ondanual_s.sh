#!/bin/sh

input=$1
output=$2

###########################################################################
#
#     				Onda Anual
#
###########################################################################

dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d2
datadir=${dirhome}/data/d2
plotsdir=${dirhome}/plots/d2
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran

cd ${workdir}


#save dates on vars
ini=$(cat fechas | head -1 |  awk '{print substr($1,1,10);exit}' )
fin=$(cat fechas | tail -1 |  awk '{print substr($1,1,10);exit}' )

#checking dates 10ia format
echo $ini
echo $fin


#ASK FOR YOUR DATES: https://www.javatpoint.com/bash-read-user-input
#------------------------------------------------------------------------
#2) Data augmentation (proyecting data)
echo "Insert your initial Wave date, format: yyyy,mm,dd,hh"
read inip

echo "Insert your final Wave date, format: yyyy,mm,dd,hh"
read finip

echo "Insert your number of points"
read numest

${progsdirexec}/genfechas-1h.f.out << eof
$inip
$finip
$numest
plantilla.h
eof


${progsdirexec}/med_day.f.out << eof
plantilla.h
0
plantilla.d
eof

#-----------------------------------------------------------------------
#Generacion de la onda anual
arm1=30
arm2=15

${progsdirexec}/ondanual.f.out << eof
$input #fichero espacial de datos tras separar
plantilla.d
tmp3
eof


${progsdirexec}/runmean.f.out <<eof
tmp3
tmp4
$arm1
eof


${progsdirexec}/runmean.f.out << eof
tmp4
tmp5
$arm2
eof


#selecting dates
fechasel=$(echo ${ini}),$(echo ${fin})
echo fechasel

${progsdirexec}/selper.f.out << eof
tmp5
output
$fechasel
eof

#######################################################################################
###No puedo dar por hecho que todos lso valores de la onda anual son POSITIVOS
#${HOME}/entra/exec/abs.ext<<eof
#tmp5
#output
#eof
#### Saco serie sin onda anual:
${progsdirexec}/trans.f.out<<eof
6
$1
output
-1 #multiplicar por un factor -1 para que sea una resta
$output
eof



