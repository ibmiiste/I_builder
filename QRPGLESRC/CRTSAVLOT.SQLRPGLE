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

// API de création de User Space
Dcl-pr Creation_usr_space Extpgm('QUSCHGUS');
  UsrSpcName Char(20) Const;
  StartPos Int(10) Const;
  LenUsrSpc Int(10) Const;
  UsrSpc Char(1000000) Const Options(*VarSize);
  Force2Aux Char(1);
  Error Like(ApiError);
END-PR;

// API de changement d'attributs d'un User Space
Dcl-pr Chg_attrib_usr_space extpgm('QUSCUSAT');
  *n char(10); // RtnUsrSpcLib
  *n char(20) const; // QualUsrSpcN
  *n char(1) const options(*varsize); // UsrSpcAttrs
  *n likeds(qusec); // ErrCde
End-pr;

// Récupérer le pointer d'un User Space
Dcl-pr Recup_Usr_Spc_Ptr extpgm('QUSPTRUS');
  *n char(20) const; // QualUsrSpcN
  *n pointer; // UsrSpcPtr
  *n likeds(qusec) options(*nopass); // ErrCde
end-pr;


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

// Nom bibliothèque retour
Dcl-s l_biblio_retournee char(10);

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

  //-----------------------------------------------------
  // API error code data structure
  //-----------------------------------------------------
  Dcl-ds MyErrCode;
    BytesProv int(10) inz(%size(myerrcode));
    BytesAvail int(10) inz(0);
    MsgID char(7);
    Reserved char(1);
    MessageData char(1000);
  End-ds;

  // Activiation de l'attribut autoextensible du User space
  Dcl-ds DS_Usr_space_Attrs qualified;
    l_NbrAttrs int(10) inz(1);
    l_AutoXtndKey int(10) inz(3);
    l_LenKeyVal int(10) inz(1);
    l_AutoXtndYes char(1) inz('1');
  End-ds;

  // inherited variables
  // héritage des types
  ///copy QINHLESRC,INH32766

  // constants
  // constantes
  dcl-c c_usr_sp_SAVOBJ const('SAVUSROBJ QTEMP     ');

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

    // Pavé de création de SavObjSpc user space QTEMP/SAVLIST utilisé par l'API Save Objects
  // List QSRSAVO
  // Vérification que le User space n'existe pas avec l'API Retrieve Pointer to User Space
  // QUSPTRUS
  // S'il n'existe pas, il est créé avec l'API Create User Space (QUSCRTUS)
  // Modification des attributs du User Space avec l'API Change User Space Attributes
  // QUSCUSAT : Il est rendu autoextensible
  // et récupére le pointeur du User space
  Recup_Usr_Spc_Ptr( c_usr_sp_SAVOBJ
                    :savobjuspptr
                    :MyErrCode);

  select;
  when MyErrCode.BytesProv = 0;
  // All is OK

  when MyErrCode.MsgID = 'CPF9801';
    // UsrSpc not found, so create it

    Creation_usr_space( SavObjUspPtr
                       :c_Usr_sp_SAVOBJ
                       :4096
                       :x'00'
                       :'*ALL'
                       :'Utilise par CRTSAVLOT'
                       :'*YES'
                       :MyErrCode
                       :'*DEFAULT'
                       :0
                       :'1');

    Chg_attrib_usr_space( l_biblio_retournee
                         :c_Usr_sp_SAVOBJ
                         :DS_Usr_space_Attrs
                         :MyErrCode);

    Recup_Usr_Spc_Ptr( c_Usr_sp_SAVOBJ
                      :SavObjUspPtr
                      :MyErrCode);

  other;
    // Serious problem, so report it

    MsgTxt = 'Error accessing SavHdrPtr: ' +
             MyErrCode.MsgID;
    SndMsg('*DIAG' :'CPF9897'
           :MsgTxt :%len(%trimr(MsgTxt)));
    SndAPIMsg();
  endsl;


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
