      program eofact
chelpini
c_______________________________________________________________
c
c Objetivo:     Multiplica eofs/cca por vector de factores
c Metodo:       Obvio
c Comentarios:  
c      write(*,100)'File with eofs'
c      read(*,100)inputfile1
c      write(*,100)'Eofs (1) or cca (2)?'
c      read(*,*)tip
c      write(*,100)'File with factors'
c      read(*,100) inputfile2
c      write(*,100)'Outputfile'
c      read(*,100)inputfile3
cc
c 100  format(A20)
cc
c      OPEN (10,file=inputfile1,form='unformatted')
c      OPEN (20,file=inputfile2,form='unformatted')
c      OPEN (30,file=inputfile2,form='unformatted')
c
c________________________________________________________________
chelpfin

      parameter(nr0=5000,n0=5048,nmax=5000,spval=9.E10)
      dimension cv(nmax,nmax)
      dimension var1(nmax),var2(nmax)
      dimension eof1(nmax,n0),eofw(nmax,n0),fct(nmax)
      dimension t1(nmax,nr0),t2(nmax,nr0)
      dimension ia(4),ib(4)
      integer t,tip
      character*100 inputfile1,inputfile2,inputfile3
c
      write(*,100)'File with eofs/ cca'
      read(*,100)inputfile1
      write(*,100)'Eofs (1) or cca (2)?'
      read(*,*)tip
      write(*,100)'File with factors'
      read(*,100) inputfile2
      write(*,100)'Outputfile'
      read(*,100)inputfile3
c
 100  format(A100)
c
      OPEN (10,file=inputfile1,form='unformatted')
      OPEN (20,file=inputfile2,form='unformatted')
      OPEN (30,file=inputfile3,form='unformatted')
c
      read(10) ia
      read(10)(var1(i),i=1,ia(4))
      write(30)ia
      write(30)(var1(i),i=1,ia(4))
c
      if (tip.eq.2) then
      read(10) ia
      read(10)(var2(i),i=1,ia(4))
      write(30)ia
      write(30)(var2(i),i=1,ia(4))
      endif
c
      read(20) ia
      read(20)(fct(i),i=1,ia(4))
c
c      write(*,*)'hola'
      m=0
 10   m=m+1
      read(10,end=999)ia
      read(10)(eof1(m,j),j=1,ia(4))
      do 30 k=1,ia(4)
      eofw(m,k)=eof1(m,k)*fct(k)
      if(eof1(m,k).eq.spval) eofw(m,k)=spval
 30   continue
      read(10)ib
      read(10)(t1(m,t),t=1,ib(4))
      write(30)ia
      write(30)(eofw(m,j),j=1,ia(4))
      write(30)ib
      write(30)(t1(m,t),t=1,ib(4))
      goto 10
      nr=ib(4)
      nn1=ia(4)
 999  continue
      stop
      end

