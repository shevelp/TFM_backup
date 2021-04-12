       program pasaext
c
chelpini
c_______________________________________________________________
c
c Objetivo:     Pasa de ascii a extra
c Metodo:       Obvio
c Comentarios:
c
c     Files:
c
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      write(*,*)'Outputfile mod?'
c      read(*,150)out1
c      write(*,*)'Outputfile dir?'
c      read(*,150)out2
c 150   format(a64)
c
c________________________________________________________________
chelpfin
c
      parameter(nr=4,spval=9.e10)
      integer ia(nr)
      integer ano,mes,dia,hora,min
      real f(70000),mod,mod2,dir,dir2
      character*64 in,out1,out2
      
      write (*,*)'Inputfile?' 
      read(*,150)in
      write(*,*)'Outputfile mod?'
      read(*,150)out1
      write(*,*)'Outputfile dir?'
      read(*,150)out2
150   format(a64)
c


      open(10,file=in,form='formatted')
      open(11,file=out1,form='unformatted')
      open(12,file=out2,form='unformatted')
c
 10      read(10,1000,end=1990)ano,mes,dia,hora,min,mod,dir
c
         ia(1)=ano*1000000+mes*10000+dia*100+hora
         ia(2)=min
         ia(3)=1
         ia(4)=1
     
         mod2=mod
         dir2=dir
         if(mod.eq.999.0) mod2=spval
         if(dir.eq.999.0) dir2=spval
          write(11)ia
          write(11)mod2
          write(12)ia
          write(12)dir2
      goto 10
c
 1000 format(i4,4i2.2,2f8.1,16x)
c
 1990 close(10)

      stop
      end
