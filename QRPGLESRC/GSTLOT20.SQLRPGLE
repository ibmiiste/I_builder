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
      // D�tail personnel                                  *
      //                                                   *
      //****************************************************
       dcl-f GSTLOT20FM workstn infds(wdsecr) indds(IndDs);
       dcl-c WTXT1 '         Modification         ';
       dcl-c WTXT2 '             Copie            ';
       dcl-c WTXT3 '         Suppression          ';
       dcl-c WTXT4 '           Affichage          ';
       dcl-c WTXT5 '           Cr�ation           ';
       dcl-c WTXT6 '        Fin de contrat        ';
       dcl-s WNREC packed(10);
       dcl-s PACT char(2);
       dcl-s PGFCT char(3);

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


       // Constantes

       // Valeur Sqlcode
       Dcl-c c_Trouve 0;
       Dcl-c c_Non_trouve 100;

       Dcl-pr Gestion_message Extpgm('ENVMSG01');
         P_TYP Char(1);
         P_FIM Char(10);
         P_MID Char(7);
         P_MDT Char(99);
       End-pr;

       // La DS du programme
       /copy qcpysrc,Psds

       Dcl-ds WDI;
        WSSAI zoned(4) pos(1);
        WMI zoned(2) pos(5);
        WJI zoned(2) pos(7);
        WDATI zoned(8) pos(1);
       end-ds;

       dcl-ds WDE;
        WJE zoned(2) pos(1);
        WME zoned(2) pos(3);
        WSSAE zoned(4) pos(5);
        WDATE zoned(8) pos(1);
       end-ds;

       dcl-ds WDSECR;
        WNLIG int(5) pos(370);
        WRANP int(5) pos(378);
        WNBRS int(5) pos(380);
        WNULC int(5) pos(382);
        WRECMI int(5) pos(403);
       end-ds;

      // Le DS des indicateurs de l'�cran
       Dcl-ds IndDs;
        Protection Ind Pos(14);
        Sflinz_Msgf Ind Pos(10);
        Sflend_Msgf Ind Pos(09);
       End-ds;

       // Ds de la table LOTS
       Dcl-DS DS_Lots Extname('LOTS') End-ds;

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


      // d�but du programme
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

       SELECT;
       WHEN (PCHX = 'MO');
         // modification
         ZMODE=WTXT1;
         // on ne peut modifier que ces zones
         Protection = *OFF;
       WHEN (PCHX = 'CO');
         // copie
         ZMODE=WTXT2;
      // toutes les zones sont autoris�es
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
         // cr�ation
         ZMODE=WTXT5;
      // tout est saisisable sauf date de sortie
         Protection = *OFF;
       WHEN (PCHX = 'PE');
         // direction Ple Emploi
         ZMODE=WTXT6;
      // on saisit simplement la date de fin
       ENDSL;
       // Initialisation de l'�cran si on un num�ro d'enregistrement
       IF PNREC <> *BLANK;
         EXEC SQL SELECT rowid_lots,
                         lot_number,
                         libelle_lots,
                         liste_biblio_projet,
                         biblio_lot,
                         description_lots,
                         statuts_lot
                    INTO :rowidlots,
                         :numlot,
                         :libellot,
                         :listbibprj,
                         :biblot,
                         :descriplot,
                         :statlot
                    FROM lots
                    WHERE CHAR( RRN( lots)) = :pnrec
                    ;

         IF PCHX = 'CR' OR PCHX = 'CO';
           // en cr�ation ou copie zone non renseign�e
           Znumlot=0;
         ELSE;
           Znumlot=Numlot;
         ENDIF;
         Znumlot=Numlot;
         Zlibellot=Libellot;
         Zlistbibpr=Listbibprj;
         Zdescripl=Descriplot;
         Zstatlot=Statlot;
       ENDIF;
       // Boucle d'attente de fin
       l_traitenement_ecran = *ON;
       DOW l_traitenement_ecran = '1';
         EXSR TRTSCR;
       ENDDO;
       //
       *INLR = *ON;
       // Les proc�dures
       BEGSR TRTSCR;
         WRITE WMGCTL;
         // On �crit l'�cran
         WRITE FORE1;
         // On attend l'appui sur une touche
         READ FORE1;
         *IN70 = %EOF;
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
                          INTO :rowidlots,
                               :numlot,
                               :libellot,
                               :listbibprj,
                               :biblot,
                               :descriplot,
                               :statlot
                          FROM lots
                         WHERE RRN( lots) = :wnrec
                         ;

               *IN70 = NOT %ERROR AND NOT %FOUND;
               *IN90 = %ERROR;

               If %found;
                 EXEC SQL DELETE
                            FROM lots
                           WHERE RRN( lots) = :wnrec
                         ;
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
         // contrle des donn�es saisies
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
       // controle des donn�es/si suppression demande de confirmation
       BEGSR CTLDTA;
         l_anomalie=*Off;
      // on v�rifie que tout est bon
         IF PCHX = 'SU';
           // on demande confirmation
         ELSE;
           // v�rification du code fonction
           // Ajouter les contr�les sur la liste de biblioth�ques
         ENDIF;
       ENDSR;
       //** Cr�ation suppression et MJ selon le cas
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
                      INTO :rowidlots,
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
             // On ne cr�e le matricule qu'en copie ou cr�ation
             EXEC SQL SELECT MAX( numlot)
                        INTO :numlot :l_null
                        FROM lots;
             If Sqlcode = c_Trouve;
               zNumlot+=1;
             EndIf;

             If Sqlcode = c_Non_trouve;
               zNumlot = 1;
             EndIf;
             l_MAJ_Lots = *OFF;
           ENDIF;

           IF l_MAJ_Lots;
             // on met � jour directement
             EXEC SQL UPDATE lots
                         SET libelle_lots=:zlibellot,
                             liste_biblio_projet=:zlistbibpr,
                             description_lots=:zdescripl
                       WHERE lot_number=:numlot
                   ;
           ELSE;
             // cr�ation
             EXEC SQL INSERT INTO lots( lot_number,
                                        libelle_lots,
                                        liste_biblio_projet,
                                        description_lots,
                                        statuts_lot)
                                VALUES( :znumlot,
                                        :zlibellot,
                                        :zlistbibpr,
                                        :zdescripl,
                                        :zstatlot)
                    ;
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