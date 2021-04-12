      program sacser
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa para convertir ia(2) en minutos exactos
c Metodo:       Obvio
c Comentarios:  
c
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      write(*,*)'Outputfile?'
c      read(*,150)out
c150   format(a64)
c
c      open(10,file=in,form='unformatted')
c      open(11,file=out,form='unformatted')
c
c________________________________________________________________
chelpfin
c
      parameter(nr=4,nspa=101178)
      integer ia(nr),ia3
      real f(nspa)
      character*200 in,out
      
      write (*,*)'Inputfile?' 
      read(*,150)in
      write(*,*)'Outputfile?'
      read(*,150)out
      write (*,*)'valor ia3?'
      read(*,*)ia3
150   format(a64)

	write(*,*) ia3
      open(10,file=in,form='unformatted')
      open(11,file=out,form='unformatted')
c
10         read(10,end=1990)(ia(j),j=1,4)
           read(10)(f(i),i=1,ia(4))
c
      if (ia(3).eq.ia3) then
       write(11)(ia)
       write(11)f(1:ia(4))
      endif
c
      goto 10
c
 1990 close(10)
      close(11)

      stop
      end


