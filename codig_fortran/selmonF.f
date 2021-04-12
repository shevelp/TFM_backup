        Program selmon
c
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa para seleccionar meses en fichero extra
c Metodo:       Obvio
c Comentarios:  
c
c
c________________________________________________________________
chelpfin
c
c       Modificacion de programa selmonF de gkss
c
	parameter(nn=60000)
	dimension f(nn),ia(4)
	character*50 inputfile,outputfile
	write(*,100)' inputfile'
	read(*,100)inputfile
	write(*,100)' outputfile'
	read(*,100)outputfile

 100	format(A50)
	write(*,100)' mon1,mon2'
	read(*,*)mon1,mon2
 	open(10,file=inputfile,form='unformatted',status='unknown')
	open(20,file=outputfile,form='unformatted',status='unknown')

	if (mon1.le.mon2) then

 10	continue

	read(10,end=999)ia
	idate=int(ia(1)/100)
	iy=int(ia(1)/10000)
	mon=idate-iy*100
	if (mon.ge.mon1.and.mon.le.mon2) then
	read(10)(f(i),i=1,ia(4))
	write(20)ia
	write(20)(f(i),i=1,ia(4))
	else
	read(10)
	endif	
	goto 10

	else

 20	continue
	read(10,end=999)ia
	idate=int(ia(1)/100)
	iy=int(ia(1)/10000)
	mon=idate-iy*100
	if (mon.ge.mon1.or.mon.le.mon2) then
	read(10)(f(i),i=1,ia(4))
	write(20)ia
	write(20)(f(i),i=1,ia(4))
	else
	read(10)
	endif
	goto 20

	endif
 999	stop
	end
