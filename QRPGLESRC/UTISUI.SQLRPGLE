      **************************************************************************
      * MODULE    : UTISUI                  Date Création : 19/06/2017         *
      * AUTEUR    : D.LANDRAGIN                 Copyright : Ista France        *
      *------------------------------------------------------------------------*
      *  APPLICATION :                                                         *
      *  Services                                                              *
      *------------------------------------------------------------------------*
      *  DESCRIPTION :                                                         *
      *  Procédures pour la consignation des événements d'exploitation         *
      *                                                                        *
      *------------------------------------------------------------------------*
      * MAINTENANCE :                                                          *
      *  N°    AUTEUR                       OBJET                       DATE   *
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      **************************************************************************
      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  OBJ(&LI/&OB);                                   */
      *     >>PARM<<  OBJTYPE(*MODULE);                               */
      *     >>PARM<<  OPTION(*EVENTF);                                */
      *     >>PARM<<  RPGPPOPT(*LVL2);                                */
      *     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
      *     >>PARM<<  DATFMT(*ISO);                                   */
      *     >>PARM<<  TIMFMT(*ISO);                                   */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */
      ******************************************************************

       ctl-opt nomain;
       ctl-opt option(*srcstmt:*nodebugio:*nounref);

      /copy qcpysrc,outpr   // prototypes et modèles
      /copy qcpysrc,utiproc   // prototypes et modèles

       dcl-ds pgmstatus LIKEDS(pgmds_t) based(ptr_pgmstatus); //la psds du pgm appelant
       dcl-s  ptr_pgmstatus pointer;                          //son pointeur
       dcl-s  w_appli LIKE(exsuip_t.appmsg);                  //la famille d'application
       dcl-s  w_pgmpre LIKE(exsuip_t.pgmpre);                 //le programme précédent

       // --------------------------------------------------
       // Procedure name: sui_inz
       // Purpose:        Initialiser le module avec les valeurs non modifiées
       // Returns:
       // Parameter:      p_appli => Initiales de l'application en cours
       // Parameter:      p_pgmstatusP => Pointeur sur la PSDS du programme a...
       //                          ppelant
       // --------------------------------------------------
       DCL-PROC sui_inz EXPORT;

         DCL-PI *N;
           p_appli like(exsuip_t.appmsg) CONST;
           p_pgmstatusP pointer CONST;
         END-PI;



         w_appli = p_appli;
         w_pgmpre = stk_rtvCaller();
         ptr_pgmstatus = p_pgmstatusP;

       //  if %addr(ptr_pgms) = *null;
       //     ptr_pgms = %alloc(%size(pgms) * w_postes);
       //     pgmstatus.prog
       //  endif;



         return;
       END-PROC;


       // --------------------------------------------------
       // Procedure name: addSuivi
       // Purpose:        Ajouter un message dans suivi d'exploitation
       // Returns:        Vrai si le message a bien été ajouté, Faux sinon
       // Parameter:      p_nivmsg => Niveau du message : 'INF' = Info, 'AVR'...
       //                           = Avertissement, 'ANO' = Anomalie
       // Parameter:      p_appli => Application
       // Parameter:      p_pgmstatus => Program Status Data Structure (PSDS)
       // Parameter:      p_msgid => Identifiant du message
       // Parameter:      p_comsui => Commentaire circonstancié
       // Parameter:      p_dtasui => Données de suivi utiles à l'analyse du ...
       //                          problème
       // Parameter:      p_libmsg => Libellé message
       // --------------------------------------------------
       DCL-PROC addSuivi;

         DCL-PI *N IND;
           p_nivmsg LIKE(exsuip_t.nivmsg) CONST;
           p_msgid LIKE(exsuip_t.codmsg) CONST;
           p_comsui LIKE(exsuip_t.comsui) CONST;
           p_dtasui LIKE(exsuip_t.dtasui) CONST;
           p_libmsg LIKE(exsuip_t.libmsg) CONST;
         END-PI ;

         dcl-s retField IND;
         dcl-ds sui likeds(exsuip_t) inz;

         if p_libmsg = SQL_DIAG;
           sui.libmsg = getSqlDiagnostic();
         else;
           sui.libmsg = p_libmsg;
         endif;

         if p_comsui = SQL_DIAG;
           sui.comsui = getSqlDiagnostic();
         else;
           sui.comsui = p_comsui;
         endif;

         sui.nivmsg = p_nivmsg;
         sui.appmsg = w_appli;
         sui.pgmact = pgmstatus.prog;
         sui.pgmpre = w_pgmpre;
         sui.codmsg = p_msgid;
         sui.dtasui = p_dtasui;
         //  sui.libmsg = p_libmsg;
         sui.jobnam = pgmstatus.jobnm;
         sui.jobusr = pgmstatus.usrnm;
         sui.jobnbr = pgmstatus.jobnr;

         //?Consignation
         exec sql
           INSERT INTO EXSUIP(NIVMSG,
                              APPMSG,
                              PGMACT,
                              CODMSG,
                              PGMPRE,
                              COMSUI,
                              DTASUI,
                              LIBMSG,
                              JOBNAM,
                              JOBUSR,
                              JOBNBR)
             VALUES (:SUI.NIVMSG,
                     :SUI.APPMSG,
                     :SUI.PGMACT,
                     :SUI.CODMSG,
                     :SUI.PGMPRE,
                     :SUI.COMSUI,
                     :SUI.DTASUI,
                     :SUI.LIBMSG,
                     :SUI.JOBNAM,
                     :SUI.JOBUSR,
                     :SUI.JOBNBR);

         if  sqlcod = 0;
           retField = *on;
         endif;

         return retField;
       END-PROC;

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
       DCL-PROC sui_addInformation EXPORT;

         DCL-PI *N IND;
           p_msgid LIKE(exsuip_t.codmsg) CONST;
           p_comsui LIKE(exsuip_t.comsui) CONST;
           p_dtasui LIKE(exsuip_t.dtasui) CONST OPTIONS(*NOPASS:*OMIT);
           p_libmsg LIKE(exsuip_t.libmsg) CONST OPTIONS(*NOPASS:*OMIT);
         END-PI;

         dcl-s w_dtasui LIKE(exsuip_t.dtasui);
         dcl-s w_libmsg LIKE(exsuip_t.libmsg);

         if %parms >= %parmnum(p_dtasui) and %addr(p_dtasui) <> *null;
           w_dtasui = p_dtasui;
         endif;
         if %parms >= %parmnum(p_libmsg) and %addr(p_libmsg) <> *null;
           w_libmsg = p_libmsg;
         endif;

         return addSuivi('INF':p_msgid:p_comsui:w_dtasui:w_libmsg);

       END-PROC;

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
       DCL-PROC sui_addAvertissement EXPORT;

         DCL-PI *N IND;
           p_msgid LIKE(exsuip_t.codmsg) CONST;
           p_comsui LIKE(exsuip_t.comsui) CONST;
           p_dtasui LIKE(exsuip_t.dtasui) CONST OPTIONS(*NOPASS:*OMIT);
           p_libmsg LIKE(exsuip_t.libmsg) CONST OPTIONS(*NOPASS:*OMIT);
         END-PI;

         dcl-s w_dtasui LIKE(exsuip_t.dtasui);
         dcl-s w_libmsg LIKE(exsuip_t.libmsg);

         if %parms >= %parmnum(p_dtasui) and %addr(p_dtasui) <> *null;
           w_dtasui = p_dtasui;
         endif;
         if %parms >= %parmnum(p_libmsg) and %addr(p_libmsg) <> *null;
           w_libmsg = p_libmsg;
         endif;

         return addSuivi('AVR':p_msgid:p_comsui:w_dtasui:w_libmsg);

       END-PROC;

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
       DCL-PROC sui_addAnomalie EXPORT;

         DCL-PI *N IND;
           p_msgid LIKE(exsuip_t.codmsg) CONST;
           p_comsui LIKE(exsuip_t.comsui) CONST;
           p_dtasui LIKE(exsuip_t.dtasui) CONST OPTIONS(*NOPASS:*OMIT);
           p_libmsg LIKE(exsuip_t.libmsg) CONST OPTIONS(*NOPASS:*OMIT);
           p_sqlcode like(sqlcode) CONST OPTIONS(*NOPASS:*OMIT);
           p_msgLowKey char(4) CONST OPTIONS(*NOPASS:*OMIT);
           p_msgHiKey char(4) CONST OPTIONS(*NOPASS:*OMIT);
         END-PI;

         dcl-s retField ind;

         dcl-s w_dtasui LIKE(exsuip_t.dtasui);
         dcl-s w_libmsg LIKE(exsuip_t.libmsg);
         dcl-s w_sqlcode LIKE(sqlcode);
         dcl-s w_msgKey char(4);
         dcl-s w_msgLowKey like(w_msgKey) inz(x'00000000');
         dcl-s w_msgHiKey like(w_msgKey);
         dcl-s w_travail char(28);


         dcl-ds caughtMessage likeds(Base_CaughtMessage) inz;

         if %parms >= %parmnum(p_dtasui) and %addr(p_dtasui) <> *null;
           w_dtasui = p_dtasui;
         endif;

         if %parms >= %parmnum(p_libmsg) and %addr(p_libmsg) <> *null;
           w_libmsg = p_libmsg;
         endif;

         if %parms >= %parmnum(p_sqlcode) and %addr(p_sqlcode) <> *null;
           w_sqlcode = p_sqlcode;
         endif;

         if %parms >= %parmnum(p_msgLowKey) and %addr(p_msgLowKey) <> *null;
           w_msgLowKey = p_msgLowKey;
         else;
           w_msgLowKey = msg_getLowKey();
         endif;

         if %parms >= %parmnum(p_msgHiKey) and %addr(p_msgHiKey) <> *null;
           w_msgHiKey = p_msgHiKey;
         else;
           w_msgHiKey = msg_getHiKey();
         endif;

         retField = addSuivi('ANO':p_msgid:p_comsui:w_dtasui:w_libmsg);

         //sqlcode = -913 <==> erreur allocation enr. ou fichier : on liste les enr. concernés.
         if w_sqlcode = -913;
           w_msgKey = w_msgLowKey;
           msg_incrHexMsgKey(w_msgKey); //incrémentation de la clé de messages
           caughtMessage = msg_rtvByKey(w_msgKey:'*ANY');
           dow w_msgKey < w_msgHiKey;
             if (caughtMessage.MsgId = 'CPF5027'  //enr. verrouillé
                  or caughtMessage.MsgId = 'CPF4270'  //table verrouillée
                  or caughtMessage.MsgId = 'SQL0913');
               addSuivi('ANO'
                         : caughtMessage.MsgId
                         : caughtMessage.MsgText
                         : caughtMessage.Msgdata
                         : *blanks
                       );
             endif;
             msg_incrHexMsgKey(w_msgKey); //incrémentation de la clé de messages
             caughtMessage = msg_rtvByKey(w_msgKey:'*ANY');
           enddo;
         endif;

         return retField;



       END-PROC;

       // --------------------------------------------------
       // Procedure name: getSqlDiagnostic
       // Purpose:        Récupérer le libellé de l'erreur sql ayant eu lieu
       // Returns:        Le libellé de l'erreur sql
       // --------------------------------------------------
       DCL-PROC getSqlDiagnostic;

         dcl-pi *n varchar(1024) end-pi;

         dcl-s retField varchar(1024);

         exec sql
           GET DIAGNOSTICS CONDITION 1 :retField = MESSAGE_TEXT;

         return %trim(retField);
       END-PROC;

       // --------------------------------------------------
       // Procedure name: sui_getSqlRowCount
       // Purpose:        Récupérer le nombre de lignes traitées
       //                  par la dernière instruction sql
       // Returns:        Le nombre trouvé
       // --------------------------------------------------
       DCL-PROC sui_getSqlRowCount EXPORT;

         dcl-pi *n like(nbr_enr_maj_t) end-pi;

         dcl-s retField like(nbr_enr_maj_t);

         exec sql
           GET DIAGNOSTICS :retField = ROW_COUNT;

         return retField;
       END-PROC;

       // --------------------------------------------------
       // Procedure name: sui_countAnomalies
       // Purpose:        Compter le nombre d'anomalies pour un traitement
       //                          identifié (tous les paramètres sont optionnels)
       // Returns:        Le nombre d'anomalies trouvées pour le traitement
       // Parameter:      p_application => la famille d'application
       // Parameter:      p_pgm => le programme du traitement
       // Parameter:      p_jobname => le nom du travail
       // Parameter:      p_jobuser => l'utilisateur du travail
       // Parameter:      p_jobnbr => le numéro du travail
       // Parameter:      p_tsDebut => l'horodatage de début du traitement
       // Parameter:      p_tsFin => l'horodatage de fin du traitement
       // --------------------------------------------------
       DCL-PROC sui_countAnomalies EXPORT;

         dcl-pi *n int(10);
           p_application char(10) const options(*nopass:*omit);
           p_pgm         char(10) const options(*nopass:*omit);
           p_jobname     char(10) const options(*nopass:*omit);
           p_jobuser     char(10) const options(*nopass:*omit);
           p_jobnbr      char(6) const options(*nopass:*omit);
           p_tsDebut     timestamp const options(*nopass:*omit);
           p_tsFin       timestamp const options(*nopass:*omit);
         end-pi;

         dcl-s w_application char(10);
         dcl-s w_pgm         char(10);
         dcl-s w_jobname     char(10);
         dcl-s w_jobuser     char(10);
         dcl-s w_jobnbr      char(6);
         dcl-s w_tsDebut     timestamp inz(*loval);
         dcl-s w_tsFin       timestamp inz(*hival);

         dcl-s requete varchar(500);

         dcl-s nbre int(10);

         //prise en compte des paramètres optionnels
         if %parms >= %parmnum(p_application) and %addr(p_application) <> *null;

           w_application = p_application;
         endif;

         if %parms >= %parmnum(p_pgm) and %addr(p_pgm) <> *null;
           w_pgm = p_pgm;
         endif;

         if %parms >= %parmnum(p_jobname) and %addr(p_jobname) <> *null;
           w_jobname = p_jobname;
         endif;

         if %parms >= %parmnum(p_jobuser) and %addr(p_jobuser) <> *null;
           w_jobuser = p_jobuser;
         endif;

         if %parms >= %parmnum(p_jobnbr) and %addr(p_jobnbr) <> *null;
           w_jobnbr = p_jobnbr;
         endif;

         if %parms >= %parmnum(p_tsDebut) and %addr(p_tsDebut) <> *null;
           w_tsDebut = p_tsDebut;
         endif;

         if %parms >= %parmnum(p_tsFin) and %addr(p_tsFin) <> *null;
           w_tsFin = p_tsFin;
         endif;



         sql_init();

         sql_addSelect('COUNT(*)');

         sql_from('EXSUIP': 'SUI');

         sql_addWhere(sql_eq('SUI.NIVMSG':'ANO')); //on ne prend que les anomalies

         if w_application <> *blanks;
           sql_addWhere(sql_eq('SUI.APPMSG':w_application));
         endif;

         if w_pgm <> *blanks;
           sql_addWhere(sql_eq('SUI.PGMPRE':w_pgm));
         endif;

         if w_jobname <> *blanks;
           sql_addWhere(sql_eq('SUI.JOBNAM':w_jobname));
         endif;

         if w_jobuser <> *blanks;
           sql_addWhere(sql_eq('SUI.JOBUSR':w_jobuser));
         endif;

         if w_jobnbr <> *blanks and w_jobnbr <> *all'0';
           sql_addWhere(sql_eq('SUI.JOBNBR':w_jobnbr));
         endif;

         if w_tsDebut <> *loval or w_tsFin <> *hival;
           sql_addWhere(sql_between('SUI.TS_CRE'
                                     :%char(w_tsDebut)
                                     :%char(w_tsFin)));
         endif;

         requete = sql_bld();

         exec sql
           prepare stm1 from :requete;

         exec sql
           declare c1 cursor for stm1;

         exec sql
           open c1;

         exec sql
           fetch next from c1 into :nbre;

         exec sql
           close c1;

         return nbre;
       END-PROC;

       // --------------------------------------------------
       // Procedure name: sui_getCursorAnomalies
       // Purpose:        Ouvre un curseur sur les anomalies sélectionnées (procédure stockée)
       // Returns:        Le curseur
       // Parameter:      p_application => la famille d'application
       // Parameter:      p_pgm => le programme du traitement
       // Parameter:      p_jobname => le nom du travail
       // Parameter:      p_jobuser => l'utilisateur du travail
       // Parameter:      p_jobnbr => le numéro du travail
       // Parameter:      p_tsDebut => l'horodatage de début du traitement
       // Parameter:      p_tsFin => l'horodatage de fin du traitement
       // --------------------------------------------------
       DCL-PROC sui_getCursor_anomalies EXPORT;

         dcl-pi *n;
           p_application char(10) const;
           p_pgm         char(10) const;
           p_jobname     char(10) const;
           p_jobuser     char(10) const;
           p_jobnbr      char(6) const;
           p_tsDebut     timestamp const;
           p_tsFin       timestamp const;
         end-pi;

         dcl-s requete varchar(500);

         sql_init();

         sql_select('SUI.NIDSUI');
         sql_addSelect('SUI.NIVMSG');
         sql_addSelect('SUI.PGMACT');
         sql_addSelect('SUI.PGMPRE');
         sql_addSelect('SUI.COMSUI');
         sql_addSelect('SUI.LIBMSG');

         sql_from('EXSUIP': 'SUI');

         sql_addWhere(sql_eq('SUI.NIVMSG':'ANO')); //on ne prend que les anomalies

         if p_application <> *blanks;
           sql_addWhere(sql_eq('SUI.APPMSG':p_application));
         endif;

         if p_pgm <> *blanks;
           sql_addWhere(sql_eq('SUI.PGMPRE':p_pgm));
         endif;

         if p_jobname <> *blanks;
           sql_addWhere(sql_eq('SUI.JOBNAM':p_jobname));
         endif;

         if p_jobuser <> *blanks;
           sql_addWhere(sql_eq('SUI.JOBUSR':p_jobuser));
         endif;

         if p_jobnbr <> *blanks and p_jobnbr <> *all'0';
           sql_addWhere(sql_eq('SUI.JOBNBR':p_jobnbr));
         endif;

         if p_tsDebut <> *loval or p_tsFin <> *hival;
           sql_addWhere(sql_between('SUI.TS_CRE'
                                     :%char(p_tsDebut)
                                     :%char(p_tsFin)));
         endif;

         requete = sql_bld();
         requete += ' FOR READ ONLY';

         exec sql
           prepare stm2 from :requete;

         exec sql
           declare c2 cursor for stm2;

         exec sql
           open c2;

       END-PROC;

