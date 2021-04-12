       program ponascii
c
chelpini
c_______________________________________________________________
c
c Objetivo:     Pasa de extra a ascii
c Metodo:       Obvio
c Comentarios:
c
c     Files:
c
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      write(*,*)'Outputfile?'
c      read(*,150)out
c 150   format(a64)
c
c________________________________________________________________
chelpfin
c
      parameter(nr=4)
      integer ia(nr)
      real f(7000000)
      character*64 in,out
      
      write (*,*)'Inputfile?' 
      read(*,150)in
      write(*,*)'Outputfile?'
      read(*,150)out
150   format(a64)

      open(10,file=in,form='unformatted')
      open(11,file=out)
c
 10      read(10,end=1990)(ia(j),j=1,4)
         read(10)(f(i1),i1=1,ia(4))
         write(11,5010)ia
         write(11,5020)(f(i1),i1=1,ia(4))
      goto 10
c
 5010 format(4i12)
 5020 format(6(1x,e12.5))
c
 1990 close(10)

      stop
      end
