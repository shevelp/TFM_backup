      program stat_diftst
chelpini
c_______________________________________________________________
c
c Objetivo:  Programa para sacar descripcion estadistica 
c            Evalua en dimension temporal para cada serie
c Metodo:       Obvio
c Comentarios: Modificado el nsp, para minimizar memoria
cc
c      I/O:
c
c      write(*,*)'Fichero de datos original?'
c      read(*,'(a24)')in
c      write(*,*)'Fichero de salida?'
c      read(*,'(a24)')out
c
c      write(*,*)' La salida incluye:'
c      write(*,*)'1.  media'
c      write(*,*)'2.  desviacion estandar'
c      write(*,*)'3.  numero de registros temporales existentes'
c
c________________________________________________________________
chelpfin
      parameter(spval=9.E10,nsp=101178,ntp=17500)
c
      integer ia(4)
      integer nreal(nsp),miss(nsp)
      integer ntot,nsta,nrel,l,nmin,opt
      real md,vr,dsv,mean,sum,ae,be,ce,de
      real data(nsp,ntp),z(ntp),medi(nsp),desv(nsp)
      real zo(ntp),medana(nsp),cu1(nsp),cu2(nsp),ric(nsp)
      real pse(nsp),max(nsp),min(nsp)
      real vec(nsp),len(nsp),mis(nsp)
      character*100 in,out
c
      write(*,*)'Fichero de datos original?'
      read(*,'(a)')in
      write(*,*)'Fichero de salida?'
      read(*,'(a)')out

      write(*,*)' La salida incluye:'
      write(*,*)'1.  media'
      write(*,*)'2.  desviacion estandar'
      write(*,*)'3.  numero de registros temporales existentes'

c
      open(10,file=in,form='unformatted',status='unknown')
      open(11,file=out,form='unformatted',status='unknown')
c
      nmin=5
c
c.....
c
      i=0
 10   i=i+1 
      read(10,end=699)ia
      read(10)(data(j,i),j=1,ia(4)) 
      goto 10
 699  continue
c
      nsta=ia(4)
      ntot=i-1 
c
c.....
c
      do 20 i=1,nsta
      write(3,*)'Calculando valores para punto',i
      k=0
      do 30 j=1,ntot
      valor=data(i,j)
      if(valor.ne.spval) then
      k=k+1
      z(k)=data(i,j)
      else
      endif
 30   continue
c
      nreal(i)=k
      len(i)=float(k)
      nrel=k
c
      if (nrel.le.nmin) then
      medi(i)=spval
      desv(i)=spval
      else
c
      call med(z,nrel,md) 
      call var(z,nrel,md,vr)
 
      desv(i)=sqrt(vr)
      medi(i)=md

      endif


  20  continue 

c.....escritura
c
       ia(2)=1
       ia(3)=1
       ia(4)=nsta
 
       ia(1)=1
       write(11)ia
       write(11)(medi(i1),i1=1,nsta) !escribe campo medias

       ia(1)=2
       write(11)ia
       write(11)(desv(i),i=1,nsta)     !desv

       ia(1)=3
       write(11)ia
       write(11)(len(i),i=1,nsta)  !excribe camp existencias


c
      stop
      end
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
         real vec(150000)
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
        real vec(150000)
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
       subroutine ORDEN(x,l,xo)
c
c*****SUBRUTINA QUE ORDENA DE menor a mayor****************
c

C
c.....definicion de variables
c
c      integer jj,i,l,l1,camb2,nso
c      real camb1
c      real x(150000),xo(150000)
c
c.....ordena de mayor a menor
c
c      do 750 j=1,l
c
c        xo(j)=0.
c
c 750  continue
c
c
c      do 755 j=1,l
c
c        xo(j)=x(j)
c
c 755  continue
c
c 760  nso=0
c
c      l1=l-1
c
c      do 765 j=1,l1
c
c         jj=j+1
c
c         IF (xo(jj).LT.xo(j)) THEN
c
c                camb1=xo(j)
c
c                xo(j)=xo(jj)
c
c                xo(jj)=camb1
c
c                nso=1
c         endif
c
c  765  continue
c
c      if (nso.eq.1) then
c         goto 760
c      endif
c
c      return
c      end
c**********************************************************
c*****FIN DE LA SUBRUTINA ORDEN****************************
c
       subroutine MEDIANA(xo,l,mdna,q1,q2,d)
c*********************


C
c.....definicion de variables
c
      integer l,par,new
      integer lim1,lim2
      real mdna,q1,q2,d,ln,ll
      real xo(150000)
c
      ll=float(int(l/2))
      ln=l/2
c
      par=0    !impar
      if(ll.eq.ln) par=1 !par
c
      if (par.eq.1) then  !par
      lim1=l/2
      lim2=(l/2)+1
      else                !impar
      lim1=(l+1)/2
      endif
c
      if (par.eq.1) then  !par
      mdna=(xo(lim1)+xo(lim2))/2
      else
      mdna=xo(lim1)
      endif
c
      new=lim1
c
      ll=float(int(new/2))
      ln=new/2
      if(ll.eq.ln) par=1 !par
c
      if (par.eq.1) then  !par
      lim1=new/2
      lim2=(new/2)+1
      else                !impar
      lim1=(new+1)/2
      endif
c
      if (par.eq.1) then  !par
      q1=(xo(lim1)+xo(lim2))/2
      else
      q1=xo(lim1)
      endif
c
      if (par.eq.1) then  !par
      q2=(xo(lim1+new)+xo(lim2+new))/2
      else
      q2=xo(lim1+new)
      endif
c
      d=q2-q1
c
c

c
      return
      end
c**********************************************************
c**

c*****fin de programa


 






