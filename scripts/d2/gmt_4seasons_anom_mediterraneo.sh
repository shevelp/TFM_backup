#!/bin/bash
#
#   Script de GMT (Generic Mapping Tools, http://www.soest.hawaii.edu/gmt/)
#
#----------------------------
file1=$1 #(datos primavera) #(datos temperatura)
file2=$2 #(datos verano) 
file3=$3 #(datos otoño) 
file4=$4 #(datos invierno) 
file_latlon=lat_lon_GReatModelS.dat
file_out=$5  # nombre fichero salida (con nombre estación del año o anual)

#

RFLAG=-R-16.5/42./26.5/48.5 # esto es el marco del Mediterráneo
#JFLAG=-JM-76/37/12c

JFLAG=-Jm0.13c

#JFLAG=-JQ1/5i
#JFLAG=-JM10

#JFLAG=-Jl-2.3/38/10/80/1:16500000
#IFLAG=-I.05g



RJFLAG="${RFLAG} ${JFLAG}"
#IFLAG=-I0.6c
#IFLAG=-I.05m

#
# ------------------------------------------------------------------------
#
paso1=1 # Crea el fichero asccii para el gmt: lon lat fecha inicio y longitud
paso2=1 # Dibuja.
paso3=1 # Borra

#
# ------------------------------------------------------------------------ 
#
if [ $paso1 -eq 1 ]  ;  then
#


################################################################ Spring
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

paste ${file_latlon} ${file1}.tmp.dat > datos.dat

rm ${file1}.tmp.dat 

#awk '$1 >= "44.5" { next } { print }' datos.dat > datosP.dat	
awk 'NR < 100001 { print }' datos.dat > datosSpring.dat                  # para quitar la línea azul superior	

rm datos.dat


############################################################### Summer

for file in ${file2} ; do
	
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

cut -c 39-100 ${file2}.tmp2.dat > ${file2}.tmp.dat
rm ${file2}.tmp2.dat  

paste ${file_latlon} ${file2}.tmp.dat > datos.dat

rm ${file2}.tmp.dat 

#awk '$1 >= "44.5" { next } { print }' datos.dat > datosP.dat	
awk 'NR < 100001 { print }' datos.dat > datosSummer.dat                  # para quitar la línea azul superior	

rm datos.dat


###############################################################  Autumn

for file in ${file3} ; do
	
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

cut -c 39-100 ${file3}.tmp2.dat > ${file3}.tmp.dat
rm ${file3}.tmp2.dat  

paste ${file_latlon} ${file3}.tmp.dat > datos.dat

rm ${file3}.tmp.dat 

#awk '$1 >= "44.5" { next } { print }' datos.dat > datosP.dat	
awk 'NR < 100001 { print }' datos.dat > datosAutumn.dat                  # para quitar la línea azul superior	

rm datos.dat


###############################################################  Winter

for file in ${file4} ; do
	
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

cut -c 39-100 ${file4}.tmp2.dat > ${file4}.tmp.dat
rm ${file4}.tmp2.dat  

paste ${file_latlon} ${file4}.tmp.dat > datos.dat

rm ${file4}.tmp.dat 

#awk '$1 >= "44.5" { next } { print }' datos.dat > datosP.dat	
awk 'NR < 100001 { print }' datos.dat > datosWinter.dat                  # para quitar la línea azul superior	

rm datos.dat




fi
#




# -----------------------------------------------------------------------
#
if [ $paso2 -eq 1 ] ; then

#
#   SETTINGS  #
gmt set MAP_FRAME_WIDTH			= 0.01p
gmt set FONT_LABEL			= 14p,Times-Italic,black
gmt set FONT_TITLE			= 16p,Times-Roman,gray39
#   SETTINGS  #

#  EScala de color de la temperatura
echo 'makecpt'

#gmt makecpt -T0.-20/30.0/5  $escala  -I  > color.cpt
#gmt makecpt -T-10.0/35.0/1  -Crainbow -Z > color.cpt
#gmt makecpt -T-3.0/3.0/0.01  -Cpolar -Z  > color.cpt
gmt makecpt -Cpolar -T-3/3/1 -Z  > color.cpt
#gmt makecpt -Cblue,white,red -T-10,0,1,20 -N > color.cpt
#gmt makecpt  -Cpolar -T-10.0,0,20.0   -Z  > color.cpt
#gmt makecpt  -Cpolar -T-3.0,0,3.0   -Z  > color.cpt
#gmt makecpt -Cpolar +h T-10.0/20.0/1  > color.cpt
#gmt makecpt -Cpolar+h -T-10/20/1 > color.cpt

#Dibuja las lineas de costa ...

echo 'pscoast'

#gmt pscoast $RJFLAG -Ba10f2/a5f5 -W1 -Dh -A100  -P -K  > ${file_out}





#cat datosP.dat |awk '{print $2, $1, $3}'| gmt psxy $RJFLAG -Ccolor.cpt -Ss0.03c -B+t"Temperature" -O -K     >>${file_out}     # Relleno del grid 1.0 x 1.0
#cat datos.dat |awk '{print $2, $1, $3}'| gmt psxy $RJFLAG -W0.01,darkgray -Ss0.01c -O -K  >>${file_out}     # Bordes del grid 1.0 x 1.0




# PAra sacar varios mapas juntos:
cat datosSpring.dat |awk '{print $2, $1, $3}'| gmt psxy $RJFLAG -Ccolor.cpt -Ss0.03c -B+t"a)  MAM" -P -K -Xc-5 -Yc+8    >${file_out}     # Relleno del grid 1.0 x 1.0
gmt pscoast $RJFLAG -Ba10f2/a5f5 -W1 -Dh -A100  -O -K  >> ${file_out}


cat datosSummer.dat |awk '{print $2, $1, $3}'| gmt psxy $RJFLAG -Ccolor.cpt -Ss0.03c -B+t"b)  JJA" -O -K -Xc+5 -Yc+8    >>${file_out}     # Relleno del grid 1.0 x 1.0
gmt pscoast $RJFLAG -Ba10f2/a5f5 -W1 -Dh -A100  -O -K  >> ${file_out}


cat datosAutumn.dat |awk '{print $2, $1, $3}'| gmt psxy $RJFLAG -Ccolor.cpt -Ss0.03c -B+t"c)  SON" -O -K -Xc-5 -Yc+1     >>${file_out}     # Relleno del grid 1.0 x 1.0
gmt pscoast $RJFLAG -Ba10f2/a5f5 -W1 -Dh -A100  -O -K  >> ${file_out}


cat datosWinter.dat |awk '{print $2, $1, $3}'| gmt psxy $RJFLAG -Ccolor.cpt -Ss0.03c -B+t"d)  DJF" -O -K -Xc+5 -Yc+1     >>${file_out}     # Relleno del grid 1.0 x 1.0
gmt pscoast $RJFLAG -Ba10f2/a5f5 -W1 -Dh -A100  -O -K  >> ${file_out}






#  Escala para la leyenda
echo 'psscale'

gmt psscale -Ccolor.cpt -D6/-0.9/13/0.3h -B1:"Temperature anomaly (@~\260@~C)": -O -K  -Xc+0.5 -Yc-2  >> ${file_out}
#gmt psscale -Ccolor.cpt -Dx0/0+w10c+h -O -K >> ${file_out}
#gmt psscale -Ccolor.cpt -Baf -Y2c -K -O >> ${file_out}

# ... Cierra el fichero ...
#
gmt psxy $RJFLAG /dev/null -O >>  ${file_out}

fi

# -----------------------------------------------------------------------
#
if [ $paso3 -eq 1 ] ; then

rm gmt.history  color.cpt 
rm datosSpring.dat datosSummer.dat datosAutumn.dat datosWinter.dat

fi

#----------------------------------------------------------------

exit
