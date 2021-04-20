      program selper
chelpini
c_______________________________________________________________
c
c Objetivo:     Selecciona periodo en fichero extra
c Metodo:       Obvio
c Comentarios:
c
c     I/O:
c
c      write(*,100)' inputfile'
c      read(*,100)inputfile
c      write(*,100)' outputfile'
c      read(*,100)outputfile
c      write(*,100)' date1,date2'
c      read(*,*)date1,date2
c      open(10,file=inputfile,form='unformatted',status='unknown')
c      open(20,file=outputfile,form='unformatted',status='unknown')
c
c________________________________________________________________
chelpfin
c 
c.....
c
      parameter(nn=101178)
      dimension f(nn),ia(4)
      character*150 inputfile,outputfile
      integer date,date1,date2

      write(*,100)' inputfile'
      read(*,100)inputfile
      write(*,100)' outputfile'
      read(*,100)outputfile
      write(*,100)' date1,date2'
      read(*,*)date1,date2
      open(10,file=inputfile,form='unformatted',status='unknown')
      open(20,file=outputfile,form='unformatted',status='unknown')
 100  format(a100)
 10   continue
      read(10,end=999)ia
      date=ia(1)
      if (date.ge.date1.and.date.le.date2) then
      read(10)(f(i),i=1,ia(4))
      write(20)ia
      write(20)(f(i),i=1,ia(4))
      else
      read(10)
      endif
      goto 10
 999  continue
      close(10)
      close(20)
      stop
      end
