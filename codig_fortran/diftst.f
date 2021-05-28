      program diftst
chelpini
c_______________________________________________________________
c
c Objetivo:     Resta dos campos y saca diffs con significacion
c Metodo:       Obvio
c Comentarios:
c      write (*,*)'Inputfile1?' 
c      read(*,150)in1
c      write (*,*)'Inputfile2?' 
c      read(*,150)in2
c
c      write(*,*)'Outputfile?'
c      read(*,150)out
c150   format(a64)
c
c    NOTA::  The input files must contain only 3 fields: 
c          1st)  The long-term mean of that period
c          2nd)  The long-term standard deviation of that period
c          3rd)  The total number of years/months during that period
c________________________________________________________________
chelpfin
c
c
      parameter(nr=4,spval=9.E10,nd=101178)
      integer tim,ngrid,num1,num2,nu,dfs
      integer ia(nr),ib(nr),ess(50)
      real den1, den2,var1,var2,fct,ldif
      real tes(4),gtt(nd)
      real f(3,nd),ff(3,nd),g(nd),gt(4,nd),te(nd),tst(nd),ts(4,50)
      character*64 in1,out,in2
c      
      write (*,*)'Inputfile1?' 
      read(*,150)in1
      write (*,*)'Inputfile2?' 
      read(*,150)in2
c
      write(*,*)'Outputfile?'
      read(*,150)out
150   format(a64)
c
      open(3,file='diftst.log',form='formatted')
      open(10,file=in1,form='unformatted')
      open(15,file=in2,form='unformatted')
      open(20,file=out,form='unformatted')
      open(30,file='/home/sergiolp/Work/TFM/progs/codig/tstu.dat',
     & form='formatted', status='old')
c
      do 10 i=1,3
           read(10)(ia(j),j=1,4)
           read(10)(f(i,i1),i1=1,ia(4))
c
           read(15)(ib(j),j=1,4)
           read(15)(ff(i,i1),i1=1,ib(4))

 10     continue
c
      if (ia(4).ne.ib(4)) then
      write(3,*)'Fields do not have the same number of points'
      write(3,*)'n field1: ',ia(4)
      write(3,*)'n field2: ',ib(4)
      goto 1999
      endif
c
      ngrid=ia(4)
       call leetest (ess,ts)
       write(3,*)ess(50),(ts(i,50),i=1,3)
       do 20, j=1,ngrid
       g(j)=f(1,j)-ff(1,j)
       num1=int(f(3,j))
       num2=int(ff(3,j))
       var1=(f(2,j)**2)/num1
       var2=(ff(2,j)**2)/num2
       den1=var1+var2
       den2=sqrt(den1)
       te(j)=abs(g(j)/den2)  !!! Ecuacion 14.3 del libro de estadistica !!!
c
       if (f(1,j).eq.spval.or.ff(1,j).eq.spval) then
       g(j)=spval
       te(j)=spval
       nu=0
       dfs=0
       tes=spval
       goto 69
       endif 
       nu=(num1+num2)-2
       dfs=den1**2/((var1**2)/(num1-1)+(var2**2)/(num2-1))
       write(3,*)j,dfs,nu
       call valtest (nu,ess,ts,tes)
c       write (3,*) num1,num2,nu,tes
 69    continue
       do 30, k=1,4
       gt(k,j)=g(j)
       if (te(j).le.tes(k)) gt(k,j)=spval
 30    continue
 20    continue
c
       do 40, j=1,ngrid
c
       fct=1.0
c       if (g(j).lt.0) fct=-1.0   !solo si neces signo en signif

c

       if (gt(1,j).eq.spval) then
       gtt(j)=0.0
       else
c       gtt(j)=90.0*fct
c       if(gt(2,j).ne.spval) gtt(j)=95.0*fct
c       if(gt(3,j).ne.spval) gtt(j)=99.0*fct
c       if(gt(4,j).ne.spval) gtt(j)=99.9*fct
       gtt(j)=10.0*fct
       if(gt(2,j).ne.spval) gtt(j)=5.0*fct
       if(gt(3,j).ne.spval) gtt(j)=1.0*fct
c       if(gt(4,j).ne.spval) gtt(j)=0.1*fct
       endif
c       ldif=abs(g(j))
c       write(3,*) 'ldif ',ldif
c       if (ldif.lt.0.1) gtt(j)=0.0
c
 40    continue

c.....Write
         write(20)(ia(j),j=1,4)
         write(20)(g(i1),i1=1,ia(4))  !diferences
         write(20)(ia(j),j=1,4)
         write(20)(gt(1,i1),i1=1,ia(4)) !dif 90
         write(20)(ia(j),j=1,4)
         write(20)(gt(2,i1),i1=1,ia(4)) !dif 95
         write(20)(ia(j),j=1,4)
         write(20)(gt(3,i1),i1=1,ia(4)) !dif 99
         write(20)(ia(j),j=1,4)
         write(20)(gt(4,i1),i1=1,ia(4)) !dif 99.9
         write(20)(ia(j),j=1,4)
         write(20)(gtt(i1),i1=1,ia(4))  !signif
c
 1999 continue

      stop
      end

      SUBROUTINE LEETEST(v,q)
c
C========================================
c SUBRUTINA QUE LEE DATOS PARA TEST
C T DE STUDENT
c_________
c  nv   -  num de grados de libertad
c  v   .-  numero de grados de libertad
c  q(v).-  percentil para v grados lib
C========================================
c
C.....definicion de variables
c
      integer c
      integer v(50)
      real q(4,50)
c
c.....cuentas
c
      do 900 c=1,50
      read(30,'(i5,f7.3,3f9.3)')
     &  v(c),q(1,c),q(2,c),q(3,c),q(4,c)
 900   continue
c
      return
      end
c
      SUBROUTINE VALTEST(nvv,v,q,tst)
C========================================
c SUBRUTINA QUE LEE DATOS PARA TEST
C T DE STUDENT
c_________
c  nv   -  num de grados de libertad
c  v   .-  numero de grados de libertad
c  q(v).-  percentil para v grados lib
C========================================
c
C.....definicion de variables
c
      integer c,cc,ci,nv,nvv,v1,v2
      integer v(50)
      real tst(4),cft(4)
      real q(4,50),q2(4),q1(4)
c
c.....cuentas
c
      nv=nvv
      if (nvv.ge.v(50)) nv=v(50)
      do 905 ci=1,4
      do 910 c=1,50
      cc=c-1
      if (nv.le.v(c).and.nv.gt.v(cc)) then
      q2(ci)=q(ci,cc)
      q1(ci)=q(ci,c)
      v2=v(cc)
      v1=v(c)     
      endif
 910  continue
 905  continue
      do 915 c=1,4
      cft(c)=((q2(c)-q1(c))/(v2-v1))*(v2-nv)
      tst(c)=q2(c)-cft(c)
 915  continue
c      write(3,*)nvv,nv,q1,q2,v1,v2,cft,tst
c
      return
      end
c
