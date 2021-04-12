      program sacfld
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa que saca campo de fichero extra
c Metodo:       Obvio
c Comentarios:  
c     Files:
c
c      open(10,file=in,form='unformatted')
c      open(11,file=out,form='unformatted')
c  
c     Imputs:
c    
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      write (*,*)'Que campo ques sacar (#)?'
c      read(*,*)num
cc      write (*,*)'Que factor queres aplicar (#)?'
cc      read(*,*)fac
c      write(*,*)'Outputfile?'
c      read(*,150)out
c150   format(a64)
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c
c     Outputs:
c
c     Escribe campo seleccionado
c
c         read(10,end=1990)(ia(j),j=1,4)
c         read(10)(f(i1),i1=1,ia(4))
c         if (a.eq.num) then
cc         do 100 i=1,ia(4)
cc
cc         f(i)=fac*f(i)
cc
cc 100     continue
c         write(11)(ia(j),j=1,4)
c         write(11)(f(i1),i1=1,ia(4))
c    
c
c________________________________________________________________
chelpfin
c  Programa para extraer eofs de fichero salida
c  de programa mkeof
c 
c  Modificacion a partir de dfor.f
c nr=Zahl der headervariablen
c
      parameter(nr=4)
      integer ia(nr)
      integer num,a
      real fac
      real f(7000000)
      character*64 in,out
      
      write (*,*)'Inputfile?' 
      read(*,150)in
      write (*,*)'Que campo ques sacar (#)?'
      read(*,*)num
c      write (*,*)'Que factor queres aplicar (#)?'
c      read(*,*)fac
      write(*,*)'Outputfile?'
      read(*,150)out
150   format(a64)
c
      open(10,file=in,form='unformatted')
      open(11,file=out,form='unformatted')
c
         a=0
 10      a=a+1
         read(10,end=1990)(ia(j),j=1,4)
         read(10)(f(i1),i1=1,ia(4))
         if (a.eq.num) then
c         do 100 i=1,ia(4)
c
c         f(i)=fac*f(i)
c
c 100     continue
         write(11)(ia(j),j=1,4)
         write(11)(f(i1),i1=1,ia(4))
         goto 1990
         endif
      goto 10

 1990 close(10)
      close(11)

      stop
      end


