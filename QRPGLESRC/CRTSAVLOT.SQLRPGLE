**FREE
// Option de compilation et de programme
 /Copy Qcpysrc,Cpyctlstm


// Main procedure prototype
// Prototype Procédure principale
// dcl-pr programme extpgm('PGM');
//   paramentre char(5);
//   paramsortie packed(9:6);
// END-PR;

// External subprocedures prototypes globales
// prototype sous-procédures externes

/Copy Qcpysrc,Prtbuilder

Dcl-pr Creation_usr_space Extpgm('QUSCHGUS');
  UsrSpcName Char(20) Const;
  StartPos Int(10) Const;
  LenUsrSpc Int(10) Const;
  UsrSpc Char(1000000) Const Options(*VarSize);
  Force2Aux Char(1);
  Error Like(ApiError);
END-PR;

// Sauvegarde des objets
Dcl-pr Sauve_objets Extpgm('QSRSAVO');
  UsrSpcName Char(20) Const;
  Error Like(ApiError);
END-PR;


// Internal subprocedures prototypes globales
// Prototype sous-procédures internes globales


// Global data-structures
// Structures de données globales
// Indicateurs renommés avec Indara et INDDS
// dcl-ds ds1;
//   donneeds1 like(r_ref4);
//   donneeds2 like(r_ref5);
// end-ds;

// global variables
// variables globales
// dcl-s donnee3 like(r_ref3);

// Program status data structure
// Data Structure d'information programme
///copy qcpysrc,psds

// Définition de l'Interface de la procédure
// Paramètres d'appel
// Procedure-Interface definition
Dcl-proc Sauv_obj_lot Export;
  Dcl-pi Sauv_obj_lot;
    p_Num_lot Packed(9:0);
  END-PI;

  // local functions prototypes
  // prototypes fonctions locales
  // dcl-pr sous_proc1 ind;
  //   donnees2 char(150);
  // end-pr;

  // Indicateurs
  // dcl-s g_indic1 ind;

  // Touches de fonction
  ///copy qcpysrc,fonction

  // Local data-structures
  // structures de données locales
  // Indicateurs renommés avec Indara et INDDS
  // $Keys = the number of records that follow.
  Dcl-s savobjuspptr Pointer;
  dcl-ds savobjusp Based(savobjuspptr) End-ds;

  // Nombres de clef utilisées dans l'API
  Dcl-s Nbr_post_cle_ptr Pointer;
  Dcl-ds Ds_Nbr_post_cle_var Based(Nbr_post_cle_ptr);
    l_Nbr_post_cle_var Int(10:0) inz(5);
  End-ds;

  // Library info record.
  Dcl-s l_Biblio_define Pointer;
  Dcl-ds DS_iblio_define Based(l_Biblio_define);
    l_Longueur_post_biblio Int(10:0) inz(26);
    l_clef_bibliotheque Int(10:0) inz(2);
    l_Longueur_valeur_biblio Int(10:0) inz(14);
    l_Nombre_valeur_biblio Int(10:0) inz(1);
    l_nom_biblio char(10);
  End_ds;

  // Device information.
  Dcl-s l_Device_define Pointer;
  Dcl-Ds Ds_Device_define Based(l_Device_define);
    l_Longueur_post_device Int(10:0) inz(26);
    l_Clef_device Int(10:0) inz(4);
    l_Longueur_valeurs_device Int(10:0) inz(14);
    l_Nombre_valeur_device Int(10:0) inz(1);
    l_nom_device Char(10) Inz('*SAVF');
  End-ds;

    // SAVF information.
  Dcl-s l_SAVF_define Pointer;
  Dcl-Ds Ds_SAVF_define Based(l_SAVF_define);
    l_Longueur_post_SAVF Int(10:0) inz(36);
    l_Clef_SAVF Int(10:0) inz(4);
    l_Longueur_valeurs_SAVF Int(10:0) inz(20);
    l_Nombre_valeur_SAVF Int(10:0) inz(1);
    l_Nom_SAVF Char(20);
  End-ds;

    // Object info record (length not known).
  Dcl-s l_Objet_define Pointer;
  Dcl-Ds DS_Objet_define Based(l_Objet_define);
    l_Longueur_post_Objet Int(10:0);
    l_Clef_Objet Int(10:0) inz(1);
    l_Longueur_valeurs_Objet Int(10:0);
    l_Nombre_valeur_Objet Int(10:0);
    l_Nom_objet_qualifie char(20) dim(1600);
  end-ds;


  // inherited variables
  // héritage des types
  ///copy QINHLESRC,INH32766

  // constants
  // constantes
  dcl-c cUsrSpcNam const('SAVUSROBJ QTEMP     ');

  // main function
  // Procédure principale

  // indicateur de fin de programme
  *inlr = *on;
  monitor;

  Init_sauvegarde();

  on-error;
    dump(a);
    gest_erreur();
  endmon;


  // les sous-routines
  // traitement de l'écran
  // begsr sr1;

  // endsr;


// --------------------------------------------------
// Procedure name: Init_sauvegarde
// Purpose: Initialisation des enregistrements de l'API QSRSAVO
//          Bibliothèque à sauvegarder
//          Device de sauvegarde (*SAVF)
//          Emplacement de la SAVF
//          Option de non sauvegarde des logiques
// Returns:
// --------------------------------------------------
DCL-PROC Init_sauvegarde;

  Dcl-pi Init_sauvegarde End-pi;


  L2= bindec(9) inz(26);
  K2 bindec(9) inz(2);
  LP2 bindec(9) inz(14);
  $Libs bindec(9) inz(1);
  LibName char(10);

  // Device information.
  L3 bindec(9) inz(26);
  K3 bindec(9) inz(4);
  LP3 bindec(9) inz(14);
  $Devs bindec(9) inz(1);
  DevName Char(10) Inz('*SAVF');

  // Device information.
  L4 bindec(9) inz(36);
  K4 bindec(9) inz(4);
  LP4 bindec(9) inz(20);
  $Devs bindec(9) inz(1);
  DevName Char(20);

END-PROC ;
