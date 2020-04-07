**FREE
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
// Détail Lot                                        *
//                                                   *
//****************************************************
dcl-f GSTLOT20FM workstn indds(IndDs);
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
Dcl-s p_PGM Char(10);


// Variable de travail de numéro de lot alphanumérique
Dcl-s l_Num_lot_carac Like(r_Num_lot_carac);

// Variables globales à Gestion_Projet
Dcl-s g_selusr char(10); // Utilisateur
Dcl-s g_sellst  char(8); // Publique ou privée
Dcl-s g_Option_action Char(2); // Option action
Dcl-s g_Liste_selectionnee Char(10); // Liste sélectionnée par l'option 1

// Flag existence enregistrement dans un SELECT
Dcl-s g_exist Ind;

// Renommage des touches de fonction
/Copy Qcpysrc,Fonction

// Constantes

// Constantes Sqlcode
Dcl-c c_Trouve 0;
Dcl-c c_Non_trouve 100;

// Prototype de sous-procédure externe
// Copy des procédures de l'outils i_Builder
/Copy Qcpysrc,Prtbuilder


Dcl-pr Gestion_message Extpgm('GSTMSG01');
  P_TYP Char(1);
  P_FIM Char(10);
  P_MID Char(7);
  P_MDT Char(99);
  p_PGM Char(10);
End-pr;

// Guide vers la liste des listes de bibliothèques
dcl-pr Gestion_liste_bibliotheque extpgm('GSTLSTLIBR');
  *n char(10); // selusr
  *n char(8); // sellst
  *n Char(2); // Option action
  *n Char(10); // Liste sélectionnée par l'option 1
end-pr;

// La DS du programme
/copy qcpysrc,Psds

// Variables globales
Dcl-s l_Null_Zlnkticket Int(5);
Dcl-s L_Null_Zlnkgit Int(5);

Dcl-s lnkticket like(Zlnkticket);
Dcl-s lnkgit like(Zlnkgit);

// Le DS des indicateurs de l'écran
Dcl-ds IndDs;
  Protection Ind Pos(14);
  Sflinz_Msgf Ind Pos(10);
  Sflend_Msgf Ind Pos(09);
  l_liste_inexistante Ind Pos(25);
End-ds;


// Prototypes d'appel
Dcl-pr Gestion_Projet Extpgm('GSTLOT20');
  PCHX char(2);
  NREC CHAR(10);
end-pr;

// Ds de la table LOTS
Dcl-DS DS_Lots Extname('LOTS') End-ds;


// Prototypes d'appel
Dcl-pi Gestion_Projet;
  PCHX char(2);
  PNREC CHAR(10);
end-pi;

// Variables locales


// Constante SQL Valeur nulle
Dcl-c c_SQL_null -1;

// début du programme
Monitor;
  Zpgm = Procedure;
  Zdate=%Date;
  Zheur=%Time;
  Zjob=Job_name;

  // Initialisation du sous=fichier des messages
  WPGMQ=PROCEDURE;
  WMGKEY='CC01';

  // Initialisation du sous-fichier de messages
  Sflend_Msgf = *ON;
  Sflinz_Msgf = *ON;
  P_TYP = '5';
  P_FICM = 'BUILDMSGF';

  Protection = *ON;

  l_Confirmation_suppression = *OFF;
  l_anomalie = *OFF;

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
    Protection = *ON;
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
      --(--data-location--+-------------------------------------------+--)-><
      SELECT Lot_Number,
             Libelle_Lots,
             Liste_Biblio_Projet,
             Biblio_Lot,
             Description_Lots,
             Statuts_Lot,
             DLURLCOMPLETE(Lien_Ticket),
             DLURLCOMPLETE(Lien_Branche_Git),
             Timecrt,
             Usrcrt,
             Timemaj,
             Usrmaj,
             Numero_Ticket
        INTO :Numlot,
             :Libellot,
             :Listbibprj,
             :Biblot,
             :Descriplot,
             :Statlot,
             :Lnkticket :L_Null_Zlnkticket,
             :Lnkgit :L_Null_Zlnkgit,
             :Timecrt,
             :Usrcrt,
             :Timemaj,
             :Usrmaj,
             :jira
        FROM Lots
        WHERE CHAR(RRN(Lots)) = :Pnrec;
    IF pchx = 'CR'
       OR pchx = 'CO';
      // en création ou copie zone non renseignée
      znumlot = 0;
    ELSE;
      Znumlot=Numlot;
    ENDIF;
    Znumlot=Numlot;
    Zlibellot=Libellot;
    Zlistbibpr=Listbibprj;
    Zdescripl=Descriplot;
    Zjira = jira;
    IF L_Null_Zlnkticket = c_SQL_null;
      Zlnkticket=*Blanks;
    Else;
      Zlnkticket=Lnkticket;
    Endif;
    IF L_Null_ZLnkgit = c_SQL_null;
      ZLnkgit=*Blanks;
    Else;
      ZLnkgit=Lnkgit;
    Endif;
    Zstatlot=Statlot;
    zbiblot = biblot;
    ZDAC=%date(timecrt);
    Zhec=%Time(timecrt);
    ZUSC=usrcrt;
    ZDAM=%date(timemaj);
    ZHEM=%Time(timemaj);
    ZUSM=usrcrt;
  ENDIF;
  // Boucle d'attente de fin
  l_traitenement_ecran = *ON;
  DOW l_traitenement_ecran;
    TRTSCR();
  ENDDO;
On-error;
  Dump(a);
  Gest_erreur();
Endmon;

//
*INLR = *ON;
// Les procédures
Dcl-proc TRTSCR;
Dcl-proc TRTSCR;
  WRITE WMGCTL;
  // On écrit l'écran
  WRITE FORE1;
  // On attend l'appui sur une touche
  READ FORE1;

  // Réinitialisation des indicateurs d'erreur
  l_liste_inexistante=*Off;

  // Effacement des sous-fichiers de messages
  P_TYP = '3';
  ENVMSG();
  P_TYP = '5';

  l_Donnees_a_controler = *ON;
  // F3 ou F12 on termine
  IF Sortie OR
        Annuler;
    l_traitenement_ecran = *OFF;
    l_Donnees_a_controler = *OFF;
  ENDIF;

  // Guide appui sur la touche F4
  If guide And l_Donnees_a_controler;
    If WZOCUR='ZLISTBIBPR';
      g_sellst='*ALL';
      g_selusr='*ALL';
      g_Option_action='SE';
      Gestion_liste_bibliotheque( g_selusr
                                 :g_sellst
                                 :g_Option_action
                                 :ZLISTBIBPR);
      l_Donnees_a_controler = *OFF;
    Endif;
  Endif;

  // on met à jour l'heure sur l'écran
  ZHEUR=%Time();


  //
  IF PCHX = 'SU';
    l_Donnees_a_controler = *OFF;
    IF l_Confirmation_suppression;
      IF Confirmer;
        // touche F15 on supprime si indicateur confirmation_suppression
        EXEC SQL
          SELECT Lot_Number,
                 Libelle_Lots,
                 Liste_Biblio_Projet,
                 Biblio_Lot,
                 Description_Lots,
                 Statuts_Lot,
                 DLURLCOMPLETE(Lien_Ticket),
                 DLURLCOMPLETE(Lien_Branche_Git)
            INTO :Numlot,
                 :Libellot,
                 :Listbibprj,
                 :Biblot,
                 :Descriplot,
                 :Statlot,
                 :Lnkticket :L_Null_Zlnkticket,
                 :Lnkgit :L_Null_Zlnkgit
            FROM Lots
            WHERE CHAR(RRN(Lots)) = :Pnrec;


        If SQLcode=c_Trouve;
          //Archivage de la biliothèque du lot
          l_Num_lot_carac=%Editc(numlot:'X');
          Savliblot(l_Num_lot_carac);

          EXEC SQL
            UPDATE Lots
              SET Statut_Enreg = 0
              WHERE CHAR(RRN(Lots)) = :Pnrec;
        endif;

        l_traitenement_ecran = *OFF;
        l_Donnees_a_controler = *OFF;
      ENDIF;
    ELSE;
      P_MGID = 'MSG0004';
      P_MGDT = *Blank;
      ENVMSG();
      l_Confirmation_suppression = *ON;
    ENDIF;
  ENDIF;
  // contrle des données saisies
  IF l_Donnees_a_controler;
    CTLDTA();
    IF l_anomalie;
      // anomalie
      l_anomalie = *OFF;
    ELSE;
      // confirmation  pour suppression
      VALID1();
    ENDIF;
  ENDIF;
End-proc;
// controle des données/si suppression demande de confirmation
Dcl-proc CTLDTA;
  l_anomalie=*Off;
  // on vérifie que tout est bon
  IF PCHX = 'SU';
  // on demande confirmation
  ELSE;
    // vérification du code fonction
    // Ajouter les contrôles sur la liste de bibliothèques
    EXEC SQL
      SELECT '1'
        INTO :G_Exist
        FROM Deflstlib
        WHERE Lstname = :Zlistbibpr;
    If Sqlcode=c_Non_trouve;
      l_anomalie=*On;
      P_MGID = 'ERR0001';
      P_MGDT = zlistbibpr;
      ENVMSG();
      l_liste_inexistante=*On;
    Endif;
  Endif;
End-proc;

//** Création suppression et MJ selon le cas
Dcl-proc VALID1;
  IF PCHX = 'SU';
  // La suppression se fait par la touche F15
  ELSE;
    EXEC SQL
      SELECT Lot_Number,
             Libelle_Lots,
             Liste_Biblio_Projet,
             Biblio_Lot,
             Description_Lots,
             Statuts_Lot,
             DLURLCOMPLETE(Lien_Ticket),
             DLURLCOMPLETE(Lien_Branche_Git)
        INTO :Numlot,
             :Libellot,
             :Biblot,
             :Listbibprj,
             :Descriplot,
             :Statlot,
             :Lnkticket :L_Null_Zlnkticket,
             :Lnkgit :L_Null_Zlnkgit
        FROM Lots
        WHERE Lot_Number = :Znumlot;

    If Sqlcode=c_trouve;
      l_MAJ_Lots=*On;
    EndIf;

    IF PCHX = 'CR' OR PCHX = 'CO';
      l_MAJ_Lots = *OFF;
    ENDIF;

    IF l_MAJ_Lots;
      // on met à jour directement
      EXEC SQL
        UPDATE Lots
          SET Libelle_Lots = :Zlibellot,
              Liste_Biblio_Projet = :Zlistbibpr,
              Description_Lots = :Zdescripl,
              Lien_Ticket = DLVALUE(:Zlnkticket, 'URL'),
              Lien_Branche_Git = DLVALUE(:Zlnkgit, 'URL'),
              Usrcrt = :User, Numero_ticket = :zJira
          WHERE Lot_Number = :Numlot;
    ELSE;
      // création
      EXEC SQL
        INSERT INTO Lots (
              Libelle_Lots,
              Liste_Biblio_Projet,
              Description_Lots,
              Statuts_Lot,
              Lien_Ticket,
              Lien_Branche_Git,
              Timecrt,
              Usrcrt, Numero_ticket

            )
          VALUES
            (
              :Zlibellot,
              :Zlistbibpr,
              :Zdescripl,
              'D',
              DLVALUE(:Zlnkticket, 'URL'),
              DLVALUE(:Zlnkgit, 'URL'),
              Current_Timestamp,
              :User, :zjira
            );

      // On récupère le numéro du lot créé
      EXEC SQL
        SELECT MAX(Numlot)
          INTO :Numlot :L_Null
          FROM Lots;
      gestion_bib_lot(zjira );
    endif;
  ENDIF;
  l_traitenement_ecran = *OFF;
End-proc;

//****Envoi d'un message programme
Dcl-proc ENVMSG;
  Gestion_message( P_TYP
                  :P_FICM
                  :P_MGID
                  :P_MGDT
                  :PROCEDURE);

End-proc;
