      program trans
chelpini
c_______________________________________________________________
c
c Objetivo:     Transformacion de datos
c Metodo:       Obvio
c Comentarios:
c
c     Files:
c      open(10,file=in,form='unformatted')
c      open(11,file=out,form='unformatted')
c    
c    I/O:
c
c      write (*,*)'Que opcion para transformar?'
c      write (*,*)'0-Suma cte?' 
c      write (*,*)'1-Multiplica por un factor?'
c      write (*,*)'2-Substituye un valor por outro'
c      write (*,*)'3-Eleva a unha potencia?'
c      write (*,*)'4-Substit datos >,<,= que un valor por missing?'
c      write (*,*)'5-Substit datos >,<,= que un valor por ese valor?'
c      write (*,*)'6-Suma dous ficheiros out=infile+valor*infile2 '
c      write (*,*)'7-Mult dous ficheiros out=infile*infile2*valor '
c      write (*,*)'8-Mult cada paso t de un fichero por un patron'
c      write (*,*)'  out=infile(t)*infile2*valor '
c      write (*,*)'9-Suma cada paso t de un fichero por un patron'
c      write (*,*)'  out=infile(t)+infile2*valor '
c      read(*,*)opt

c________________________________________________________________
chelpfin
c
c
      parameter(nr=4,spval=9.E10,nd=700000)
      integer ia(nr),ib(nr),opt,subo,tim
      real factor,val1,val2
      real f(nd),ff(nd),g(nd)
      character*64 in,out,in2
c      
      write (*,*)'Que opcion para transformar?'
      write (*,*)'0-Suma cte?' 
      write (*,*)'1-Multiplica por un factor?'
      write (*,*)'2-Substituye un valor por outro'
      write (*,*)'3-Eleva a unha potencia?'
      write (*,*)'4-Substit datos >,<,= que un valor por missing?'
      write (*,*)'5-Substit datos >,<,= que un valor por ese valor?'
      write (*,*)'6-Suma dous ficheiros out=infile+valor*infile2 '
      write (*,*)'7-Mult dous ficheiros out=infile*infile2*valor '
      write (*,*)'8-Mult cada paso t de un fichero por un patron'
      write (*,*)'  out=infile(t)*infile2*valor '
      write (*,*)'9-Suma cada paso t de un fichero por un patron'
      write (*,*)'  out=infile(t)+infile2*valor '
      read(*,*)opt
c
      write (*,*)'Inputfile?' 
      read(*,150)in
c
        if (opt.eq.4) then 
        write (*,*)'Opcion 1: >  2: <  3: =?' 
        read(*,*)subo
        endif
        if (opt.eq.5) then 
        write (*,*)'Opcion 1: >  2: <  3: =?' 
        read(*,*)subo
        endif

        if (opt.eq.6.or.opt.eq.7.or.opt.eq.8.or.opt.eq.9) then
        write (*,*)'Inputfile2?' 
        read(*,150)in2
        endif
        if (opt.eq.2) then
        write (*,*)'valor antiguo, valor novo?'
        read(*,*) val1,val2
        else
        write (*,*)'valor?'
        read(*,*)factor
        endif
c
      write(*,*)'Outputfile?'
      read(*,150)out
150   format(a64)
c
c      open(3,file='trans.log',form='formatted')
      open(10,file=in,form='unformatted')
      open(11,file=out,form='unformatted')
      if (opt.eq.6) open(12,file=in2,form='unformatted')
      if (opt.eq.7) open(12,file=in2,form='unformatted')
      if (opt.eq.8) open(12,file=in2,form='unformatted')
      if (opt.eq.9) open(12,file=in2,form='unformatted')
c

      tim=0
 10   tim=tim+1
           read(10,end=1990)(ia(j),j=1,4)
           read(10)(f(i1),i1=1,ia(4))
c
       if (opt.eq.6.or.opt.eq.7) then
c       if (tim.eq.1) then
           read(12)(ib(j),j=1,4)
           read(12)(ff(i1),i1=1,ia(4))
c       endif
       endif
c
       if (opt.eq.8) then
       if (tim.eq.1) then
           read(12)(ib(j),j=1,4)
           read(12)(ff(i1),i1=1,ia(4))
       endif
       endif
c
       if (opt.eq.9) then
       if (tim.eq.1) then
           read(12)(ib(j),j=1,4)
           read(12)(ff(i1),i1=1,ia(4))
       endif
       endif
c
       if (opt.eq.0) then
       do 14, j=1,ia(4)
       g(j)=f(j)+factor
       if (f(j).eq.spval) g(j)=spval
 14    continue
       endif
       if (opt.eq.1) then
       do 15, j=1,ia(4)
       g(j)=f(j)*factor
       if (f(j).eq.spval) g(j)=spval
 15    continue
       endif
       if (opt.eq.2) then
       do 16, j=1,ia(4)
       g(j)=f(j)
       if (f(j).eq.val1) g(j)=val2
 16   continue
       endif
       if (opt.eq.3) then
       do 17, j=1,ia(4)
       if (f(j).ne.0.) then
       g(j)=f(j)**factor
       if (f(j).eq.spval) g(j)=spval
       else
       g(j)=spval
       endif
 17   continue
       endif
       if (opt.eq.4) then
       do 18, j=1,ia(4)
       g(j)=f(j)
       if (subo.eq.1) then
       if (f(j).ne.spval.and.f(j).gt.factor) then
       g(j)=spval
       write(3,*)ia(1),ia(2),j,f(j)
       endif
       endif
       if (subo.eq.2) then
       if (f(j).lt.factor) g(j)=spval
       endif
       if (subo.eq.3) then
       if (f(j).eq.factor) g(j)=spval
       endif
 18   continue
       endif
       if (opt.eq.5) then
       do 19, j=1,ia(4)
       g(j)=f(j)
       if (subo.eq.1) then
       if (f(j).gt.factor) g(j)=factor
       endif
       if (subo.eq.2) then
       if (f(j).lt.factor) g(j)=factor
       endif
       if (subo.eq.3) then
       if (f(j).eq.factor) g(j)=factor
       endif
 19    continue
       endif
       if (opt.eq.6.or.opt.eq.9) then
       do 20, j=1,ia(4)
       g(j)=f(j)+factor*ff(j)
       if (f(j).eq.spval.or.ff(j).eq.spval) g(j)=spval
       write(3,*) f(j),ff(j),g(j),factor    
 20   continue
       endif
       if (opt.eq.7.or.opt.eq.8) then
       do 21, j=1,ia(4)
       g(j)=f(j)*ff(j)*factor
       if (f(j).eq.spval.or.ff(j).eq.spval) g(j)=spval
c       write(3,*) f(j),ff(j),g(j),factor
 21   continue

       endif

c
         write(11)(ia(j),j=1,4)
         write(11)(g(i1),i1=1,ia(4))
c 10   continue
      goto 10
c
 1990 close(10)

      stop
      end






