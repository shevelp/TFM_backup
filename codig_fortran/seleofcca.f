      program seleofcca
chelpini
c_______________________________________________________________
c
c Objetivo:     Divide patrones e series file eof o cca
c Metodo:       Obvio
c Comentarios:
c
c      write(*,100)' Inputfile'
c      read(*,100)inputfile1
c      write(*,100)' Num componentes a seleccionar?'
c      read(*,*)pvar
c      write(*,100)' Outputfile'
c      read(*,100) inputfile2
c      write(*,100)' eof/cca 1/2?'
c      read(*,*)code
c 100  format(A20)
c
c      OPEN (10,file=inputfile1,form='unformatted')
c      OPEN (3,file='selpc.log',form='formatted')
c      OPEN (20,file=inputfile2,form='unformatted')
c________________________________________________________________
chelpfin

      parameter(nsta=12000,ntep=2000,spval=9.E10)
      real      numc,sum
      real      var(nsta),eof(nsta),pc(ntep),cor(nsta)
      integer   code
      integer   ia(4),ib(4)
      character*100 inputfile1,inputfile2,inputfile3
c
      write(*,100)' Inputfile'
      read(*,100)inputfile1
      write(*,100)' Num componentes seleccionadas?'
      read(*,*)numc
      write(*,100)' Outputfile patterns'
      read(*,100) inputfile2
      write(*,100)' Outputfile series'
      read(*,100) inputfile3
      write(*,100)' eof/cca (1/2)?'
      read(*,*)code
 100  format(A100)

      OPEN (10,file=inputfile1,form='unformatted')
      OPEN (3,file='seleofcca.log',form='formatted')
      OPEN (20,file=inputfile2,form='unformatted')
      OPEN (30,file=inputfile3,form='unformatted')
      if (code.eq.2) then
      read(10)ia
      read(10)(cor(i),i=1,ia(4))
      endif
      read(10) ia
      read(10)(var(i),i=1,ia(4))
c
      sum=0.
      do 5 i=1,numc
      sum=sum+var(i)
 5    continue
 7    continue

      write (3,*)'File: ',inputfile1
      write (3,*)'Num comp retained: ',numc
      write (3,*)'Perc of varce retained: ',sum
c
      do 10 i=1,numc
      read(10)ia
      read(10)(eof(j),j=1,ia(4))
      read(10)ib
      read(10)(pc(k),k=1,ib(4))
      ia(2)=code
      ia(3)=i
      ib(2)=code
      ib(3)=i
      write(20)ia
      write(20)(eof(j),j=1,ia(4))
      write(30)ib
      write(30)(pc(j),j=1,ib(4))
 10   continue

      stop
      end



