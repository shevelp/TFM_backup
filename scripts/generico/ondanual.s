#!/bin/bash

input=$1
output=$2
output2=$3

#######################################################################################
#### Genero plantilla:

${HOME}/entra/scripts/feici.s $input

head -1 fechas > tmp1
read fini kk1 kk2 numest < tmp1

tail -1 fechas > tmp2
read ffin resto < tmp2

#inicio=$(echo $fini | awk '{print substr($1,1,4)","substr($1,5,2)","substr($1,7,2)","substr($1,9,2)}')
#final=$(echo $ffin | awk '{print substr($1,1,4)","substr($1,5,2)","substr($1,7,2)",23"}')
#####ojo que las fechas se ponen a mano  ################
#1 mes y medio antes de la fecha de inicio y 1 m y medio despues de la fecha final
inicio2=2011,11,15,00
final2=2020,02,15,23

${HOME}/entra/exec/genfechas-1h.f.out<<eof
$inicio2
$final2
$numest
plantilla.h
eof

${HOME}/entra/exec/med_day.f.out<<eof
plantilla.h
0
plantilla.d
eof
#######################################################################################
#### Calculo onda anual:

brazo=30
brazo2=15

${HOME}/entra/exec/ondanual.f.out<<eof
$input
plantilla.d
tmp3
eof

##~
#selper.f.out<<eof
#
#
#eof
##~

${HOME}/entra/exec/runmean.f.out<<eof
tmp3
tmp4
$brazo
eof

${HOME}/entra/exec/runmean.f.out<<eof
tmp4
tmp5
$brazo2
eof

##Pongo la misma fecha en onda anual que el fichero de entrada para poder restar
fechasel=$(echo ${fini}),$(echo ${ffin})
#echo ${fechasel}
#
${HOME}/entra/exec/selper.f.out<<eof
tmp5
${output}
${fechasel}
eof
#######################################################################################
###No puedo dar por hecho que todos lso valores de la onda anual son POSITIVOS
#${HOME}/entra/exec/abs.ext<<eof
#tmp5
#$output
#eof
#### Saco serie sin onda anual:
${HOME}/entra/exec/trans.f.out<<eof
6
$input
$output
-1 #multiplicar por un factor -1 para que sea una resta
${output2}
eof

#rm tmp* plantilla.* fechas
