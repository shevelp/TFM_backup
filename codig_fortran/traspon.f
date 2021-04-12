      program traspon
chelpini
c_______________________________________________________________
c
c Objetivo:     Programa para trasonher fichero extra
c Metodo:       Obvio
c Comentarios:  Version de datformF.f de gkss
c      write (*,*)'Inputfile?' 
c      read(*,150)in
c      write(*,*)'Outputfile?'
c      read(*,150)out
c      open(10,file=in,form='unformatted',status='unknown')
c      open(11,file=out,form='unformatted',status='unknown')
c________________________________________________________________
chelpfin
c      modificacion de gkss
c     7  1         2         3         4         5         6         7 2
c     vorher: m header, zu jedem header n daten
c     nachher: n header, zu jedem header m daten
c     maxste=max.zahl d.header, maxsta=max.zahl d.daten pro header
c     Durch Angabe eines Inkrementes kann man ggf. richtige "Datums"
c     erzeugen:    
c     Bei monatlichen Daten ist das Inkrement 1/12. Das Anfangsjahr
c     ist ajahr. Zu jedem Zeitschritt wird das inkrement+ajahr genommen.

      parameter(maxsta=50000,maxste=10000)
      character*64 in,out
      character*1 rep
      real data(maxsta,maxste)
      integer ia(4)
      
      write (*,*)'Inputfile?' 
      read(*,150)in
      write(*,*)'Outputfile?'
      read(*,150)out
      open(10,file=in,form='unformatted',status='unknown')
      open(11,file=out,form='unformatted',status='unknown')
      read(10)ia
      rewind(10)
      if (ia(4).ne.1) then
         write(*,*)'Soll ein Datum erzeugt werden (y oder n)?'
         read(*,151) rep
         if (rep.eq.'y') then
            write(*,*)'Wann beginnen die Daten? Inkrement?'
            write(*,*)'z.B.: "1900.+8./12. , 30/360." hiesse, die Daten'
            write(*,*)'beginnen 190008, Inkrement sind 1 Monat.'
            read(*,*) ajahr, addink
         endif
      endif
150   format(a64)
151   format(a1)

      do 10, iste=1,maxste+1
         read(10,end=15)ia
         if (ia(4).gt.maxsta .or. iste.gt.maxste) then
             write(*,*)'AENDERN SIE DIE DIMENSIONIERUNG IM PROGRAMM!'
             goto 1990
         endif
         read(10)(data(ista,iste),ista=1,ia(4))
  10   continue


15     nrsta=ia(4)
       nrste=iste-1
       ia(4)=nrste
       if (rep.eq.'y') ajahr=ajahr-addink

       do 20, ista=1,nrsta
          if (rep.eq.'y') then
             adat=ajahr+addink*float(ista)
             ijahr=int(adat)
             imon=int((adat-float(ijahr))*12.+1e-8)
             ia(1)=10000*ijahr+100*imon
          endif
          write(11)ia
          write(11)(data(ista,iste),iste=1,nrste)
20     continue

1990   stop
       end

