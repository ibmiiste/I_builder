**FREE
// --------------------------------------------------
// Prototype for procedure: Restauration_objet
// --------------------------------------------------


// Option de compilation et de programme
/Copy Qcpysrc,Cpyctlstm


// Déclaration des fichiers
// dcl-f fichier disk;

// Main procedure prototype
// Prototype Procédure principale
// dcl-pr programme extpgm('PGM');
//   paramentre char(5);
//   paramsortie packed(9:6);
// END-PR;

// External subprocedures prototypes globales
// prototype sous-procédures externes
// dcl-pr proc_ext varchar(300) extproc('PROC_EXT1');
//   donnees1 packed(10:0);
// end-pr;

// Internal subprocedures prototypes globales
// Prototype sous-procédures internes globales
// dcl-pr proc_int varchar(150);
//   donnees1 packed(10:0);
// end-pr;

// Global data-structures
// Structures de données globales
// Indicateurs renommés avec Indara et INDDS
// dcl-ds ds1;
//   donneeds1 like(r_ref4);
//   donneeds2 like(r_ref5);
// end-ds;

// global variables
// variables globales
// Dcl-s g_Donnee3 like(r_ref3);

// Program status data structure
// Data Structure d'information programme
///copy qcpysrc,psds



// inherited variables
// héritage des types
/copy QCPYSRC,INHBUILDER

// constants
// constantes
// dcl-c constante1 'CONSTANTE';

// Définition de l'Interface de la procédure
// Paramètres d'appel
// Procedure-Interface definition
DCL-PI Restauration_objet;
  p_Num_lot LIKE(r_Num_lot);
END-PI;


Dcl-s l_Objdst Like(r_Nom_obj_IBMi);
Dcl-s l_Typobj Like(r_TypObj);
Dcl-s l_Num_lot like(r_Num_lot);
Dcl-s l_Cmd Like(r_commande_CLLE);

// main function
// Procédure principale

Monitor;

  l_Num_lot=p_Num_lot;

  // Mise en ligne de la bibliothèque temporaire de livraison
  l_Cmd='Addlible L' + %Editc(l_Num_lot:'X');
  CMD_EXEC(l_md);

  EXEC SQL
    CLOSE Csr_Obj_Sav;

  EXEC SQL
    DECLARE Csr_Obj_Sav CURSOR FOR
      SELECT Objet_Destination,
             Type_Objet
        FROM List_Objet_Build
        WHERE Lot_Number = :L_Num_Lot
        ORDER BY Ordre;

  EXEC SQL
    OPEN Csr_Obj_Sav;

  // Lecture des objets du lot à livrer
  EXEC SQL
    FETCH Csr_Obj_Sav INTO :L_Objdst, :L_Typobj;

  // Alimentation du User Space avec l'entête de la partie clef=1 définition objet
  g_Objet_define=SavObjUspPtr;
  g_Clef_Objet=1;
  g_Nombre_valeur_Objet=0;

  // Ajout de 1 au nombre de clef
  g_Nbr_post_cle_var+=1;
  // On déplace le pointeur de la longueur de la DS d'entête de la clef 1
  SavObjUspPtr += %Size(DS_Objet_define);
  // On place le pointeur de description d'objet sur le pointeur du user space de sauvegarde
  g_Objet_desc=SavObjUspPtr;
  Dow Sqlcode=c_Trouve;
    // Save access paths information.


    g_Nom_objet=L_Objdst;
    g_Type_objet=L_Typobj;
    g_Nombre_valeur_Objet+=1;

    g_Objet_desc+=%Size(DS_Object_Desc);


    EXEC SQL
      FETCH Csr_Obj_Sav INTO :L_Objdst, :L_Typobj;
  Enddo;

  g_Longueur_valeurs_Objet=g_Nombre_valeur_Objet*20;

  g_Longueur_post_Objet=%Size(DS_Objet_define)+g_Longueur_valeurs_Objet;

  EXEC SQL CLOSE Csr_Obj_Sav;

on-error;
  dump(a);
  gest_erreur();
endmon;

// indicateur de fin de programme
*inlr = *on;

Retunr;

// les sous-routines
// traitement de l'écran
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
// Données locales
// DCL-S l_donnee1 like(r_ref6);
// Programmation


// END-PROC ;



