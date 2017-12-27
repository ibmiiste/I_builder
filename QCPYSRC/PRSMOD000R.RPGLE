       // Prototypes des modules généraux non fonctionnels
       // Bibliothèque BERGER

      /if defined(PRSMOD000R_H)
        /eof
      /endif

      /define PRSMOD000R_H

      /copy BPPGM/QCPYSRC,INH32766

      *---------------------------------------------------------------*
      *                                                               *
      * Constantes de mnémoniques                                     *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-C TRUE  const(*on);
       DCL-C FALSE const(*off);

       DCL-C FIRST const('0');
       DCL-C NEXT const('1');
       DCL-C LAST const('2');


       DCL-C CREATION const('1');
       DCL-C MODIFICATION const('2');
       DCL-C COPIE const('3');
       DCL-C SUPPRESSION const('4');
       DCL-C VISUALISATION const('5');
       DCL-C MODE_FERMETURE const('*');
       DCL-C MODE_INITIALISATION const('0');

       dcl-c KEY_ENTER const(X'F1');
       dcl-c KEY_EXIT const(X'33');     //F03
       dcl-c KEY_CANCEL const(X'3C');   //F12
       dcl-c KEY_PAGEUP const(X'F4');
       dcl-c KEY_PAGEDOWN const(X'F5');
       dcl-c KEY_INVITE const(X'34');   //F04
       dcl-c KEY_REFRESH const(X'35');  //F05
       dcl-c KEY_CREATE const(X'36');   //F06
       dcl-c KEY_VALIDATE const(X'3A'); //F10
       dcl-c KEY_F08 const(X'38');    //F08
       dcl-c KEY_F15 const(X'B3');    //F15
       dcl-c KEY_DELETE const(X'BB'); //F23

       DCL-C INNER_JOIN const('INNER JOIN');
       DCL-C LEFT_OUTER_JOIN const('LEFT OUTER JOIN');
       DCL-C RIGHT_OUTER_JOIN const('RIGHT OUTER JOIN');
       DCL-C EXCEPTION_JOIN const('EXCEPTION JOIN');

       //demander l'extraction du diagnostic SQL en place du paramètre
       DCL-C SQL_DIAG const('*SQLDIAG');

       //valeur std des boutons pour les boites de dialogue
       DCL-C BTN_NONE    0;
       DCL-C BTN_OK      1;
       DCL-C BTN_CANCEL  2;
       DCL-C BTN_ABORT   4;
       DCL-C BTN_RETRY   8;
       DCL-C BTN_IGNORE 16;
       DCL-C BTN_YES    32;
       DCL-C BTN_NO     64;

       dcl-c JOB_INTERACTIF 'I';
       dcl-c JOB_BATCH 'B';



      // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
      // Test existence objet   renvoi *ON : objet existe, *OFF : objet non trouv
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
       end-pr;
      //  Optional 2
      // Auxiliary storage pool (ASP) control  INPUT char(*)

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


      // Retrieve Job Information (QUSRJOBI) API
       Dcl-pr rtvJobInf EXTPGM('QUSRJOBI');
         Receiver char(100) OPTIONS(*VARSIZE);     // Receiver variable
         RcvLen  int(10:0) CONST;                  // Length of receiver
         FmtName char(8) CONST;                    // Format name
         ObjName char(20) CONST;                   // Object and library
         ObjType char(10) CONST;                   // Object type
      //  Optional 1
         ErrorCode char(32767) OPTIONS(*VARSIZE:*NOPASS); // Error Code
       end-pr;

      // OBJD0100 Format
       dcl-ds JOBI0100 QUALIFIED;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         jobType char(1) pos(61);       // Job type : 'B'=batch, 'I'=Interactif, ...
       end-ds;

       // Prototype retour erreur API
       Dcl-ds ErrApi qualified;
         ErrLen int(10) inz(%len(ErrApi));  // Bytes provided
         ErrRtn int(10);                // Bytes available
         ErrId char(7);                 // Exception ID
         Filler char(1);                // Reserved  data
         ErrData char(32767);           //  Exception data
       end-ds;

       // Prototype de la gestion d'erreur
       dcl-pr gest_erreur end-pr;

       // Contrôle de la syntaxe d'un adresse email
       dcl-pr adresse_valide ind;
         p_adresse_mail like(r_adress_email) const;
       END-Pr;
              // Manipulation de date
       // Traiement des date EURO
       dcl-pr Format_date like(r_datechar);
         p_date date const;
         p_format char(5) const;
       END-Pr;


       // Détermination du 1er du mois
       dcl-pr premier_jour_mois date;
         p_date date const;
       END-Pr;

       // Détermination du dernier jour du mois
       dcl-pr dernier_jour_mois date;
         p_date date const;
       END-Pr;

       // Procédures de gestion des sous-fichiers de messages
       dcl-ds variables_gst_message qualified;
          MSGBIB like(r_nomobj);        //Bib du MSGF
          MSGFIC like(r_nomobj);        //Nom du MSGF
          MSGNUM like(r_numero_msg);     //N° du messag
          MSGPGM like(r_nomobj);        //Pgm récepteur
          MSGDT1 like(r_data_message);  //Variable 1
          MSGDT2 like(r_data_message);  //Variable 2
          MSGDT3 like(r_data_message);  //Variable 3
          MSGDT4 like(r_data_message);  //Variable 4
          MSGDT5 like(r_data_message);  //Variable 5
          MSGCLR char(1);               // Clear MSGQ (0/1)
       end-ds;

       dcl-pr gst_message;
       //   MSGBIB like(r_nomobj);        //Bib du MSGF
       //   MSGFIC like(r_nomobj);        //Nom du MSGF
       //   MSGNUM like(r_numro_msg);     //N° du messag
       //   MSGPGM like(r_nomobj);        //Pgm récepteur
       //   MSGDT1 like(r_data_message);  //Variable 1
       //   MSGDT2 like(r_data_message);  //Variable 2
       //   MSGDT3 like(r_data_message);  //Variable 3
       //   MSGDT4 like(r_data_message);  //Variable 4
       //   MSGDT5 like(r_data_message);  //Variable 5
       //   MSGCLR char(1);               // Clear MSGQ (0/1)
       end-pr;

       dcl-pr EMS010C;
          MSGBIB like(r_nomobj) const;        //Bib du MSGF
          MSGFIC like(r_nomobj) const;        //Nom du MSGF
          MSGNUM like(r_numero_msg) const;    //N° du messag
          MSGPGM like(r_nomobj) const;        //Pgm récepteur
          MSGDT1 like(r_data_message) const;  //Variable 1
          MSGDT2 like(r_data_message) const;  //Variable 2
          MSGDT3 like(r_data_message) const;  //Variable 3
          MSGDT4 like(r_data_message) const;  //Variable 4
          MSGDT5 like(r_data_message) const;  //Variable 5
          MSGCLR char(1) const;               // Clear MSGQ (0/1)
       end-pr;


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
      * Procedure qry_init   : initilise un nouvel OPNQRYF            *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PR qry_init;
          fichier char(10) const;
          membre  char(10) const  options(*omit:*nopass);
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addslt : ajout d'un critère de sélection        *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PR qry_addSlt;
          nomZone     varchar(50) const;
          comparateur char(4)     const;
          valeur      varchar(50) const;
          type        char(1)     const options(*nopass);
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSlt_beg : ajout d'un critère de sélection    *
      *                            sur les premiers caractères        *
      *---------------------------------------------------------------*
       DCL-PR qry_addSlt_beg;
          nomZone     varchar(10) const;
          long        packed(3:0) const;
          valeur      varchar(50) const;
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_clrSlt : initialisation de la sélection seule   *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PR qry_clrSlt END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSort: ajout d'un critère de tri              *
      *                       ASCENDANT                               *
      *---------------------------------------------------------------*
       DCL-PR qry_addSort;
          nomZone     char(10) const;
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSortD: ajout d'un critère de tri             *
      *                         DESCENDANT                            *
      *---------------------------------------------------------------*
       DCL-PR qry_addSortD;
          nomZone     char(10) const;
       END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_clrSrt : initialisation des critères de tri     *
      *                        seuls                                  *
      *---------------------------------------------------------------*
       DCL-PR qry_clrSort END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_bldcmd : Construction de l'OPNQRYF              *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PR qry_bldcmd varchar(2000) END-PR;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSlt_in : ajout d'un critère de sélection     *
      *                           sur une liste de valeurs            *
      * paramètres d'entrée : nomZone                                 *
      *                       valeur élément de la liste de valeurs   *
      *                       position (FIRST, LAST ou NEXT)          *
      *---------------------------------------------------------------*
       DCL-PR qry_addSlt_in;
          nomZone     varchar(10)    const;
          valeur      varchar(65535) const;
          position    char(1)        const options(*nopass);
       END-PR;


     ***************************************************************************
     **                                                                       **
     **  DummyPtr : modèle de pointeur pour les DS                            **
     **                                                                       **
     ***************************************************************************
       DCL-S DummyPtr pointer;

     ***************************************************************************
     **                                                                       **
     **  Throw : Throw : Emission d'un message programme                      **
     **                                                                       **
     ***************************************************************************
       DCL-PR msg_throw ExtProc('MSG_THROW');
          MsgId     char(7) const;
          MsgDataIn varchar(3000) const options(*Omit:*NoPass);
          MsgFileIn char(10) const options(*NoPass);
          MsgLibIn char(10) const options(*NoPass);
       END-PR;

     ***************************************************************************
     **                                                                       **
     **  Send  : Emission d'un message programme avec choix du type de        **
     **          message                                                      **
     **                                                                       **
     **  Returns:   La clé du message généré                                  **
     ***************************************************************************
       DCL-PR msg_send char(4) ExtProc('MSG_SEND');
          MsgId     char(7) const;
          MsgDataIn varchar(32767) const options(*Omit:*NoPass);
          MsgType   char(10) const options(*NoPass);
          MsgFileIn char(10) const options(*NoPass);
          MsgLibIn char(10) const options(*NoPass);
       END-PR;

       // --------------------------------------------------
       // Procedure name: msg_genLowKey
       // Purpose:        Génère une clé de message pour début de bornage historique
       // Returns:        La clé du message générée
       // --------------------------------------------------
       DCL-PR msg_genLowKey char(4) END-PR;

       // --------------------------------------------------
       // Procedure name: msg_genHiKey
       // Purpose:        Génère une clé de message pour fin de bornage historique
       // Returns:        La clé du message générée
       // --------------------------------------------------
       DCL-PR msg_genHiKey char(4) END-PR;

       // --------------------------------------------------
       // Procédure name:  msg_incrHexMsgKey
       // Purpose:         Incrémentation d'une clé de message en hexa (+1)
       // Parameter:       p_msgKey => la clé de message codée en hexa
       //
       // --------------------------------------------------
       DCL-PR msg_incrHexMsgKey extproc('MSG_INCRMK');
         p_msgKey char(4);
       END-PR;

       // --------------------------------------------------
       // Procedure name: msg_getLowKey
       // Purpose:        Récupération de la clé de message de début de bornage
       // Returns:        La clé du message de début
       // --------------------------------------------------
       DCL-PR msg_getLowKey char(4) END-PR;

       // --------------------------------------------------
       // Procedure name: msg_getHiKey
       // Purpose:        Récupération de la clé de message de fin de bornage
       // Returns:        La clé du message de fin
       // --------------------------------------------------
       DCL-PR msg_getHiKey char(4) END-PR;

     ***************************************************************************
     **                                                                       **
     **  Catch : Capture d'un message programme                               **
     **                                                                       **
     ***************************************************************************
       DCL-PR msg_catch LikeDs(Base_CaughtMessage) ExtProc('MSG_CATCH') END-PR;

     ***************************************************************************
     **                                                                       **
     **  Base_CaughtMessage : DS Détails d'un message capturé par Catch       **
     **                                                                       **
     ***************************************************************************
       DCL-DS Base_CaughtMessage BASED(DummyPtr) qualified;
          MsgId char(7);
          MsgFile char(20);
             MsgFileName char(10) overLay(MsgFile);
             MsgLibName  char(10) overLay(MsgFile:*Next);
          MsgText char(132);
          Msgdata char(3000);
          msgkey char(4);
       END-DS;

     ***************************************************************************
     **                                                                       **
     **  msg_throwBack : Réémission d'un message programme                    **
     **                                                                       **
     ***************************************************************************
       DCL-PR msg_throwBack;
          cm LikeDs(Base_CaughtMessage) const options(*nopass);
       END-PR;

       // --------------------------------------------------
       // Procedure name: msg_sendStatus
       // Purpose:        Afficher un message de statut pendant le déroulement
       //                 du traitement
       // Returns:
       // Parameter:      msgId  => l'identifiant du message
       // Parameter:      msgDataIn  => les données du message
       // Parameter:      msgFileIn  => le fichier du message
       // Parameter:      msgLibIn  => la biblio du fichier de messages
       // --------------------------------------------------
        DCL-PR msg_sendStatus;
           MsgId char(7) const;
           MsgDataIn varchar(32767) const options(*Omit:*NoPass);
           MsgFileIn char(10) const options(*NoPass);
           MsgLibIn char(10) const options(*NoPass);
        END-PR;

       // --------------------------------------------------
       // Procedure name: msg_rtvByKey
       // Purpose:        Capture d'un message selon une clé
       // Returns:        Le message récupéré
       // Parameter:      La clé par rapport à laquelle on veut récupérer le message
       // Parameter:      l'entrée à récupérer : *ANY pour le message de la clé,
       //                                        *NEXT pour le suivant,
       //                                        *PRV pour le précédent
       // --------------------------------------------------
       DCL-PR msg_rtvByKey LikeDs(Base_CaughtMessage);
         p_msgKey char(4) const;
         p_msgType char(10) const;
       END-PR;

     ***************************************************************************
     **                                                                       **
     **  env_loadLibl : Chargement d'une liste de bibliothèques de SESAME     **
     **                                                                       **
     ** paramètres d'entrée : le nom de la liste de bibliothèques             **
     **                                                                       **
     **                                                                       **
     ** paramètre de retour : Vrai si la liste a été chargée                  **
     **                                                                       **
     **                                                                       **
     ***************************************************************************
       DCL-PR env_loadLibl ind;
         p_libl char(8);
       END-PR;

     ***************************************************************************
     **                                                                       **
     **  stk_rtvCaller : récupère le programme appelant                       **
     **                                                                       **
     ***************************************************************************
       DCL-PR stk_rtvCaller char(10);
         p_levels uns(5) options(*nopass) CONST; //nombre de niveaux attendus
       END-PR;


     ***************************************************************************
     **                                                                       **
     **  stk_isCaller : le programme désigné est appelant                     **
     **                                                                       **
     ***************************************************************************
       DCL-PR stk_isCaller ind;
         p_programme char(10) const; //Programme appelant recherché dans la pile
       END-PR;

     ***************************************************************************
     **                                                                       **
     **  genUuid        : génére un UUID au format standard                   **
     **                                                                       **
     ***************************************************************************
       dcl-pr genUuid char(36) end-pr;

     ***************************************************************************
     **                                                                       **
     **  cvtUuid32ToStd : convertit un UUID du format hexadécimal au format   **
     **                   standard (ajout de tiret)                           **
     **                                                                       **
     ***************************************************************************
       dcl-pr cvtUuid32ToStd char(36);
         Uuid32 char(32) const;
       end-pr;

     ***************************************************************************
     **                                                                       **
     **  cvtUuidStdTo32 : convertit un UUID du format standard au format      **
     **                   hexadécimal (retrait de tiret)                      **
     **                                                                       **
     ***************************************************************************
       dcl-pr cvtUuidStdTo32 char(32);
         Uuid32 char(36) const;
       end-pr;

     ***************************************************************************
     **                                                                       **
     **  genUuid32      : génére un UUID au format court /32 sans tiret       **
     **                   (pour Mirus et SAP sauf transaction id)             **
     ***************************************************************************
       dcl-pr genUuid32 Char(32) end-pr;

       // --------------------------------------------------
       // Procedure name: msg_inz
       // Purpose:        initialisation de la gestion de messages programme
       // Returns:
       // Parameter:      p_msglib => Bibliothèque du fichier de messages
       // Parameter:      p_msgfic => Nom du fichier de messages
       // Parameter:      p_msgpgm => Programme dont on alimente la file de messages
       //                              (*prv par défaut)
       // --------------------------------------------------
       dcl-pr msg_inz;
         p_msgfic char(10) const;
         p_msglib char(10) const options(*omit:*nopass);
         p_msgpgm char(10) const options(*nopass);
       end-pr;

       // --------------------------------------------------
       // Procedure name: msg_clrq
       // Purpose:        RàB de la file d'attente de messages
       // Returns:
       // Parameter:      p_msgpgm => Programme pour lequel remettre la file ...
       //                          à blanc (*prv par défaut)
       // --------------------------------------------------
       dcl-pr msg_clrq;
         p_msgpgm char(10) const options(*nopass);
       end-pr;

       // --------------------------------------------------
       // Procedure name: msg_dsp
       // Purpose:        Affichage d'un message dans le s-f de la file du programme
       // Returns:
       // Parameter:      p_msgnum => Id message
       // Parameter:      p_msgpgm => Programme dont on alimente la file d'attente
       //                                 de messages (optionnel)
       // Parameter:      p_msgdt1 => Chaine de données 1 du message (optionnel)
       // Parameter:      p_msgdt2 => Chaine de données 2 du message (optionnel)
       // Parameter:      p_msgdt3 => Chaine de données 3 du message (optionnel)
       // Parameter:      p_msgdt4 => Chaine de données 4 du message (optionnel)
       // Parameter:      p_msgdt5 => Chaine de données 5 du message (optionnel)
       //
       // Remarque:       les chaines de données seront concaténées --> char(100)
       // --------------------------------------------------
       dcl-pr msg_dsp;
           p_msgnum char(7) const;
           p_msgdta varchar(100) const options(*nopass);
       end-pr;

       // --------------------------------------------------
       // Procedure name: msg_chrmsg (même usage que la s-r CHRMSG)
       // Purpose:        Affichage d'un message dans le s-f de la file du programme
       // Returns:
       // Parameter:      p_msgnum => Id message
       // Parameter:      p_msgdt1 => Chaine de données 1 du message (optionnel)
       // Parameter:      p_msgdt2 => Chaine de données 2 du message (optionnel)
       // Parameter:      p_msgdt3 => Chaine de données 3 du message (optionnel)
       // Parameter:      p_msgdt4 => Chaine de données 4 du message (optionnel)
       // Parameter:      p_msgdt5 => Chaine de données 5 du message (optionnel)
       //
       // Remarque:       les chaines de données seront concaténées --> char(100)
       // --------------------------------------------------
       dcl-pr msg_chrmsg;
         p_msgnum char(7) const;
         p_msgdt1 char(20) const options(*nopass);
         p_msgdt2 char(20) const options(*nopass);
         p_msgdt3 char(20) const options(*nopass);
         p_msgdt4 char(20) const options(*nopass);
         p_msgdt5 char(20) const options(*nopass);
       end-pr;

       // --------------------------------------------------
       // Procedure name: msg_dspCaught
       // Purpose:        Affichage d'un message attrapé
       // Returns:
       // Parameter:      caughtMessage => le message attrapé
       // --------------------------------------------------
       DCL-PR msg_dspCaught;
         caughtMessage LIKEDS(Base_CaughtMessage) CONST;
       END-PR;

     ***************************************************************************
     **                                                                       **
     **  msg_retrieve : Récupération d'un message                             **
     **                                                                       **
     ***************************************************************************
       dcl-pr msg_retrieve varchar(1024);
         p_msgid   char(7) const;
         p_msgDta  varchar(512) const options(*omit:*nopass);
         p_msgFile char(10) const options(*nopass);
         p_msgLib  char(10) const options(*nopass);
       end-pr;

       // --------------------------------------------------
       // Procedure name: msg_dlg
       // Purpose:        Afficher une boite de dialogue et récupérer la répo...
       //                          nse de l'utilisateur
       // Returns:        Réponse sélectionnée par l'utilisateur
       // Parameter:      p_titre => Titre de la boite de dialogue
       // Parameter:      p_message => Message de la boite de dialogue
       // Parameter:      p_boutons => Boutons autorisés (somme des constantes)
       // Parameter:      p_dft_choix => Réponse par défaut
       // --------------------------------------------------
       DCL-PR msg_dlg uns(5);
         p_titre char(30) const options(*omit);
         p_message varchar(180) const;
         p_boutons uns(5) const;
         p_dft_choix uns(5) const options(*omit:*nopass);
         p_dspatr char(1) const options(*omit:*nopass);
       END-PR;

       // --------------------------------------------------
       // Procedure name: IfNum
       // Purpose: détermine si une chaine de car. peut être convertie
       // Returns: *On si oui, *Off sinon
       // Parameter:   String => Chaîne testée
       // --------------------------------------------------
       DCL-PR IfNum packed(15:9);
         String char(500) CONST;
       END-PR;

       //Suivi exploitation inter-applications
       dcl-ds exsuip_t ext extname('EXSUIP') template qualified end-ds;

       //message récupéré à l'exécution d'une requête SQL
       dcl-s sqlMessage_t varchar(1024) template;

       dcl-s nbr_enr_maj_t uns(10) template;

       //Program Status Data Structure
       //doit être redéclaré dans le module : dcl-ds <nom_ds> psds likeds(pgmds_t);
       DCL-DS pgmds_t template qualified;
          prog CHAR(10) POS(1);
          status CHAR(5) POS(11);
          routine CHAR(8) POS(29);
          msgid CHAR(7) POS(40);
          libpgm CHAR(10) POS(81);
          msgdta CHAR(80) POS(91);
          jobnm CHAR(10) POS(244);
          usrnm CHAR(10) POS(254);
          jobnr CHAR(6) POS(264);
          user CHAR(10) POS(358);
          parms ZONED(3) POS(37);
          jobDate ZONED(6) POS(276);
          unused CHAR(50) POS(380);
       END-DS;

       //Display Specific Feedback Information
       dcl-ds dspds_t template qualified;
         dsp_flag1 char(2) pos(367); // Display flags
         touche    char(1) pos(369); // AID byte
         cursor    char(2) pos(370); // Cursor location
         data_len  int(10) pos(372); // Actual data len
         sf_rrn    int(5)  pos(376); // Subfile rrn
         min_rrn   int(5)  pos(378); // Subfile min rrn
         num_rcds  int(5)  pos(380); // Subfile num rcds
         act_curs   char(2)pos(382); // Active window cursor location
         dsp_major char(2) pos(401); // Major ret code
         dsp_minor char(2) pos(403); // Minor ret code
         screen    zoned(4) pos(67); // Screen size
         rows      int(5) pos(152) ; // Rows for screen
         columns   int(5) pos(154) ; // Columns for screen
       end-ds;

     ***************************************************************************
     **                                                                       **
     **  pgmToSys_t : Program To System Fields (pour DSPATR)                  **
     **                                                                       **
     **  à utiliser de la manière suivante :                                  **
     **                                                                       **
     **           dcl-ds pgmToSys likeds(pgmToSys_t) inz(*likeds);            **
     **                                                                       **
     **           pfld001 = pgmToSys.PR_BLU;                                  **
     **                                                                       **
     **  à déclarer de la manière suivante dans l'écran :                     **
     **                                                                       **
     **           01 A          R SCREEN1                                     **
     **           02 A            FLD001         3A  B  2  2DSPATR(&PFLD001)  **
     **           03 A            PFLD001        1A  P                        **
     **                                                                       **
     ***************************************************************************
       dcl-ds pgmToSys_t template qualified;
         // Fields will be unprotected
         GRN             char(1) inz(x'20');
         GRN_RI          char(1) inz(x'21');
         WHT             char(1) inz(x'22');
         WHT_RI          char(1) inz(x'23');
         GRN_UL          char(1) inz(x'24');
         GRN_UL_RI       char(1) inz(x'25');
         WHT_UL          char(1) inz(x'26');
         ND              char(1) inz(x'27');
         RED             char(1) inz(x'28');
         RED_RI          char(1) inz(x'29');
         RED_HI          char(1) inz(x'2A');
         RED_HI_RI       char(1) inz(x'2B');
         RED_UL          char(1) inz(x'2C');
         RED_UL_RI       char(1) inz(x'2D');
         RED_UL_BL       char(1) inz(x'2E');
         TRQ_CS          char(1) inz(x'30');
         TRQ_CS_RI       char(1) inz(x'31');
         YLW_CS          char(1) inz(x'32');
         WHT_RI_CS       char(1) inz(x'33');
         TRQ_UL_CS       char(1) inz(x'34');
         TRQ_UL_RI_CS    char(1) inz(x'35');
         YLW_UL_CS       char(1) inz(x'36');
         PNK             char(1) inz(x'38');
         PNK_RI          char(1) inz(x'39');
         BLU             char(1) inz(x'3A');
         BLU_RI          char(1) inz(x'3B');
         PNK_UL          char(1) inz(x'3C');
         PNK_UL_RI       char(1) inz(x'3D');
         BLU_UL          char(1) inz(x'3E');
         // Fields will be protected
         PR_GRN           char(1) inz(x'A0');
         PR_GRN_RI        char(1) inz(x'A1');
         PR_WHT           char(1) inz(x'A2');
         PR_WHT_RI        char(1) inz(x'A3');
         PR_GRN_UL        char(1) inz(x'A4');
         PR_GRN_UL_RI     char(1) inz(x'A5');
         PR_WHT_UL        char(1) inz(x'A6');
         PR_ND            char(1) inz(x'A7');
         PR_RED           char(1) inz(x'A8');
         PR_RED_RI        char(1) inz(x'A9');
         PR_RED_HI        char(1) inz(x'AA');
         PR_RED_HI_RI     char(1) inz(x'AB');
         PR_RED_UL        char(1) inz(x'AC');
         PR_RED_UL_RI     char(1) inz(x'AD');
         PR_RED_UL_BL     char(1) inz(x'AE');
         PR_TRQ_CS        char(1) inz(x'B0');
         PR_TRQ_CS_RI     char(1) inz(x'B1');
         PR_YLW_CS        char(1) inz(x'B2');
         PR_WHT_RI_CS     char(1) inz(x'B3');
         PR_TRQ_UL_CS     char(1) inz(x'B4');
         PR_TRQ_UL_RI_CS  char(1) inz(x'B5');
         PR_YLW_UL_CS     char(1) inz(x'B6');
         PR_PNK           char(1) inz(x'B8');
         PR_PNK_RI        char(1) inz(x'B9');
         PR_BLU           char(1) inz(x'BA');
         PR_BLU_RI        char(1) inz(x'BB');
         PR_PNK_UL        char(1) inz(x'BC');
         PR_PNK_UL_RI     char(1) inz(x'BD');
         PR_BLU_UL        char(1) inz(x'BE');
       end-ds;

       // --------------------------------------------------
       // Procedure name: sui_inz
       // Purpose:        Initialiser le module avec les valeurs non modifiées
       // Returns:
       // Parameter:      p_appli => Initiales de l'application en cours
       // Parameter:      p_pgmstatusP => Pointeur sur la PSDS du programme a...
       //                          ppelant
       // --------------------------------------------------
       DCL-PR sui_inz;
         p_appli LIKE(exsuip_t.appmsg) CONST;
         p_pgmstatusP POINTER CONST;
       END-PR;


       // --------------------------------------------------
       // Procedure name: sui_addInformation
       // Purpose:        Ajouter un message d'information dans le suivi d'exploitation
       // Returns:        Vrai si le message a bien été ajouté, Faux sinon
       // Parameter:      p_appli => Application
       // Parameter:      p_pgmstatus => Program Status Data Structure (PSDS)
       // Parameter:      p_msgid => Identifiant du message
       // Parameter:      p_comsui => Commentaire circonstancié
       // Parameter:      p_dtasui => Données de suivi utiles à l'analyse du ...
       //                          problème
       // Parameter:      p_libmsg => Libellé message
       // --------------------------------------------------
       DCL-PR sui_addInformation IND;
         p_msgid LIKE(exsuip_t.codmsg) CONST;
         p_comsui LIKE(exsuip_t.comsui) CONST;
         p_dtasui LIKE(exsuip_t.dtasui) CONST OPTIONS(*NOPASS:*OMIT);
         p_libmsg LIKE(exsuip_t.libmsg) CONST OPTIONS(*NOPASS:*OMIT);
       END-PR;

       // --------------------------------------------------
       // Procedure name: sui_addAvertissement
       // Purpose:        Ajouter un message d'avertissement dans le suivi d'exploitation
       // Returns:        Vrai si le message a bien été ajouté, Faux sinon
       // Parameter:      p_appli => Application
       // Parameter:      p_pgmstatus => Program Status Data Structure (PSDS)
       // Parameter:      p_msgid => Identifiant du message
       // Parameter:      p_comsui => Commentaire circonstancié
       // Parameter:      p_dtasui => Données de suivi utiles à l'analyse du ...
       //                          problème
       // Parameter:      p_libmsg => Libellé message
       // --------------------------------------------------
       DCL-PR sui_addAvertissement IND;
         p_msgid LIKE(exsuip_t.codmsg) CONST;
         p_comsui LIKE(exsuip_t.comsui) CONST;
         p_dtasui LIKE(exsuip_t.dtasui) CONST OPTIONS(*NOPASS:*OMIT);
         p_libmsg LIKE(exsuip_t.libmsg) CONST OPTIONS(*NOPASS:*OMIT);
       END-PR;

       // --------------------------------------------------
       // Procedure name: sui_addAnomalie
       // Purpose:        Ajouter un message d'anomalie dans le suivi d'exploitation
       // Returns:        Vrai si le message a bien été ajouté, Faux sinon
       // Parameter:      p_appli => Application
       // Parameter:      p_pgmstatus => Program Status Data Structure (PSDS)
       // Parameter:      p_msgid => Identifiant du message
       // Parameter:      p_comsui => Commentaire circonstancié
       // Parameter:      p_dtasui => Données de suivi utiles à l'analyse du ...
       //                          problème
       // Parameter:      p_libmsg => le libellé du message (optionnel)
       // Parameter:      p_sqlcode => le code sql du message (optionnel)
       // Parameter:      p_msgLowKey => plus petite clé des messages à récupérer (optionnel)
       // Parameter:      p_msgLowKey => plus grande clé des messages à récupérer (optionnel)
       // --------------------------------------------------
       DCL-PR sui_addAnomalie IND;
         p_msgid LIKE(exsuip_t.codmsg) CONST;
         p_comsui LIKE(exsuip_t.comsui) CONST;
         p_dtasui LIKE(exsuip_t.dtasui) CONST OPTIONS(*NOPASS:*OMIT);
         p_libmsg LIKE(exsuip_t.libmsg) CONST OPTIONS(*NOPASS:*OMIT);
         p_sqlcode int(10) CONST OPTIONS(*NOPASS:*OMIT);
         p_msgLowKey char(4) CONST OPTIONS(*NOPASS:*OMIT);
         p_msgHiKey char(4) CONST OPTIONS(*NOPASS:*OMIT);
       END-PR;

       // --------------------------------------------------
       // Procedure name: sui_getSqlRowCount
       // Purpose:        Récupérer le nombre de lignes traitées
       //                  par la dernière instruction sql
       // Returns:        Le nombre trouvé
       // --------------------------------------------------
       DCL-PR sui_getSqlRowCount like(nbr_enr_maj_t) END-PR;

       // --------------------------------------------------
       // Procedure name: sui_countAnomalies
       // Purpose:        Compter le nombre d'anomalies pour un traitement
       //                          identifié
       // Returns:        Le nombre d'anomalies trouvées pour le traitement
       // Parameter:      p_application => la famille d'application
       // Parameter:      p_pgm => le programme du traitement
       // Parameter:      p_jobname => le nom du travail
       // Parameter:      p_jobuser => l'utilisateur du travail
       // Parameter:      p_jobnbr => le numéro du travail
       // Parameter:      p_tsDebut => l'horodatage de début du traitement
       // Parameter:      p_tsFin => l'horodatage de fin du traitement
       // --------------------------------------------------
       DCL-PR sui_countAnomalies int(10);
         p_application char(10) const options(*nopass:*omit);
         p_pgm         char(10) const options(*nopass:*omit);
         p_jobname     char(10) const options(*nopass:*omit);
         p_jobuser     char(10) const options(*nopass:*omit);
         p_jobnbr      char(6) const options(*nopass:*omit);
         p_tsDebut     timestamp const options(*nopass:*omit);
         p_tsFin       timestamp const options(*nopass:*omit);
       END-PR;


       // --------------------------------------------------
       // Procedure name: sui_getCursorAnomalies
       // Purpose:        Ouvre un curseur sur les anomalies sélectionnées
       // Returns:        Le curseur
       // Parameter:      p_application => la famille d'application
       // Parameter:      p_pgm => le programme du traitement
       // Parameter:      p_jobname => le nom du travail
       // Parameter:      p_jobuser => l'utilisateur du travail
       // Parameter:      p_jobnbr => le numéro du travail
       // Parameter:      p_tsDebut => l'horodatage de début du traitement
       // Parameter:      p_tsFin => l'horodatage de fin du traitement
       // --------------------------------------------------
       DCL-PR sui_getCursor_anomalies;
         p_application char(10) const;
         p_pgm         char(10) const;
         p_jobname     char(10) const;
         p_jobuser     char(10) const;
         p_jobnbr      char(6) const;
         p_tsDebut     timestamp const;
         p_tsFin       timestamp const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_init : Initialisation de la requête                              *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_init END-PR;
      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_from : Ajout de la clause from                                   *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_from;
         fichier varchar(200) const;
         as      varchar(30) const options(*nopass:*omit);
       END-PR;
      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_addFrom : Ajout d'un fichier à la requête                        *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_addFrom;
         fichier varchar(200) const;
         as      varchar(30) const options(*nopass:*omit);
         join    varchar(16) const options(*nopass:*omit);
         on      varchar(500) const options(*nopass);
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_select : Construction de la clause select                        *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_select;
         colonne varchar(500) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_sql_addSelect : Ajout d'une colonne ou d'un groupe de colonnes   *
      *               à sélectionner                                          *
      *-----------------------------------------------------------------------*
       DCL-PR sql_addSelect;
         colonne varchar(500) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_eq : Construction d'un critère d'égalité sur une zone numérique  *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_eq_num varchar(233);
         colonne varchar(30) const;
         valeur varchar(200) const;
       END-PR;
      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_eq : Construction d'un critère d'égalité sur une zone alphanum   *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_eq varchar(233);
         colonne varchar(30) const;
         valeur varchar(200) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_ne_num: Construction d'un critère d'inégalité numérique          *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_ne_num varchar(233);
         colonne varchar(30) const;
         valeur varchar(200) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_between :                                                        *
      *           Construction d'un critère d'inclusion dans une fourchette   *
      *           de représentation alphanumérique                            *
      *                                                                       *
      *-----------------------------------------------------------------------*
        DCL-PR sql_between varchar(233);
           colonne varchar(30) const;
           valeurMin varchar(200) const;
           valeurMax varchar(200) const;
        END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_between_num :                                                    *
      *           Construction d'un critère d'inclusion dans une fourchette   *
      *           de représentation numérique                                 *
      *                                                                       *
      *-----------------------------------------------------------------------*
        DCL-PR sql_between_num varchar(233);
           colonne varchar(30) const;
           valeurMin varchar(200) const;
           valeurMax varchar(200) const;
        END-PR;


      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_ne : Construction d'un critère d'inégalité (colonne alphanum)    *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_ne varchar(233);
         colonne varchar(30) const;
         valeur varchar(200) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_comp_num : Construction d'un discriminant numérique              *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_comp_num varchar(233);
         colonne varchar(30) const;
         comparateur varchar(30) const;
         valeur varchar(200) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_comp : Construction d'un discriminant                            *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_comp varchar(233);
         colonne varchar(30) const;
         comparateur varchar(30) const;
         valeur varchar(200) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_initList : Initilisation liste de valeurs                        *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_initList END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_addList : Ajout d'une valeur ou d'un groupe de valeurs à une     *
      *                liste                                                  *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_addList varchar(2000);
         valeur varchar(200) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_rtvList : Récupération de la liste en cours                      *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_rtvList varchar(2000) END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_in : Construction d'un critère d'appartenance à une liste        *
      *           ou à la liste en cours                                      *
      *-----------------------------------------------------------------------*
       DCL-PR sql_in varchar(2000);
         colonne varchar(30)const;
         liste varchar(500) const options(*nopass);
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_and : Concaténation de 2 restrictions par 'and'                  *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_and varchar(2000);
         crit1 varchar(2000) const;
         crit2 varchar(2000) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_or : Concaténation de 2 restrictions par 'or'                    *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_or varchar(2000);
         crit1 varchar(2000) const;
         crit2 varchar(2000) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_where : Ajout de la clause WHERE                                 *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_where;
         where varchar(2000) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_addWhere : Ajout à la clause WHERE ou ajout à la clause WHERE    *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_addWhere;
         where varchar(2000) const;
         conj char(2) const options(*nopass);
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_orderBy : Ajout de la clause order by                            *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_orderBy;
         colonnes varchar(500) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_addOrderby : Ajout d'une colonne ou d'un groupe de colonnes au tri
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_addOrderby;
         colonne varchar(500) const;
       END-PR;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_bld : Construction de la requête                                 *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PR sql_bld varchar(6000) END-PR;


       // --------------------------------------------------
       // Program name:    rtvJobType
       // Purpose:         Récupération du type de travail
       // Parameter:       p_type => Type de travail : 'I'=Interactif, 'B'=Batch
       //
       // --------------------------------------------------
       DCL-PR rtvJobType extpgm('RTVJOBTYPC');
         p_type char(1);
       END-PR;

       // --------------------------------------------------
       // Procedure name: dsp_rtvPosition
       // Purpose:        renvoyer la position d'une zone
       //                 (col, lig) pour positionnement
       // Returns:
       // Parameter:      p_fichier => Nom qualifié du fichier
       // Parameter:      p_format => Nom du format de fichier
       // Parameter:      p_zone => Nom de la zone
       // Parameter:      p_colonne => la colonne (entrée-sortie)
       // Parameter:      p_ligne => la ligne (entrée-sortie)
       // --------------------------------------------------
       DCL-PR dsp_rtvPosition;
         p_fichier char(10) const;
         p_format char(10) const;
         p_zone char(10) const;
         p_colonne zoned(3);
         p_ligne zoned(3);
       END-PR;

     ***************************************************************************
     **                                                                       **
     **  dsp_rtvMode : Retrieve Display Mode                                  **
     **                                                                       **
     ***************************************************************************
       DCL-PR dsp_rtvMode Extproc('QsnRtvMod');
          DspMode      char(1);                //mode d'affichage en cours
          Handle       int(10) options(*omit); //low-level environment that the operation applies to
          ErrorForAPI  options(*omit) like(ErrApi); //error information
       END-PR;

       // --------------------------------------------------
       // Procedure name: dsp_remove
       // Purpose:        Libérer les ressources allouées
       //
       // Returns:        Vrai
       // --------------------------------------------------
       dcl-pr dsp_remove ind end-pr;

       // --------------------------------------------------
       // Procedure name: chn_trimrParam
       // Purpose:        renvoyer une chaine trimée à droite sans les
       //                          caractères < ' ' (chaine reçue d'un pgm cl)
       // Returns:        la nouvelle chaine
       // Parameter:      p_chaine => La chaine à traiter
       // --------------------------------------------------
       DCL-PR chn_trimrParam like(r_var131072);
         p_chaine like(r_var131072) const;
       END-PR;

       // --------------------------------------------------
       // Procedure name: chn_toUpperCase
       // Purpose:        Transformer une chaine en capitales d'imprimerie
       // Returns:        La chaine en majuscules
       // Parameter:      p_chaine => la chaine à transformer
       // Parameter:      p_garder_accents => garder les accents (optionnel, non par défaut)
       // --------------------------------------------------
       DCL-PR chn_toUpperCase like(r_var131072);
         p_chaine  like(r_var131072) const;
         p_garder_accents ind const options(*omit:*nopass);
       END-PR;

       // --------------------------------------------------
       // Procedure name: chn_toLowerCase
       // Purpose:        Transformer une chaine en bas de casse
       // Returns:        La chaine en minuscules
       // Parameter:      p_chaine => la chaine à transformer
       // Parameter:      p_garder_accents => garder les accents (optionnel, non par défaut)
       // --------------------------------------------------
       DCL-PR chn_toLowerCase  like(r_var131072);
          p_chaine  like(r_var131072) const;
          p_garder_accents ind const options(*omit:*nopass);
       END-PR;

       // --------------------------------------------------
       // Procedure name: chn_centrer
       // Purpose:        Centre une chaine de caractère dans une variable
       //                          selon sa longueur
       // Returns:        la chaine de retour
       // Parameter:      p_chaine => La chaine de caractères à centrer
       // Parameter:      p_long => Longueur de la chaine réceptrice
       // --------------------------------------------------
       DCL-PR chn_centrer varchar(131);
         p_chaine varchar(131) const;
         p_long uns(3) const;
       END-PR;

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
       DCL-PR aleatoire ;
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
         MACHINE like(r_nomobj);
         USER like(r_profil);
         MDP like(r_profil);
         Nom_savf like(r_nomobj);
         nom_fic_source like(r_nomobj);
       End-Pr;

       // --------------------------------------------------
       // Prototype for procedure: ScanRpl
       // --------------------------------------------------
       DCL-PR ScanRpl VARCHAR(1024);
         p_scan_string VARCHAR(1024) CONST;
         p_replacement VARCHAR(1024) CONST;
         p_source VARCHAR(1024) CONST;
         p_scan_start PACKED(8:0) OPTIONS(*OMIT);
         p_scan_length PACKED(8:0) OPTIONS(*OMIT);
       END-PR ;

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
       END-PR ;

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
         P_User LIKE(R_NomObj) Const;
         P_Mot_De_Passe CHAR(10) Const;
       End-Pr;

       // --------------------------------------------------
       // Prototype for procedure: source_standard
       // --------------------------------------------------
       DCL-PR source_standard IND;
         P_Type_Source LIKE(R_NomObj) CONST;
         P_Type_Objet LIKE(R_TypObj) CONST;
         P_Biblio_Src_PRE LIKE(R_NomObj);
         P_Fichier_Src_PRE LIKE(R_NomObj);
         P_Membre_Src_PRE LIKE(R_NomObj);
       END-PR ;

       // --------------------------------------------------
       // Prototype for procedure: Envoi d'un mail avec des pièces attachées au
       //                          user du job
       // --------------------------------------------------
       DCL-PR EnvRapMel;
         P_FileAttach char(10000);
       END-PR ;

       // --------------------------------------------------
       // Prototype for Programme:Envoi vers système distant
       // --------------------------------------------------
       Dcl-Pr i_MrgMsgf ExtPgm('I_MRGMSGF');
         P_Objet char(20) Const;
         P_BibSrc like(R_NomObj) Const;
         P_MbrSrc like(R_NomObj) Const;
         P_Sys_Dst CHAR(32) Const;
         P_User LIKE(R_NomObj) Const;
         P_Mot_De_Passe CHAR(10) Const;
       End-Pr;

       // --------------------------------------------------
       // Prototype for procedure: builder
       // --------------------------------------------------
       DCL-PR builder EXTPGM('BUILDER');
         P_Projet LIKE(R_NomObj) const;
         P_Biblio_Lot LIKE(R_NomObj) const;
         P_Env_Dest CHAR(1) const;
         P_Optim_Compil CHAR(20);
         P_Livr_Env_Dst IND const;
         P_Sys_Dst CHAR(32) const;
         P_User LIKE(R_NomObj) const;
         P_Mot_De_Passe CHAR(10) const;
       END-PR ;

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
