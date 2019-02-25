**FREE
// --------------------------------------------------
// Procedure: Restauration_objet
// --------------------------------------------------

// Option de compilation et de programme
/Copy Qcpysrc,Cpyctlstm

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
  p_Num_lot LIKE(r_Num_lot);
END-PI;

Dcl-s l_Bibdst Like(r_Nom_obj_IBMi);
Dcl-s l_Objdst Like(r_Nom_obj_IBMi);
Dcl-s l_Typobj Like(r_TypObj);
Dcl-s l_Num_lot like(r_Num_lot);
Dcl-s l_Cmd Like(r_commande_CLLE);

Dcl-s l_Bib_lot Like(r_Nom_obj_IBMi);
Dcl-s l_Sav_lot Like(r_Nom_obj_IBMi);
Dcl-s l_Objet_lot Like(r_Nom_obj_IBMi);

Dcl-s l_Requete Char(1024);

// main function
// Procédure principale

Monitor;

  l_Num_lot=p_Num_lot;
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
                   'Type_Objet ' +
              'FROM ' + l_Objet_lot +
             'WHERE Lot_Number = :L_Num_Lot ' +
             'ORDER BY Ordre';

  EXEC SQL PREPARE Obj_List FROM :L_Requete;

  EXEC SQL
    DECLARE Csr_Obj_Sav CURSOR FOR Obj_List;

  EXEC SQL
    OPEN Csr_Obj_Sav;

  // Lecture des objets du lot à livrer
  EXEC SQL
    FETCH Csr_Obj_Sav INTO :L_Bibdst, :L_Objdst, :L_Typobj;


  Dow Sqlcode=c_Trouve;
    // Constitution de la commande de restauration par objet

    l_Cmd='RSTOBJ OBJ(' + L_Objdst + ') ' +
           'SAVLIB(' + l_Bib_lot + ') ' +
           'DEV(*SAVF)' +
           'OBJTYPE(' + L_Typobj + ') ' +
           'SAVF(' + l_Bib_lot + '/' + l_Sav_lot + ') ' +
           'RSTLIB(' + L_Bibdst + ')';

    Cmd_exec(l_Cmd);

    EXEC SQL
      FETCH Csr_Obj_Sav INTO :L_Bibdst, :L_Objdst, :L_Typobj;
  Enddo;

  EXEC SQL CLOSE Csr_Obj_Sav;

  l_Cmd = 'DLTLIB ' + l_Bib_lot;
  Cmd_exec(l_Cmd);

on-error;
  dump(a);
  gest_erreur();
endmon;

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
