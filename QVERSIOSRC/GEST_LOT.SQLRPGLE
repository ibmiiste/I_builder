       //***************************************************************
       // PROGRAMME : BAMP303R                 Date Création : 01/02/2016
       // AUTEUR    : O.DRUBIGNY               Copyright C.I.Services
       //----------------------------------------------------------------
       // APPLICATION :
       //  AMM
       //----------------------------------------------------------------
       //  DESCRIPTION :
       //  L'objectif est de constituer un Fichier Excel informant le
       //  gestionnaire et les chauffagistes des températures des
       //  logements et de l'immeuble.
       //  Ces informations serviront de base pour vérifier la
       //  température dans les cas suivants :
       //        -	Réclamation des occupants quand ils déclarent avoir froid.
       //        -	Equilibrage du réseau de chauffage
       //        -	Détecter les appartements en anomalie de température
       //           (surchauffe, sous-chauffage etc...)
       //        -	Etc...
       //  Le programme BAMP303R calcule les moyennes de température
       //  selon les spécifications décrites dans le document:
       //  Z:\02 - Projets & Applications\Applications iSeries NEW\
       //  03 - Applications\Thermos\02 - Spécifications générales et détaillées (SGD)
       //  \EBM fichier Excel Sonde de T°\
       //  Ista-SD-THE-013 - Fichier Excel sonde de température.docx
       //----------------------------------------------------------------
       //  MAINTENANCE :
       //  N°    AUTEUR                 OBJET                     DATE
       // ...  ...........  .................................  ../../....
       // ...  ...........  .................................  ../../....
       // ...  ...........  .................................  ../../....
       //----------------------------------------------------------------
       //  INDICATEURS :
       //  xx -> xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
       //****************************************************************
       // Option de compilation et de programme
       /If Defined(*CRTBNDRPG )
         ctl-opt actgrp(*caller);
         ctl-opt DftActGrp(*No);
       /endif

       ctl-opt option(*nodebugio:*srcstmt);
       ctl-opt bnddir('SERVICE');


      // déclaration des fichiers
      // dcl-f fichier disk;

      // structure information programme
      /copy qcpysrc,psds


      // main function prototype
      // prototype fonction principale
       dcl-proc gestion_lot export;
       dcl-pr gestion_lot extproc('GEST_LOT');
         p_action char(3);
         p_num_lot packed(6:0);
         p_bib_lot char(10);
         p_libelle char(50);
       END-PR;

       dcl-pi gestion_lot;
         p_action char(3);
         p_num_lot packed(6:0);
         p_bib_lot char(10);
         p_libelle char(50);
       END-Pi;

      // external functions prototypes
      // prototype fonctions externes
      // dcl-pr proc_ext varchar(300) extproc('PROC_EXT1');
      //   donnees1 packed(10:0);
      // end-pr;
      /copy qcpysrc,prsmod000r
      // program status data structure
      // structure information programme
      ///copy qcpysrc,psds

      // local functions prototypes
      // prototypes fonctions locales
      // dcl-pr sous_proc1 ind;
      //   donnees2 char(150);
      // end-pr;


      // global variables
      // variables globales
       dcl-s g_numero_lot packed(6:0);
       dcl-s g_bib_lot char(10);
       dcl-s g_code_retour packed(5:0);
       dcl-s g_libelle_lot char(80);

      // Indicateurs
      // dcl-s g_indic1 ind;

      // Touches de fonction
      /copy qcpysrc,fonction

      // data-structures
      // structures de données
      // Indicateurs renommés avec Indara et INDDS
      // dcl-ds ds1;
      //   donneeds1 like(r_ref4);
      //   donneeds2 like(r_ref5);
      // end-ds;


      // inherited variables
      // héritage des types
      /copy QCPYSRC,INH32766

      // constants
      // constantes
      // dcl-c constante1 'CONSTANTE';

      * main function
      * fonction principale

       // indicateur de fin de programme
       *inlr = *on;
       monitor;
         select;
           when p_action='CRT';

             exec sql select NUMERO_LOT
                        into :g_numero_lot
                        from listlot
                    order by IDENTIFIANT_LOT DESC
             FETCH FIRST 1 ROWS ONLY;

             if SQLCODE <> 0;
               g_numero_lot =0;
             ENDIF;

             g_numero_lot +=1;

             g_bib_lot='LOT_' + %editc(g_numero_lot :'X');
             g_libelle_lot = g_bib_lot + ' - ' + %trim(p_libelle);

             exec sql INSERT INTO LISTLOT
                             VALUES( default,
                                     :g_numero_lot ,
                                     :g_libelle_lot,
                                     :g_bib_lot,
                                     '1',
                                     default,
                                     :user,
                                     default,
                                     :user);
        ENDSL;

        p_num_lot=g_numero_lot ;
        p_bib_lot=g_bib_lot;

       on-error;
         dump(a);
         g_code_retour=ERROR;
         gest_erreur();
       endmon;

       return;

       end-proc gestion_lot;
       // les sous-routines
       // traitement de l'écran
       // begsr sr1;

       // endsr;


       // --------------------------------------------------
       // Procedure name: sous_proc1
       // Purpose:
       // Returns:
       // --------------------------------------------------
       //DCL-PROC sous_proc1 ;
       //
       //dcl-pi sous_proc1 ind;
       //  donnees2 char(150);
       //end-pi;
           // Données locales
       //DCL-S l_donnee1 like(r_ref6);
           // Programmation


       //END-PROC ;

