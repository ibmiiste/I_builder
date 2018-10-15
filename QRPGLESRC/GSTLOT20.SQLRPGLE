      // >>PRE-COMPILER<<                                              */
      //   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
      //   >>IMPORTANT<<                                               */
      //     >>PARM<<  OBJ(&LI/&OB);                                   */
      //     >>PARM<<  OBJTYPE(*PGM);                                  */
      //     >>PARM<<  OPTION(*EVENTF);                                */
      //     >>PARM<<  RPGPPOPT(*LVL2);                                */
      //     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
      //     >>PARM<<  DATFMT(*ISO);                                   */
      //     >>PARM<<  TIMFMT(*ISO);                                   */
      //     >>PARM<<  COMMIT(*NONE);                                  */
      //     >>PARM<<  COMPILEOPT(&U0);                                */
      //   >>END-IMPORTANT<<                                           */
      // >>EXECUTE<<                                                   */
      // >>END-PRE-COMPILER<<                                          */
       /copy qcpysrc,cpyctlstm
       Ctl-opt bnddir('I_BUILDER');
      //****************************************************
      //                                                   *
      // Détail personnel                                  *
      //                                                   *
      //****************************************************
       dcl-f GSTLOT20FM workstn infds(wdsecr) indds(IndDs);
       dcl-c WTXT1 '         Modification         ';
       dcl-c WTXT2 '             Copie            ';
       dcl-c WTXT3 '         Suppression          ';
       dcl-c WTXT4 '           Affichage          ';
       dcl-c WTXT5 '           Création           ';
       dcl-c WTXT6 '        Fin de contrat        ';


       // Modèles de variables
       /Copy Qcpysrc,Inhbuilder

       // Indicateur Programme
       Dcl-s l_Confirmation_suppression Ind;
       Dcl-s l_Anomalie Ind;
       Dcl-s l_Donnees_a_controler Ind;
       Dcl-s l_traitenement_ecran Ind;
       Dcl-s l_MAJ_Lots Ind;
       // Indicateur de valeur null en SQL
       Dcl-s l_null Int(5);

       // Gestion des messages
       Dcl-s P_TYP Char(1);
       Dcl-s P_FICM Char(10);
       Dcl-s P_MGID Char(7);
       Dcl-s P_MGDT Char(99);


       // Gestion du ROWID
       Dcl-s g_Rowidlots SQLTYPE(ROWID);

       // Constantes

       // Constantes Sqlcode
       Dcl-c c_Trouve 0;


       // Prototype de sous-procédure externe
       // Copy des procédures de l'outils i_Builder
       /Copy Qcpysrc,Prtbuilder


       Dcl-pr Gestion_message Extpgm('ENVMSG01');
         P_TYP Char(1);
         P_FIM Char(10);
         P_MID Char(7);
         P_MDT Char(99);
       End-pr;

       // La DS du programme
       /copy qcpysrc,Psds

       // Le DS des indicateurs de l'écran
       Dcl-ds IndDs;
        Protection Ind Pos(14);
        Sflinz_Msgf Ind Pos(10);
        Sflend_Msgf Ind Pos(09);
       End-ds;


       // Prototypes d'appel
       Dcl-pr Gestion_Projet Extpgm('GSTLOT20');
         PCHX char(2);
         NREC CHAR(10);
       end-pr;

       // Prototypes d'appel
       Dcl-pi Gestion_Projet;
         PCHX char(2);
         PNREC CHAR(10);
       end-pi;


         // début du programme
         Monitor;
           Zpgm = Procedure;
           Zdate=%Date;
         Zheur=%Time;
         Zjob=Job_name;

         // Initialisation du sous=fichier des messages
         WPGMQ='*  ';
         WMGKEY='CC01';

         Sflend_Msgf = *ON;
         Sflinz_Msgf = *ON;
         Protection = *ON;

         l_Confirmation_suppression = *OFF;
         l_anomalie = *OFF;

         // constantes pour ce programme
         P_TYP = '1';
         P_FICM = 'FICMSG   ';

         // Effacer le sous-fichier de message
         Sflend_Msgf = *ON;
         Sflinz_Msgf = *ON;

         SELECT;
         WHEN (PCHX = 'MO');
           // modification
           ZMODE=WTXT1;
           // on ne peut modifier que ces zones
           Protection = *OFF;
         WHEN (PCHX = 'CO');
           // copie
           ZMODE=WTXT2;
         // toutes les zones sont autorisées
           Protection = *OFF;
         WHEN (PCHX = 'SU');
           // suppression
           ZMODE=WTXT3;
         // aucune zone n'est saisisable
         WHEN (PCHX = 'AF');
           // affichage
           ZMODE=WTXT4;
         // aucune zone n'est saisisable
         WHEN (PCHX = 'CR');
           // création
           ZMODE=WTXT5;
         // tout est saisisable sauf date de sortie
           Protection = *OFF;
         WHEN (PCHX = 'PE');
           // direction Ple Emploi
           ZMODE=WTXT6;
         // on saisit simplement la date de fin
         ENDSL;
         // Initialisation de l'écran si on un numéro d'enregistrement
         IF PNREC <> *BLANK;
           EXEC SQL
             SELECT rowid_lots,
                    lot_number,
                    libelle_lots,
                    liste_biblio_projet,
                    biblio_lot,
                    description_lots,
                    statuts_lot
               INTO :g_rowidlots,
                    :numlot,
                    :libellot,
                    :listbibprj,
                    :biblot,
                    :descriplot,
                    :statlot
               FROM lots
               WHERE CHAR(RRN(lots)) = :pnrec ;

           IF PCHX = 'CR' OR PCHX = 'CO';
             // en création ou copie zone non renseignée
             Znumlot=0;
           ELSE;
             Znumlot=Numlot;
           ENDIF;
           Znumlot=Numlot;
           Zlibellot=Libellot;
           Zlistbibpr=Listbibprj;
           Zdescripl=Descriplot;
           Zstatlot=Statlot;
           cvthc(%addr(zrowidlots): %addr(g_rowidlots): %Len(g_rowidlots)*2);  //make hex
         ENDIF;
         // Boucle d'attente de fin
         l_traitenement_ecran = *ON;
         DOW l_traitenement_ecran = '1';
           EXSR TRTSCR;
         ENDDO;
       On-error;
         Dump(a);
         Gest_erreur();
       Endmon;

         //
       *INLR = *ON;
       // Les procédures
       BEGSR TRTSCR;
         WRITE WMGCTL;
         // On écrit l'écran
         WRITE FORE1;
         // On attend l'appui sur une touche
         READ FORE1;

         // Effacement des sous-fichiers de messages
         P_TYP = '3';
         EXSR ENVMSG;
         P_TYP = '1';

         l_Donnees_a_controler = *ON;
         // F3 ou F12 on termine
         IF *INKC = '1' OR
               *INKL = '1';
           l_traitenement_ecran = *OFF;
           l_Donnees_a_controler = *OFF;
         ENDIF;

         // on met  jour l'heure
         ZHEUR=%Time();

         //If *INKD
         //And Donnees_a_controler;
         // appui sur la touche F4
         //  Donnees_a_controler = *OFF;
         //ENDIF;
         //
         IF PCHX = 'SU';
           l_Donnees_a_controler = *OFF;
           IF l_Confirmation_suppression;
             IF *INKP = '1';
               // touche F15 on supprime si indicateur confirmation_suppression
               EXEC SQL SELECT rowid_lots,
                               lot_number,
                               libelle_lots,
                               liste_biblio_projet,
                               biblio_lot,
                               description_lots,
                               statuts_lot
                          INTO :g_rowidlots,
                               :numlot,
                               :libellot,
                               :listbibprj,
                               :biblot,
                               :descriplot,
                               :statlot
                          FROM lots
                         WHERE CHAR( RRN( lots)) = :pnrec
                         ;


               If SQLcode=c_Trouve;
                 //Archivage de la biliothèque du lot
                 Savliblot(%Char(numlot));

                 EXEC SQL
                   DELETE FROM lots WHERE CHAR(RRN(lots)) = :pnrec ;
               endif;

               l_traitenement_ecran = *OFF;
               l_Donnees_a_controler = *OFF;
             ENDIF;
           ELSE;
             P_MGID = 'MSG0004';
             P_MGDT = *Blank;
             EXSR ENVMSG;
             l_Confirmation_suppression = *ON;
           ENDIF;
         ENDIF;
         // contrle des données saisies
         IF l_Donnees_a_controler = '1';
           EXSR CTLDTA;
           IF l_anomalie;
             // anomalie
             EXSR ENVMSG;
             l_anomalie = *OFF;
           ELSE;
             // confirmation  pour suppression
             EXSR VALID1;
           ENDIF;
         ENDIF;
       ENDSR;
       // controle des données/si suppression demande de confirmation
       BEGSR CTLDTA;
         l_anomalie=*Off;
      // on vérifie que tout est bon
         IF PCHX = 'SU';
           // on demande confirmation
         ELSE;
           // vérification du code fonction
           // Ajouter les contrôles sur la liste de bibliothèques
         ENDIF;
       ENDSR;
       //** Création suppression et MJ selon le cas
       BEGSR VALID1;
         IF PCHX = 'SU';
           // La suppression se fait par la touche F15
         ELSE;
           EXEC SQL SELECT rowid_lots,
                           lot_number,
                           libelle_lots,
                           liste_biblio_projet,
                           biblio_lot,
                           description_lots,
                           statuts_lot
                      INTO :g_rowidlots,
                           :numlot,
                           :libellot,
                           :biblot,
                           :listbibprj,
                           :descriplot,
                           :statlot
                      FROM lots
                     WHERE lot_number=:znumlot;

           If Sqlcode=c_trouve;
             l_MAJ_Lots=*On;
           EndIf;

           IF PCHX = 'CR' OR PCHX = 'CO';
             l_MAJ_Lots = *OFF;
           ENDIF;

           IF l_MAJ_Lots;
             // on met à jour directement
             EXEC SQL UPDATE lots
                         SET libelle_lots=:zlibellot,
                             liste_biblio_projet=:zlistbibpr,
                             description_lots=:zdescripl
                       WHERE lot_number=:numlot
                   ;
           ELSE;
             // création
             EXEC SQL INSERT INTO lots( libelle_lots,
                                        liste_biblio_projet,
                                        description_lots,
                                        statuts_lot)
                                VALUES( :zlibellot,
                                        :zlistbibpr,
                                        :zdescripl,
                                        :zstatlot)
                    ;

             // On récupère le numéro du lot créé
             EXEC SQL SELECT MAX( numlot)
                        INTO :numlot :l_null
                        FROM lots;
             gestion_bib_lot(numlot);
           endif;
         ENDIF;
         l_traitenement_ecran = *OFF;
       ENDSR;

       //****Envoi d'un message programme
       BEGSR ENVMSG;
         Gestion_message( P_TYP
                         :P_FICM
                         :P_MGID
                         :P_MGDT);

       ENDSR;
