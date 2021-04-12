      program fechas2
chelpini
c_______________________________________________________________
c
c Objetivo:     Saca ficheiro con fechas en fich extra
c Metodo:       Obvio
c Comentarios:  Non escribe ficheiro con fechas cambiadas en dia
c
c     I/O:
c      miss=9999999999.9
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c
c 150   format(a64)
c
c      out1='fechas'
c
c________________________________________________________________
chelpfin
c
      parameter(nr=4,spval=9.E10)
      integer ia(nr),ano,mes
      real miss
      real f(8000000)
      character*64 in,out1,out2
      
      miss=9999999999.9
      write (*,*)'Inputfile?' 
      read(*,150)in

150   format(a64)

      out1='fechas'

      open(10,file=in,form='unformatted')
c      open(11,file='fechas.extra',form='unformatted')
      open(15,file=out1)


 10        read(10,end=1990)(ia(j),j=1,4)
           read(10)(f(i1),i1=1,ia(4))
c           write(15,*)ia(1)
           write(15,*)(ia(j),j=1,4)
      ano=int(ia(1)/10000)
      mes=(ano*100)-int(ia(1)/100)
      if (mes.eq.0) ia(1)=ia(1)+100
      do 50 k=1,ia(4)
      if (f(k).gt.miss) f(k)=spval
 50   continue
c      write(11)(ia(j),j=1,4)
c      write(11)(f(i1),i1=1,ia(4))
      goto 10

 5010 format(4i10)
 5020 format(6(1x,e12.5))


 1990 close(10)

      stop
      end


