      program origin
chelpini
c_______________________________________________________________
c
c Objetivo:     Pasa unformated a columnas con fechas gnuplot
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
      real f(60000),g(60000)
      character*64 in,out
      character fecha
      character*1 com
c
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
      com='"'
      i=0
 10   i=i+1     
           read(10,end=1990)(ia(j),j=1,4)
           year=int(ia(1)/1000000)
           mon=int((ia(1)-year*1000000)/10000)
           day=int((ia(1)-(year*1000000+mon*10000))/100)
           hour=int(ia(1)-(year*1000000+mon*10000+day*100))
           min=ia(2)
           if (min.gt.60) min=0
           read(10)(f(i1),i1=1,ia(4))
      do 100 k=1,ia(4)
c
      if (f(k).eq.spval) then
      g(k)=-9999.9
      else
      g(k)=fac*f(k)
      endif
c
 100  continue
c       write(20,6000)i,ia(1),mon,(g(i1),i1=1,ia(4))
c       write(11,5000)i,year,mon,day,hour,min,(g(i1),i1=1,ia(4))
      write (11,7000)i,year,"/",mon,"/",day,hour,":",min,
     .(g(i1),i1=1,ia(4))
      goto 10

 5010 format(4i10)
 5000 format(i6,5i5,50f20.4)
 6000 format(i6,2i6,50f20.4)
 7000 format(i6,3x,i4,a,i2.2,a,i2.2,1x,i2.2,a,i2.2,2x,20(e12.5,2x))

 1990 close(10)

      stop
      end


