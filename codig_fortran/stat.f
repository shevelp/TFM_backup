           program stat
chelpini
c_______________________________________________________________
c
c Objetivo:  Programa para sacar descripcion estadistica 
c            Evalua en dimension temporal para cada serie
c Metodo:       Obvio
c Comentarios:
cc
c      I/O:
c
c      write(*,*)'Fichero de datos original?'
c      read(*,'(a24)')in
c      write(*,*)'Fichero de salida?'
c      read(*,'(a24)')out
c      write(*,*)'Seleccion de salida:'
c      write(*,*)'0.  Todas las variables'
c      write(*,*)'1.  medias'
c      write(*,*)'2.  medianas'
c      write(*,*)'3.  deviacions'
c      write(*,*)'4.  pseud stand deviati'
c      write(*,*)'5.  quartile 1'
c      write(*,*)'6.  quartile 2'
c      write(*,*)'7.  interquartilic length'
c      write(*,*)'8.  maximum value'
c      write(*,*)'9.  minimum value'
c      write(*,*)'10.  number of missing'
c      write(*,*)'11.  number of existing'
c      write(*,*)'QUE OPCION?'
c      read(*,*)opt
c
c________________________________________________________________
chelpfin
        parameter(spval=9.E10,nsp=105000,ntp=20000)
c       parameter(spval=9.E10,ntp=5000,nsp=20000)
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
      read(*,'(a100)')in
      write(*,*)'Fichero de salida?'
      read(*,'(a100)')out
      write(*,*)'Seleccion de salida:'
      write(*,*)'0.  Todas las variables'
      write(*,*)'1.  medias'
      write(*,*)'2.  medianas'
      write(*,*)'3.  deviacions'
      write(*,*)'4.  pseud stand deviati'
      write(*,*)'5.  quartile 1'
      write(*,*)'6.  quartile 2'
      write(*,*)'7.  interquartilic length'
      write(*,*)'8.  maximum value'
      write(*,*)'9.  minimum value'
      write(*,*)'10.  number of missing'
      write(*,*)'11.  number of existing'
      write(*,*)'QUE OPCION?'
      read(*,*)opt

c
      open(3,file='sta.log',form='formatted')
      open(10,file=in,form='unformatted',status='unknown')
      open(11,file=out,form='unformatted',status='unknown')
c
      nmin=2
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
      md=spval
      dsv=spval
      else
c
         if (opt.eq.0.or.opt.eq.1.or.opt.eq.3) then
          call med(z,nrel,md)
         endif
         if (opt.eq.0.or.opt.eq.3) then
          call var(z,nrel,md,vr)
          dsv=sqrt(vr)
         endif
c
      endif
      if (opt.eq.0.or.opt.eq.1.or.opt.eq.3) medi(i)=md
      if (opt.eq.0.or.opt.eq.3) desv(i)=dsv
      miss(i)=ntot-nreal(i)
      mis(i)=float(miss(i))
c      write(*,*)i,ntot,mis(i),len(i)
c
      if  (opt.eq.0.or.
     &     opt.eq.2.or.
     &     opt.eq.4.or.
     &     opt.eq.5.or.
     &     opt.eq.6.or.
     &     opt.eq.7.or.
     &     opt.eq.8.or.
     &     opt.eq.9) then
      call ORDEN(z,nrel,zo)
      call MEDIANA(zo,nrel,ae,be,ce,de)
c
      medana(i)=ae
      cu1(i)=be
      cu2(i)=ce
      ric(i)=de
      pse(i)=de/1.349
      max(i)=zo(nrel)
      min(i)=zo(1)
       endif
c
  20  continue 
c
c.....escritura
c
       ia(2)=1
       ia(3)=1
       ia(4)=nsta
       if (opt.eq.0.or.opt.eq.1) then
        ia(1)=1
        write(11)ia
        write(11)(medi(i1),i1=1,nsta) !escribe campo medias
       endif
       if (opt.eq.0.or.opt.eq.2) then
        ia(1)=2
        write(11)ia
        write(11)(medana(i1),i1=1,nsta) !medianas
       endif
       if (opt.eq.0.or.opt.eq.3) then
        ia(1)=3
        write(11)ia
        write(11)(desv(i),i=1,nsta)     !desv
       endif
       if (opt.eq.0.or.opt.eq.4) then
        ia(1)=4
        write(11)ia
        write(11)(pse(i),i=1,nsta)      !pseudo desv est
       endif
       if (opt.eq.0.or.opt.eq.5) then
        ia(1)=5
        write(11)ia
        write(11)(cu1(i),i=1,nsta)      !cuartil 1
       endif
       if (opt.eq.0.or.opt.eq.6) then
        ia(1)=6
        write(11)ia
        write(11)(cu2(i),i=1,nsta)      !cuartil 2
       endif
       if (opt.eq.0.or.opt.eq.7) then
        ia(1)=7
        write(11)ia
        write(11)(ric(i),i=1,nsta)      !ric
       endif
       if (opt.eq.0.or.opt.eq.8) then
        ia(1)=8
        write(11)ia
        write(11)(max(i),i=1,nsta)      !max
       endif
       if (opt.eq.0.or.opt.eq.9) then
        ia(1)=9
        write(11)ia
        write(11)(min(i),i=1,nsta)      !min
       endif
       if (opt.eq.0.or.opt.eq.10) then
        ia(1)=10
        write(11)ia
        write(11)(mis(i),i=1,nsta)   !escribe campo missing
       endif
       if (opt.eq.0.or.opt.eq.11) then
        ia(1)=11
        write(11)ia
        write(11)(len(i),i=1,nsta)  !excribe camp existencias
       endif
 999   continue
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
         real vec(105000)
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
        real vec(105000)
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
      integer jj,i,l,l1,camb2,nso
      real camb1
      real x(105000),xo(105000)
c
c.....ordena de mayor a menor
c
      do 750 j=1,l
c
        xo(j)=0.
c
 750  continue
c
c
      do 755 j=1,l
c
        xo(j)=x(j)
c
 755  continue
c
 760  nso=0
c
      l1=l-1
c
      do 765 j=1,l1
c
         jj=j+1
c
         IF (xo(jj).LT.xo(j)) THEN
c
                camb1=xo(j)
c
                xo(j)=xo(jj)
c
                xo(jj)=camb1
c
                nso=1
         endif
c
  765  continue
c
      if (nso.eq.1) then
         goto 760
      endif
c
      return
      end
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
      real xo(105000)
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


 






