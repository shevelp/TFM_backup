      program datnorm
c
chelpini
c_______________________________________________________________
c
c Objetivo:     Normaliza series de matriz 
c Metodo:       Obvio
c Comentarios:  Saca pesos mensuales
c
c
c150   format(a15)
c      write(*,*)'Inputfile ?'
c      read(*,150) in
c      write(*,*)'Normalization period (yyyy,yyyy)?'
c      read(*,*)iyy1,iyy2
c      write(*,*)' Outputfile: normalized data  ?'
c      read(*,150) out1
c      write(*,*)' Outputfile: factors ?'
c      read(*,150) out2
cc
c      open(3,file='datnorm.log')
c      open(10,file=in,form='unformatted')
c      open(11,file=out1,form='unformatted')
c      open(12,file=out2,form='unformatted')
c
c
c________________________________________________________________
chelpfin
c
c Normierung der eingegebenen Daten auf Standardabweichung 1 und 
c Mittelwert 0. Die Normierfaktoren sind die urspruenglichen
c Standardabweichungen; durch sie wurde dividiert und mit ihnen muss
c ggf. wieder multipliziert werden. Achtung: Dieses Programm ersetzt
c nicht automatisch anomal, denn es beruecksichtigt nicht den 
c Jahresgang.

      parameter(maxsta=6000,spval=9.E10)
      real miss
      real data(maxsta),std(maxsta),dat1(maxsta),dat2(maxsta),
     -     datmit(maxsta)
      integer ia(4),nr(maxsta)
      character*25 in,out1,out2
c
      miss=9999.9
c
150   format(a25)
      write(*,*)'Inputfile ?'
      read(*,150) in
      write(*,*)'Normalization period (yyyy,yyyy)?'
      read(*,*)iyy1,iyy2
      write(*,*)' Outputfile: normalized data  ?'
      read(*,150) out1
      write(*,*)' Outputfile: factors ?'
      read(*,150) out2
c
      open(3,file='datnorm.log')
      open(10,file=in,form='unformatted')
      open(11,file=out1,form='unformatted')
      open(12,file=out2,form='unformatted')
c
c Einlesen der Datei und Berechnung der bestehenden Varianzen
c
      nr=0
      dat1=0.
      dat2=0.
c      write(*,*)'Entro en bucle 10'
      do 10, inr=1,100000
         read(10,end=30)ia
         yyyy=int(ia(1)/10000)
         read(10)(data(ista),ista=1,ia(4))
c
         if (yyyy.lt.iyy1.or.yyyy.gt.iyy2) goto 10
         do 20, ista=1,ia(4)
            if (data(ista).ne.spval) then
               nr(ista)=nr(ista)+1
               dat1(ista)=dat1(ista)+data(ista)
               dat2(ista)=dat2(ista)+data(ista)**2
            endif
 20       continue

 10    continue
c
c Errechnen des gefundenen Mittelwertes und der Standardabweichung
c
       
30     continue
c       write(*,*)'Sallo de bucle 10'
       do 32, ista=1,ia(4)
         if (nr(ista).gt.1) then
            datmit(ista)=dat1(ista)/float(nr(ista))
            std(ista)=sqrt((dat2(ista)-dat1(ista)**2./float(nr(ista)))/
     -                      float(nr(ista)-1))
         else
            std(ista)=spval
         endif
         if (std(ista).eq.0.) then
          std(ista)=spval
         endif
c        write(*,*)std(ista)
32    continue
c        write(*,*) 'salin de bucle 32'
c
c Subtraktion des Mittelwertes und Division durch die gefundenen
c Standardabweichungen:
c
c
40    nrste=inr-1
      rewind(10)
c
c        write(*,*) 'Entro en bucle 42'
      do 42, inr=1,nrste
c         write(*,*) 'Paso a',inr
         read(10)ia
         read(10)(data(ista),ista=1,ia(4))

c         write(*,*) 'Paso b',inr
         do 45, ista=1,ia(4)
            if (std(ista).ne.spval.and.data(ista).ne.spval) then
c                write(*,*)inr,ista,data(ista),datmit(ista),std(ista)
                data(ista)=(data(ista)-datmit(ista))/std(ista)
c                write(*,*)inr,ista,data(ista)
            else
                data(ista)=spval
c                write(*,*)inr,ista,data(ista)
            endif
45       continue
c
c         write(*,*) 'Paso c',inr
c
         write(11)ia
         write(11)(data(ista),ista=1,ia(4))

42    continue

      write(12)ia
      write(12)(std(ista),ista=1,ia(4))

      stop
      end



