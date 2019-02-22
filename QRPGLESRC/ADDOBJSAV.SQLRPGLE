**FREE
// Spécification de contrôles
/Copy Qcpysrc,Cpyctlstm


// External subprocedures prototypes globales
// prototype sous-procédures externes

/Copy Qcpysrc,Prtbuilder

// API de création de User Space
Dcl-pr Creation_usr_space extpgm('QUSCRTUS');
  *n char(20) const; // QualUsrSpcN
  *n char(10) const; // XAttr
  *n int(10) const; // IntSize
  *n char(1) const; // IntValue
  *n char(10) const; // PubAut
  *n char(50) const; // TxtDesc
  *n char(10) const options(*nopass); // ReplaceOpt
  *n likeds(ApiError) options(*nopass); // ErrCde
  *n char(10) const options(*nopass); // Domain
  *n int(10) const options(*nopass); // TfrSize
  *n char(1) const options(*nopass); // OptSpcAlgn
End-pr;

// API de changement d'attributs d'un User Space
Dcl-pr Chg_attrib_usr_space extpgm('QUSCUSAT');
  *n char(10); // RtnUsrSpcLib
  *n char(20) const; // QualUsrSpcN
  *n char(1) const options(*varsize); // UsrSpcAttrs
  *n likeds(ApiError); // ErrCde
End-pr;

// Récupérer le pointer d'un User Space
Dcl-pr Recup_Usr_Spc_Ptr extpgm('QUSPTRUS');
  *n char(20) const; // QualUsrSpcN
  *n pointer; // UsrSpcPtr
  *n likeds(ApiError) options(*nopass); // ErrCde
end-pr;


// Sauvegarde des objets
Dcl-pr Sauve_objets Extpgm('QSRSAVO');
  UsrSpcName Char(20) Const;
  Error Like(ApiError);
END-PR;

Dcl-pr SndPgmMsg extpgm('QMHSNDPM');
  *n char(7) const; // MsgID
  *n char(20) const; // QualMsgF
  *n char(256) const options(*varsize); // MsgDta
  *n int(10) const; // LenMsgDta
  *n char(10) const; // MsgType
  *n char(10) const; // CSE
  *n int(10) const; // CSECtr
  *n char(4); // MsgKey
  *n likeds(ApiError); // ErrCde
  *n int(10) const options(*nopass); // LenCSE
  *n char(20) const options(*nopass); // CSEQual
  *n int(10) const options(*nopass); // DspWait
  *n char(10) const options(*nopass); // CSEType
  *n int(10) const options(*nopass); // CCSID
End-pr;


// Internal subprocedures prototypes globales
// Prototype sous-procédures internes globales
Dcl-pr SndMsg;
  MsgType char(10) const;
  MsgID char(7) const;
  MsgDta char(256) const options(*varsize);
  LenMsgDta int(10) const;
End-pr;

Dcl-pr Init_keys_SAVOBJ;
  p_Num_lot like(r_Num_lot);
END-Pr;


// inherited variables
// héritage des types
/copy Qcpysrc,INHBuilder


// Global data-structures
// Structures de données globales
Dcl-s savobjuspptr Pointer;
dcl-ds savobjusp Based(savobjuspptr);
  User_Space Char(32766);
End-ds;


// Nombres de clef utilisées dans l'API
Dcl-s Nbr_post_cle_ptr Pointer;
Dcl-ds Ds_Nbr_post_cle_var Based(Nbr_post_cle_ptr);
  g_Nbr_post_cle_var Int(10:0);
End-ds;

// Library info record.
Dcl-s g_Biblio_define Pointer;
Dcl-ds DS_Biblio_define Based(g_Biblio_define);
  g_Longueur_post_biblio Int(10:0);
  g_clef_bibliotheque Int(10:0);
  g_Longueur_valeur_biblio Int(10:0);
  g_Nombre_valeur_biblio Int(10:0);
  g_nom_biblio char(10);
End-ds;

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
  g_Nom_SAVF Char(20);
End-ds;

// Chemin d'accès information.
Dcl-s g_Access_Path_define Pointer;
Dcl-Ds Ds_Access_Path_define Based(g_Access_Path_define);
  g_Longueur_post_Access_Path Int(10:0);
  g_Clef_Access_Path Int(10:0);
  g_Longueur_valeurs_Access_Path Int(10:0);
  g_valeur_Access_Path Char(1);
End-ds;

// Entête Object info record (length not known).
Dcl-s g_Objet_define Pointer;
Dcl-Ds DS_Objet_define Based(g_Objet_define);
  g_Longueur_post_Objet Int(10:0);
  g_Clef_Objet Int(10:0);
  g_Longueur_valeurs_Objet Int(10:0);
  g_Nombre_valeur_Objet Int(10:0);
End-ds;

// Description des objets à sauvegarder
Dcl-s g_Objet_desc Pointer;
Dcl-ds DS_Object_Desc Based(g_Objet_desc);
  g_Nom_objet Like(r_Nom_obj_IBMi);
  g_Type_objet Like(r_Typobj);
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

Dcl-s g_MsgTxt char(256);

// Program status data structure
// Data Structure d'information programme
/copy qcpysrc,psds

// constants
// constantes
Dcl-s c_usr_sp_SAVOBJ Char(20) inz('USPSAVOBJ QTEMP     ');
Dcl-c c_Trouve 0;

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


  // main function
  // Procédure principale


  monitor;

    // Sous-procédure de création du User Space utilisé par l'API QSRSAVO
    Creat_user_space();

    // Alimentation du User Space USPSAVOBJ avec les clefs 2, 3, 4 et 18
    // Cela définit la bibliothèque des objets à sauvegarder
    //              Le support de sauvegarde
    //              Le SAVF utilisé comme support
    //              l'option de ne pas sauvegarder les accès liés à des physiques présents
    //              dans la liste d'objets à sauvegarder
    Init_keys_SAVOBJ(p_Num_lot);

    // Alimentation du user space USPSAVOBJ avec la clef 1 et les objets à sauvegarder
    Ajout_clef_obj_sauv(p_Num_lot);

    // Sauvegarde des objets
    Sauve_objets(c_usr_sp_SAVOBJ :APIError);

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
DCL-PROC Creat_user_space Export;

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
                    :APIError);

  select;
  when APIError.BytesProv = 0;
  // All is OK

  when APIError.MsgID = 'CPF9801';
    // UsrSpc not found, so create it

    Creation_usr_space( c_Usr_sp_SAVOBJ
                       :'ListObjLot'
                       :4096
                       :x'00'
                       :'*ALL'
                       :'Utilise par Sauv_obj_lot'
                       :'*YES'
                       :APIError
                       :'*DEFAULT'
                       :0
                       :'1');

    Chg_attrib_usr_space( g_biblio_retournee
                         :c_Usr_sp_SAVOBJ
                         :DS_Usr_space_Attrs
                         :APIError);

    Recup_Usr_Spc_Ptr( c_Usr_sp_SAVOBJ
                      :SavObjUspPtr
                      :APIError);

  other;
    // Serious problem, so report it

    g_MsgTxt = 'Erreur d''accès au user space ' + c_Usr_sp_SAVOBJ +
                ': ' + APIError.MsgID;

    SndMsg('*DIAG' :'CPF9897'
           :g_MsgTxt :%len(%trimr(g_MsgTxt)));
    SndAPIMsg();
  endsl;

  Return;

END-PROC ;


// --------------------------------------------------
// Procedure name: Init_keys_SAVOBJ
// Purpose:
// Returns:
// --------------------------------------------------
DCL-PROC Init_keys_SAVOBJ Export;
  Dcl-pi Init_keys_SAVOBJ;
    p_Num_lot like(r_Num_lot);
  END-PI;

  Dcl-s l_Num_lot like(r_Num_lot);

  l_Num_lot=p_Num_lot;

  //Le pointer Nbr_post_cle_ptr est positionné au début du pointer de SavObjUspPtr
  // pour pouvoir modifier le nombre de clef au fur et à mesure des ajouts
  Nbr_post_cle_ptr=SavObjUspPtr;

  // Initialisation du nombre de poste et on le palce au début du pointeur.
  g_Nbr_post_cle_var=0;


  // On déplace le pointeur de la taille de Ds_Nbr_post_cle_var pour écrire à la suite
  SavObjUspPtr += %Size(Ds_Nbr_post_cle_var);

  // On place le pointeur g_Biblio_define au même emplacement que SavObjUspPtr
  g_Biblio_define=SavObjUspPtr;
  // On alimente la DS g_Longueur_post_biblio qui se place à l'emplacement indiqué
  // par le pointeur g_Biblio_define dans le Usr Space
  // Information bibliothèque
  g_Longueur_post_biblio=%Size(DS_Biblio_define);
  g_clef_bibliotheque=2;
  g_Longueur_valeur_biblio=%Size(g_Nombre_valeur_biblio)
                                     + %Size(g_nom_biblio);
  g_Nombre_valeur_biblio=1;
  g_nom_biblio='L' + %Editc(l_Num_lot:'X');

  // On déplace le pointeur de la taille de la DS alimentée précédemment
  SavObjUspPtr+=%Size(DS_Biblio_define);
  g_Nbr_post_cle_var+=1;

  // Device information.
  g_Device_define=SavObjUspPtr;
  g_Longueur_post_device=%Size(Ds_Device_define);
  g_Clef_device=3;
  g_Longueur_valeurs_device=%Size(g_Nombre_valeur_device)
                       +%Size(g_nom_device);
  g_Nombre_valeur_device=1;
  g_nom_device='*SAVF';

  SavObjUspPtr+=%Size(Ds_Device_define);
  g_Nbr_post_cle_var+=1;

  // SAVF information.
  g_SAVF_define=SavObjUspPtr;
  g_Longueur_post_SAVF=%Size(Ds_SAVF_define);
  g_Clef_SAVF=4;
  g_Longueur_valeurs_SAVF=%Size(g_Nom_SAVF);
  g_Nom_SAVF='S' + %Editc(l_Num_lot:'X') + 'L' + %Editc(l_Num_lot:'X');

  SavObjUspPtr+=%Size(Ds_SAVF_define);
  g_Nbr_post_cle_var+=1;

  // Save access paths information.
  g_Access_Path_define=SavObjUspPtr;
  g_Longueur_post_Access_Path=%Size(Ds_Access_Path_define);
  g_Clef_Access_Path=18;
  g_Longueur_valeurs_Access_Path=%Size(g_valeur_Access_Path);
  g_valeur_Access_Path='0';

  SavObjUspPtr+=%Size(Ds_Access_Path_define);
  g_Nbr_post_cle_var+=1;

End-proc;


// --------------------------------------------------
// Procedure name: Ajout_clef_obj_sauv
// Purpose:        Ajouter la clef listant les objets à sauvegarder da...
//                          ns le User Space utilisé par l'API QSRSAVO
// Returns:
// --------------------------------------------------
DCL-PROC Ajout_clef_obj_sauv Export;
  Dcl-pi Ajout_clef_obj_sauv;
    p_Num_lot like(r_Num_lot);
  END-PI;

  Dcl-s l_Objdst Like(r_Nom_obj_IBMi);
  Dcl-s l_Typobj Like(r_TypObj);
  Dcl-s l_Num_lot like(r_Num_lot);

  l_Num_lot=p_Num_lot;

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

  return ;
END-PROC ;

Dcl-proc SndMsg Export;
  Dcl-pi SndMsg;
    MsgType char(10) const;
    MsgID char(7) const;
    MsgDta char(256) const options(*varsize);
    LenMsgDta int(10) const;
  End-pi;

  Dcl-s l_MsgKey char(4);

  SndPgmMsg( MsgID
            :'QCPFMSG   *LIBL'
            :MsgDta
            :LenMsgDta
            :MsgType
            :'*PGMBDY'
            :1
            :l_MsgKey
            :APIError);
End-proc;


Dcl-proc SndAPIMsg Export;
  Dcl-pi SndAPIMsg end-pi;

  Dcl-s LenMsgDta int(10);
  Dcl-s l_MsgKey char(4);

  Select;
  When APIError.BytesAvail <= 16;
    LenMsgDta = 0;
  When APIError.BytesAvail > %size(APIError);
    LenMsgDta = %size(APIError.MessageData);
  Other;
    LenMsgDta = APIError.BytesAvail - %size(APIError);
  Endsl;

  SndPgmMsg( APIError.MsgID :'QCPFMSG   *LIBL'
            :APIError.MessageData :LenMsgDta
            :'*ESCAPE' :'*PGMBDY' :1 :l_MsgKey :APIError);
End-proc;
