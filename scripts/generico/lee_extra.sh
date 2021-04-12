
#! /bin/sh
#helpini
# _______________________________________________________________________
#
#    
#     Muestra en pantalla contenido de ficheros en formato extra (binario)
#     
# _______________________________________________________________________
#helpfin
#
#
dirhome=/Users/elena/entra/people/TFM/TFM2015
scriptsdir=${dirhome}/scripts/
direxec=${dirhome}/progs/exec/

#
#${scriptsdir}/compila.sh ponasci.f   #Compilar solo una vez!!!

rm q

${direxec}ponasci.f.out<<m1
$1
q
m1
more q

exit
