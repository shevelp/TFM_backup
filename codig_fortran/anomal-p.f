      program anomalp
c
c Calcula las anomalias restando a la serie temporal la media.
c
      parameter (spval=9.e10)
c
      character*100 input,output
      integer ia(4)
      real, dimension(:), allocatable :: f(:),mf(:),n(:)
c
      write(*,*) 'input?'
      read(*,*) input
      write(*,*) 'output?'
      read(*,*) output
c
      open(10,file=input,form='unformatted')
      open(20,file=output,form='unformatted')
c     
c dimensiona
c
      read(10) ia
      nx=ia(4)
      rewind 10
c
      allocate (f(nx),mf(nx),n(nx))
c
c lee...
c
      n=0.
      mf=0.
 10   read(10,end=100) ia
      read(10) (f(i),i=1,ia(4))
      do  40 i=1,ia(4)
      if (f(i).ne.spval) then
         mf(i)=mf(i)+f(i)
         n(i)=n(i)+1
      endif
 40   continue
c
      goto 10
c
 100  continue
c
c calcula la media
c
      do 110 i=1,ia(4)
      if (n(i).ne.0.) then
         mf(i)=mf(i)/n(i)
      endif
 110  continue
c
      rewind 10
c
c calcula las anomalias y escribe...
c
 120  read(10,end=200) ia
      read(10) (f(i),i=1,ia(4))
      do 150 i=1,ia(4)
      if (f(i).ne.spval) f(i)=f(i)-mf(i)
 150  continue
c
      write(20) ia
      write(20) (f(i),i=1,ia(4))
c
      goto 120
c
 200  continue
c
      stop
      end
