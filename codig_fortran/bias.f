       program bias
c
c calcula el bias de dos campos en extra, la serie 1 con la serie 1, ls serie 2
c con la 2.... bias=medsim-medmed
c
       parameter (spval=9.E10,ne=101178,nt=17520)

       character*100 input1,input2,output
       real medida(ne,nt),simula(ne,nt)
       real sumamed(ne),sumasim(ne)
       real biass(ne)
       integer t
       integer ia(4),ib(4),nmed(ne),nsim(ne)

      write (*,*) 'fichero con las medidas? '
      read (*,*) input1
      write(*,*) 'fichero con la simulacion?'
      read (*,*) input2
      write(*,*) 'fichero salida?'
      read (*,*) output

      open(10,file=input1,form='unformatted')
      open(20,file=input2,form='unformatted')
      open(30,file=output,form='unformatted')
c
c  leemos los ficheros de entrada
c
      t=1
 10   read (10,end=100) ia
      read(10) (medida(i,t),i=1,ia(4))
      t=t+1
      goto 10
 100  continue
      t=1
 20   read (20,end=200) ib
      read(20) (simula(i,t),i=1,ib(4))
      t=t+1
      goto 20
 200  t=t-1 

      if (ia(4).ne.ib(4)) then
      write(*,*) 'los ficheros no tienen la misma dim temporal!!!'
      stop
      endif
c
c  calculamos el estadistico.
c
      nmed=0
      nsim=0
      sumamed=0.
      sumasim=0.
      do 40 i=1,ia(4)
      do 30 j=1,t
      if (medida(i,j).ne.spval) then 
      sumamed(i)=sumamed(i)+medida(i,j)
      nmed(i)=nmed(i)+1
      endif
      if (simula(i,j).ne.spval)then
      sumasim(i)=sumasim(i)+simula(i,j)
      nsim(i)=nsim(i)+1
      endif
 30   continue
 40   continue
      korte=nint(t/float(2))
   
      do 50 i=1,ia(4)
      if (nmed(i).gt.korte) then
      sumamed(i)=sumamed(i)/float(nmed(i))
      else
      sumamed(i)=spval
      endif
      if (nsim(i).gt.korte) then
      sumasim(i)=sumasim(i)/float(nsim(i))
      else
      sumasim(i)=spval
      endif
 50   continue

      do 60 i=1,ia(4)
      if (sumasim(i).ne.spval.and.sumamed(i).ne.spval) then
      biass(i)=sumasim(i)-sumamed(i)
      else 
      biass(i)=spval
      endif
 60   continue
c
c escribimos el resultado
c
      write(30) ia
      write(30) (biass(i),i=1,ia(4))
      stop
      end 



