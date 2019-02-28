**FREE
// --------------------------------------------------
// Procedure: Restauration_objet
// --------------------------------------------------

// Option de compilation et de programme
ctl-opt datedit(*ymd) decedit('0,');
ctl-opt option(*nodebugio:*srcstmt:*nounref) CCSIDCVT(*LIST);

// Déclaration des fichiers
// dcl-f fichier disk;

// Prototype Procédures Externe
//---------------------------------------------------------------*
//                                                               *
// Programme qcmdexc   : permet de lancer l'API                  *
//                                                               *
// paramètres en entrée : la chaine contenant la commande        *
//                        la longueur de la chaine de commande   *
//                                                               *
// REMARQUE            : sera appelé par la procédure exec
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

// Prototypes des sous-procédures interne
//---------------------------------------------------------------*
//                                                               *
// Procedure cmd_exec  : lance une commande (alias de exec)      *
//                                                               *
// paramètre en entrée : la commande                             *
//                                                               *
//---------------------------------------------------------------*
DCL-PR cmd_exec;
  cmd varchar(1024) const;
END-PR;


// Program status data structure
// Data Structure d'information programme
/copy qcpysrc,psds


// inherited variables
// héritage des types
/copy QCPYSRC,INHBUILDER

// constants
// constantes
dcl-c  c_Trouve 0;

// Définition de l'Interface de la procédure
// Paramètres d'appel
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
// Procédure principale

Monitor;

  l_Num_lot=%Dec(p_Num_lot:9:0);
  // Nom de la bibliothèque lot
  l_Bib_lot = 'L' + %Editc(l_Num_lot:'X');
  // Nom de la SAVF lot
  l_Sav_lot = 'S' + %Editc(l_Num_lot:'X');
  // Nom de la table contenant les objets à livrer
  l_Objet_lot = 'O' + %Editc(l_Num_lot:'X');

  // Mise en ligne de la bibliothèque temporaire de livraison
  l_Cmd='Addlible ' + l_Bib_lot;
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

  // Lecture des objets du lot à livrer
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

  EXEC SQL CLOSE Csr_Obj_Sav;

  // Mise en ligne de la bibliothèque temporaire de livraison
  l_Cmd='Rmvlible ' + l_Bib_lot;
  Cmd_exec(l_Cmd);

  l_Cmd = 'DLTLIB ' + l_Bib_lot;
  Cmd_exec(l_Cmd);

on-error;
  dump(a);
Endmon;

// indicateur de fin de programme
*inlr = *on;

Return;

// les sous-routines
// traitement de l'écran
// begsr sr1;

// endsr;


//---------------------------------------------------------------*
//                                                               *
// Procedure exec      : lance une commande                      *
//                                                               *
// paramètre en entrée : la commande                             *
//                                                               *
//---------------------------------------------------------------*
DCL-PROC cmd_exec;

  DCL-PI *n;
    cmd varchar(1024) const;
  END-PI;

  qcmdexc(%trim(cmd):%len(%trim(cmd)));

END-PROC;
