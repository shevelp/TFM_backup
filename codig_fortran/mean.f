      program mean
c
c hace la media de las series temporales...
c     
      parameter (spval=9.e10)
c
      character*100 input,output
      integer ia(4)
c      real, dimension(:), allocatable :: f(:),suma(:)
c      integer, dimension(:), allocatable :: nval(:)
       real  f(500000),suma(500000)
       integer  nval(100000)
c
      write(*,*) 'input?'
      read (*,*) input
      write(*,*) 'output?'
      read (*,*) output
c
      open(10,file=input,form='unformatted')
      open(20,file=output,form='unformatted')
c
c ... dimensiona ...
c
      read(10) ia
      rewind 10
      nx=ia(4)
      write(*,*) nx
c
c      allocate (f(nx),suma(nx),nval(nx))
c
c ... algoritmo ...
c
      suma=0.
      nval=0
c
 10   read(10,end=100) ia
      read (10) (f(i),i=1,ia(4))
c
      do 20 i=1,nx
      if (f(i).ne.spval) then
      suma(i)=suma(i)+f(i)
      nval(i)=nval(i)+1
      endif
 20   continue
c
      goto 10
c
 100  continue
c
      do 110 i=1,nx
      if (nval(i).ne.0) then
      f(i)=suma(i)/float(nval(i))
      else
      f(i)=spval
      endif
 110  continue
c
c ... escribe ...
c
      write(20)1,1,1,nx
      write(20)(f(i),i=1,ia(4))
c
      stop
      end

