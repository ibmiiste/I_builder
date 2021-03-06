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
//*********************************************************************
// ODR 31/05/2018
// Liste ddes lots
//*********************************************************************
// D�claration des fichiers
dcl-f GSTLOT10FM workstn sfile(sfl01 :wran01) indds(IndDs);


// Prototypes d'appel
Dcl-pr Gestion_Projet Extpgm('GSTLOT20');
  PCHX char(2);
  NREC CHAR(10);
end-pr;

Dcl-pr Impression Extpgm('LSTLOT2SCL');
  p_Num_lot Like(r_Num_lot) Const;
End-pr;

Dcl-pr Gestion_message Extpgm('GSTMSG01');
  PTYP Char(1);
  PFIM Char(10);
  PMID Char(7);
  PMDT Char(99);
End-pr;

/Copy Qcpysrc,Prtbuilder

// Gestion des objets du projet
// --------------------------------------------------
DCL-PR liste_objet_construction EXTPGM('LISTBUILD');
  p_Num_lots Like(r_Num_lot) Const;
END-PR ;

// Mod�les de variables
/Copy Qcpysrc,Inhbuilder

// D�claration des variables
Dcl-s WSLIBELLOT char(50);
Dcl-s ZSLIBELLOTP char(50);
Dcl-s I packed(3);
Dcl-s NREC Char(10);

// Gestion sous-fichier
Dcl-s LSTLIG Packed(4:0);
// Le compteur de ligne par page
Dcl-s NBRLIG Packed(4:0);
// Le fameux WRAN01
Dcl-s WRAN01 Packed(4:0);

// Gestion des messages
Dcl-s PTYP Char(1);
Dcl-s PFIM Char(10);
Dcl-s PMID Char(7);
Dcl-s PMDT Char(99);

// Variables Lots
Dcl-s p_Num_lot Like(r_Num_lot);
// Action transmise � gestion lot
Dcl-s PCHX Char(2);
// Num�ro relatif d'enregistrement de la table LOTS
Dcl-s g_numero_relatif Packed(15:0);



// Indicateurs
Dcl-s g_Sortie Ind;
Dcl-s g_Fin_actions Ind;
Dcl-s g_Selection Ind;
Dcl-s g_Selection_generique Ind;
Dcl-s g_Selection_OK Ind;
Dcl-s g_Traitement_option Ind;

// La DS du programme, noter le S indispensable
/copy qcpysrc,Psds

// Le DS des indicateurs de l'�cran
Dcl-ds IndDs;
  Rollup Ind Pos(2);
  Sflnxtchg Ind Pos(8);
  Zoptpr Ind Pos(20);
  g_inactif Ind Pos(21);
  // Indique si on affiche les lots actifs ou tous les lots
  g_tous_lots Ind Pos(22);
  Sfldsp Ind Pos(4);
  Sfldspctl Ind Pos(5);
  Sflclr Ind Pos(6);
  Sflend_no_rollup Ind Pos(7);
  Sflinz_Msgf Ind Pos(10);
  Sflend_Msgf Ind Pos(09);
End-ds;

// Renommage des touches de fonction
/Copy Qcpysrc,Fonction

// La DS de la table LOTS
Dcl-ds Ds_Lots Extname('LOTS') End-ds;


// Constantes
// Constantes pour SQLCODE
Dcl-c Non_trouve 100;
Dcl-c Trouve 0;
Dcl-c c_nbr_ligne_page 17;

Monitor;
  // initialisation des variables syst�me affich�es � l'�cran
  Zpgm = Procedure;
  Zdate=%Date;
  Zheur=%Time;
  Zjob=Job_name;

  // Initialisation du sous=fichier des messages
  WPGMQ='*  ';
  WMGKEY='CC01';

  Sflend_Msgf = *ON;
  Sflinz_Msgf = *ON;
  // Indicateur fin
  g_Sortie = *ON;
  // Debut du traitement,
  INITSF();
  // Boucle d'attente de sortie
  DOW g_Sortie;
    TRTSFL();
  ENDDO;
On-error;
  Dump(a);
  Gest_erreur();
Endmon;

// Indicateur de fin de programme
*INLR = *ON;
// Les proc�dures
// Traitement de l'�cran
Dcl-proc TRTSFL;
  // Effacement du sous=fichier de messages
  PTYP = '3';
  PFIM = *Blank;
  PMID = *Blank;
  Gestion_message( PTYP
                  :PFIM
                  :PMID
                  :PMDT);

  WRITE WSFCTL;
  // Ecriture de l'�cran
  Sfldsp = *ON;
  Sfldspctl = *ON;
  WRITE FORE1;

  WRITE FORB1;
  // Attente lecture
  READ FORE1;

  // Une touche a �t� actionn�e
  // Chargement de l'heure
  ZHEUR=%TIME;

  // Indicateur pour ne pas tester d'autres actions
  g_Fin_actions = *ON;
  IF Rollup;
    // page suivante
    CHGPAG();
    g_Fin_actions = *OFF;
  ENDIF;
  //
  IF ZSLIBELLOTP <> ZSLIBELLOT And g_Fin_actions;
    // Test si selection/ si chang� on initialise
    INITSF();
    g_Fin_actions = *OFF;
  ENDIF;

  // touches F3 et F12
  IF Sortie OR
        Annuler;
    // on met l'indicateur � Off = fin du programme
    g_Sortie = *OFF;
    g_Fin_actions = *OFF;
  ENDIF;
  //
  IF Refresh;
    // F5 Rafraichissement de l'�cran
    INITSF();
    g_Fin_actions = *OFF;
  ENDIF;
  //
  IF Creer;
    // F6 cr�ation d'un nouveau matricule
    PCHX = 'CR';
    Clear NREC;

    Gestion_Projet( PCHX
                   :NREC);

    INITSF();
    g_Fin_actions = *OFF;
  ENDIF;
  IF Imprimer;
    // F8 impression du fichier
    // On appelle le CL de routage sans soumission, sinon PGMF20CL
    Impression(Numlot);
    clear p_Num_lot;
    g_Fin_actions = *OFF;
  ENDIF;

  If permut_act_inact;
    If g_tous_lots=*Off;
      g_tous_lots=*on;
    Else;
      g_tous_lots=*off;
    Endif;
    INITSF();
    g_Fin_actions = *OFF;
  ENDIF;

  // On ne fait ceci que s'il n'y a eu rien d'autre
  IF g_Fin_actions = '1';
    TRTOPT();
  ENDIF;
// On recommence la boucle d'attente
End-proc;

// Initialisation du sous-fichier
Dcl-proc INITSF;

  // Variable de pr�paration de la requ�te SQL dynamique
  Dcl-s l_requete Char(1024);

  //    l'indicateur 20 conditionne la zone OPT (protection)
  Zoptpr = *OFF;
  // Initialisation de la variable de s�lection
  ZSLIBELLOTP =  ZSLIBELLOT;
  Clear WSLIBELLOT;
  // Initialisation de la cl� pour positionnement
  Clear NUMLOT;
  g_Selection = *OFF;
  g_Selection_generique = *OFF;

  // La derni�re ligne �crite
  Clear LSTLIG;
  // Le compteur de ligne par page
  Clear NBRLIG;
  // Le fameux WRAN01
  Clear WRAN01;

  // Effacement du sous=fichier
  Sflclr = *ON;
  Sflend_no_rollup = *ON;
  Sfldsp = *OFF;
  Sfldspctl = *OFF;
  WRITE FORE1;
  Sflclr = *OFF;
  Sfldsp = *ON;
  Sfldspctl = *ON;
  // Positionnement en d�but de fichier
  EXEC SQL
    CLOSE Curs_Lots02;

  If ZSLIBELLOT<>*Blank;
    l_requete='SELECT Lot_Number, ' +
                     'Libelle_Lots, ' +
                     'Liste_Biblio_Projet, ' +
                     'Biblio_Lot, ' +
                     'Statuts_Lot, ' +
                     'RRN(Lots), ' +
                     'Statut_Enreg ' +
                'FROM Lots ' +
               'WHERE Regexp_Like(Libelle_Lots, ''' +
                      %Trim(Zslibellot) + ''') ' +
            'ORDER BY Lot_Number DESC';
  Else;
    L_Requete = 'SELECT Lot_Number, ' +
                       'Libelle_Lots, ' +
                       'Liste_Biblio_Projet, ' +
                       'Biblio_Lot, ' +
                       'Statuts_Lot, ' +
                       'RRN(Lots), ' +
                       'Statut_Enreg ' +
                 'FROM Lots ' +
              'ORDER BY Lot_Number DESC';
  ENDIF;
  EXEC SQL
    PREPARE Curs_Lots02v FROM :L_Requete;
  EXEC SQL
    DECLARE Curs_Lots02 CURSOR FOR Curs_Lots02v;


  EXEC SQL
    OPEN Curs_Lots02;

  // Lexture de l'enregistrement suivant
  EXEC SQL
    FETCH Curs_Lots02
      INTO :Numlot, :Libellot, :Listbibprj, :Biblot, :Statlot, :G_Numero_Relatif,
        :Statenreg;

  // Chargement de la premi�re page
  CHGPAG();
End-proc;
// Traitement des options, on ne lit que les enregistrements modifi�s
Dcl-proc TRTOPT;
  // Lecture des enregistrements modifi�s
  WRAN01=1;
  // Top pour rafraichir l'�cran, si besoin
  g_Selection_OK = *OFF;


  READC SFL01;

  //
  DOW not %Eof;
    NREC=%Char(HNREC);
    IF HSTATENREG=0;
      IF %Trim(ZOPT)='2' OR %Trim(ZOPT)='3' OR %Trim(ZOPT)='4' OR %Trim(ZOPT)='99';
        // Si le lot a �t� ferm�, on ne peut plus rien modifier
        ZOPT = '5 ';
      ENDIF;
    ENDIF;
    g_Traitement_option = *ON;
    // Selection en fonction du choix saisi
    SELECT;
    WHEN (ZOPT = '2') OR (ZOPT = ' 2');
      PCHX = 'MO';
    WHEN (ZOPT = '3') OR (ZOPT = ' 3');
      PCHX = 'CO';
    WHEN (ZOPT = '4') OR (ZOPT = ' 4');
      PCHX = 'SU';
    WHEN (ZOPT = '5') OR (ZOPT = ' 5');
      PCHX = 'AF';
    WHEN (ZOPT = '6') OR (ZOPT = ' 6');
      impression(Numlot);
      g_Traitement_option = *OFF;
    WHEN (ZOPT = '12');
      liste_objet_construction(znumlot);
      g_Traitement_option = *Off;
      g_Selection_OK=*on;
    WHEN (ZOPT = '99');
      PCHX = 'PE';
    OTHER;
      // La saisie ne correspond � rien
      g_Traitement_option = *OFF;
      // Envoyer un message pour dire que l'option n'existe pas
      PTYP = '5';
      PFIM = 'BUILDMSGF';
      PMID = 'MSG0002';
      Gestion_message( PTYP
                      :PFIM
                      :PMID
                      :PMDT);
    ENDSL;

    // IF HTOUT = '0';
    //   // Pour ne pas perdre l'attribut couleur
    //   Znomred = *OFF;
    // ELSE;
    //   Znomred = *ON;
    // ENDIF;

    // Nettoyage
    Clear ZOPT;
    UPDATE(E) SFL01;
    // On aurait pu aussi faire IF..., en tout cas le choix est bon
    If g_Traitement_option;
      Gestion_Projet( PCHX
                     :NREC);
      g_Selection_OK=*on;
    EndIf;

    // On continue de boucler si autre option
    READC(E) SFL01;
  ENDDO;

  // Potentiellement il y a eu mise � jour, on pourrait affiner
  If g_Selection_OK;
    INITSF();
  EndIf;
End-proc;

// Chargement d'une page
Dcl-proc CHGPAG;
  // Il faut positionner correctement les indicateurs et les variables
  Sflnxtchg = *OFF;
  //                  SETON                                        04
  Wran01 = LSTLIG;

  // Remise � z�ro du compteur de ligne, mais on pourrait faire autrement
  Clear NBRLIG;
  //
  DOW Sqlcode = Trouve
  AND NBRLIG < c_nbr_ligne_page;
    // Remplissage des zones �cran
    g_Selection_OK = *ON;

    // On ne charge pas les lots ferm�s
    If g_tous_lots=*off
    And STATENREG=0;
      g_Selection_OK=*off;
    ENDIF;

    // L'indicateur est � '1' si s�lection OK ou pas de s�lection
    IF g_Selection_OK;
      ZNUMLOT = NUMLOT;
      ZLIBELLOT = LIBELLOT;
      ZLISTBIBPR = LISTBIBPRJ;
      ZBIBLOT =  BIBLOT;
      Select;
      When STATLOT='D';
        ZSTATLOT  = 'D�VELOPPEMENT';
      When STATLOT='R';
        ZSTATLOT  = 'RECETTE';
      When STATLOT='P';
        ZSTATLOT  = 'PRODUCTION';
      Endsl;
      HNREC=g_numero_relatif;
      HSTATENREG=STATENREG;
      IF STATENREG = 0;
        // Top statut Lot ferm�
        g_inactif = *ON;
      ELSE;
        g_inactif = *OFF;
      ENDIF;
      // Les compteurs, attention au WRAN01
      NBRLIG+=1;
      LSTLIG+=1;
      WRAN01+=1;
      // Ecriture de la ligne
      WRITE SFL01;
    ENDIF;
    // Lecture du suivant
    EXEC SQL
      FETCH Curs_Lots02
        INTO :Numlot, :Libellot, :Listbibprj, :Biblot, :Statlot, :G_Numero_Relatif,
          :Ds_Lots.Statenreg;

  ENDDO;
  // On quitte la boucle soit en fin de page
  //                     soit en fin de fichier
  IF Sqlcode=Non_trouve;
    // Le caract�re de suite, on est en fin de fichier
    Sflend_no_rollup = *ON;
  ELSE;
    Sflend_no_rollup = *OFF;
  ENDIF;

  // Si le fichier est vide
  IF WRAN01 = 0;
    NBRLIG=1;
    LSTLIG=1;
    // Un petit message
    WRAN01=1;
    // Pas de saisie d'option
    Zoptpr = *ON;
    IF ZSLIBELLOT = *BLANK;
      ZLIBELLOT = 'S�lection Vide';
    ENDIF;

    // Ne pas oublier de remettre � blanc
    Clear ZNUMLOT;
    Clear ZLISTBIBPR;
    Clear ZBIBLOT;
    Clear HNREC;

    // Ecriture du message sur la premi�re ligne
    WRITE SFL01;
  ENDIF;

  WRAN01 = LSTLIG;
end-proc;
