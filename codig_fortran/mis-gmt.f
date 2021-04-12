      program misgmt
chelpini
c_______________________________________________________________
c
c Objetivo:     Quita filas de missing en un fichero ascii
c Metodo:       Obvio
c Comentarios:
c
c     I/O:
c      write (*,*)'Inputfile?' 
c      read(*,150)in      
c      write(*,*)'Outputfile?'
c      read(*,150)out
c150   format(a64)
c      open(10,file=in,form='formatted')
c
c________________________________________________________________
chelpfin
c
c
      parameter(nr=40,spval2=-9999.9004)
      real lat,lon,val,kk
      character*64 in,out
      
      write (*,*)'Inputfile?' 
      read(*,150)in
      write(*,*)'Outputfile?'
      read(*,150)out
150   format(a64)
c
      open(10,file=in,status='unknown',form='formatted')
      open(11,file=out,status='unknown',form='formatted')
c
      i=0
 10   i=i+1     
      read(10,*,end=1990)lat,lon,val


       if (val.ne.spval2) then
       write(11,6000)lat,lon,val
      end if
      goto 10

 6000 format(60f20.4)


 1990 close(10)

      stop
      end


