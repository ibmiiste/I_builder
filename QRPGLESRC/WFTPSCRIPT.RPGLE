**FREE
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) +
//                 SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//     >>PARM<<  TRUNCNBR(*NO);
//   >>END-IMPORTANT<<
//   >>CMD<<  CRTSRCPF FILE(QTEMP/FTPCMD) RCDLEN(240);
//   >>EXECUTE<<
//   >>CMD<<  DLTF FILE(QTEMP/FTPCMD);
// >>END-PRE-COMPILER<<
/copy qcpysrc,cpyctlstm

dcl-f ftpcmd usage(*output) rename(ftpcmd:ftpcmdf) usropn;
/copy qcpysrc,inhbuilder

/Copy Qcpysrc,prtbuilder

dcl-proc ECRITURE_SCRIPT_FTP export;
  dcl-pi ECRITURE_SCRIPT_FTP;
    l_USER like(r_profil);
    l_MDP like(r_profil);
    l_Nom_Objet char(128);
    l_chemin_origine like(r_chemin);
    l_CHEMIN_destination like(r_chemin);
  End-Pi;

  dcl-s l_seq packed(6:2) inz(1);

  Monitor;
    open ftpcmd;

    srcseq=l_seq;
    srcdat=*zero;
    srcdta = %trimr(l_USER) + ' ' + l_MDP;

    write ftpcmdf;

    l_seq+=1;
    srcseq=l_seq;
    srcdat=*zero;
    srcdta='NAMEFMT 1';

    write ftpcmdf;

    l_seq+=1;
    srcseq=l_seq;
    srcdat=*zero;
    srcdta='bin';

    write ftpcmdf;

    l_seq+=1;
    srcseq=l_seq;
    srcdat=*zero;
    srcdta='cd ' + %trim( l_CHEMIN_destination);

    write ftpcmdf;

    l_seq+=1;
    srcseq=l_seq;
    srcdat=*zero;
    srcdta='lcd ' + %trim( l_chemin_origine);

    write ftpcmdf;

    l_seq+=1;
    srcseq=l_seq;
    srcdat=*zero;
    srcdta='put ' + %trim( l_Nom_Objet) + '.FILE';

    write ftpcmdf;

    l_seq+=1;
    srcseq=l_seq;
    srcdat=*zero;
    srcdta='quit';

    write ftpcmdf;

    close ftpcmd;

  On-error;
    Dump(a);
    Gest_erreur();
  Endmon;

  return;
end-proc;
