      program sacser
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa para extraer una serie temporal
c Metodo:       Obvio
c Comentarios:  
c
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      write (*,*)'Que serie ques sacar?'
c      read(*,*)num
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
      parameter(nr=4,nspa=300000)
      integer ia(nr)
      integer num,a,total
      real f(nspa)
      character*64 in,out
      
      write (*,*)'Inputfile?' 
      read(*,150)in
      write (*,*)'Que serie ques sacar?'
      read(*,*)num
      write(*,*)'Outputfile?'
      read(*,150)out
150   format(a64)

      open(10,file=in,form='unformatted')
      open(11,file=out,form='unformatted')
c
         a=0
 10      a=a+1
         read(10,end=1990)(ia(j),j=1,4)
         read(10)(f(i1),i1=1,ia(4))
c
      do 20 i=1,ia(4)
c
      if (i.eq.num) then
       write(11)(ia(j),j=1,3),1
       write(11)f(i)
      endif
c
 20   continue
c
      goto 10
c
 1990 close(10)
      close(11)

      stop
      end


