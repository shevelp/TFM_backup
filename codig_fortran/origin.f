      program origin
chelpini
c_______________________________________________________________
c
c Objetivo:     Pasa unformated a columnas
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
      parameter(nr=40,spval=9E10)
      integer ia(nr),year,mon,day,hour
      real fac
      real f(150000),g(150000)
      character*64 in,out
      
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
 10   i=i+1     
           read(10,end=1990)(ia(j),j=1,4)


           year=int(ia(1)/10000)
           mon=int((ia(1)-year*10000)/100)
           day=int(ia(1)-(year*10000+mon*100))
           hour=int(ia(2))
           
           read(10)(f(i1),i1=1,ia(4))
      do 100 k=1,ia(4)
c
      if (f(k).eq.spval) f(k)=-9999.9
      g(k)=fac*f(k)
c
 100  continue
c           write(11,6000)i,ia(1),mon,(g(i1),i1=1,ia(4))
       write(11,5000)i,year,mon,day,hour,(g(i1),i1=1,ia(4))
      goto 10

 5010 format(4i10)
 5000 format(i6,i7,3i5,40f20.5)
 6000 format(i6,2i6,40f20.4)


 1990 close(10)

      stop
      end


