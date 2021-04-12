      program ondanual
c
c ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
c     PROGRAMA PARA CALCULAR LA ONDA ANUAL DE UNA SERIE.
c---------------------------------------------------------------------
c
c < 1 fichero de entrada .ext (nx estaciones)
c
c > 1 fichero de salida en .ext (nx estaciones)
c
c Pero esta onda anual en vez de tener la longitud de la serie
c tiene una fija que va de 1930 a 2020, para poder luego calcular
c 1.) bien una interpolacion sin perder datos en mi periodo 
c 2.) bien una media corrida sin perder los bordes de mi periodo
c
c ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
c
      parameter (spval=9.e10)
c
      character*100 input,output,input2
c
      real g
      integer ib(4),c,ini,fin,tot,nt,inia,fina,ord,anno
      integer, dimension(:,:), allocatable :: nval(:,:),ia(:,:),ic(:,:)
      real, dimension(:,:), allocatable :: f(:,:),s(:,:)
c
      write(*,*) 'input?'
      read(*,*) input
      write(*,*) 'input2?'
      read(*,*) input2
      write(*,*) 'output?'
      read (*,*) output
c
      open (3,file='ondanual.log')
      open(10,file=input,form='unformatted')
      open(30,file=input2,form='unformatted')
      open(20,file=output,form='unformatted')
c ---------
c chapuza para ver las dimensiones de input...
c
      nt=0
      c=0
 10   read (10,end=20) ib
      if (c.eq.0) then
         ini=ib(1)
         c=1
      endif
      read (10)g
      nt=nt+1
      goto 10
 20   continue
      fin=ib(1)
c
c ... Para saber la resolucion aproximada en la que esta escrita el archivo:
c
      inia=int(ini/1000000)
      fina=int(fin/1000000)
      tot=fina+1-inia
      ratio=float(nt/tot)
      if (ratio.le.13) inter=12
      if (ratio.gt.13) inter=366
c
      nx=ib(4)
      rewind 10

c ---------
c chapuza para ver las dimensiones de input2...
c
      mt=0
 11   read (30,end=21) ib
      read (30)g
      mt=mt+1
      goto 11
 21   continue
      rewind(30)


c
c dimensiona
c
      allocate (f(nx,nt),s(nx,inter),nval(nx,inter),ia(4,nt),ic(4,mt))


c
c se queda con las fechas de input2
c

      do i=1,mt
         read(30)(ic(k,i),k=1,4)
         read(30) g
      enddo
c
c ==================================================================
c     ALGORITMO: lectura y calculo.
c ==================================================================
c
      s=0.
      nval=0
      ord=0
c
      do i=1,nt
         read (10) (ia(j,i),j=1,4)
         read (10)(f(j,i),j=1,nx)
c
c vamos haciendo el sumatorio:
c
         call ORDINAL(ia(1,i),inter,ord)

         do j=1,nx
            if(f(j,i).ne.spval) then
               nval(j,ord)=nval(j,ord)+1
               s(j,ord)=s(j,ord)+f(j,i)
            endif
         enddo
      enddo
         
c
c ... calculo de las medias:
c
      do j=1,nx
         do k=1,inter
            if (nval(j,k).gt.1) then
               s(j,k)=s(j,k)/float(nval(j,k))
            else
               s(j,k)=spval
            endif
         enddo
      enddo

c
c calculo Y escritura de las anomalias:
c
      do i=1,mt
         call ORDINAL(ic(1,i),inter,ord)
         write(20) (ic(k,i),k=1,4)
         write(20) (s(k,ord),k=1,nx)
      enddo
c
      stop
      end


c
c.....SUBRUTINAS
c
c
c===========================================================
c
      SUBROUTINE ORDINAL(din,peri,dout)
c
c     calcula la fecha ordinal dentro de un anno:
c     a) si 'peri' es diario:
c        -> 1 de enero: 1
c        -> 2 de febrero: 32
c     b) si 'peri' es mensual -> el numero del mes.
c
c===========================================================
      integer din,dout,peri,anno,mes,dia,dias,kias
      real r,anna
c
      anno=int(din/1000000.)
      mes=int((din-anno*1000000)/10000)
      dia=int((din-anno*1000000-mes*10000)/100)
c
      dout=0
      dias=0
      kias=0
c
      if (peri.eq.12) then
         dout=mes
      else
          do i=1,mes-1

            if (i.eq.1.or.i.eq.3.or.i.eq.5.or.i.eq.7.or.i.eq.8.or.
     .i.eq.10.or.i.eq.12) then
               kias=31
            elseif(i.eq.4.or.i.eq.6.or.i.eq.9.or.i.eq.11) then
               kias=30
            else
               kias=28
            endif
               
            dias=dias+kias
         enddo
         
         dout=dias+dia
         if(mes.eq.2.and.dia.eq.29) dout=366 ! el 29-f va a la casilla 366
      endif
c
      return
      end
