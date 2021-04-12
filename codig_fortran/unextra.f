        Program unextra
c
chelpini
c_______________________________________________________________
c
c Objetivo:     Une ficheros extra por campos
c Metodo:       Obvio
c Comentarios:
c
c	write(*,100)' no. of files'
c	read(*,*)n
c	write(*,100)' outputfile'
c	read(*,100)outputfile
c 100	format(A40)
c 110	format(A10,2x,I4)
c	
c	open(30,file=outputfile,form='unformatted')
c
c	do 10 k=1,n
c	write(*,110)' inputfile', k
c	read(*,100)inputfile
c	open(10,file=inputfile,form='unformatted')
c
c________________________________________________________________
chelpfin
c 
c
	parameter(nn=700000)
	dimension f(nn),ia(4)
	character*40 inputfile,outputfile
	write(*,100)' no. of files'
	read(*,*)n
	write(*,100)' outputfile'
	read(*,100)outputfile
 100	format(A40)
 110	format(A10,2x,I4)
	
	open(30,file=outputfile,form='unformatted')

	do 10 k=1,n
	write(*,110)' inputfile', k
	read(*,100)inputfile
	open(10,file=inputfile,form='unformatted')

 20	continue
	read(10,end=999)ia
	read(10)(f(i),i=1,ia(4))
	write(30)ia
	write(30)(f(i),i=1,ia(4))
	goto 20
 999	continue
	close(10)
 10	continue
	end

