      program med_day2
c
c calcula medias diarias si hay suficiente numero de datos.
c
      parameter (spval=9.E10,nx=900000)
c
      character*100 input,output
      integer ia(4),nmiss(nx),ldat(nx)
      real f(nx),s(nx)
c
      write(*,*)'input?'
      read (*,*) input
      write(*,*) 'miss allowed?'
      read (*,*) kmis
      write(*,*) 'output?'
      read (*,*) output
c
      open (10,file=input,form='unformatted')
      open (20,file=output,form='unformatted')
c
c iniciamos...
c
      k=0
      s=0.
      nmiss=0
      ldat=0
c
c algoritmo...
c
 10   read (10,end=100) (ia(i),i=1,4)
      read (10)(f(i),i=1,ia(4))
c
      kano=int(ia(1)/float(1000000))
      kmes=int((ia(1)-kano*1000000)/float(10000))
      kdia=int((ia(1)-kano*1000000-kmes*10000)/float(100))
c
      if (k.eq.0) then
      ifecha=kano*1000000+kmes*10000+kdia*100
      ilev=ia(3)
      kdiabef=kdia
      k=1
      endif
c
      if (kdia.eq.kdiabef) then
      do 20 i=1,ia(4)
      if (f(i).ne.spval) then
      s(i)=s(i)+f(i)
      ldat(i)=ldat(i)+1
      else
      nmiss(i)=nmiss(i)+1
      endif
 20   continue
c
      else
c
     
      do 30 i=1,ia(4)
      if (nmiss(i).le.kmis) then
      s(i)=s(i)/float(ldat(i))
      else
      s(i)=spval
      endif
 30   continue
c
      write(20) ifecha,0,ilev,ia(4)
      write(20) (s(i),i=1,ia(4))
c
      ifecha=kano*1000000+kmes*10000+kdia*100
      ilev=ia(3)
      kdiabef=kdia
      ldat=0
      s=0.
      nmiss=0
      do 40 i=1,ia(4)
      if (f(i).ne.spval) then
      s(i)=s(i)+f(i)
      ldat(i)=ldat(i)+1
      else
      nmiss(i)=nmiss(i)+1
      endif
 40   continue
      endif
c
      goto 10
c
 100  continue
c
      do 110 i=1,ia(4)
      if (nmiss(i).le.kmis) then
c     s(i)=s(i)/float(ldat(i))
      else
      s(i)=spval
      endif
 110  continue
c
      write(20) ifecha,0,ilev,ia(4)
      write(20) (s(i),i=1,ia(4))
c
      stop
      end
