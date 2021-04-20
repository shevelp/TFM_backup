#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       GMT: PLOTTING MAPS                                   #
#                                                                            #
#                                                                            #
#                                                                            #
##############################################################################


# Stablishig flags
#---------------------------------------------------------------------------

PROJ=-JM10c
LIMS=-R-16.5/42./26.5/48.5

RJFLAG="${PROJ} ${LIMS}"

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
# ------------------------------------------------------------------------
#

if [ $paso2 -eq 1 ]  ;  then

#  Escala de color de la temperatura
echo 'makecpt'

echo "Minimum"
cat datos.dat | awk {'print $3'} | sort -n | head -1

echo "Maximum"
cat datos.dat | awk {'print $3'} | sort -n | tail -1

echo 'Select your scale: min/max/freq':
read scale

echo 'Select your period:'
read period 

echo 'Select your frequency in scale'
read freq

echo 'invert? Y = I, N = ""'
read invert

#
#-------------------------------------------------------------------------
#

#Map confg
gmt set MAP_FRAME_WIDTH                 = 2p
gmt set FONT_LABEL                      = 14p,Times-Italic,black


#Color Palette

gmt makecpt -C${scriptsdir}/generico/temp_19lev.cpt -T$scale $invert > color.cpt


#plotting

gmt pscoast $RJFLAG -W0.5p -K > ${file_out}

gmt psbasemap $RJFLAG -Bxa10 -Bya5 -BWesN -K -O >> ${file_out}

cat datos.dat |awk '{print $2, $1, $3}'|gmt psxy $RJFLAG -Ccolor.cpt -Ss0.04c -O -K >> ${file_out}

gmt pscoast $RJFLAG -W0.5 -O -K  >> ${file_out}

gmt psscale -Ccolor.cpt -D5/-0.4/10/0.2h -B$freq -O -K >> ${file_out}

gmt pstext -R -JM -N -D-0.5/0 -O << eof>> ${file_out}
42 28 10 0 4 CM $period
eof


# ... Cierra el fichero ...
#
gmt psxy $RJFLAG /dev/null -O >>  ${file_out}

fi














