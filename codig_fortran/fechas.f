      program fechas
chelpini
c_______________________________________________________________
c
c Objetivo:     Determina aprox ano inicio para cada punto
c Metodo:       Obvio
c Comentarios:  
c
c     I/O:
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      saca fichero de salida fechas.ext
c
c 150   format(a64)
c
c      out1='fechas'
c
c________________________________________________________________
chelpfin
c
      parameter(nr=4,nspa=20000,spval=9.E10)
      integer ia(nr),ano,mes
      real fechain(nspa),fechafi(nspa)
      real miss
      real f(nspa)

      character*64 in,out1,out2
      
      miss=9999999999.9
      write (*,*)'Inputfile?' 
      read(*,150)in
c      write (*,*)'Outputfile?' 
c      read(*,150)out1

150   format(a64)
      do 5, i=1,nspa
      fechain(i)=spval
      fechafi(i)=spval
 5    continue
c
      open(3,file='fechas.log')
      open(10,file=in,form='unformatted')
      open(11,file='fechas.ext',form='unformatted')
 

 10        read(10,end=1990)(ia(j),j=1,4)
           read(10)(f(i1),i1=1,ia(4))
c
      do 20, i=1,ia(4)
c
      if(f(i).ne.spval) then
c      write(3,*) i,ia(1),f(i)
      if(fechain(i).eq.spval) then
      fechain(i)=float(ia(1))/10000
      endif
      endif
c
 20   continue
      goto 10

 1990 continue
      write(11) 1,1,1,ia(4)
      write(11)(fechain(i1),i1=1,ia(4))
c

      stop
      end


