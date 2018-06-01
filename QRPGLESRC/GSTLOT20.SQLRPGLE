       ctl-opt debug decedit('0,') datedit(*dmy.);
      //****************************************************
      //                                                   *
      // Détail personnel                                  *
      //                                                   *
      //****************************************************
       dcl-f GSTLOT20FM workstn infds(wdsecr) indds(IndDs);
       dcl-f Lots usage(*update);
       dcl-f FIC01L keyed usage(*update: *output) rename(ficf      :ficf1);
       dcl-f FIF01L keyed;
       dcl-c WTXT1 '         Modification         ';
       dcl-c WTXT2 '             Copie            ';
       dcl-c WTXT3 '         Suppression          ';
       dcl-c WTXT4 '           Affichage          ';
       dcl-c WTXT5 '           Création           ';
       dcl-c WTXT6 '        Fin de contrat        ';
       dcl-s PCHX char(2);
       dcl-s PNREC char(10);
       dcl-s WNREC packed(10);
       dcl-s PACT char(2);
       dcl-s PGFCT char(3);

       // Indicateur Programme
       Dcl-s l_Confirmation_suppression Ind;
       Dcl-s l_Anomalie Ind;

       dcl-ds WDI;
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

      // La DS du programme
       /copy qcpysrc,Psds

       dcl-ds WDSECR;
        WNLIG int(5) pos(370);
        WRANP int(5) pos(378);
        WNBRS int(5) pos(380);
        WNULC int(5) pos(382);
        WRECMI int(5) pos(403);
       end-ds;

      // Le DS des indicateurs de l'écran
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
         NREC CHAR(10);
       end-pi;


      // début du programme
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
       PTYP = '1';
       PFIM = 'FICMSG   ';

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
                         :descriplot,
                         :statlot
                    FROM lots
                    WHERE CHAR( RRN( lots)) = :pnrec
                    ;

         IF PCHX = 'CR' OR PCHX = 'CO';
           // en création ou copie zone non renseignée
           Znumlot=0;
         ELSE;
           Znumlot=Numlot;
         ENDIF;
         EXSR INVDAT;
      /END-FREE
     C                   Z-ADD     WDATE         ZDAE
      /FREE
         IF PCHX = 'PE';
      /END-FREE
     C                   Z-ADD     ZDATE         ZDAS
      /FREE
         ELSE;
      /END-FREE
     C                   Z-ADD     FIDAS         WDATI
      /FREE
           EXSR INVDAT;
      /END-FREE
     C                   Z-ADD     WDATE         ZDAS
      /FREE
         ENDIF;
         // zones d'audit
      /END-FREE
     C                   Z-ADD     FIDAC         WDATI
      /FREE
         EXSR INVDAT;
      /END-FREE
     C                   Z-ADD     WDATE         ZDAC
     C                   Z-ADD     FIHEC         ZHEC
     C                   MOVEL     FIUSC         ZUSC
     C                   Z-ADD     FIDAM         WDATI
      /FREE
         EXSR INVDAT;
      /END-FREE
     C                   Z-ADD     WDATE         ZDAM
     C                   Z-ADD     FIHEM         ZHEM
     C                   MOVEL     FIUSM         ZUSM
      /FREE
       ELSE;
         // pas grand chose, la date du jour
      /END-FREE
     C                   MOVE      WDAT          ZDAE
      /FREE
       ENDIF;
       // Boucle d'attente de fin
       *IN50 = *ON;
       DOW *IN50 = '1';
         EXSR TRTSCR;
       ENDDO;
       //
       *INLR = *ON;
       // Les procédures
       BEGSR TRTSCR;
         WRITE WMGCTL;
         // On écrit l'écran
         WRITE FORE1;
         // On attend l'appui sur une touche
         READ FORE1;
         *IN70 = %EOF;
         *IN51 = *ON;
         // F3 ou F12 on termine
         IF *INKC = '1' OR
               *INKL = '1';
           *IN50 = *OFF;
           *IN51 = *OFF;
         ENDIF;
         // on met  jour l'heure
      /END-FREE
     C   51              TIME                    ZHEUR
     C   51*INKD         IFEQ      '1'
      // appui sur la touche F4
      /FREE
           IF WZOCUR = 'ZFCOD';
             PACT = 'GS';
      /END-FREE
     C                   CALL      'PGMI01'
     C                   PARM                    PACT
     C                   PARM                    PGFCT
      /FREE
             IF PGFCT <> *BLANK;
      /END-FREE
     C                   MOVEL     PGFCT         ZFCOD
      /FREE
             ENDIF;
           ENDIF;
           *IN51 = *OFF;
         ENDIF;
         //
         IF PCHX = 'SU';
           *IN51 = *OFF;
           IF l_Confirmation_suppression = '1';
             IF *INKP = '1';
               // touche F15 on supprime si indicateur confirmation_suppression
               CHAIN(E) WNREC FICF;
               *IN70 = NOT %ERROR AND NOT %FOUND;
               *IN90 = %ERROR;
      /END-FREE
     C  N70              DELETE    FICF
      /FREE
               *IN50 = *OFF;
               *IN51 = *OFF;
             ENDIF;
           ELSE;
      /END-FREE
     C                   MOVEL     'MSG0004'     PMGID
     C                   MOVEL     *BLANK        PMGDT
      /FREE
             EXSR ENVMSG;
             l_Confirmation_suppression = *ON;
           ENDIF;
         ENDIF;
         // contrle des données saisies
         IF *IN51 = '1';
           EXSR CTLDTA;
           IF l_anomalie = '1';
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
      /END-FREE
     C                   MOVE      '0'           l_anomalie
      // on vérifie que tout est bon
      /FREE
         IF PCHX = 'SU';
           // on demande confirmation
         ELSE;
           // vérification du code fonction
           CHAIN(E) KEY002 FIFF;
           *IN70 = NOT %ERROR AND NOT %FOUND;
           *IN90 = %ERROR;
           IF *IN70 = '1';
      /END-FREE
     C                   MOVE      '0'           l_anomalie
     C                   MOVEL     'MSG0003'     PMGID
      /FREE
             PMGDT = '&1'+ ZFCOD;
      /END-FREE
     C                   MOVE      '1'           l_anomalie
      /FREE
           ENDIF;
         ENDIF;
       ENDSR;
       //** Création suppression et MJ selon le cas
       BEGSR VALID1;
         IF PCHX = 'SU';
           // La suppression se fait par la touche F15
         ELSE;
           CHAIN(E) KEY001 FICF1;
           *IN71 = NOT %ERROR AND NOT %FOUND;
           *IN90 = %ERROR;
           IF PCHX = 'CR' OR PCHX = 'CO';
             // On ne crée le matricule qu'en copie ou création
      /END-FREE
     C                   MOVE      'MAT'         PCOD
     C                   MOVE      '2'           PCPT
     C                   CALL      'PGMC01'
     C                   PARM                    PCOD              3
     C                   PARM                    PCPT              1
     C                   PARM                    PCP1              6
     C                   PARM                    PMAT             10
     C                   MOVE      PMAT          FIMAT
      /FREE
             *IN71 = *ON;
           ENDIF;
      /END-FREE
     C                   MOVEL     ZFCOD         FIFON
     C                   MOVEL     ZNOM          FINOM
     C                   MOVEL     ZPR1          FIPR1
     C                   MOVEL     ZPR2          FIPR2
     C                   MOVEL     ZAD1          FIAD1
     C                   MOVEL     ZAD2          FIAD2
     C                   MOVEL     ZAD3          FIAD3
     C                   MOVEL     ZCPO          FICPO
     C                   MOVEL     ZVIL          FIVIL
     C                   MOVEL     ZTEL          FITEL
     C                   MOVEL     ZPOR          FIPOR
      // traitement des dates
     C                   Z-ADD     ZDAE          WDATE
      /FREE
           EXSR DATINV;
      /END-FREE
     C                   Z-ADD     WDATI         FIDAE
     C                   Z-ADD     ZDAS          WDATE
      /FREE
           EXSR DATINV;
      /END-FREE
     C                   Z-ADD     WDATI         FIDAS
      // zones d'audit
      /FREE
           EXSR DATHEU;
      /END-FREE
     C                   MOVE      WDAT          WDATE
      /FREE
           EXSR DATINV;
      /END-FREE
     C                   Z-ADD     WDATI         FIDAM
     C                   MOVE      WHEU          FIHEM
     C                   MOVEL     WUSER         FIUSM
      /FREE
           IF *IN71 = '0';
             // on met  jour directement
             UPDATE FICF1;
           ELSE;
             // création
      /END-FREE
     C                   Z-ADD     WDATI         FIDAC
     C                   MOVE      WHEU          FIHEC
     C                   MOVEL     WUSER         FIUSC
      /FREE
             WRITE FICF1;
           ENDIF;
         ENDIF;
         *IN50 = *OFF;
       ENDSR;
       // Traitements de la date
       BEGSR DATHEU;
      /END-FREE
     C                   TIME                    W14
     C                   MOVE      W14           WDAT
     C                   MOVEL     W14           WHEU
      /FREE
       ENDSR;
       BEGSR INVDAT;
      /END-FREE
     C                   Z-ADD     WSSAI         WSSAE
     C                   Z-ADD     WMI           WME
     C                   Z-ADD     WJI           WJE
      /FREE
       ENDSR;
       BEGSR DATINV;
      /END-FREE
     C                   Z-ADD     WSSAE         WSSAI
     C                   Z-ADD     WME           WMI
     C                   Z-ADD     WJE           WJI
      /FREE
       ENDSR;
       //****Envoi d'un message programme
       BEGSR ENVMSG;
      /END-FREE
     C                   CALL      'PGM001CL'
     C                   PARM                    PTYP              1
     C                   PARM                    PFICM            10
     C                   PARM                    PMGID             7
     C                   PARM                    PMGDT            99
      /FREE
       ENDSR;
      /END-FREE
