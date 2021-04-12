      program genfechas
c
c Genera un fichero con missings con las fechas cada 3h a partir de la fecha inicial.
c
      parameter (spval=9.e10)
c
      character*100 output
      integer ia(4),mes(12)
      real, dimension(:), allocatable :: f(:)
c
      write(*,*)'ano,mes,dia,hora inicial?'
      read (*,*)kano,kmes,kdia,khora 
      write(*,*)'ano,mes,dia,hora final?'
      read (*,*)kano2,kmes2,kdia2,khora2
      write(*,*)'nest?'
      read(*,*) nest
      write(*,*) 'output?'
      read(*,*) output
c
      open(10,file=output,form='unformatted')
c
c ... inicia ...
c
      r=kano/4.
      i=int((r-int(r))*100)
c
      mes(1)=31
      mes(2)=28
      mes(3)=31
      mes(4)=30
      mes(5)=31
      mes(6)=30
      mes(7)=31
      mes(8)=31
      mes(9)=30
      mes(10)=31
      mes(11)=30
      mes(12)=31
c
      if (i.eq.0) mes(2)=29
c
      allocate (f(nest))
      f=spval
c
      ia(1)=kano*1000000+kmes*10000+kdia*100+khora
      ia(2)=0
      ia(3)=1
      ia(4)=nest
c
      iafin=kano2*1000000+kmes2*10000+kdia2*100+khora2
c
c ... algoritmo ...
c
      do while (ia(1).le.iafin)
c      write(*,*)ia(1)
      write(10) ia
      write(10) (f(i),i=1,ia(4))
c
      khora=khora+1
      if (khora.ge.24) then
      khora=khora-24
      kdia=kdia+1
      if (kdia.gt.mes(kmes)) then
      kmes=kmes+1
      kdia=1
      if (kmes.eq.13) then
      kmes=1
      kano=kano+1
c
      r=kano/4.
      i=int((r-int(r))*100)
c
      mes(2)=28
      if (i.eq.0)mes(2)=29
      endif
      endif
      endif
      ia(1)=kano*1000000+kmes*10000+kdia*100+khora
      end do
c
      stop
      end
