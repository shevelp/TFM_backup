      Program tipf
chelpini
c_______________________________________________________________
c
c Objetivo:     Tipifica series temporales de una matriz
c Metodo:       Obvio
c Comentarios:
c
c     I/O:
c
c      write(*,*)'Fichero matriz original (input)?'
c      read(*,150)in1
c      write(*,*)'Fichero matriz tipificada (salida)?'
c      read(*,150)out
c
c________________________________________________________________
chelpfin
c
c.....Definicion de variables
C
      parameter(nr=4,nto=40000,spval=9.e10)
      integer nser,nsta,nrel
      integer ia(nr)
      real md,vr,dsv,miss,falta,valor
      real z(nto)
      real f(50,nto)               !(estacion,pastemp)
      real ftip(50,nto)               !(estacion,pastemp)
      character*64 in1,out
c
c.....Input nombres de ficheros 
c
      write(*,*)'Fichero matriz original (input)?'
      read(*,150)in1
      write(*,*)'Fichero matriz tipificada (salida)?'
      read(*,150)out
c
150   format(a64)
c
c.....Inicializo
c
c      miss=999999999.9
c      falta=999999999.9
c
c.....Apertura de ficheros
c
      open(5,file='tipf.log',status='unknown')
      open(10,file=in1,status='unknown',form='unformatted')
      open(12,file=out,status='unknown',form='unformatted')
c
c.....Lectura de datos
c
c     matriz f:
      k=0
 100        k=k+1
            read(10,end=1990)(ia(j),j=1,4)
            read(10)(f(i1,k),i1=1,ia(4))
      goto 100
c
c.....Formatos
c
 1990 nsta=ia(4)
      nser=k-1
      close(10)
c
c.....tipificacion
c
      do 110, i=1,nsta
      write(*,*)'Estou en serie',i
      k=0
      do 120, j=1,nser
      valor=f(i,j)
      if(valor.ne.spval) then
      k=k+1
      z(k)=f(i,j)
      else
c      write(5,*)i,j,f(i,j),valor
      endif
 120  continue
c
      nrel=k
c
      write(*,*)'Numero de datos',nrel
      call med(z,nrel,md)
      call var(z,nrel,md,vr)
      dsv=sqrt(vr)
c
c      write(*,*)md,dsv
      do 130, j=1,nser
c
      if(f(i,j).eq.spval) then
      ftip(i,j)=spval
      else     
      ftip(i,j)=(f(i,j)-md)/dsv
      endif
c
 130  continue
c
c      write(5,*)'Estou en serie',i
      write(5,'(i15,2f15.2,i15)')i,md,dsv,nrel
 110  continue      
c
c.....Escrituras
c
c
      open(10,file=in1,status='unknown',form='unformatted')
        k=0
 200    k=k+1
          read(10,end=1998)(ia(j),j=1,4)
          read(10)(f(i1,k),i1=1,ia(4))
c
          write(12)ia
          write(12)(ftip(i1,k),i1=1,ia(4))
        goto 200
c
1998  continue
      stop
      end
c
c.....SUBRUTINAS
c
c
c
c===========================================
c
         SUBROUTINE MED(vec,l,mean)
c
c        vec: input vector
c        l: length vec
c        mean: =
c===========================================
c
         integer l,c
         real mean,sum
         real vec(16000)
c.....
         mean=0.0
         sum=0.
c.....
         do 300 c=1,l
         sum=sum+vec(c)
c
 300     continue
c
         mean=sum/l
         sum=0.
c.....
        return
        end
c
c===========================================
c
        SUBROUTINE VAR(vec,l,mean,varv)
c
c vec: input vector
c mean: media
c l: length vec
c varv: varianza
c
c============================================
c
        integer l,c
        real mean,varv,sum
        real vec(16000)
c.....
        varv=0.
        sum=0.
c.....
        do 400 c=1,l
        sum=sum+(vec(c)-mean)**2.
 400    continue
c
        varv=sum/(l-1)
c
        sum=0.
        return
        end
c
c*****fin de programa




