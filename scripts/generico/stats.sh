#! /bin/sh

##############################################################################
#                                                                            #
#                                                                            #
#                                                                            #
#                       SHELL SCRIPT: STATISTICAL ANALYSIS(POINTS)           #
#                                (STAT.F(1) + RESTA = BIAS                   #
#                                 BIAS + PLOT                                 #
#                                                                            #
#                                                                            #
##############################################################################


# Select your work directories
#---------------------------------------------------------------------------

dirhome=/home/sergiolp/Work/TFM

workdir=${dirhome}/work/d2
datadir=${dirhome}/data/d2
plotsdir=${dirhome}/plots/d2
progsdir=${dirhome}/progs/codig
progsdirexec=${dirhome}/progs/exec
scriptsdir=${dirhome}/scripts
cajondir=${dirhome}/cajon/codig_fortran


# Selecting the stat (1 = mean) for both matrixes
#---------------------------------------------------------------------------

cd ${workdir}

echo "Whats your first matrix?"
read file1

echo "Whats your second matrix?"
read file2

echo "Output1?"
read outfile1

echo "Output2?"
read outfile2

echo " Seleccion de salida:
0.  Todas las variable
1.  medias
2.  medianas
3.  deviaciones
4.  pseud stand deviati
5.  quartile 1
6.  quartile 2
7.  interquartilic length
8.  maximum value
9.  minimum value
10.  number of missing
11.  number of existing"

read option

echo "Getting operation for matrix 1 \n" 
${progsdirexec}/stat.f.out<<eof #modify program to your dimension
$file1
$outfile1
$option
eof
echo "Done\n"

echo "Getting operation for matrix 2 \n" 
${progsdirexec}/stat.f.out<<eof #modify program to your dimension
${datadir}/$file2
$outfile2
$option
eof
echo "Done\n"

# Calculating bias = substraction
#----------------------------------------------------------------------------

#### Saco serie sin onda anual:
${progsdirexec}/trans.f.out<<eof
6
$outfile1
$outfile2
-1 #multiplicar por un factor -1 para que sea una resta
bias.ext
eof

