            program origin2
chelpini
c_______________________________________________________________
c
c Objetivo:     Pasa unformated a columnas. No escribe cabeceros.
c               Escribe los datos del campo si ninguno es missing
c Metodo:       Obvio
c Comentarios:
c
c     I/O:
c      write (*,*)'Inputfile?'
c      read(*,150)in
c      write (*,*)'Factor?'
c      read(*,*)fac
c      write(*,*)'Outputfile?'
c      read(*,150)out
c150   format(a64)
c      open(10,file=in,form='formatted')
c
c________________________________________________________________
chelpfin
c
c
      parameter(nr=4,spval=9E10)
      integer ia(nr),year,mon,day,hour,min
      real fac
      real f(150000),g(150000)
      character*100 in,out

      write (*,*)'Inputfile?'
      read(*,150)in
      write (*,*)'Factor?'
      read(*,*)fac
      write(*,*)'Outputfile?'
      read(*,150)out
150   format(a64)
c
      open(10,file=in,status='unknown',form='unformatted')
      open(11,file=out)
c
      i=0
      kk=1
 10   i=i+1
           read(10,end=1990)(ia(j),j=1,4)
           year=int(ia(1)/1000000)
           mon=int((ia(1)-year*1000000)/10000)
           day=int((ia(1)-(year*1000000+mon*10000))/100)
           hour=int(ia(1)-(year*1000000+mon*10000+day*100))
           min=ia(2)
           read(10)(f(i1),i1=1,ia(4))
      do 100 k=1,ia(4)
c
      if (f(k).eq.spval) kk=0
      g(k)=fac*f(k)
c
 100  continue
c       write(20,6000)i,ia(1),mon,(g(i1),i1=1,ia(4))
      if (kk.ne.0) write(11,5000)(g(i1),i1=1,ia(4))
      kk=1
      goto 10

 5010 format(4i10)
 5000 format(100000f20.4)
 6000 format(i6,2i6,100000f20.4)


 1990 close(10)

      stop
      end
