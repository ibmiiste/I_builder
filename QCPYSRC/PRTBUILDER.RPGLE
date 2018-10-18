      // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
      // Test existence objet   renvoi *ON : objet existe, *OFF : objet non trouv
      // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
       Dcl-pr Exists ind;
         Obj char(20) CONST;
         ObjType char(10) CONST;
       end-pr;


      // OBJD0100 Format
       Dcl-ds OBJD0100_t qualified template;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         Name char(10);                 // Object name
         Lib char(10);                  // Object library name
         Type char(10);                 // Object type
         RtnLib char(10);               // Return library
         ASPNbr int(10);                // Object ASP number
         Owner char(10);                // Object owner
         Dommain char(2);               // Object domain
         CrtDte char(13);               // Creation date and t
         ChgDte char(13);               // Object change date
       end-ds;

       Dcl-ds OBJD0200_t qualified template;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         Name char(10);                 // Object name
         Lib char(10);                  // Object library name
         Type char(10);                 // Object type
         RtnLib char(10);               // Return library
         ASPNbr int(10);                // Object ASP number
         Owner char(10);                // Object owner
         Dommain char(2);               // Object domain
         CrtDte char(13);               // Creation date and t
         ChgDte char(13);               // Object change date
         Atr char(10);                  // Extended object att
         Txt char(50);                  // Text description
         SrcF char(10);                 // Source file name
         SRCL char(10);                 // Source file library
         SRCM char(10);                 // Source file member
       end-ds;

       Dcl-ds OBJD0300_t qualified template;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         Name char(10);                 // Object name
         Lib char(10);                  // Object library name
         Type char(10);                 // Object type
         RtnLib char(10);               // Return library
         ASPNbr int(10);                // Object ASP number
         Owner char(10);                // Object owner
         Dommain char(2);               // Object domain
         CrtDte char(13);               // Creation date and t
         ChgDte char(13);               // Object change date
         Atr char(10);                  // Extended object att
         Txt char(50);                  // Text description
         SrcF char(10);                 // Source file name
         SRCL char(10);                 // Source file library
         SRCM char(10);                 // Source file member
         SrcUpd char(13);               // Source file updated
         SveDte char(13);               // Object saved date a
         RstDte char(13);               // Object restored dat
         CrtUsr char(10);               // Creator's user prof
         filler char(8);                // System where object
         RzDte char(7);                 // Reset date
         SavSz int(10);                 // Save size
         SavSeq int(10);                // Save sequence numbe
         SavSto char(10);               // Storage
         SavCmd char(10);               // Save command
         SavVid char(71);               // Save volume ID
         SavDev char(10);               // Save device
         SavFnm char(10);               // Save file name
         SavFLb char(10);               // Save file library n
         SavLbl char(17);               // Save label
         SysLvl char(9);                // System level
         Compiler char(16);             // Compiler
         ObjLvl char(8);                // Object level
         UsrChgd char(1);               // User changed
         LicPgm char(16);               // Licensed program
         Ptf char(10);                  // Program temporary f
         AApar char(10);                // Authorized program
       end-ds;

        //          OBJD0400 -----------
       Dcl-ds OBJD0400_t qualified template;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         Name char(10);                 // Object name
         Lib char(10);                  // Object library name
         Type char(10);                 // Object type
         RtnLib char(10);               // Return library
         ASPNbr int(10);                // Object ASP number
         Owner char(10);                // Object owner
         Dommain char(2);               // Object domain
         CrtDte char(13);               // Creation date and t
         ChgDte char(13);               // Object change date
         Atr char(10);                  // Extended object att
         Txt char(50);                  // Text description
         SrcF char(10);                 // Source file name
         SRCL char(10);                 // Source file library
         SRCM char(10);                 // Source file member
         SrcUpd char(13);               // Source file updated
         SveDte char(13);               // Object saved date a
         RstDte char(13);               // Object restored dat
         CrtUsr  char(10);              // Creator's user prof
         filler char(8);                // System where object
         RzDte char(7);                 // Reset date
         SavSz int(10);                 // Save size
         SavSeq int(10);                // Save sequence numbe
         SavSto char(10);               // Storage
         SavCmd char(10);               // Save command
         SavVid char(71);               // Save volume ID
         SavDev char(10);               // Save device
         SavFnm char(10);               // Save file name
         SavFLb char(10);               // Save file library n
         SavLbl char(17);               // Save label
         SysLvl char(9);                // System level
         Compiler char(16);             // Compiler
         ObjLvl char(8);                // Object level
         UsrChgd char(1);               // User changed
         LicPgm char(16);               // Licensed program
         Ptf char(10);                  // Program temporary f
         AApar char(10);                // Authorized program
         UseDte char(7);                // Last-used date
         UseInfUpd char(1);             // Usage information u
         DayCnt int(10);                // Days-used count
         ObjSz int(10);                 // Object size
         OBjMul int(10);                // Object size multipl
         Compress char(1);              // Object compression
         PgmChgAlw char(1);             // Allow change by pro
         ChdPgm char(1);                // Changed by program
         UsrAtt char(10);               // User-defined attrib
         OflAsp char(1);                // Object overflowed A
         ActSavDte char(13);            // Save active date an
         AudVlu char(10);               // Object auditing val
         PriGrp char(10);               // Primary group
         JrnSts char(1);                //  Journal status
         JrnNm char(10);                // Journal name
         JrnLib char(10);               // Journal library nam
         JrnImg char(1);                // Journal images
         JrnOmit char(1);               // Journal entries to
         JrnStrDte char(13);            // Journal start date
         DgtSig char(1);                // Digitally signed
         SavUntSiz int(10);             // Saved size in units
         SavUntMul int(10);             // Saved size multipli
         AspLibNbr int(10);             // Library ASP number
         AspDevNm  char(10);            // Object ASP device n
         AspLibNm char(10);             // Library ASP device
         DgtTrust char(1);              // Digitally signed by
         dgtMost char(1);               //
       end-ds;

      // Prototype retour erreur API
       Dcl-ds ErrApi qualified;
         ErrLen int(10) inz(%len(ErrApi));  // Bytes provided
         ErrRtn int(10);                // Bytes available
         ErrId char(7);                 // Exception ID
         Filler char(1);                // Reserved  data
         ErrData char(32767);           //  Exception data
       end-ds;


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
         p_Objet_qual char(20) Const;
         P_gestion_donnees Char(1) Const;
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
