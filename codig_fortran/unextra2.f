        Program unextra2
c
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa que une ficheros con formato extra 
c               (une columnas)
c Metodo:       Obvio
c Comentarios:  Files deben ter a misma lonxitude
c
c	character*40 inputfile,outputfile
c	write(*,100)' no. of files'
c	read(*,*)n
c	write(*,100)' outputfile'
c	read(*,100)outputfile
c 100	format(A40)
c 110	format(A10,2x,I4)	
c	open(30,file=outputfile,form='unformatted')
c________________________________________________________________
chelpfin
c       Une ficheros con formato extra
c       uniendo datos en cada campo
c
	parameter(nspa=50000,ntmp=50000)
	dimension f(ntmp,nspa),ia(4)
        integer date(ntmp),min(ntmp)
	character*60 inputfile,outputfile
	write(*,100)' no. of files'
	read(*,*)n
	write(*,100)' outputfile'
	read(*,100)outputfile
 100	format(A60)
 110	format(A10,2x,I4)
	
	open(30,file=outputfile,form='unformatted')
        nv=0
	do 10 kk=1,n  !une n files
	write(*,110)' inputfile', kk
	read(*,100)inputfile
	open(10,file=inputfile,form='unformatted')
c
        k=0

 20	continue
        k=k+1
	read(10,end=999)ia
        date(k)=ia(1)
        min(k)=ia(2)
        j=nv+1
        jj=ia(4)+ nv
	read(10)(f(k,i),i=j,jj)
	goto 20
 999	continue  
	close(10)
c
        nv=nv+ia(4)
 10	continue
        ktot=k-1
        k=0
 30     continue
        k=k+1
        ia(1)=date(k)
        ia(2)=min(k)
        write(30)ia(1),ia(2),ia(3),nv
	write(30)(f(k,i),i=1,nv)
        if (k.eq.ktot) goto 40
        goto 30
 40     continue
        end


