      // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
       // Test existence objet   renvoi *ON : objet existe, *OFF : objet non trouv
      // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
       Dcl-pr Exists ind;
         Obj char(20) CONST;
         ObjType char(10) CONST;
       end-pr;

       // Retrieve Object Description (QUSROBJD) API
       Dcl-pr RtvObj EXTPGM('QUSROBJD');
         Receiver char(1000) OPTIONS(*VARSIZE);    // Receiver variable
         RcvLen  int(10:0) CONST;                  // Length of receiver
         FmtName char(8) CONST;                    // Format name
         ObjName char(20) CONST;                   // Object and library
         ObjType char(10) CONST;                   // Object type
         //  Optional 1
         ErrorCode char(1300) OPTIONS(*VARSIZE:*NOPASS); // Error Code
       End-pr;

       //  Optional 2
       // Auxiliary storage pool (ASP) control  INPUT char(*)


       // --------------------------------------------------
       // Procedure name: aleatoire
       // Purpose:        Générer un nombre entier aléatoire entre 0 et le pa...
       //                          ramètre transmis
       // Returns:
       // Parameter:      mult => Valeur entière limite supérieure
       // --------------------------------------------------
       // --------------------------------------------------
       // Prototype for procedure: aleatoire
       // --------------------------------------------------
       DCL-PR aleatoire packed(15:0);
         mult PACKED(15:0) CONST;
       END-PR ;

       // --------------------------------------------------
       // Procedure name: ECRITURE_SCRIPT_FTP
       // Purpose:        Générer le script FTP d'envoi
       // Returns:
       // Parameter:      User de connexion distante
       //                 Mot de passe de connexion distante
       //                 Objet à envoyer par ftp
       //                 chemin ifs complet du répertoire d'origine
       //                 chemin ifs complet du répertoire de dépose
       // --------------------------------------------------
       // --------------------------------------------------
       // Prototype for procedure: aleatoire
       // --------------------------------------------------
       dcl-pr ECRITURE_SCRIPT_FTP;
         USER like(r_profil);
         MDP like(r_profil);
         Nom_Objet char(128);
         CHEMIN_origine like(r_chemin);
         CHEMIN_destination like(r_chemin);
       End-Pr;

       // --------------------------------------------------
       // Procedure name: SCRIPTFTP
       // Purpose:        Générer les fichiers sources FTP
       // Returns:
       // Parameter:      User de connexion distante
       //                 Mot de passe de connexion distante
       //                 Objet à envoyer par ftp
       //                 chemin ifs complet du répertoire d'origine
       //                 chemin ifs complet du répertoire de dépose
       // --------------------------------------------------
       // --------------------------------------------------
       // Prototype for procedure: aleatoire
       // --------------------------------------------------
       dcl-pr SCRIPTFTP;
         MACHINE like(r_nom_OBJ_IBMi);
         USER like(r_profil);
         MDP like(r_profil);
         Nom_savf like(r_nom_OBJ_IBMi);
         nom_fic_source like(r_nom_OBJ_IBMi);
       End-Pr;


       // --------------------------------------------------
       // Prototype for procedure: Elaboration du rapport de construction
       // --------------------------------------------------
       DCL-PR GstErrStr;
         P_Failed PACKED(10:0);
         P_FileAttach char(10000);
       END-PR ;

       // --------------------------------------------------
       // Prototype for Programme:Envoi vers système distant
       // --------------------------------------------------
       Dcl-Pr I_Push ExtPgm('I_PUSH');
         P_Objet char(20) Const;
         P_Sys_Dst CHAR(32) Const;
         P_User LIKE(r_nom_OBJ_IBMi) Const;
         P_Mot_De_Passe CHAR(10) Const;
       End-Pr;

       // --------------------------------------------------
       // Prototype for procedure: source_standard
       // --------------------------------------------------
       DCL-PR source_standard IND;
         P_Type_Objet LIKE(R_TypObj) CONST;
         P_Type_Source LIKE(r_nom_OBJ_IBMi) CONST;
         P_Biblio_Src_PRE LIKE(r_nom_OBJ_IBMi);
         P_Fichier_Src_PRE LIKE(r_nom_OBJ_IBMi);
         P_Membre_Src_PRE LIKE(r_nom_OBJ_IBMi);
       END-PR ;

       /If not defined(builder)
       // --------------------------------------------------
       // Prototype for procedure: builder
       // --------------------------------------------------
       DCL-PR builder EXTPGM('BUILDER');
         p_num_lot Like(r_Num_lot);
         P_Biblio_Lot LIKE(r_Nom_obj_IBMi) const;
         P_Env_Dest CHAR(1) const;
         P_Optim_Compil CHAR(20);
         P_Livr_Env_Dst IND const;
         P_Sys_Dst CHAR(32) const;
         P_User LIKE(r_Nom_obj_IBMi) const;
         P_Mot_De_Passe CHAR(10) const;
       END-PR ;
       /endif

       /If not defined(Livraison)
       //---------------------------------------------------
       // Préparation de la livraison
       //---------------------------------------------------
       Dcl-pr Livraison;
         p_Num_lot Like(r_Num_lot) value;
         p_Sys_Dst char(32) Const;
         P_User Char(10) Const;
         P_Mot_De_Passe Char(10) Const;
       End-Pr;
       /endif

       /If not defined(Cvthc)
       //---------------------------------------------------------
       // Convert Hex to Character
       dcl-pr cvthc extproc(*dclcase);
         *n pointer value; // receiver pointer
         *n pointer value; // source pointer
         *n int(10) value; // receiver length
       end-pr;
       /endif

       /If not defined(CVTCH)
       //---------------------------------------------------------
       // Convert Character to HEX
       dcl-pr cvtch extproc(*dclcase);
         *n pointer value; // receiver pointer
         *n pointer value; // source pointer
         *n int(10) value; // HexLen
       end-pr;
       /endif

       /If not defined(Construct)
       // --------------------------------------------------
       // Prototype for procedure: Construct
       // --------------------------------------------------
       DCL-PR Construct;
         P_PreBibSrc CHAR(10) CONST;
         P_PreFicSrc CHAR(10) CONST;
         P_UseSrcMbr CHAR(10) CONST;
         P_BibDst CHAR(10) CONST;
         P_ObjDst CHAR(10) CONST;
         P_TypObj char(7) CONST;
         P_BibSrc CHAR(10)  CONST;
         P_FicSrc CHAR(10)  CONST;
         P_MbrSrc CHAR(10) CONST;
         P_Optimize CHAR(20);
         P_Failed PACKED(10:0);
         P_FileAttach char(10000);
         P_liste_biblio Like(r_Nom_obj_IBMi);
         P_gestion_donnees Char(1) Const;
         p_Sys_Dst char(32) Const;
         P_User Char(10) Const;
         P_Mot_De_Passe Char(10) Const;
         P_Livr_Env_Dst IND const;
       END-PR ;
       /Endif

       /If not defined(EnvRapMel)
       // --------------------------------------------------
       // Prototype for procedure: Envoi d'un mail avec des pièces attachées au
       //                          user du job
       // --------------------------------------------------
       DCL-PR EnvRapMel;
       END-PR ;
       /Endif

       /If not defined(gest_erreur)
       // Prototype de la gestion d'erreur
       dcl-pr gest_erreur end-pr;
       /Endif

       // --------------------------------------------------
       // Prototype for procedure: gestion_bib_lot
       // --------------------------------------------------
       DCL-PR gestion_bib_lot IND;
         p_Num_lot Like(r_Num_lot) value;
       END-PR ;

       //---------------------------------------------------
       // Prototype for procédure:crtbibbld
       //---------------------------------------------------
       DCL-PR crtbibbld;
         P_NOUVLOTC like(r_Num_lot_carac);
         p_LIBEL_lot Like(r_Lib_lot);
         p_BIB_LOT like(r_Nom_obj_IBMi);
         p_prefix like(r_Prefix);
       END-PR ;

       // --------------------------------------------------
       // Prototype for procedure: infos_objet
       // --------------------------------------------------
       DCL-PR infos_objet IND;
         p_Object_name LIKE(r_qualified_name) CONST;
         p_Object_type LIKE(r_Nom_obj_IBMi) CONST;
         p_Base_infos_obj_light likeDS(OBJD0200_t);
       END-PR ;
      *---------------------------------------------------------------*
      *                                                               *
      * Procedure cmd_exec  : lance une commande (alias de exec)      *
      *                                                               *
      * paramètre en entrée : la commande                             *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PR cmd_exec;
         cmd varchar(1024) const;
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure cmd_chk   : teste une commande                      *
      *                                                               *
      * paramètre en entrée : la commande                             *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PR cmd_chk;
         cmd varchar(1024) const;
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Programme qcmdexc   : permet de lancer l'API                  *
      *                                                               *
      * paramètres en entrée : la chaine contenant la commande        *
      *                        la longueur de la chaine de commande   *
      *                                                               *
      * REMARQUE            : sera appelé par la procédure exec
      *                       ou cmd_exec                             *
      *---------------------------------------------------------------*
       DCL-PR qcmdexc extpgm('QCMDEXC');
         command char(1024) const options(*varsize);
         length  packed(15:5) const;
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Programme qcmdchk   : teste une commande                      *
      *                                                               *
      * paramètres en entrée : la chaine contenant la commande        *
      *                        la longueur de la chaine de commande   *
      *                                                               *
      * REMARQUE            : sera appelé par la procédure exec       *
      *---------------------------------------------------------------*
       DCL-PR qcmdchk extpgm('QCMDCHK');
         command char(1024) const options(*varsize);
         length  packed(15:5) const;
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procédure Edtliblot Mise en ligne d'une liste de bibliothèques*
      *                                                               *
      * paramètres en entrée : le nom de la liste paramétré dans      *
      *                        WRKLSTLIB                              *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PR edtliblot;
         p_List_bibliotheques char(10) const;
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procédure Savliblot sauvegarde une bibliothèque lot           *
      * identifiée par son numéro passé en paramète dans une SAVF     *
      * Placée dans la bibliothèque ARCHIVELOT                        *
      *                                                               *
      * paramètres en entrée : le numéro de lot                       *
      *---------------------------------------------------------------*
       DCL-PR Savliblot;
         p_Lot_number like(r_Num_lot_carac) Const;
       END-PR;

      * Prototypage fonction externe
       dcl-pr Mailerr;
         *n like(r_nom_obj_ibmi); // a_program
         *n like(r_nom_obj_ibmi); // a_module
         *n char(60); // a_procedure
         *n like(r_nom_obj_ibmi); // a_statement
         *n char(320); // a_mail
       end-pr;
