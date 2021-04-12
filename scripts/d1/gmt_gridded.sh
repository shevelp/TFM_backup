#!/bin/bash
#
#   Script de GMT (Generic Mapping Tools, http://www.soest.hawaii.edu/gmt/)
#
#----------------------------
#

RFLAG=-R70./145./15./50. # esto es el marco de China

JFLAG=-JQ0/5i
JFLAG=-JM10
RJFLAG="${RFLAG} ${JFLAG}"
IFLAG=-I0.6m


dirhome=/home/sergiolp/Work/TFM
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
workdir=${dirhome}/work


file1=$1 #(datos temperatura)
file_latlon=${dirhome}/data/d1/cru_1.0_latlon.dat
file_out=${workdir}/d1/cru1.0_temp_china.ps


#
# ------------------------------------------------------------------------
#
paso1=1 # Crea el fichero asccii para el gmt: lon lat fecha inicio y longitud
paso2=1 # Dibuja.
paso3=0 # Borra

#
# ------------------------------------------------------------------------ 
#
if [ $paso1 -eq 1 ]  ;  then

#COMPILING 
${scriptsdir}/generico/compila.sh       traspon.f
${scriptsdir}/generico/compila.sh       origin.f

for file in ${file1} ; do	
${progsdirexec}/traspon.f.out<<EOF
${file}
${file}.tmp.t
n
EOF
#
${progsdirexec}/origin.f.out<<EOF
${file}.tmp.t
1.0
${file}.tmp2.dat
EOF

rm ${file}.tmp.t

done

cut -c 39-100 ${file1}.tmp2.dat > ${file1}.tmp.dat
rm ${file1}.tmp2.dat  

paste ${file_latlon} ${file1}.tmp.dat > datos.dat

rm ${file1}.tmp.dat 
	
fi


#
# -----------------------------------------------------------------------
#
if [ $paso2 -eq 1 ] ; then

#
#   SETTINGS  #
gmt set MAP_FRAME_WIDTH			= 0.1p
gmt set FONT_LABEL			= 12p,Times-Italic,black
#   SETTINGS  #

#  EScala de color de la temperatura
echo 'makecpt'

gmt makecpt -T0.0/40.0/10  $escala  -I  > color.cpt


#Dibuja las lineas de costa ...

echo 'pscoast'

gmt pscoast $RJFLAG -Ba15f10/a5f5 -W2 -Dl -A100  -P -K  > ${file_out}


#  Dibuja el mapa de observaciones sobre su grid 
cat datos.dat |awk '{$2 $1 $3}'| gmt psxy $RJFLAG -Ccolor.cpt -Ss1.4c -O -K     >>$file_out     # Relleno del grid 1.0 x 1.0
cat datos.dat |awk '{$2 $1 $3}'| gmt psxy $RJFLAG -W0.5,darkgray -Ss1.5c -O -K  >>$file_out     # Bordes del grid 1.0 x 1.0


#  Escala para la leyenda
echo 'psscale'

gmt psscale -Ccolor.cpt -D6/-0.8/9/0.2h -B10:"Observed temperature (C deg)": -O -K >> ${file_out}


# ... Cierra el fichero ...
#
gmt psxy $RJFLAG /dev/null -O >>  ${file_out}

fi
# -----------------------------------------------------------------------
#
if [ $paso3 -eq 1 ] ; then

rm gmt.history  color.cpt 
rm datos.dat

fi

#----------------------------------------------------------------

exit
