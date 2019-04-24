**FREE
// PROGRAMME   : GSTLIBLSTR             DATE CREATION : 10/01/2017
// AUTEUR      : M.MIAUT                     COPYRIGHT C.I.S
//----------------------------------------------------------------
// Application : OUTILS
//               GESTION LISTES DE BIBLIOTHEQUES
//----------------------------------------------------------------
// MAINTENANCE :
//   AUTEUR                  OBJET                        DATE
//----------------------------------------------------------------
// INDICATEURS :
//----------------------------------------------------------------
// >>PRE-COMPILER<<                                              */
//   >>CRTCMD<<  CRTBNDRPG SRCFILE(&SL/&SF);                     */
//   >>IMPORTANT<<                                               */
//     >>PARM<<  PGM(&LI/&OB);                                   */
//     >>PARM<<  OPTION(*EVENTF);                                */
//     >>PARM<<  DBGVIEW(*ALL);                                  */
//   >>END-IMPORTANT<<                                           */
//   >>EXECUTE<<                                                 */
// >>END-PRE-COMPILER<<                                          */
//****************************************************************
ctl-opt datedit(*dmy) dftactgrp(*no) Bnddir('I_BUILDER') Option(*srcstmt);
dcl-f gstlstlibe workstn sfile(sfl1:sflrrn) sfile(sfl2:sflrrn) indds(IndDs);
dcl-f deflstlib1 keyed usage(*update: *output:*Delete) usropn;
dcl-f gstlstlib1 keyed usage(*update: *output:*Delete) prefix(f2_);

dcl-pr Gestion_liste_bibliotheque extpgm('PLIBLSTR');
  *n char(10); // selusr
  *n char(8); // sellst
  *n Char(2); // Option action
  *n Char(10); // Liste sélectionnée par l'option 1
end-pr;

/Copy Qcpysrc,inhbuilder

/Copy Qcpysrc,Prtbuilder

dcl-pi Gestion_liste_bibliotheque;
  selusr char(10);
  sellst char(8);
  Option_action Char(2); // Option opération
  P_List_selectionnee Char(10); // Liste de bibliothèques sélectionnée
end-pi;

dcl-pr Addlib extpgm('PADDLIBC');
  *n char(10);
end-pr;

dcl-pr Savlib extpgm('POSLIBC');
  *n char(4);
  *n char(10);
  *n char(10);
  *n char(10);
end-pr;

dcl-s updsfl ind;
dcl-s rrnsav like(sflrrn);
dcl-s seqnbr like(seqlib);

dcl-s Possav char(4) inz('*SAV');
dcl-s Poslst char(10) inz('LSTLIB');
dcl-s Poslib char(10) inz('QTEMP');
dcl-s Poscur char(10) inz('*YES');

dcl-s Lstlib char(2000) dtaara;
dcl-s I packed(4);

dcl-ds pgmsts PSDS;
  user char(10) pos(254);
end-ds;

dcl-ds dynArrInfo qualified;
  numAlloc int(10) inz(0);
  current int(10) inz(0);
  p pointer;
end-ds;

// Le DS des indicateurs de l'écran
Dcl-ds IndDs;
  Selectionner Ind Pos(25);
  Sflclr Ind Pos(30);
  Not_SFLDSP Ind Pos(31);
  Not_LSTNAME_PR Ind Pos(34);
  Not_RESTE_PR Ind Pos(35);
End-ds;

dcl-s dyndta char(14) dim(39) based(dynarrinfo.p);

// Renommage des touches de fonction
/Copy Qcpysrc,Fonction

// Sélection OK
Dcl-s l_Selection Ind Inz('0');

// Nombre d'option utilisé
Dcl-s l_Nbre_option Packed(4:0);

Monitor;
  sflini();

  dow not Sortie and Not l_Selection;

    if rrnsav <> 0;
      sflrrn = rrnsav;
    endif;

    write sflfn1;
    exfmt sflctl1;

    clear msgfn1;

    rrnsav = 0;

    if Creer;
      fmtadd();
    else;
      if sflrrn > 0;
        sflchg();
      endif;
    endif;

    if updsfl = *on;
      Sflclr = *on;
      Not_SFLDSP = *on;
      write sflctl1;
      Sflclr = *off;
      Not_SFLDSP = *off;
      sflini();
    endif;

  enddo;
On-error;
  Dump(a);
  Gest_erreur();
Endmon;

*inlr = *on;

Dcl-proc sflchg;
  l_Nbre_option=0;
  readc sfl1;
  rrnsav = sflrrn;
  dow not %eof;
    if opt <> '';
      l_Nbre_option+=1;
      rrnsav = sflrrn;
      chkaut();
      select;
      when opt = '1';
        Sellist();
      when opt = '2';
        fmtmaj();
      when opt = '4';
        fmtdlt();
        sflini();
      when opt = '5';
        fmtdsp();
      when opt = '6';
        edtlib();
      when opt = '7';
        chain (lstname) gstlstlib1;
        if %found(gstlstlib1);
          addlib (lstname);
        else;
          msgfn1 = 'Liste ' + %trim(lstname) +
                                      'vide. Option 7 rejetée.';
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
  // Si un message existe alors sélection invalide
  if l_Selection=*on and l_Nbre_option > 1;
    l_Selection=*off;
    msgfn1 = 'L''option 1=Selectionner s''utilise seule';
  Endif;

  sflrrn = rrnsav;
End-proc;

Dcl-proc fmtdsp;
  open deflstlib1;
  chain (lstname) deflstlib1;
  close deflstlib1;
  Not_SFLDSP = *off;
  Not_LSTNAME_PR = *off;
  exfmt fmt001;
End-proc;

Dcl-proc fmtdlt;
  exfmt windlt;
  if optdlt = 'O';
    open deflstlib1;
    chain lstname deflstlib1;
    chain lstname gstlstlib1;
    if %found(gstlstlib1);
      dow not %eof(gstlstlib1)
        or not %found(gstlstlib1);
        delete gstlstlib1;
        reade lstname gstlstlib1;
      enddo;
    endif;
    delete deflstlib1;
    close deflstlib1;
  endif;
  updsfl = *on;
  if sflrrn > 1 and optdlt = 'O';
    sflrrn = sflrrn - 1;
  endif;
  rrnsav = sflrrn;
End-proc;

Dcl-proc fmtadd;
  clear fmt001;
  Not_SFLDSP = *on;
  Not_LSTNAME_PR = *on;
  Not_RESTE_PR = *on;
  lstdate = %date;
  lsttime = %time;
  lstuser = user;
  exfmt fmt001;
  open deflstlib1;
  if lstname <> '';
    chain lstname deflstlib1;
    if not %found(deflstlib1);
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
  close deflstlib1;

  sflini();
End-proc;

// Choix d'une liste et renvoi dans le paramètre l'appel SELLIST
Dcl-proc Sellist;
  If not l_Selection;
    P_List_selectionnee=LSTNAME;
    l_Selection=*on;
  Else;
    msgfn1 = 'Vous ne pouvez sélectionner qu''une seule liste';
  Endif;
End-proc;

Dcl-proc fmtmaj;
  open deflstlib1;
  chain (lstname) deflstlib1;
  Not_SFLDSP = *off;
  Not_LSTNAME_PR = *off;
  Not_RESTE_PR = *on;
  exfmt fmt001;
  if lsttype = '2' and user <> lstuser;
    lsttype = '1';
    msgfn1 = 'Positionnement liste ' + %trim(lstname) +
      ' en accès privé impossible.';
  endif;
  update flibls1r;
  close deflstlib1;
  update sfl1;
End-proc;

Dcl-proc sflini;

  If Option_action='SE';
    Selectionner=*On;
  Endif;

  Sflclr = *on;
  Not_SFLDSP = *on;
  write sflctl1;
  Sflclr = *off;
  Not_SFLDSP = *off;

  sflrrn = 0;
  open deflstlib1;
  setll (*loval) deflstlib1;
  read deflstlib1;
  dow not %eof(deflstlib1);
    if sellst = '*ALL' and user = lstuser
      or sellst = '*ALL' and selusr = lstuser
      or sellst = '*ALL' and selusr = '*ALL'
      or sellst = '*PRIVATE' and user = lstuser
      or sellst = '*PRIVATE' and selusr = lstuser
      or sellst = '*PRIVATE' and selusr = '*ALL';
      sflrrn = sflrrn + 1;
      write sfl1;
    endif;
    read deflstlib1;
  enddo;
  if sflrrn > 0;
    sflrrn = 1;
  else;
    Sflclr = *off;
    Not_SFLDSP = *on;
  endif;
  close deflstlib1;
End-proc;

Dcl-proc edtlib;
  rrnsav = sflrrn;

  dou Annuler;

    Sflclr = *on;
    Not_SFLDSP = *on;
    write sflctl2;
    Sflclr = *off;
    Not_SFLDSP = *off;

    sflrrn = 0;
    setll lstname gstlstlib1;
    reade lstname gstlstlib1;
    curlib = f2_lib;
    reade lstname gstlstlib1;
    seqlib = 10;

    dow not %eof(gstlstlib1);
      sflrrn = sflrrn + 1;
      lib = f2_lib;
      write sfl2;
      seqlib = seqlib + 10;
      reade lstname gstlstlib1;
    enddo;

    dow sflrrn < 39;
      sflrrn = sflrrn + 1;
      clear lib;
      write sfl2;
      seqlib = seqlib + 10;
    enddo;

    sflrrn = 1;

    write sflfn2;
    exfmt sflctl2;

    if Capture;
      Sflclr = *on;
      Not_SFLDSP = *on;
      write sflctl2;
      Sflclr = *off;
      Not_SFLDSP = *off;
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

    // chargement des bibliothèques saisie à l'écran dans tableau
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

    // mise à jour du fichier
    if curlib = ' ';
      curlib = 'BERGER';
    endif;
    f2_seqlib = 0;
    f2_lstname = lstname;
    chain (lstname:f2_seqlib) gstlstlib1;
    if %found(gstlstlib1);
      f2_lib = curlib;
      update flibls2r;
    else;
      f2_lib = curlib;
      write flibls2r;
    endif;

    for i = 1 by 1 to 39;
      f2_lstname = lstname;
      f2_seqlib = f2_seqlib + 10;
      chain (lstname:f2_seqlib) gstlstlib1;
      if %found(gstlstlib1);
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

End-proc;

Dcl-proc chkaut;
  open deflstlib1;
  chain (lstname) deflstlib1;
  if user <> lstuser and lsttype = '2';
    msgfn1 = 'Non autorisé à modifier liste ' + lstname;
    clear opt;
  endif;
  close deflstlib1;
End-proc;
