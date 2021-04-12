      program ponfecha
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa que pon fecha a fichero extra
c Metodo:       Obvio
c Comentarios:   Para ficheros mensuales
c
c     I/O:
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      write (*,*)'Anoinicial?' 
c      read(*,*)anoi
c      write (*,*)'Mes inicial,mes final?' 
c      read(*,*)mesi,mesf
c
c________________________________________________________________
chelpfin
      parameter(nr=4,spval=9.E10)
      integer ia(nr),ano,mes,anoi,mesi,mesf,ano2,mes2,meslim,fecha
      real miss
      real f(80000)
      character*100 in
      
      miss=9999999999.9
      write (*,*)'Inputfile?' 
      read(*,150)in
      write (*,*)'Anoinicial?' 
      read(*,*)anoi
      write (*,*)'Mes inicial,mes final?' 
      read(*,*)mesi,mesf
c      
150   format(a100)
c
      open(10,file=in,form='unformatted')
      open(11,file='ponfecha.ext',form='unformatted')
c
      meslim=mesf+1
      kk=0
      k=0
 10   k=k+1
           read(10,end=1990)(ia(j),j=1,4)
           read(10)(f(i1),i1=1,ia(4))
c
      ano=int(ia(1)/1000000)
      mes=int(ia(1)/10000)-(ano*100)
      dia=00
c
      if (k.eq.1) then 
       ano2=anoi
       mes2=mesi
      else
       mes2=mes2+1
       ano2=ano2
c       if (mes2.eq.meslim) then
c         mes2=mesi
c         if (mesi.lt.mesf) kk=1
c         if (mesi.gt.mesf) kk=0
c       endif
       if (mes2.eq.13) then
         mes2=1
         kk=1
       endif
       if (kk.eq.1) then
         ano2=ano2+1
         kk=0
       endif
       if (mesi.eq.mesf) then
       ano2=ano2+1
       mes2=mesi
       endif
      endif
c
      fecha=ano2*10000
      fecha=fecha+(mes2*100)
      fecha=fecha+dia
      ia(1)=fecha
      ia(1)=ia(1)*100 
c
      write(11)(ia(j),j=1,4)
      write(11)(f(i1),i1=1,ia(4))
      goto 10
c
 5010 format(4i10)
 1990 close(10)
      close(11)
      stop
      end


