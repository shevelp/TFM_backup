#! /bin/sh
#helpini
# _______________________________________________________________________
#
#    
#     Compila programas fortran 
#     
# _______________________________________________________________________
#helpfin
#
#
dirhome=/home/sergiolp/Work/TFM

dircodig=${dirhome}/progs/codig/
direxec=${dirhome}/progs/exec/
#
    
       cp  ${dircodig}$1     ${direxec}prog-temp.f

       cd  ${direxec}

                  gfortran ${direxec}prog-temp.f

#  o bien 
#                f95  ${dir2}prog-temp.f	
#                f77  ${dir2}prog-temp.f	

       mv  ${direxec}a.out  ${direxec}$1.out
       rm  ${direxec}prog-temp.f

       exit
