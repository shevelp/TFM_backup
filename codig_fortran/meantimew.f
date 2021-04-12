      program meantime
c
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa que fai media de todo un campo 
c               para cada paso temporal
c Metodo:       Obvio
c Comentarios:  Version con pesos de desviacion para cada var.
c   
c     Files:
c
c      open(3,file='meantimew.log',form='formatted')
c      open(10,file=in,form='unformatted',status='unknown')
c      open(11,file=out,form='unformatted',status='unknown')
c
c     Imputs:
c
c      write(*,*)'Fichero de datos original?'
c      read(*,'(a24)')in
c      write(*,*)'Fichero de salida?'
c      read(*,'(a24)')out
c
c      Outputs:
c
c      fichero extra con medias de campos
c
c________________________________________________________________
chelpfin
c
c     Modificcado para calcular media de base de datos
c     No medias climaticas sino media en cada punto
c     Logo saca un mapa de medias
c
      parameter(spval=9.E10,ns=15000,nt=5000)
      integer nspa,ntot,nto
      integer ia(4,nt)
      integer i1
      real xmed(ns),desv(ns),data(ns,nt),xv(nt),xvmd(nt)
      real sum,md,vr,wght
      character*24 in,out

      write(*,*)'Fichero de datos original?'
      read(*,'(a24)')in
      write(*,*)'Fichero de salida?'
      read(*,'(a24)')out
c
      open(3,file='meantimew.log',form='formatted')
      open(10,file=in,form='unformatted')
      open(11,file=out,form='unformatted')
c
       i=0
 10    i=i+1 
       read(10,end=699)(ia(j,i),j=1,4)
       read(10)(data(j,i),j=1,ia(4,i)) !lee mapa de datos
       goto 10
 699   ntot=i-1
       nspa=ia(4,1)
c
c..... Calcula medias,varianzas por serie      
c
       do 20, j=1,nspa
       k=0
       do 25 i=1,ntot
       if(data(j,i).ne.spval) then   
       k=k+1
       xv(k)=data(j,i)
       endif
 25    continue
       nto=k
       if (nto.ne.0) then
       call med(xv,nto,md)
       call var(xv,nto,md,vr)
       else
       md=spval
       vr=spval
       endif
       write(3,*)j,md,vr,nto
       xmed(j)=md
       desv(j)=sqrt(vr)
 20    continue
       sum=0.0
       do 30 j=1,nspa
       if(desv(j).ne.spval) then
       sum=sum+(1/desv(j))
       endif
 30    continue
       wght=sum
c
c.....Promedio 
c
       do 40 i=1,ntot
       sum=0.0
       k=0
       do 35 j=1,nspa
       if(data(j,i).ne.spval) then   
       k=k+1      
       sum=sum+((data(j,i)-xmed(j))/desv(j))
       endif
 35    continue
       xvmd(i)=sum/wght
 40    continue
c
c
c
       do 50 i=1,ntot
       ia(4,i)=1
       write(11)(ia(j,i),j=1,4)
       write(11)xvmd(i)
 50    continue
      stop
      end

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
         real vec(5000) !tantos como pasos temporales
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
        real vec(5000) !tantos como pasos temp
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

