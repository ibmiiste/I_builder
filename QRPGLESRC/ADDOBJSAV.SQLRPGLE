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
//   >>CMD<<  UPDSRVPGM SRVPGM(&LI/BUILDERSRV) +                //
//                      MODULE(&LI/&OB);                        //
// >>END-PRE-COMPILER<<                                         //

// Sp�cification de contr�les
ctl-opt nomain;


// External subprocedures prototypes globales
// prototype sous-proc�dures externes

/Copy Qcpysrc,Prtbuilder

// API de cr�ation de User Space
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

// R�cup�rer le pointer d'un User Space
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
// Prototype sous-proc�dures internes globales
Dcl-pr SndMsg;
  MsgType char(10) const;
  MsgID char(7) const;
  MsgDta char(256) const options(*varsize);
  LenMsgDta int(10) const;
End-pr;

Dcl-pr Init_keys_SAVOBJ;
  p_Num_lot like(r_Num_lot);
  p_Target_release Like(r_Target_release);
END-Pr;


// inherited variables
// h�ritage des types
/copy Qcpysrc,INHBuilder


// Global data-structures
// Structures de donn�es globales
Dcl-s savobjuspptr Pointer;
dcl-ds savobjusp Based(savobjuspptr);
  User_Space Char(32766);
End-ds;


// Nombres de clef utilis�es dans l'API
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

// Chemin d'acc�s information.
Dcl-s g_Access_Path_define Pointer;
Dcl-Ds Ds_Access_Path_define Based(g_Access_Path_define);
  g_Longueur_post_Access_Path Int(10:0);
  g_Clef_Access_Path Int(10:0);
  g_Longueur_valeurs_Access_Path Int(10:0);
  g_valeur_Access_Path Char(1);
End-ds;

// Ent�te Object info record (length not known).
Dcl-s g_Objet_define Pointer;
Dcl-Ds DS_Objet_define Based(g_Objet_define);
  g_Longueur_post_Objet Int(10:0);
  g_Clef_Objet Int(10:0);
  g_Longueur_valeurs_Objet Int(10:0);
  g_Nombre_valeur_Objet Int(10:0);
End-ds;

// Description des Version cible
Dcl-s g_Target_release Pointer;
Dcl-ds DS_Target_release Based(g_Target_release);
  g_Longueur_post_Target_release Int(10:0);
  g_Clef_Target_release Int(10:0);
  g_Longueur_valeurs_Target_release Int(10:0);
  g_valeurs_Target_release Like(r_Target_release);
End-ds;


// Description des objets � sauvegarder
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

// Nom biblioth�que retour
Dcl-s g_biblio_retournee char(10);

Dcl-s g_MsgTxt char(256);

// Program status data structure
// Data Structure d'information programme
/copy qcpysrc,psds

// constants
// constantes
Dcl-s c_usr_sp_SAVOBJ Char(20) inz('USPSAVOBJ QTEMP     ');
Dcl-c c_Trouve 0;

// D�finition de l'Interface de la proc�dure
// Param�tres d'appel
// Procedure-Interface definition
Dcl-proc Sauv_obj_lot Export;
  Dcl-pi Sauv_obj_lot;
    p_Num_lot Like(r_Num_lot);
    pEnvironnementDestination Char(1);
    p_Target_release Like(r_Target_release);
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
  // structures de donn�es locales


  // main function
  // Proc�dure principale

  Exec sql Set option commit=*None;

  monitor;

    // Sous-proc�dure de cr�ation du User Space utilis� par l'API QSRSAVO
    Creat_user_space();

    // Alimentation du User Space USPSAVOBJ avec les clefs 2, 3, 4 et 18
    // Cela d�finit la biblioth�que des objets � sauvegarder
    //              Le support de sauvegarde
    //              Le SAVF utilis� comme support
    //              l'option de ne pas sauvegarder les acc�s li�s � des physiques pr�sents
    //              dans la liste d'objets � sauvegarder
    Init_keys_SAVOBJ( p_Num_lot
                     :p_Target_release);

    // Alimentation du user space USPSAVOBJ avec la clef 1 et les objets � sauvegarder
    Ajout_clef_obj_sauv(p_Num_lot:pEnvironnementDestination);

    // Sauvegarde des objets
    Sauve_objets(c_usr_sp_SAVOBJ :APIError);

  on-error;
    dump(a);
    gest_erreur();
  endmon;


  // les sous-routines
  // traitement de l'�cran
  // begsr sr1;

  // endsr;

  return ;
END-PROC ;

// --------------------------------------------------
// Procedure name: Init_sauvegarde
// Purpose: Initialisation des enregistrements de l'API QSRSAVO
//          Biblioth�que � sauvegarder
//          Device de sauvegarde (*SAVF)
//          Emplacement de la SAVF
//          Option de non sauvegarde des logiques
// Returns:
// --------------------------------------------------
DCL-PROC Creat_user_space Export;

  // Pav� de cr�ation de SavObjSpc user space QTEMP/SAVLIST utilis� par l'API Save Objects
  // List QSRSAVO
  // V�rification que le User space n'existe pas avec l'API Retrieve Pointer to User Space
  // QUSPTRUS
  // S'il n'existe pas, il est cr�� avec l'API Create User Space (QUSCRTUS)
  // Modification des attributs du User Space avec l'API Change User Space Attributes
  // QUSCUSAT : Il est rendu autoextensible
  // et r�cup�re le pointeur du User space
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

    g_MsgTxt = 'Erreur d''acc�s au user space ' + c_Usr_sp_SAVOBJ +
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
    p_Target_release Like(r_Target_release);
  END-PI;

  Dcl-s l_Num_lot like(r_Num_lot);

  l_Num_lot=p_Num_lot;

  //Le pointer Nbr_post_cle_ptr est positionn� au d�but du pointer de SavObjUspPtr
  // pour pouvoir modifier le nombre de clef au fur et � mesure des ajouts
  Nbr_post_cle_ptr=SavObjUspPtr;

  // Initialisation du nombre de poste et on le palce au d�but du pointeur.
  g_Nbr_post_cle_var=0;


  // On d�place le pointeur de la taille de Ds_Nbr_post_cle_var pour �crire � la suite
  SavObjUspPtr += %Size(Ds_Nbr_post_cle_var);

  // On place le pointeur g_Biblio_define au m�me emplacement que SavObjUspPtr
  g_Biblio_define=SavObjUspPtr;
  // On alimente la DS g_Longueur_post_biblio qui se place � l'emplacement indiqu�
  // par le pointeur g_Biblio_define dans le Usr Space
  // Information biblioth�que
  g_Longueur_post_biblio=%Size(DS_Biblio_define);
  g_clef_bibliotheque=2;
  g_Longueur_valeur_biblio=%Size(g_Nombre_valeur_biblio)
                                     + %Size(g_nom_biblio);
  g_Nombre_valeur_biblio=1;
  g_nom_biblio='L' + %Editc(l_Num_lot:'X');

  // On d�place le pointeur de la taille de la DS aliment�e pr�c�demment
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

  // Version cible.
  g_Target_release=SavObjUspPtr;
  g_Longueur_post_Target_release=%Size(Ds_Target_release);
  g_Clef_Target_release=11;
  g_Longueur_valeurs_Target_release=%Size(g_valeurs_Target_release);
  g_valeurs_Target_release=p_Target_release;

  SavObjUspPtr+=%Size(Ds_Target_release);
  g_Nbr_post_cle_var+=1;

End-proc;


// --------------------------------------------------
// Procedure name: Ajout_clef_obj_sauv
// Purpose:        Ajouter la clef listant les objets � sauvegarder da...
//                          ns le User Space utilis� par l'API QSRSAVO
// Returns:
// --------------------------------------------------
DCL-PROC Ajout_clef_obj_sauv Export;
  Dcl-pi Ajout_clef_obj_sauv;
    p_Num_lot like(r_Num_lot);
    pEnvironnementDestination Char(1);
  END-PI;

  // Requ�te dynamique
  Dcl-s l_requete_sql Char(1024);
  Dcl-s l_Objdst Like(r_Nom_obj_IBMi);
  Dcl-s L_Srcdst Like(r_Nom_obj_IBMi);
  Dcl-s l_Typobj Like(r_TypObj);
  Dcl-s l_Num_lot like(r_Num_lot);
  // Environnement Origine
  Dcl-s l_environnement Char(1);
  // Biblioth�que Destination
  Dcl-s l_BIBLIOTHEQUE_DESTINATION Like(r_Nom_obj_IBMi);

  // Constantes locales
  Dcl-c PRODUCTION 'P';

  l_Num_lot=p_Num_lot;
  l_environnement=pEnvironnementDestination;

  EXEC SQL
    CLOSE Csr_Obj_Sav;

   l_requete_sql='SELECT Objet_Destination,' +
                         ' Type_Objet,' +
                         ' BIBLIOTHEQUE_DESTINATION' +
                   ' FROM L' + %editc(L_Num_Lot:'X') +
                       '.O' +  %editc(L_Num_Lot:'X') +
                    ' WHERE Lot_Number = ' + %char( L_Num_Lot) +
                    ' AND Type_Source <> ''SQL''' +
                    ' ORDER BY Ordre';

  EXEC SQL PREPARE Select_dyn_obj FROM :l_requete_sql;

  EXEC SQL
    DECLARE Csr_Obj_Sav CURSOR FOR Select_dyn_obj;

  EXEC SQL
    OPEN Csr_Obj_Sav;

  // Lecture des objets du lot � livrer
  EXEC SQL
    FETCH Csr_Obj_Sav INTO :L_Objdst, :L_Typobj, :l_BIBLIOTHEQUE_DESTINATION;


  // Alimentation du User Space avec l'ent�te de la partie clef=1 d�finition objet
  g_Objet_define=SavObjUspPtr;
  g_Clef_Objet=1;
  g_Nombre_valeur_Objet=0;

  // Ajout de 1 au nombre de clef
  g_Nbr_post_cle_var+=1;
  // On d�place le pointeur de la longueur de la DS d'ent�te de la clef 1
  SavObjUspPtr += %Size(DS_Objet_define);
  // On place le pointeur de description d'objet sur le pointeur du user space de sauvegarde
  g_Objet_desc=SavObjUspPtr;
  Dow Sqlcode=c_Trouve;
    If pEnvironnementDestination = PRODUCTION;
      Cpyobj( l_BIBLIOTHEQUE_DESTINATION
             :L_Objdst
             :L_Typobj
             :g_nom_biblio);
    Endif;

    g_Nom_objet=L_Objdst;
    g_Type_objet=L_Typobj;
    g_Nombre_valeur_Objet+=1;

    g_Objet_desc+=%Size(DS_Object_Desc);


    EXEC SQL
      FETCH Csr_Obj_Sav INTO :L_Objdst, :L_Typobj, :l_BIBLIOTHEQUE_DESTINATION;
  Enddo;


  // Ajout des sources SQL
  EXEC SQL
    CLOSE Csr_Sql_Sav;

  l_requete_sql='SELECT DISTINCT Fichier_Source ' +
                 ' FROM L' + %editc(L_Num_Lot:'X') +
                       '.O' +  %editc(L_Num_Lot:'X') +
                ' WHERE Lot_Number = ' + %char( L_Num_Lot)  +
                  ' AND Type_Source = ''SQL''';

  EXEC SQL PREPARE Select_dyn_sql FROM :l_requete_sql;

  EXEC SQL
    DECLARE Csr_Sql_Sav CURSOR FOR Select_dyn_sql;

  EXEC SQL
    OPEN Csr_Sql_Sav;

  // Lecture des objets du lot � livrer
  EXEC SQL
    FETCH Csr_Sql_Sav INTO :L_Srcdst;

  Dow Sqlcode=c_Trouve;

    g_Nom_objet=L_Srcdst;
    g_Type_objet='*FILE';
    g_Nombre_valeur_Objet+=1;

    g_Objet_desc+=%Size(DS_Object_Desc);


    EXEC SQL
      FETCH Csr_Sql_Sav INTO :L_Srcdst;
  Enddo;

  // Ajout du programme de restauration distante
  G_Nom_Objet='RSTOBJSQL';
  g_Type_objet='*PGM';
  g_Nombre_valeur_Objet+=1;

  g_Objet_desc+=%Size(DS_Object_Desc);

  g_Nom_objet='O' + %Editc(l_Num_lot:'X');
  g_Type_objet='*FILE';
  g_Nombre_valeur_Objet+=1;

  g_Objet_desc+=%Size(DS_Object_Desc);

  g_Longueur_valeurs_Objet=g_Nombre_valeur_Objet*20;

  g_Longueur_post_Objet=%Size(DS_Objet_define)+g_Longueur_valeurs_Objet;

  EXEC SQL
    CLOSE Csr_Obj_Sav;

  // Ajout des sources SQL
  EXEC SQL
    CLOSE Csr_Sql_Sav;

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
