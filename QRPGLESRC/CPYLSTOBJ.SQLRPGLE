**FREE
// Sp�cification de contr�les
/Copy Qcpysrc,Cpyctlstm
// --------------------------------------------------
// Procedure name: Copie_liste_objet_a_livres
// Purpose:        Liste dans une table les objets � livrer avec les e...
//                          mplacements o� les envoy�s
// Returns:
// Parameter:      p_Numero_lot => Num�ro de lot
// --------------------------------------------------
// >>PRE-COMPILER<<                                             //
//   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);       //
//   >>IMPORTANT<<                                              //
//     >>PARM<<  OBJ(&LI/&OB);                                  //
//     >>PARM<<  COMMIT(*NONE);                                 //
//     >>PARM<<  OBJTYPE(*MODULE);                              //
//     >>PARM<<  OPTION(*EVENTF);                               //
//     >>PARM<<  TGTRLS(*CURRENT);                              //
//     >>PARM<<  RPGPPOPT(*LVL2);                               //
//     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                         //
//     >>PARM<<  DATFMT(*ISO);                                  //
//     >>PARM<<  TIMFMT(*ISO);                                  //
//     >>PARM<<  DBGVIEW(*SOURCE);                              //
//     >>PARM<<  COMPILEOPT(&U0);                               //
//   >>END-IMPORTANT<<                                          //
//   >>EXECUTE<<                                                //
//   >>CMD<<  UPDSRVPGM SRVPGM(&LI/BUILDERSRV) +                //
//                      MODULE(&LI/&OB);                        //
// >>END-PRE-COMPILER<<                                         //
//
DCL-PROC Copie_liste_objet_a_livres Export;
  DCL-PI *N;
    p_Numero_lot LIKE(r_Num_lot);
    p_Objet_number Like(r_Auto_Number) options(*Nopass);
  END-PI ;


  // External subprocedures prototypes globales
  // prototype sous-proc�dures externes
  /Copy Qcpysrc,Prtbuilder


  // inherited variables
  // h�ritage des types
  /copy Qcpysrc,INHBuilder


  Dcl-s l_requete_sql Char(1024);

  Exec sql Set option commit=*None;

  Monitor;
    If %Parms= 1;
      l_requete_sql='Create Table L' + %editc(p_Numero_lot:'X') +
                    '.O' +  %editc(p_Numero_lot:'X') +
                    ' as ( Select a.*, ' +
                                 'b.LISTE_BIBLIO_PROJET ' +
                            'From list_objet_build a, Lots b ' +
                           'Where a.LOT_NUMBER = ' + %Char(p_Numero_lot) +
                            ' And a.LOT_NUMBER = b.LOT_NUMBER) With data';
    Else;


      l_requete_sql='Create Table L' + %editc(p_Numero_lot:'X') +
                    '.O' +  %editc(p_Numero_lot:'X') +
                    ' as ( Select a.*, ' +
                                 'b.LISTE_BIBLIO_PROJET ' +
                            'From list_objet_build a, Lots b ' +
                           'Where a.LOT_NUMBER = ' + %Char(p_Numero_lot) +
                            ' And a.LOT_NUMBER = b.LOT_NUMBER ' +
                            ' And a.OBJ_NUMBER= ' + %Char(p_Objet_number) +
                            ') With data';
    ENDIF;

    EXEC SQL
      EXECUTE IMMEDIATE :L_Requete_Sql;

  On-error;
    Dump(a);
    Gest_erreur();
  Endmon;

  return ;
END-PROC ;
