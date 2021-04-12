#!/bin/sh


###########################################################################
#
#     Pintar  mapa de estaciones en China con GMT
#
###########################################################################

switch1=1 #Mapa
switch2=1 #Limpia

#_________________________________________________________________________
    
    #   Directorios   #
dirhome=/Users/elena/entra/people/TFM/TFM2017

workdir=${dirhome}/work/d1
datadir=${dirhome}/data/d1
plotsdir=${dirhome}/plots/d1

progsdir=${dirhome}/progs
scriptsdir=${dirhome}/scripts

#----------------------------------------------> Switch1
if [ ${switch1} -eq 1 ] ;  then

cd ${workdir}

#Compilo los programas que necesito
${scriptsdir}/generico/compila.sh origin2.f
${scriptsdir}/generico/compila.sh origin.f
${scriptsdir}/generico/compila.sh traspon.f


#Copio al directorio de trabajo los datos que necesito
cp ${datadir}/latlon_recons.ext                   ${workdir}
cp ${datadir}/china.fechaini.ext                  ${workdir}
cp ${datadir}/china.grd                           ${workdir}
cp ${datadir}/symbols_recons_locals.dat           ${workdir}


#Paso a formato ascii los datos de latitud y longitud de las estaciones
${progsdir}/exec/origin2.f.out<<eof
latlon_recons.ext
1
china_latlon.dat
eof

#Pinto mapa de China con las estaciones y fecha de inicio de las medidas en cada estacion
${scriptsdir}/d1/gmt_map_china.sh china.fechaini.ext

#Paso de ps a eps para recortar los bordes

ps2eps china_locs.ps
mv china_locs.eps ${plotsdir}



fi

#----------------------------------------------> Switch2
if [ ${switch2} -eq 1 ] ;  then

rm plot.1
rm china_locs.ps
rm latlon_recons.ext china.fechaini.ext
rm symbols_recons_locals.dat china_latlon.dat

fi

#_________________________________________________________________________

exit
