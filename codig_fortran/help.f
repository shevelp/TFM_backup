      program help
chelpini
c_______________________________________________________________
c
c Objetivo:     Saca cabeceira de axuda de outros programas
c Metodo:       Obvio
c Comentarios:  
c
c     Files:
c
c      open(10,file=in,form='formatted')
c  
c     Imputs:
c
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c
c     Outputs:
c
c      Saca cabecera de fichero por pantalla
c
c________________________________________________________________
chelpfin
c
      integer l1,l2,indi
c
      character*64 in,out
      character*100 linea
      character*8 iden
c      
      write (*,*)'Inputfile?' 
      read(*,150)in
150   format(a64)
      open(10,file=in,form='formatted')
      i=0
 10   i=i+1
      read(10,'(a8,100x)',end=1990)iden
c      write(*,*)iden
      if (iden.eq.'chelpini') ini=i
      if (iden.eq.'chelpfin') fin=i
      if (iden.eq.'#helpini') ini=i
      if (iden.eq.'#helpfin') fin=i
      goto 10
 1990 continue
      close(10)
      open(10,file=in,form='formatted')
      i=0
 20   i=i+1
      read(10,'(a65)',end=1991)linea
      if (i.ge.ini.and.i.le.fin) then
      write(*,'(a65)')linea
      endif
      goto 20
 1991 continue
c
      stop
      end





