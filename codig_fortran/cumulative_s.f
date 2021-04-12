        program cumulative
chelpini
c_______________________________________________________________
c
c Objetivo:     Calcula acumulación de una variable/día 
c Metodo:       Obvio
c Comentarios:
c
c     parameter (spval=9.E10,nx=900000)
c
      character*100 input,output
      integer ia(4),nmiss(nx),ldat(nx)
      real f(nx),s(nx)
c
      write(*,*)'input?'
      read (*,*) input
      write(*,*) 'miss allowed?'
      read (*,*) kmis
      write(*,*) 'output?'
      read (*,*) output
c
      open (10,file=input,form='unformatted')
      open (20,file=output,form='unformatted')
c ________________________________________________________________
chelpfin
c

