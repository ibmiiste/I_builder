**FREE
// --------------------------------------------------
// Procedure: Restauration_objet
// --------------------------------------------------

// Option de compilation et de programme
/Copy Qcpysrc,Cpyctlstm
Ctl-opt bnddir('I_BUILDER');

// D�claration des fichiers
// dcl-f fichier disk;

// External subprocedures prototypes globales
// prototype sous-proc�dures externes
/Copy Qcpysrc,Prtbuilder


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
  p_Num_lot LIKE(r_Num_lot);
END-PI;

Dcl-s l_Bibdst Like(r_Nom_obj_IBMi);
Dcl-s l_Objdst Like(r_Nom_obj_IBMi);
Dcl-s l_Typobj Like(r_TypObj);
Dcl-s l_Num_lot like(r_Num_lot);
Dcl-s l_Cmd Like(r_commande_CLLE);

Dcl-s l_Bib_lot Like(r_Nom_obj_IBMi);
Dcl-s l_Sav_lot Like(r_Nom_obj_IBMi);
// main function
// Proc�dure principale

Monitor;

  l_Num_lot=p_Num_lot;
  // Nom de la biblioth�que lot
  l_Bib_lot = 'L' + %Editc(l_Num_lot:'X');
  // Nom de la SAVF lot
  l_Sav_lot = 'S' + %Editc(l_Num_lot:'X');

  // Mise en ligne de la biblioth�que temporaire de livraison
  l_Cmd='Addlible ' + l_Bib_lot;
  Cmd_exec(l_Cmd);

  EXEC SQL
    CLOSE Csr_Obj_Sav;

  EXEC SQL
    DECLARE Csr_Obj_Sav CURSOR FOR
      SELECT Bibliotheque_destination,
             Objet_Destination,
             Type_Objet
        FROM List_Objet_Build
        WHERE Lot_Number = :L_Num_Lot
        ORDER BY Ordre;

  EXEC SQL
    OPEN Csr_Obj_Sav;

  // Lecture des objets du lot � livrer
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
// traitement de l'�cran
// begsr sr1;

// endsr;


// --------------------------------------------------
// Procedure name: sous_proc1
// Purpose:
// Returns:
// --------------------------------------------------
// DCL-PROC sous_proc1 ;

// dcl-pi sous_proc1 ind;
//   donnees2 char(150);
// end-pi;
// Donn�es locales
// DCL-S l_donnee1 like(r_ref6);
// Programmation


// END-PROC ;


