        program anomal
chelpini
c_______________________________________________________________
c
c Objetivo:     Calcula anomalias respecto a la media diaria (i.e, quita el ciclo diario)
c Metodo:       Obvio
c Comentarios:  
c
c	write(*,100)' inputfile'
c	read(*,100) inputfile
c	write(*,100)' outputfile'
c	read(*,100) outputfile
c	write(*,100)' file with means'
c	read(*,100) outputfile2
c 100	format(A20)
c        nmes=12
c        open(3,file='anomal.log',form='formatted')
c	open(10,file=inputfile,form='unformatted')
c	open(20,file=outputfile,form='unformatted')
c	open(30,file=outputfile2,form='unformatted')
c________________________________________________________________
chelpfin
c
	parameter(nn=101178,nm=12,spval=9E10)
        integer nmes
        real miss
	dimension f(nn),rmed(nm,nn),ia(4),nd(nm,nn)
	character*64 inputfile,outputfile,outputfile2
c
        miss=9999.9
c
	write(*,100)' inputfile'
	read(*,100) inputfile
	write(*,100)' outputfile'
	read(*,100) outputfile
	write(*,100)' file with means'
	read(*,100) outputfile2
 100	format(A64)
        nmes=12
        open(3,file='anomal.log',form='formatted')
	open(10,file=inputfile,form='unformatted')
	open(20,file=outputfile,form='unformatted')
	open(30,file=outputfile2,form='unformatted')
c
 10	continue
	read(10,end=999)ia
	read(10)(f(i),i=1,ia(4))
c
	idate=int(ia(1)/100) !fecha
	iy=int(ia(1)/1000000)  !ano
        moda=idate-iy*10000
	mon=int(moda/100) !mes
        day=moda-mon*100  !dia
c        write(*,*)idate,iy,moda,mon,day
c        stop
c        end
c        if (mon.eq.0) mon=1
c
	do 20 i=1,ia(4)
	i1=1-int(abs(f(i))/spval)       !0 se missing e 1 se no missing
	rmed(day,i)=rmed(day,i)+i1*f(i) !suma de valores 
	nd(day,i)=nd(day,i)+i1          !contador por día
 20	continue
c
	goto 10

 999	continue

	close (10)

	do 30 k=1,nmes
	do 40 i=1,ia(4)
	if (nd(k,i).eq.0) goto 40
	rmed(k,i)=rmed(k,i)/nd(k,i)   !fai medias 
 40	continue
c
c.....escritura de control
c
        write(3,*)'---- Mes: ',k,'--------------->'
        write(3,*)k,(rmed(k,i),i=1,5)
        write(3,*)k,(nd(k,i),i=1,5)
        write(3,*)'-------------------------'
        write(30)k,1,1,ia(4)
        write(30)(rmed(k,i),i=1,ia(4))
 30	continue

	open(10,file=inputfile,form='unformatted')
c
 50	continue
	read(10,end=998)ia
	read(10)(f(i),i=1,ia(4))
c
c        do 79 i=1,ia(4)
c         if (f(i).gt.miss) then  !OLLO MISSING
c         f(i)=spval
c         endif
c 79     continue
	idate=int(ia(1)/10000)
	iy=int(ia(1)/1000000)
	mon=idate-iy*100
c        if (mon.eq.0) mon=1
c	if (mon.eq.0) ia(1)=ia(1)+100
        do 60 i=1,ia(4)
	i1=1-int(abs(f(i))/spval)
	f(i)=i1*(f(i)-rmed(mon,i))+(1-i1)*spval
 60	continue
	write(20)ia
	write(20)(f(i),i=1,ia(4))
	goto 50
 998	stop
	end
