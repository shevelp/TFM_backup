      program medias
chelpini
c_______________________________________________________________
c
c Objetivo:     Realiza medias con distintos periodos temporales.
c Metodo:       Obvio
c Comentarios:
c
c     Files:
c      open(10,file=in,form='unformatted')
c      open(20,file=out,form='unformatted')
c    
c    I/O:
c
c      write (*,*)'Que opcion para transformar?'
c
c      write (*,*)'1-Media horaria'
c      write (*,*)'2-Media diaria'
c      write (*,*)'3-Media mensual'
c      write (*,*)'4-Media estacional'
c      write (*,*)'5-Media anual'
c      read(*,*)opt

c________________________________________________________________
chelpfin
c
c

      parameter(nr=4,spval=9.E10,nd=101178)
      integer ia(nr),ib(nr),opt,isuma(nd),ndatos(nd),nmissing(nd)
      real factor,val1,val2
      real f(nd),ff(nd),g(nd),media(nd),rmis(nd),suma(nd)
      character*100 in,out,in2
c 
      write(*,*)'Inputtfile?'
      read(*,5) in
      write(*,*)'Outputfile?'
      read(*,5) out
 5    format(A100)

      open(3,file='media.log')
      open (10,file=in,form='unformatted')
      open (20,file=out,form='unformatted')
      open (30,file='missing.ext',form='unformatted')
   
      write (*,*)'1-Media horaria'
      write (*,*)'2-media diaria' 
      write (*,*)'3-Media mensual'
      write (*,*)'4-Media estacional'
      write (*,*)'5-Media anual'
      write (*,*)' '
      write (*,*)'Que opcion para transformar?'
      read(*,*)opt

c
c  medias diarias. Opcion 2
c
      
      if (opt.eq.2) then
      write (*,*) 'missing>... para anular valor?'
      read (*,*) kkk
      idiacomp=1
      ib(2)=0
      ib(3)=1
      nmissing=0
      nanulado=0
      ndatos=0
      nmissing=0
      isuma=0
      suma=0
      kontador=0
 102  read(10,end=112)(ia(j),j=1,4)
      read(10)(f(i1),i1=1,ia(4))
      kontador=kontador+1
      
      iyear=int(ia(1)/1000000)
      imes=int((ia(1)-iyear*1000000)/10000)
      idia=int((ia(1)-(iyear*1000000+imes*10000))/100)
      

      if (idia.ne.idiacomp) then
         kontador=kontador-1
         do 992 i=1,ia(4)
         if (nmissing(i).gt.kkk) then
         nanulado=nanulado+1
         media(i)=spval
         else
         media(i)=suma(i)/float(ndatos(i))
         endif
         rmis(i)=float(nmissing(i))/float(kontador)

         write(3,*)iantiguo,i,nmissing(i),kontador,media(i)
         ndatos(i)=0
         suma(i)=0
         
         
 992     continue
         iantiguo=int(iantiguo/100)*100
         write(20)iantiguo,ib(2),ib(3),ia(4)
         write(20)(media(j),j=1,ia(4))
         write(30)iantiguo,ib(2),ib(3),ia(4) 
         write(30)(rmis(j),j=1,ia(4))
         write(3,*)iantiguo
         kontador=1
         nmissing=0
         idiacomp=idia
       endif

      do 502 i=1,ia(4)
         if (f(i).eq.spval) then
         nmissing(i)=nmissing(i)+1
         else        
         suma(i)=suma(i)+f(i)
         ndatos(i)=ndatos(i)+1
         endif
 502  continue
      iantiguo=ia(1)
      goto 102
 
c
c ahora escribe el último día
c

 112     kontador=kontador-1
         
         do 9912 i=1,ia(4)
         if (nmissing(i).gt.kkk) then
         nanulado=nanulado+1
         media(i)=spval
         else
         media(i)=suma(i)/float(ndatos(i))
         endif

         rmis(i)=float(nmissing(i))/float(kontador)
         ndatos(i)=0
         suma(i)=0
         
         
 9912    continue
         iantiguo=iantiguo-23
         write(20)iantiguo,ib(2),ib(3),ia(4)
         write(20)(media(j),j=1,ia(4))
         write(30)iantiguo,ib(2),ib(3),ia(4) 
         write(30)(rmis(j),j=1,ia(4))
         write(3,*) nanulado 
         goto 1001
      endif
c
c   medias horarias. Opcion 1
c


      if (opt.eq.1) then
      write (*,*) 'missing>... para anular valor?'
      read (*,*) kkk
      ihoracomp=0
      ib(2)=0
      ib(3)=1
      nmissing=0
      nanulado=0
      ndatos=0
      nmissing=0
      isuma=0
      suma=0
      kontador=0
 101  read(10,end=111)(ia(j),j=1,4)
      read(10)(f(i1),i1=1,ia(4))
      kontador=kontador+1
      
      iyear=int(ia(1)/1000000)
      imes=int((ia(1)-iyear*1000000)/10000)
      idia=int((ia(1)-(iyear*1000000+imes*10000))/100)
      ihora=ia(1)-(iyear*1000000+imes*10000+idia*100)

      if (ihora.ne.ihoracomp) then
         kontador=kontador-1
         do 991 i=1,ia(4)
         if (nmissing(i).gt.kkk) then
         nanulado=nanulado+1
         media(i)=spval
         else
         media(i)=suma(i)/float(ndatos(i))
         endif

         rmis(i)=float(nmissing(i))/float(kontador)
         write(3,*)iantiguo,i,nmissing(i),kontador,media(i),rmis(i)
         ndatos(i)=0
         suma(i)=0
 991     continue
         
         write(20)iantiguo,ib(2),ib(3),ia(4)
         write(20)(media(j),j=1,ia(4))
         write(30)iantiguo,ib(2),ib(3),ia(4) 
         write(30)(rmis(j),j=1,ia(4))
c         write(3,*)iantiguo,i,nmissing,kontador,media(i)
         kontador=1
         nmissing=0
         ihoracomp=ihora
       endif

      do 501 i=1,ia(4)
         if (f(i).eq.spval) then
         nmissing(i)=nmissing(i)+1
         else        
         suma(i)=suma(i)+f(i)
         ndatos(i)=ndatos(i)+1
         endif
 501  continue
      iantiguo=ia(1)
      goto 101
 
c
c ahora escribe la ultima hora
c

 111     kontador=kontador-1
         
         do 9911 i=1,ia(4)
         if (nmissing(i).gt.kkk) then
         nanulado=nanulado+1
         media(i)=spval
         else
         media(i)=suma(i)/float(ndatos(i))
         endif

         rmis(i)=float(nmissing(i))/float(kontador)
         ndatos(i)=0
         suma(i)=0
         
         
 9911    continue
         
         write(20)iantiguo,ib(2),ib(3),ia(4)
         write(20)(media(j),j=1,ia(4))
         write(30)iantiguo,ib(2),ib(3),ia(4) 
         write(30)(rmis(j),j=1,ia(4))
         write(3,*) nanulado 
         goto 1001
      endif

c
c  medias mensuales. Opcion 3
c

      if (opt.eq.3) then
      write (*,*) 'missing>... para anular valor?'
      read (*,*) kkk
      imescomp=1
      ib(2)=0
      ib(3)=1
      nmissing=0
      nanulado=0
      ndatos=0
      nmissing=0
      isuma=0
      suma=0
      kontador=0
 1002 read(10,end=192)(ia(j),j=1,4)
      read(10)(f(i1),i1=1,ia(4))
      kontador=kontador+1
      
      iyear=int(ia(1)/1000000)
      imes=int((ia(1)-iyear*1000000)/10000)
      
      if (imes.ne.imescomp) then
         kontador=kontador-1
         do 1992 i=1,ia(4)
         if (nmissing(i).gt.kkk) then
         nanulado=nanulado+1
         media(i)=spval
         else
         media(i)=suma(i)/float(ndatos(i))
         endif
         rmis(i)=float(nmissing(i))/float(kontador)

         write(3,*)iantiguo,i,nmissing(i),kontador,media(i)
         ndatos(i)=0
         suma(i)=0
         
         
 1992    continue
         iantiguo=int(iantiguo/10000)*10000
         write(20)iantiguo,ib(2),ib(3),ia(4)
         write(20)(media(j),j=1,ia(4))
         write(30)iantiguo,ib(2),ib(3),ia(4) 
         write(30)(rmis(j),j=1,ia(4))
         write(3,*)iantiguo
         kontador=1
         nmissing=0
         imescomp=imes
       endif

      do 512 i=1,ia(4)
         if (f(i).eq.spval) then
         nmissing(i)=nmissing(i)+1
         else        
         suma(i)=suma(i)+f(i)
         ndatos(i)=ndatos(i)+1
         endif
 512  continue
      iantiguo=ia(1)
      goto 1002
 
c
c ahora escribe el último mes
c

 192     kontador=kontador-1
         
         do 6612 i=1,ia(4)
         if (nmissing(i).gt.kkk) then
         nanulado=nanulado+1
         media(i)=spval
         else
         media(i)=suma(i)/float(ndatos(i))
         endif

         rmis(i)=float(nmissing(i))/float(kontador)
         ndatos(i)=0
         suma(i)=0
         
         
 6612    continue
         iantiguo=int(iantiguo/10000)*10000
         write(20)iantiguo,ib(2),ib(3),ia(4)
         write(20)(media(j),j=1,ia(4))
         write(30)iantiguo,ib(2),ib(3),ia(4) 
         write(30)(rmis(j),j=1,ia(4))
         write(3,*) nanulado 
         goto 1001
      endif
      

c
c     medias anuales. Opción 5
c

      if (opt.eq.5) then
         write(*,*) 'porcentaje de missing > q 0... para anular valor?'
         read(*,*) porc
      iyearcomp=1992
      ib(2)=1
      ib(3)=1
      nmissing=0
      ndatos=0
      nmissing=0
      isuma=0
      kontador=0
 10   read(10,end=100)(ia(j),j=1,4)
      read(10)(f(i1),i1=1,ia(4))
      kontador=kontador+1
      
      iyear=int(ia(1)/1000000)
      if (iyear.ne.iyearcomp) then
         kontador=kontador-1
         do 99 i=1,ia(4)
         rmis(i)=float(nmissing(i))/float(kontador)
         if (rmis(i).gt.porc) then
         media(i)=spval
         else
         media(i)=float(isuma(i))/float(ndatos(i))
         endif        
        
         write (3,'(i10,i5,f8.2,i10)') iyearcomp,i,rmis(i),nmissing(i)
         ndatos(i)=0
         isuma(i)=0
         nmissing(i)=0
         
 99      continue         
         write(20)iyearcomp,ib(2),ib(3),ia(4)
         write(20)(media(j),j=1,ia(4))
         write(30)iyearcomp,ib(2),ib(3),ia(4)
         write(30)(rmis(j),j=1,ia(4))
         kontador=1
         iyearcomp=iyear
       endif

      do 50 i=1,ia(4)
         if (f(i).eq.spval) then
         nmissing(i)=nmissing(i)+1
         else
         isuma(i)=isuma(i)+f(i)
         ndatos(i)=ndatos(i)+1
         endif
 50   continue
      goto 10
 100  continue
      endif
 1001  stop
      end
