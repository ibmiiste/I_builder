      * PROGRAMME   : PLIBLSTR               DATE CREATION : 10/01/2017
      * AUTEUR      : M.MIAUT                     COPYRIGHT C.I.S
      *----------------------------------------------------------------
      * Application : OUTILS
      *               GESTION LISTES DE BIBLIOTHEQUES
      *----------------------------------------------------------------
      * MAINTENANCE :
      *   AUTEUR                  OBJET                        DATE
      *----------------------------------------------------------------
      * INDICATEURS :
      *----------------------------------------------------------------
      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  CRTBNDRPG SRCFILE(&SL/&SF);                     */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  PGM(&LI/&OB);                                   */
      *     >>PARM<<  OPTION(*EVENTF);                                */
      *     >>PARM<<  DBGVIEW(*ALL);                                  */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */
      *****************************************************************
     h datedit(*dmy)  dftactgrp(*no)
     ffliblst   cf   e             workstn sfile(sfl1:sflrrn)
     f                                     sfile(sfl2:sflrrn)
     ffliblst1  uf a e           k disk    usropn
     ffliblst2  uf a e           k disk
     f                                     prefix(f2_)

     d Entry           pr                  Extpgm('PLIBLSTR')
     d  selusr                       10
     d  sellst                        8
     d Entry           pi
     d  selusr                       10
     d  sellst                        8

     d Addlib          pr                  Extpgm('PADDLIBC')
     d                               10

     d Savlib          pr                  Extpgm('POSLIBC')
     d                                4
     d                               10
     d                               10
     d                               10

     d updsfl          S               n
     d rrnsav          S                   like(sflrrn)
     d seqnbr          S                   like(seqlib)

     d Possav          s              4    inz('*SAV')
     d Poslst          s             10    inz('LSTLIB')
     d Poslib          s             10    inz('QTEMP')
     d Poscur          s             10    inz('*YES')

     d Lstlib          s           2000    Dtaara
     d I               s              4  0

     d pgmsts         sds
     d user                  254    263

     D dynArrInfo      ds                  qualified
     D   numAlloc                    10i 0 inz(0)
     D   current                     10i 0 inz(0)
     D   p                             *
     D dyndta          s             14a   dim(39) based(dynArrInfo.p)

      /free
        exsr sflini;

        dow *inkc = *off;

        if rrnsav <> 0;
         sflrrn = rrnsav;
        endif;

        write sflfn1;
        exfmt sflctl1;

        clear msgfn1;

        rrnsav = 0;

        if *in06;
         exsr fmtadd;
        else;
        if sflrrn > 0;
         exsr sflchg;
        endif;
        endif;

        if updsfl = *on;
         *in30 = *on;
         *in31 = *on;
         write sflctl1;
         *in30 = *off;
         *in31 = *off;
         exsr sflini;
        endif;

        enddo;

        *inlr = *on;

        begsr sflchg;
         readc sfl1;
         rrnsav = sflrrn;
         dow not %eof;
         if opt <> '';
          rrnsav = sflrrn;
          exsr chkaut;
          select;
           when opt = '2';
            exsr fmtmaj;
           when opt = '4';
            exsr fmtdlt;
            exsr sflini;
           when opt = '5';
            exsr fmtdsp;
           when opt = '6';
            exsr edtlib;
           when opt = '7';
            chain (lstname) fliblst2;
            if %found(fliblst2);
             addlib (lstname);
            else;
             msgfn1 = 'Liste ' + %trim(lstname) + 'vide. Option 7 rejetée.';
            endif;
          endsl;
         endif;
         if sflrrn > 0;
          sflrrn = rrnsav;
          chain sflrrn sfl1;
          clear opt;
          update sfl1;
        endif;
          readc sfl1;
         enddo;
          sflrrn = rrnsav;
        endsr;

        begsr fmtdsp;
         open fliblst1;
         chain (lstname) fliblst1;
         close fliblst1;
         *in31 = *off;
         *in32 = *off;
         *in34 = *off;
         exfmt fmt001;
        endsr;

        begsr fmtdlt;
         exfmt windlt;
         if optdlt = 'O';
          open fliblst1;
          chain lstname fliblst1;
          chain lstname fliblst2;
          if %found(fliblst2);
          dow not %eof(fliblst2)
            or not %found(fliblst2);
          delete fliblst2;
          reade lstname fliblst2;
          enddo;
          endif;
          delete fliblst1;
          close fliblst1;
         endif;
          updsfl = *on;
          if sflrrn > 1 and optdlt = 'O';
          sflrrn = sflrrn - 1;
          endif;
          rrnsav = sflrrn;
        endsr;

        begsr fmtadd;
         clear fmt001;
         *in31 = *on;
         *in32 = *on;
         *in34 = *on;
         *in35 = *on;
         lstdate = %date;
         lsttime = %time;
         lstuser = user;
         exfmt fmt001;
         open fliblst1;
         if lstname <> '';
         chain lstname fliblst1;
         if not %found(fliblst1);
         lstdate = %date;
         lsttime = %time;
         lstuser = user;
         if lstdesc = ' ';
          lstdesc = 'Liste ' + lstname;
         endif;
         if lsttype = ' ';
          lsttype = '1';
         endif;
         write flibls1r;
         else;
         msgfn1= 'La liste ' + %trim(lstname) + ' existe déjà !';
         endif;
         endif;
         close fliblst1;
         exsr sflini;
        endsr;

        begsr fmtmaj;
         open fliblst1;
         chain (lstname) fliblst1;
         *in31 = *off;
         *in32 = *on;
         *in34 = *off;
         *in35 = *on;
         exfmt fmt001;
         if lsttype = '2' and user <> lstuser;
          lsttype = '1';
          msgfn1 = 'Positionnement liste ' + %trim(lstname) +
            ' en accès privé impossible.';
         endif;
         update flibls1r;
         close fliblst1;
         update sfl1;
        endsr;

        begsr sflini;

        *in30 = *on;
        *in31 = *on;
        write sflctl1;
        *in30 = *off;
        *in31 = *off;

        sflrrn = 0;
        open fliblst1;
        setll (*loval) fliblst1;
        read fliblst1;
        dow not %eof(fliblst1);
         if sellst = '*ALL' and user = lstuser
          or sellst = '*ALL' and selusr = lstuser
          or sellst = '*ALL' and selusr = '*ALL'
          or sellst = '*PRIVATE' and user = lstuser
          or sellst = '*PRIVATE' and selusr = lstuser
          or sellst = '*PRIVATE' and selusr = '*ALL';
         sflrrn = sflrrn + 1;
         write sfl1;
         endif;
         read fliblst1;
        enddo;
        if sflrrn > 0;
         sflrrn = 1;
        else;
         *in30 = *off;
         *in31 = *on;
        endif;
        close fliblst1;
        endsr;

        begsr edtlib;

        rrnsav = sflrrn;

        dou *in12 = '1';

        *in30 = *on;
        *in31 = *on;
        write sflctl2;
        *in30 = *off;
        *in31 = *off;

        sflrrn = 0;
        setll lstname fliblst2;
        reade lstname fliblst2;
        curlib = f2_lib;
        reade lstname fliblst2;
        seqlib = 10;

        dow not %eof(fliblst2);
         sflrrn = sflrrn + 1;
         lib = f2_lib;
         write sfl2;
         seqlib = seqlib + 10;
         reade lstname fliblst2;
        enddo;

        dou sflrrn = 39;
         sflrrn = sflrrn + 1;
         clear lib;
         write sfl2;
         seqlib = seqlib + 10;
        enddo;

        sflrrn = 1;

        write sflfn2;
        exfmt sflctl2;

        if *in08;
          *in30 = *on;
          *in31 = *on;
          write sflctl2;
          *in30 = *off;
          *in31 = *off;
          savlib (possav:poslst:poslib:poscur);
          in *lock *dtaara;
          seqlib = 00;
          sflrrn = 0;
          curlib = %subst(Lstlib:1:10);
          seqlib = 10;
          for i = 11 by 11 to %len(Lstlib);
          if sflrrn = 39;
           leave;
          else;
           lib = %subst(Lstlib:i:10);
           sflrrn = sflrrn + 1;
           write sfl2;
           seqlib = seqlib + 10;
          endif;
          endfor;
          sflrrn = 1;
          write sflfn2;
          exfmt sflctl2;
        endif;

     ** chargement des bibliothèques saisie à l'écran dans tableau
        dynArrInfo.numAlloc = 39;
        dynArrInfo.p = %alloc(%size(dyndta) *
                            dynarrInfo.numAlloc);
        dynArrInfo.current = 1;

        for i = 1 by 1 to 39;
         readc sfl2;
         if lib <> '';
           %subarr(dyndta : i : dynarrInfo.current) = *blank;
           dyndta(i) = %editc(seqlib : 'X') + lib;
         else;
           dyndta(i) = '9999';
         endif;
        endfor;

        sorta %subarr(dyndta: 1);

     ** mise à jour du fichier
        if curlib = ' ';
         curlib = 'BERGER';
        endif;
        f2_seqlib = 0;
        f2_lstname = lstname;
        chain (lstname:f2_seqlib) fliblst2;
        if %found(fliblst2);
         f2_lib = curlib;
         update flibls2r;
        else;
         f2_lib = curlib;
         write flibls2r;
        endif;

        for i = 1 by 1 to 39;
         f2_lstname = lstname;
         f2_seqlib = f2_seqlib + 10;
         chain (lstname:f2_seqlib) fliblst2;
         if %found(fliblst2);
         if  %subst(dyndta(i):5:10) <> '';
          f2_lib = %subst(dyndta(i):5:10);
          update flibls2r;
         else;
          delete flibls2r;
         endif;
         else;
         if  %subst(dyndta(i):5:10) <> '';
          f2_lib = %subst(dyndta(i):5:10);
          write flibls2r;
         endif;
         endif;
        endfor;

        enddo;

        endsr;

        begsr chkaut;
         open fliblst1;
         chain (lstname) fliblst1;
         if user <> lstuser and lsttype = '2';
          msgfn1 = 'Non autorisé à modifier liste ' + lstname;
          clear opt;
         endif;
         close fliblst1;
        endsr;

      /end-free
