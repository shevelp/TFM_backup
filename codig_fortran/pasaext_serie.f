           program pasaext_serie

c
chelpini
c_______________________________________________________________
c
c Objetivo:     Pasa de ascii a extra una columna de datos
c Metodo:       Obvio
c Comentarios:
c
c     Files:
c
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      write(*,*)'Outputfile'
c      read(*,150)out
c   
c      
c 150   format(a64)
c
c________________________________________________________________
chelpfin
c


      parameter(nr=4,spval=9.e10,spval2=-9999.90)
      real kk,cc
      integer ia(nr),num,nda
      character*64 in,out
      
      write (*,*)'Inputfile?' 
      read(*,150)in
      write(*,*)'Outputfile'
      read(*,150)out
     
      
150   format(a64)
      
      open(10,file=in,form='formatted')
      open(11,file=out,form='unformatted')
      

      ndat=0
 10   read(10,*,end=1990)cc
      ndat=ndat+1
      ia(1)=ndat
      ia(2)=1
      ia(3)=1
      ia(4)=1  
        
      write(11)ia
      write(11)cc
      goto 10
c

c
 1990 close(10)

      stop
      end
