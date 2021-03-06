**FREE
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
// >>END-PRE-COMPILER<<                                         //

// --------------------------------------------------
// Procedure: Restauration_objet
// --------------------------------------------------

// Option de compilation et de programme
ctl-opt datedit(*ymd) decedit('0,');
ctl-opt option(*nodebugio:*srcstmt:*nounref) CCSIDCVT(*LIST);

// D�claration des fichiers
// dcl-f fichier disk;

// Prototype Proc�dures Externe
//---------------------------------------------------------------*
//                                                               *
// Programme qcmdexc   : permet de lancer l'API                  *
//                                                               *
// param�tres en entr�e : la chaine contenant la commande        *
//                        la longueur de la chaine de commande   *
//                                                               *
// REMARQUE            : sera appel� par la proc�dure exec
//                       ou cmd_exec                             *
//---------------------------------------------------------------*
DCL-PR qcmdexc extpgm('QCMDEXC');
  command char(1024) const options(*varsize);
  length  packed(15:5) const;
END-PR;

// --------------------------------------------------
// Prototype for procedure: Construct
// --------------------------------------------------
DCL-PR Crtobjsql;
  P_PreBibSrc CHAR(10) CONST;
  P_PreFicSrc CHAR(10) CONST;
  P_UseSrcMbr CHAR(10) CONST;
  P_BibDst CHAR(10) CONST;
  P_ObjDst CHAR(10) CONST;
  P_TypObj char(7) CONST;
  P_BibSrc CHAR(10)  CONST;
  P_FicSrc CHAR(10)  CONST;
  P_MbrSrc CHAR(10) CONST;
  P_liste_biblio Like(r_Nom_obj_IBMi);
  P_gestion_donnees Char(1) Const;
END-PR ;

// Prototypes des sous-proc�dures interne
//---------------------------------------------------------------*
//                                                               *
// Procedure cmd_exec  : lance une commande (alias de exec)      *
//                                                               *
// param�tre en entr�e : la commande                             *
//                                                               *
//---------------------------------------------------------------*
DCL-PR cmd_exec;
  cmd varchar(1024) const;
END-PR;


// Program status data structure
// Data Structure d'information programme
/copy qcpysrc,psds


// inherited variables
// h�ritage des types
/copy QCPYSRC,INHBUILDER

// constants
// constantes
dcl-c  c_Trouve 0;

// D�finition de l'Interface de la proc�dure
// Param�tres d'appel
// Procedure-Interface definition
DCL-PI Restauration_objet ExtPGM('DSTLOT10');
  p_Num_lot LIKE(r_Num_lot_carac) Const;
END-PI;

Dcl-s l_Bibdst Like(r_Nom_obj_IBMi);
Dcl-s l_Objdst Like(r_Nom_obj_IBMi);
Dcl-s l_Typobj Like(r_TypObj);
Dcl-s l_Num_lot like(r_Num_lot);
Dcl-s l_Cmd Like(r_commande_CLLE);

Dcl-s l_Bib_lot Like(r_Nom_obj_IBMi);
Dcl-s l_Sav_lot Like(r_Nom_obj_IBMi);
Dcl-s l_Objet_lot Like(r_Nom_obj_IBMi);
Dcl-s L_Ficsrc Like(r_Nom_obj_IBMi);
Dcl-s L_Mbrsrc Like(r_Nom_obj_IBMi);
Dcl-s L_Typsrc Like(r_Typsrc);
Dcl-s L_ListLib Like(r_Nom_obj_IBMi);
Dcl-s l_option_donnees Char(1);

Dcl-s l_Requete Char(1024);

// main function
// Proc�dure principale

Monitor;

  l_Num_lot=%Dec(p_Num_lot:9:0);
  // Nom de la biblioth�que lot
  l_Bib_lot = 'L' + %Editc(l_Num_lot:'X');
  // Nom de la SAVF lot
  l_Sav_lot = 'S' + %Editc(l_Num_lot:'X');
  // Nom de la table contenant les objets � livrer
  l_Objet_lot = 'O' + %Editc(l_Num_lot:'X');

  // Mise en ligne de la biblioth�que temporaire de livraison
  l_Cmd='Addlible ' + l_Bib_lot;
  Cmd_exec(l_Cmd);

  // Mise en ligne de la biblioth�que de la commande STRPREPRC
  l_Cmd='Addlible ISPHERE';
  Cmd_exec(l_Cmd);

  EXEC SQL
    CLOSE Csr_Obj_Sav;

  l_Requete='SELECT Bibliotheque_destination, ' +
                   'Objet_Destination, ' +
                   'Type_Objet, ' +
                   'Fichier_source, ' +
                   'Membre_source, ' +
                   'Type_source, ' +
                   'Liste_biblio_projet ' +
              'FROM ' + l_Objet_lot +
             ' WHERE Lot_Number = ' + %Char(L_Num_Lot) +
             ' ORDER BY Ordre';

  EXEC SQL
    PREPARE Obj_List FROM :L_Requete;

  EXEC SQL
    DECLARE Csr_Obj_Sav CURSOR FOR Obj_List;

  EXEC SQL
    OPEN Csr_Obj_Sav;

  // Lecture des objets du lot � livrer
  EXEC SQL
    FETCH Csr_Obj_Sav
      INTO :L_Bibdst, :L_Objdst, :L_Typobj, :L_Ficsrc, :L_Mbrsrc, :L_Typsrc, :L_Listlib;

  Dow Sqlcode=c_Trouve;
    // Constitution de la commande de restauration par objet
    If L_Typsrc <> 'SQL';
      l_Cmd='RSTOBJ OBJ(' + L_Objdst + ') ' +
             'SAVLIB(' + l_Bib_lot + ') ' +
             'DEV(*SAVF) ' +
             'OBJTYPE(' + L_Typobj + ') ' +
             'SAVF(' + l_Bib_lot + '/' + l_Sav_lot + ') ' +
             'RSTLIB(' + L_Bibdst + ')';

      Cmd_exec(l_Cmd);
    Else;
      l_Cmd='RSTOBJ OBJ(' + L_Ficsrc + ') ' +
            'SAVLIB(' + L_BIB_LOT + ') ' +
            'DEV(*SAVF) ' +
            'SAVF(' + L_BIB_LOT + '/' + L_SAV_LOT + ') ' +
            'FILEMBR((' + L_FICSRC + ' (' + L_MBRSRC + '))) ' +
            'MBROPT(*ALL)'  ;
      Cmd_exec(l_Cmd);
      Crtobjsql( L_BIB_LOT
                 :L_FICSRC
                 :L_MBRSRC
                 :L_Bibdst
                 :L_Objdst
                 :L_Typobj
                 :L_BIB_LOT
                 :L_FICSRC
                 :L_MBRSRC
                 :L_ListLib
                 :l_option_donnees);
    Endif;
    EXEC SQL
      FETCH Csr_Obj_Sav
        INTO :L_Bibdst, :L_Objdst, :L_Typobj, :L_Ficsrc, :L_Mbrsrc, :L_Typsrc, :L_Listlib;
  Enddo;

  EXEC SQL
    CLOSE Csr_Obj_Sav;

  // Mise en ligne de la biblioth�que temporaire de livraison
  Monitor;
    l_Cmd='Rmvlible ' + l_Bib_lot;
    Cmd_exec(l_Cmd);
  On-error;
  ENDMON;

  Monitor;
    l_Cmd = 'DLTLIB ' + l_Bib_lot;
    Cmd_exec(l_Cmd);
  On-error;
  ENDMON;

on-error;
  dump(a);
Endmon;

// indicateur de fin de programme
*inlr = *on;

Return;

// les sous-routines
// traitement de l'�cran
// begsr sr1;

// endsr;


//---------------------------------------------------------------*
//                                                               *
// Procedure exec      : lance une commande                      *
//                                                               *
// param�tre en entr�e : la commande                             *
//                                                               *
//---------------------------------------------------------------*
DCL-PROC cmd_exec;

  DCL-PI *n;
    cmd varchar(1024) const;
  END-PI;

  qcmdexc(%trim(cmd):%len(%trim(cmd)));

END-PROC;
