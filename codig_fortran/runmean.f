      program runmean
chelpini
c_______________________________________________________________
c
c Objetivo:     Medias moviles centradas
c Metodo:       Obvio
c Comentarios:  ma de inter=2*desf+1 terminos
c  
c      write(*,*)'Name der Eingabedatei?'
c      read(*,150)in
c      write(*,*)'Name der Ausgabedatei?'
c      read(*,150)out
c      write(*,*)'Intervall (desf)?'
c
c________________________________________________________________
chelpfin
c
c.....Definicions
c
      parameter(maxste=1000,maxsta=105000,spval=9e10)
      integer desf,inter,ntop
      integer ia(4,maxste),nr(maxsta)
      real data(maxsta,maxste),datr(maxsta,maxste),sum(maxsta)
      character*65 in,out
c
150   format(a65)
c  
c..... Input ficheros
c

      write(*,*)'Name der Eingabedatei?'
      read(*,150)in
      write(*,*)'Name der Ausgabedatei?'
      read(*,150)out
      write(*,*)'Intervall?'
      read(*,*)desf
c
      inter=2*desf+1
c      desf=int(float(inter)/2) 
c
c..... Apertura ficheros
c
      open(10,file=in,form='unformatted',status='unknown')
      open(11,file=out,form='unformatted',status='unknown')
     
c
c..... Lectura de ficheros
c
      datr=0.0

      do 10, i0=1,maxste+1
         read(10,end=15)(ia(i4,i0),i4=1,4)   !garda cabeza
         read(10)(data(i1,i0),i1=1,ia(4,i0)) !Lee datos
10    continue
15    nrste=i0-1                             !num fechas

      do 20,i0=inter+1,nrste+1             !perde inter datos

         do 21, i4=1,ia(4,1)             !move estacions
            sum(i4)=0.
            nr(i4)=0
            do 22, i1=1,inter            !suma  movil
               if (data(i4,i0-i1).ne.spval) then
                  sum(i4)=sum(i4)+data(i4,i0-i1)
                  nr(i4)=nr(i4)+1
               endif

22          continue
            if (nr(i4).ne.0) then        !si non faltan todos
               datr(i4,i0)=sum(i4)/float(nr(i4))  !media
            else
               datr(i4,i0)=spval       !se faltan ...missing
            endif

21       continue
20    continue
 
c      write(*,*)'def=',desf
      do 30, i0=1,nrste 
      i1=i0+desf+1  
         ntop=nrste-desf
         if(i0.le.desf.or.i0.ge.ntop)  then
         do 60 k=1,ia(4,i0)
         datr(k,i1)=spval
 60      continue
         endif
         write(11)(ia(i4,i0),i4=1,4)
         write(11)(datr(i4,i1),i4=1,ia(4,i0))        
30    continue

      stop
      end




