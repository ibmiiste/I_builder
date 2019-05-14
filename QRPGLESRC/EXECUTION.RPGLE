**FREE
// >>PRE-COMPILER<<                                             //
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) +   //
//                  SRCMBR(&SM);                                //
//  >>IMPORTANT<<                                               //
//     >>PARM<<  OPTION(*EVENTF);                               //
//     >>PARM<<  TGTRLS(*CURRENT);                              //
//     >>PARM<<  DBGVIEW(*ALL);                                 //
//     >>PARM<<  OPTIMIZE(&U0);                                 //
//     >>PARM<<  TRUNCNBR(*NO);                                 //
//   >>END-IMPORTANT<<                                          //

/copy Qcpysrc,cpyctlstm


/copy qcpysrc,prtbuilder

/copy Qcpysrc,Inhbuilder

//---------------------------------------------------------------*
//                                                               *
// Procedure exec      : lance une commande                      *
//                                                               *
// paramètre en entrée : la commande                             *
//                                                               *
//---------------------------------------------------------------*
DCL-PROC cmd_exec EXPORT;

  DCL-PI *n;
    cmd varchar(1024) const;
  END-PI;

  qcmdexc(%trim(cmd):%len(%trim(cmd)));

END-PROC;

//---------------------------------------------------------------*
//                                                               *
// Procedure cmd_chk   : teste une commande                      *
//                                                               *
// paramètre en entrée : la commande                             *
//                                                               *
//---------------------------------------------------------------*
DCL-PROC cmd_chk EXPORT;

  DCL-PI *n;
    cmd varchar(1024) const;
  END-PI;

  DCL-S long packed(15:5);
  monitor;
    long = %len(%trim(cmd));
    qcmdchk(cmd:long);
  On-error;
    Dump(a);
    Gest_erreur();
  Endmon;
END-PROC;
