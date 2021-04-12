      program meantime
c
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa que fai media de todo un campo 
c               para cada paso temporal
c Metodo:       Obvio
c Comentarios:  Version sin pesos de desviacion.
c   
c     Files:
c
c      open(3,file='mean.log',form='formatted')
c      open(10,file=in,form='unformatted',status='unknown')
c      open(11,file=out,form='unformatted',status='unknown')
c
c     Imputs:
c
c      write(*,*)'Fichero de datos original?'
c      read(*,'(a24)')in
c      write(*,*)'Fichero de salida?'
c      read(*,'(a24)')out
c
c      Outputs:
c
c      fichero extra con medias de campos
c
c________________________________________________________________
chelpfin
c
c     Modificcado para calcular media de base de datos
c     No medias climaticas sino media en cada punto
c     Logo saca un mapa de medias
c
      parameter(spval=9.E10,spval2=9.E9,ns=101178)
      integer n
      integer ia(4)
      integer i1
      real xmed(ns),data(ns)
      real sum,media
      character*100 in,out

      write(*,*)'Fichero de datos original?'
      read(*,'(a100)')in
      write(*,*)'Fichero de salida?'
      read(*,'(a100)')out
c
      open(3,file='mean.log',form='formatted')
      open(10,file=in,form='unformatted',status='unknown')
      open(11,file=out,form='unformatted',status='unknown')
c
       i=1
 10    read(10,end=699)ia
       read(10)(data(j),j=1,ia(4)) !lee mapa de datos
c
       n=0
       sum=0.0
       do 20 k=1,ia(4)
       if (data(k).ne.spval.and.data(k).ne.spval2) then
       n=n+1
       sum=sum+data(k)
c       write(*,*) sum
       endif
 20    continue
c
       if (n.ne.0) then
        media=sum/float(n)
c       media=sum
       else
       media=spval
       endif
c
       ia(4)=1
       write(11) ia
       write(11) media
       goto 10
 699   continue
c
      stop
      end

 


