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

  dcl-ds UsrSpc;

    // $Keys = the number of records that follow.
    $Keys bindec(9) inz(5);

    // Library info record.
    L2 bindec(9) inz(26);
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

    // Object info record (length not known).
    L1 bindec(9);
    K1 bindec(9) inz(1);
    LP1 bindec(9);
    $Objs bindec(9);
    ObjArr char(20) dim(1600);
  end-ds;

  Dcl-ds Device;
    $Devs bindec(9) inz(1);
    DevName Char(10) Inz('*SAVF');
  END-DS;
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

  on-error;
    dump(a);
    gest_erreur();
  endmon;


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
