#!/bin/bash
#
#   Script de GMT (Generic Mapping Tools, http://www.soest.hawaii.edu/gmt/)
#
#----------------------------
file1=$1 #(anio de inicio de datos)
file_latlon=china_latlon.dat
file_out=china_locs.ps
#

factor=0.01      #medida de los circulos
factor2=-2000
factor3=-1

#

RFLAG=-R70./145./15./50. # esto es el marco de China
JFLAG=-JQ0/5i
#JFLAG=-JM10
RJFLAG="${RFLAG} ${JFLAG}"
IFLAG=-I0.6m

#
# ------------------------------------------------------------------------
#
paso1=1 # Crea el fichero asccii para el gmt: lon lat fecha inicio y longitud
paso2=1 # Dibuja.
paso4=0 # Borra

#
# ------------------------------------------------------------------------ 
#
if [ $paso1 -eq 1 ]  ;  then
#
for file in ${file1} ; do
	
traspon.f.out<<EOF
${file}
${file}.tmp.t
n
EOF
#
origin.f.out<<EOF
${file}.tmp.t
1.0
${file}.tmp2.dat
EOF

rm ${file}.tmp.t

done

cut -c 39-100 ${file1}.tmp2.dat > ${file1}.tmp.dat
rm ${file1}.tmp2.dat  

paste ${file_latlon} ${file1}.tmp.dat symbols_recons_locals.dat > datos.dat

rm ${file1}.tmp.dat 
	
fi
#

# -----------------------------------------------------------------------
#
if [ $paso2 -eq 1 ] ; then

#
#Escala de color para la topografia
gmt makecpt -T0/6000/100 -Z -I -Cgray > china_topo.cpt


#Dibuja la topografia y las lineas de costa ...
#
echo 'grdimage'

gmt grdimage china.grd $RJFLAG -Cchina_topo.cpt  -P -K > ${file_out}

echo 'pscoast'

gmt pscoast $RJFLAG -Ba15f10/a5f5 -W2 -Dl -A100 -K -O >> ${file_out}

#Crea una escala de color para indicar las fechas segun los colores del simbolo
gmt makecpt -T250/2000/5 -Z -I -Crainbow > beta.cpt

#Dibuja los simbolos de color sobre la localizacion de las estaciones

echo 'psxy'

cat datos.dat  | awk '{print $2, $1,  ($3  +'$factor2')*'$factor3' , $4 }' | gmt psxy $RJFLAG -Cbeta.cpt -S0.5 -W1 -O -K >> ${file_out}
factor4=0.5

echo 'psscale'
gmt psscale -Cbeta.cpt -D6/-0.8/9/0.2h -B200:"Years BP": -O -K >> ${file_out}


# ... Cierra el fichero ...
#
gmt psxy $RJFLAG /dev/null -O >>  ${file_out}

fi
# -----------------------------------------------------------------------
#
if [ $paso2 -eq 1 ] ; then

rm gmt.history  beta.cpt china_topo.cpt
rm china.grd datos.dat

fi

#----------------------------------------------------------------

exit
