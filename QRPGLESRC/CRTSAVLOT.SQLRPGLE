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

// inherited variables
// héritage des types
/copy Qcpysrc,INHBuilder

// Global data-structures
// Structures de données globales
Dcl-s savobjuspptr Pointer;
dcl-ds savobjusp Based(savobjuspptr) End-ds;


// Nombres de clef utilisées dans l'API
Dcl-s Nbr_post_cle_ptr Pointer;
Dcl-ds Ds_Nbr_post_cle_var Based(Nbr_post_cle_ptr);
  g_Nbr_post_cle_var Int(10:0) inz(5);
End-ds;

// Library info record.
Dcl-s g_Biblio_define Pointer;
Dcl-ds DS_Biblio_define Based(g_Biblio_define);
  g_Longueur_post_biblio Int(10:0);
  g_clef_bibliotheque Int(10:0);
  g_Longueur_valeur_biblio Int(10:0);
  g_Nombre_valeur_biblio Int(10:0);
  g_nom_biblio char(10);
End_ds;

// Device information.
Dcl-s g_Device_define Pointer;
Dcl-Ds Ds_Device_define Based(g_Device_define);
  g_Longueur_post_device Int(10:0);
  g_Clef_device Int(10:0);
  g_Longueur_valeurs_device Int(10:0);
  g_Nombre_valeur_device Int(10:0);
  g_nom_device Char(10);
End-ds;

// SAVF information.
Dcl-s g_SAVF_define Pointer;
Dcl-Ds Ds_SAVF_define Based(g_SAVF_define);
  g_Longueur_post_SAVF Int(10:0);
  g_Clef_SAVF Int(10:0);
  g_Longueur_valeurs_SAVF Int(10:0);
  g_Nombre_valeur_SAVF Int(10:0);
  g_Nom_SAVF Char(20);
End-ds;

// Chemin d'accès information.
Dcl-s g_Access_Path_define Pointer;
Dcl-Ds Ds_Access_Path_define Based(g_Access_Path_define);
  g_Longueur_post_Access_Path Int(10:0) inz(36);
  g_Clef_Access_Path Int(10:0) inz(4);
  g_Longueur_valeurs_Access_Path Int(10:0) inz(20);
  g_Nombre_valeur_Access_Path Int(10:0) inz(1);
  g_valeur_Access_Path Char(1);
End-ds;

// Entête Object info record (length not known).
Dcl-s g_Objet_define Pointer;
Dcl-Ds DS_Objet_define Based(g_Objet_define);
  g_Longueur_post_Objet Int(10:0);
  g_Clef_Objet Int(10:0) inz(1);
  g_Longueur_valeurs_Objet Int(10:0);
  g_Nombre_valeur_Objet Int(10:0);
End-ds;

// Description des objets à sauvegarder
Dcl-s g_Objet_desc Pointer;
Dcl-ds DS_Object_Desc Based(g_Objet_desc);
  g_Nom_objet Like(r_Nom_obj_IBMi);
  g_Type_objet Like(r_Typobj);
End-ds;

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
  g_NbrAttrs int(10) inz(1);
  g_AutoXtndKey int(10) inz(3);
  g_LenKeyVal int(10) inz(1);
  g_AutoXtndYes char(1) inz('1');
End-ds;


// global variables
// variables globales

// Nom bibliothèque retour
Dcl-s g_biblio_retournee char(10);

// Program status data structure
// Data Structure d'information programme
/copy qcpysrc,psds

// Définition de l'Interface de la procédure
// Paramètres d'appel
// Procedure-Interface definition
Dcl-proc Sauv_obj_lot Export;
  Dcl-pi Sauv_obj_lot;
    p_Num_lot Like(r_Num_lot);
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


  // constants
  // constantes
  dcl-c c_usr_sp_SAVOBJ const('USPSAVOBJ QTEMP     ');

  // main function
  // Procédure principale

  // indicateur de fin de programme
  *inlr = *on;
  monitor;

    // Sous-procédure de création du User Space utilisé par l'API QSRSAVO
    Creat_user_space();

    // Alimentation du User Space USPSAVOBJ avec les clefs 2, 3, 4 et 18
    // Cela définit la bibliothèque des objets à sauvegarder
    //              Le support de sauvegarde
    //              Le SAVF utilisé comme support
    //              l'option de ne pas sauvegarder les accès liés à des physiques présents dans la
    //              liste d'objets à sauvegarder
    Init_keys_SAVOBJ();

    // Alimentation du user space USPSAVOBJ avec la clef 1 et les objets à sauvegarder

    Ajout_clef_obj_sauv();

  on-error;
    dump(a);
    gest_erreur();
  endmon;


  // les sous-routines
  // traitement de l'écran
  // begsr sr1;

  // endsr;

  return ;
END-PROC ;

// --------------------------------------------------
// Procedure name: Init_sauvegarde
// Purpose: Initialisation des enregistrements de l'API QSRSAVO
//          Bibliothèque à sauvegarder
//          Device de sauvegarde (*SAVF)
//          Emplacement de la SAVF
//          Option de non sauvegarde des logiques
// Returns:
// --------------------------------------------------
DCL-PROC Creat_user_space;

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

    Chg_attrib_usr_space( g_biblio_retournee
                         :c_Usr_sp_SAVOBJ
                         :DS_Usr_space_Attrs
                         :MyErrCode);

    Recup_Usr_Spc_Ptr( c_Usr_sp_SAVOBJ
                      :SavObjUspPtr
                      :MyErrCode);

  other;
    // Serious problem, so report it

    MsgTxt = 'Erreur d''accès au user space ' + c_Usr_sp_SAVOBJ + ': ' +
             MyErrCode.MsgID;
    SndMsg('*DIAG' :'CPF9897'
           :MsgTxt :%len(%trimr(MsgTxt)));
    SndAPIMsg();
  endsl;

  Return;

END-PROC ;


// --------------------------------------------------
// Procedure name: Init_keys_SAVOBJ
// Purpose:
// Returns:
// --------------------------------------------------
DCL-PROC Init_keys_SAVOBJ ;

  g_Nbr_post_cle_var=0;
  //Le pointer Nbr_post_cle_ptr est positionné au début du pointer de SavObjUspPtr
  // pour pouvoir modifier le nombre de clef au fur et à mesure des ajouts
  Nbr_post_cle_ptr=SavObjUspPtr;
  // On déplace le pointeur de la taille de Ds_Nbr_post_cle_var pour écrire à la suite
  SavObjUspPtr += %Size(Ds_Nbr_post_cle_var);

  // On place le pointeur g_Biblio_define au même emplacement que SavObjUspPtr
  g_Biblio_define=SavObjUspPtr;
  // On alimente la DS g_Longueur_post_biblio qui se place à l'emplacement indiqué par le pointeur
  // g_Biblio_define dans le Usr Space
  // Information bibliothèque
  g_Longueur_post_biblio=%Size(DS_Biblio_define);
  g_clef_bibliotheque=2;
  g_Longueur_valeur_biblio=14;
  g_Nombre_valeur_biblio=1;
  g_nom_biblio='L' + %Editc(p_Num_lot:'X');

  // On déplace le pointeur de la taille de la DS alimentée précédemment
  SavObjUspPtr+=%Size(DS_Biblio_define);
  Nbr_post_cle_ptr+=1;

  // Device information.
  g_Device_define=SavObjUspPtr;
  g_Longueur_post_device=%Size(Ds_Device_define);
  g_Clef_device=3;
  g_Longueur_valeurs_device=14;
  g_Nombre_valeur_device=1;
  g_nom_device='*SAVF';

  SavObjUspPtr+=%Size(Ds_Device_define);
  Nbr_post_cle_ptr+=1;

  // SAVF information.
  g_SAVF_define=SavObjUspPtr;
  g_Longueur_post_SAVF=%Size(Ds_SAVF_define);
  g_Clef_SAVF=4;
  g_Longueur_valeurs_SAVF=20;
  g_Nombre_valeur_SAVF=1;
  g_Nom_SAVF='S' + %Editc(p_Num_lot:'X') + 'L' + %Editc(p_Num_lot:'X');

  SavObjUspPtr+=%Size(Ds_SAVF_define);
  Nbr_post_cle_ptr+=1;

  // Save access paths information.
  g_Access_Path_define=SavObjUspPtr;
  g_Longueur_post_Access_Path=%Size(Ds_Access_Path_define);
  g_Clef_Access_Path_=18;
  g_Longueur_valeurs_Access_Path=1;
  g_Nombre_valeur_Access_Path=1;
  g_Flag_Access_Path_='0';

  SavObjUspPtr+=%Size(Ds_Access_Path_define);
  Nbr_post_cle_ptr+=1;
End-proc;


// --------------------------------------------------
// Procedure name: Ajout_clef_obj_sauv
// Purpose:        Ajouter la clef listant les objets à sauvegarder da...
//                          ns le User Space utilisé par l'API QSRSAVO
// Returns:
// --------------------------------------------------
DCL-PROC Ajout_clef_obj_sauv ;
  Dcl-pi Ajout_clef_obj_sauv;
    p_Num_lot like(r_Numlot);
  END-PI;
  Dcl-s L_Objdst Like(r_Nom_obj_IBMi);
  Dcl-s L_Typobj Like(r_TypObj);

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
    FETCH List_Obj INTO :L_Objdst, :L_Typobj;

  // Alimentation du User Space avec l'entête de la partie clef=1 définition objet
  g_Objet_define=SavObjUspPtr;
  g_Clef_Objet=1;
  g_Nombre_valeur_Objet=0;

  // Ajout de 1 au nombre de clef
  Nbr_post_cle_ptr+=1;
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
      FETCH List_Obj INTO :L_Objdst, :L_Typobj;
  Enddo;

  g_Longueur_valeurs_Objet=g_Nombre_valeur_Objet*20;

  g_Longueur_post_Objet=%Size(DS_Objet_define)+g_Longueur_valeurs_Objet;

  return ;
END-PROC ;

