#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       GMT: PLOTTING MAPS	                             #
#                                                                            #
#                                                                            #
#                                                                            #
##############################################################################


# Stablishig flags
#---------------------------------------------------------------------------


RFLAG=-R-16.5/42./26.5/48.5 # SELECT YOUR MARK! (format is W_Border/E_Border/S_Border/N_Border)

JFLAG=-Jm0.2c
RJFLAG="${RFLAG} ${JFLAG}"
#IFLAG=-I0.5m


# Select your directories
#---------------------------------------------------------------------------

dirhome=/home/sergiolp/Work/TFM
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
workdir=${dirhome}/work


file1=$1 #YOUR CLIMATE DATA
file_latlon=${dirhome}/data/d2/lat_lon_GReatModelS.dat #YOUR LATLON DATA
file_out=${workdir}/d2/cont_analysis.ps


#
# -------------------------------------------------------------------------
#

paso1=1 # Crea el fichero asccii para el gmt
paso2=1 # Plot
paso3=0 # Borra

#
# -------------------------------------------------------------------------
#


# Asci format file generation 
#---------------------------------------------------------------------------

if [ $paso1 -eq 1 ]  ;  then

#COMPILING
${scriptsdir}/generico/compila.sh       traspon.f
${scriptsdir}/generico/compila.sh       origin.f

for f in ${file1} ; do

${progsdirexec}/traspon.f.out<<EOF
${f}
${f}.tmp.t
n
EOF
#
${progsdirexec}/origin.f.out<<EOF
${f}.tmp.t
1.0
${f}.tmp2.dat
EOF

rm ${f}.tmp.t

cut -c 39-100 ${f}.tmp2.dat > ${f}.tmp.dat
rm ${f}.tmp2.dat

paste ${file_latlon} ${f}.tmp.dat > datos.dat

rm ${f}.tmp.dat 

done

fi

#Filtering data to remove blueline

awk 'NR < 100001 { print }' datos.dat| sponge datos.dat

#
# -----------------------------------------------------------------------
#

# Plotting
#---------------------------------------------------------------------------

if [ $paso2 -eq 1 ] ; then

#
#   SETTINGS  #
gmt set MAP_FRAME_WIDTH			= 0.01p
gmt set FONT_LABEL			= 14p,Times-Italic,black
gmt set PS_MEDIA 			= A3


#   SETTINGS  #

#  Escala de color de la temperatura
echo 'makecpt'

echo "Minimum"
cat datos.dat | awk {'print $3'} | sort -n | head -1

echo "Maximum"
cat datos.dat | awk {'print $3'} | sort -n | tail -1

echo 'Select your scale: min/max/freq':
read scale

echo 'Select your variable:'
read var

gmt makecpt -C${scriptsdir}/generico/temp_19lev.cpt -T$scale > color.cpt


#Dibuja las lineas de costa y topografia

echo 'pscoast'

gmt pscoast $RJFLAG -Ba15f10/a5f5 -W1 -Dh -A100  -P -K  > ${file_out}

#  Dibuja el mapa de observaciones sobre su grid 
cat datos.dat |awk '{print $2, $1, $3}'| gmt psxy $RJFLAG -Ccolor.cpt -Ss0.04c -O -K     >>${file_out} # Relleno del grid 1.0 x 1.0

gmt pscoast $RJFLAG -Ba15f10/a5f5 -W1 -Dh -A100  -O -K  >> ${file_out}

#  Escala para la leyenda
echo 'psscale'

gmt psscale -Ccolor.cpt -D6/-0.8/9/0.2h  -B10:"$var": -O -K >> ${file_out}

# ... Cierra el fichero ...
#
gmt psxy $RJFLAG /dev/null -O >>  ${file_out}

fi

# Removing intermediate files 
#---------------------------------------------------------------------------
if [ $paso3 -eq 1 ] ; then

rm gmt.history  color.cpt 
rm datos.dat

fi

#---------------------------------------------------------------------------

exit
