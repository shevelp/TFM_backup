      Program corr
chelpini
c_______________________________________________________________
c
c Objetivo:     Correlaciona matrices. Cada serie de file1 con
c               todas de file2 
c Metodo:       Obvio
c Comentarios:  Necesita campos ordenados en secuencia temporal
c               por fechas.
c               Saca fichero extra con correlacions
c
c
c      I/O:
c
c      write (*,*)'Fichero 1 (input)?'
c      read(*,150)in1
c      write(*,*)'Fichero 2 (input)?'
c      read(*,150)in2
c      write(*,*)'Vect. correl. (salida extra)?'
c      read(*,150)out
cc
c150   format(a64)
cc
c      open(3,file='cor.log',status='unknown',form='formatted')
c      open(10,file=in1,status='unknown',form='unformatted')
c      open(11,file=in2,status='unknown',form='unformatted')
c      open(12,file=out,status='unknown',form='unformatted')
c
c________________________________________________________________
chelpfin
c.....Definicion de variables
C
      parameter(nr=4,nspa=7000,ntp=20000,spval=9.E10)
      integer nser,nsta1,nsta2,ntot,numi
      integer ia(nr)
      real c,missv,missm
      real u(ntp),v(ntp)
      real y(nspa,ntp),z1(ntp),z2(ntp),crl(nspa,nspa)
      real f(nspa,ntp)               !(estacion,pastemp)
      character*64 in1,in2,out
c
c            OLLO CON VALORES DIMENSIONS EN SUBRUTINAS
c
c.....Input nombres de ficheros 
c
      write (*,*)'Fichero 1 (input)?'
      read(*,150)in1
      write(*,*)'Fichero 2 (input)?'
      read(*,150)in2
      write(*,*)'Vect. correl. (salida extra)?'
      read(*,150)out
c
150   format(a64)
c
c.....Apertura de ficheros
c
      open(3,file='cor.log',status='unknown',form='formatted')
      open(10,file=in1,status='unknown',form='unformatted')
      open(11,file=in2,status='unknown',form='unformatted')
      open(12,file=out,status='unknown',form='unformatted')
c
c.....
c
      numi=4
c
c.....Lectura de datos
c
      i=0
 10   i=i+1
            read(10,end=1980)(ia(j),j=1,4)
            read(10)(y(i1,i),i1=1,ia(4))
      goto 10
c
 1980 nsta1=ia(4)
       nser=i-1    
c
      k=0
 100        k=k+1
            read(11,end=1990)(ia(j),j=1,4)
            read(11)(f(i1,k),i1=1,ia(4))
      goto 100
c
c.....Formatos
c
 1990 nsta2=ia(4)
      nser=k-1 
      close(10)
      write(3,*)'nsta1=',nsta1,'nsta2=',nsta2,'nser=',nser
c
c.....correlacions
c
      do 108, i2=1,nsta1
      do 110, i=1,nsta2
      do 120, j=1,nser
c
      z1(j)=y(i2,j)
      z2(j)=f(i,j)
c
 120  continue
c
      ntot=0
c
      do 125 k=1,nser
      if (abs(z1(k)).ne.spval) then
      if (abs(z2(k)).ne.spval) then
      ntot=ntot+1
      u(ntot)=z1(k)
      v(ntot)=z2(k)
      endif
      endif
 125  continue
c
      if (ntot.gt.numi) then
      call corl(v,u,ntot,c)
      crl(i2,i)=c
      else
      c=9.E10
      crl(i2,i)=c
      endif
c
 110  continue      
 108  continue
c
c.....Escrituras
c
          ia(1)=0
          ia(2)=0
          ia(3)=0
          ia(4)=nsta2
c
          do 130 i2=1,nsta1
          write(12)ia
          write(12)(crl(i2,k),k=1,ia(4))
 130      continue
      stop
      end
c
c.....SUBRUTINAS
c
c
c===========================================
c
         SUBROUTINE CoRL(xvec,yvec,l,crln)
c
c        xvec: input x
c        yvec: input y
c        l: legth x,y
c        crln: correlacion
c
c===========================================
c
         integer l,c
         real crln,mx,my,varx,vary,dx,dy
         real sum
         real xvec(10000), yvec(10000) !tantos como pasos temporales
c
c.....inicializo
c
         crln=0.0
         mx=0.0
         my=0.0
         varx=0.0
         vary=0.0
         sum=0.
c         write(*,*)'tou en corr',l
c
c......calculo med e var
c
         call med(xvec,l,mx)
         call med(yvec,l,my)
         call var(xvec,l,mx,varx)
         call var(yvec,l,my,vary)
c
c.....correlacion
cc
c         write(*,*)'tou en cor de novo',mx,my,varx,vary
         dx=sqrt(varx)
         dy=sqrt(vary)
c
         sum=0.
         do 200 c=1,l
         sum=sum+(xvec(c)-mx)*(yvec(c)-my)
 200     continue
c
         crln=sum/(float(l-1)*dx*dy)
c
         return
         end
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
         real vec(10000) !tantos como pasos temporales
c.....
         mean=0.0
         sum=0.
c.....
c         write(*,*)'tou en med',l
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
        real vec(10000) !tantos como pasos temp
c.....
        varv=0.
        sum=0.
c.....         
c        write(*,*)'tou en varr',l

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




