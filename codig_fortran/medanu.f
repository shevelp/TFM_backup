      program medanu
chelpini
c_______________________________________________________________
c
c   
c Objetivo:     Programa para calculo de medias estacionales (DJF, MAM, JJA, SON)
c Metodo:       Obvio
c Comentarios:  Necesita multiplo exacto de meses para media
c
c   I/O:
c
c      write(*,*)'Fichero de datos original?'
c      read(*,'(a15)')in
c      write(*,*)'Numero de meses para la media?'
c      read(*,*)nmes
c      write(*,*)'Fichero de salida?'
c      read(*,'(a15)')out
c
c________________________________________________________________
chelpfin
c
      parameter(spval=9.E10,nsp=70000)
      integer ia(4),nr(nsp),miss(nsp)
      integer nano,anoid,oldanoid,nmes
      integer year,mon
      real media(nsp),data(12,nsp)
      real falta
      character*64 in,out
c
      write(*,*)'Fichero de datos original?'
      read(*,'(a64)')in
      write(*,*)'Numero de meses para la media?'
      read(*,*)nmes
      write(*,*)'Fichero de salida?'
      read(*,'(a64)')out
    
      open(10,file=in,form='unformatted',status='unknown')
      open(11,file=out,form='unformatted',status='unknown')
c
c

      write(*,*)'missing is gt 999999999'
      ifill=0
c
      k=0
10    k=k+1
c
c.....Lee conxunto de 12 meses
c
      media=0.0
      miss=0
c
      do 15 i=1,nmes
      read(10,end=999)ia
      year=int(ia(1)/10000)
      mon=int((ia(1)-year*10000)/100)
c      write(*,*)year,mon
      read(10)(data(i,j),j=1,ia(4)) !lee mapa de datos
      do 20 j=1,ia(4)
      if(data(i,j).eq.spval) miss(j)=miss(j)+1  !miro si hai algun missing neses 
 20   continue
 15   continue
c     
      do 24 j=1,ia(4) 
      do 25 i=1,nmes

      if (data(i,j).eq.spval) then
         goto 25
      else
      media(j)=media(j)+data(i,j)
      
      endif

c      if(miss(j).eq.1) media(j)=spval
 25   continue
      if (miss(j).eq.nmes) then
         media(j)=spval
      else
         media(j)=media(j)/(nmes-miss(j))
      endif
c      write(*,*)year,mon
 24   continue
c
      anoid=int(ia(1)/10000)     !identifica ano
      if (mon.eq.2)   then
      ia(1)=anoid*10000+130
      else
      if (mon.eq.5)      then
      ia(1)=anoid*10000+230
      else
      if (mon.eq.8)      then
      ia(1)=anoid*10000+330
      else
      ia(1)=anoid*10000+430
      endif
      endif
      endif
      write(11)(ia(j),j=1,4)
      write(11)(media(j),j=1,ia(4))
      goto 10
c
 999  continue

       stop
       end

 

