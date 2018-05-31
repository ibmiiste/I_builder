     h debug decedit('0,') datedit(*dmy.) bnddir('SERVICES')
     h option(*srcstmt)
     h/if defined(*crtbndrpg)
     h DFTACTGRP(*no) actgrp(*caller)
     h/Endif
      //*********************************************************************
      // OD 21/07/2015
      // liste du personnel
      //*********************************************************************
      // déclaration des fichiers
     fpgmf01fm  cf   e             workstn
     f                                     sfile(sfl01 :wran01)
     f                                     infds(dssfl1)
     f                                     indds(IndDS)

      // main function prototype
      // prototype fonction principale
     dliste_lot        pr                  extpgm('PGMF01')
     dliste_lot        pi

      // external functions prototypes
      // prototype fonctions externes
      * Gestion des messages
     dgst_message      pr                  extpgm('PGM001CL')
     d a_typ                               like(r_typmsg)
     d a_fim                               like(r_nomobj)
     d a_mid                               like(r_msgid)
     d a_mdt                               like(r_msgdta)

      * Appel de l'écran détail du personnel
     ddetail_personnel...
     d                 pr                  extpgm('PGMF02')
     d a_chx                               like(r_operation)
     d a_nrec                              like(r_matricule)

     d* Impression
     dimpression       pr                  extpgm('PGMF2SCL')
     d a_mat                               like(r_matricule)

      // Gestion des erreurs non prévues
     d gest_erreur     pr

      // program status data structure
      // structure information programme
     d/copy qcpysrc,psds

      // local functions prototypes
      // prototypes fonctions locales

      // global variables
      // variables globales
     dg_snom           s                   like(r_nom)
     dg_wsnop          s                   like(r_nom)

     dg_nblis1         s                   like(r_nblign)
     dg_lstlig         s                   like(r_nblign)
     dg_nbrlig         s                   like(r_nblign)
     dg_i              s              3p 0
     dg_xnom           s                   like(r_nom)
     da_typ            s                   like(r_typmsg)
     da_fim            s                   like(r_nomobj)
     da_mid            s                   like(r_msgid)
     da_mdt            s                   like(r_msgdta)

     d a_chx           s              2a
     d a_nrec          s                   like(r_matricule)
     d a_mat           s                   like(r_matricule)

      // Indicateurs
     d g_sortie        s               n
     d g_trt_opt       s               n
     d g_selection     s               n
     d g_alimsfl       s               n
     d g_filtre        s               n

      // Touches de fonction
      /copy qcpysrc,fonction

      // data-structures
      // structures de données
      // Indicateurs renommés avec Indara et INDDS
     D IndDS           ds
     D  ROLLUP                         N   Overlay(IndDS:2)
     D  SFLDSP                         N   Overlay(IndDS:4)
     D  SFLDSPCTL                      N   Overlay(IndDS:5)
     D  SFLCLR                         N   Overlay(IndDS:6)
     d  SFLEND                         N   Overlay(IndDS:7)
     d  SFLNXTCHG                      N   Overlay(IndDS:8)
     d  SFLENDMSG                      N   Overlay(IndDS:9)
     D  SFLINZ                         N   Overlay(IndDS:10)
     D  PROTECT                        N   Overlay(IndDS:20)
     D  ROUGE                          N   Overlay(IndDS:30)

      // la ds du sous=fichier
     ddssfl1           ds
     dwposc                  370    371b 0
     dwrrng                  376    377b 0
     dwrngp                  378    379b 0
     dwnbrsf                 380    381b 0

      // la ds du fichier
     dfic              ds
     dwnrc01                 397    400b 0
     dwdsfic           ds
     dwcdfil                   1      8
     dwopenf                   9      9
     dwstsfi                  11     15  0
     dwopcod                  16     21
     dwrpgsq                  30     37
     dwrpgnr                  38     45
     dwerrfi                  46     52
     dwnfich                  83     92
     dwnlibr                  93    102
     dwspnam                 103    112
     dwsplib                 113    122
     dwspnum                 123    124b 0
     dwlimbr                 129    138
     dwnbput                 243    246b 0
     dwnbget                 247    250b 0
     dwnbpg                  251    254b 0
     dwnbio                  255    258b 0
     dwrcdft                 261    270
     dwnbrcd                 283    286b 0
     dwnrcfi                 397    400b 0

      // inherited variables
      // héritage des types
     d/copy QCPYSRC,INH32766

      // constants
      // constantes

      * main function
      * fonction principale
      /free
       monitor;
       // le nombre de lignes affichables, déclaration à la volée
         g_nblis1=14;
         // initialisation des variables générales
         zpgm=PROCEDURE;
         zdate=%dec(%date():*eur);
         zheur=%dec(%time():*eur);
         zuser=USER;
         zjob=JOB_NAME;
         // initialisation du sous fichier des messages
         wpgmq='*  ';
         wmgkey='CC01';
         sflendmsg = *on;
         sflinz = *on;
         // indicateur fin
         g_sortie = *off;
         // début du traitement,
         exsr initsf;
         // boucle d'attente de sortie
         dow not g_sortie;
           exsr trtsfl;
         enddo;

         on-error;
           dump(a);
           gest_erreur();
         endmon;

       // indicateur de fin de programme
       *inlr = *on;
       // les procédures
       // traitement de l'écran
       begsr trtsfl;
         // effacement du sous=fichier de messages
          a_typ='3';
          a_fim=*blank;
          a_mid=*blank;
          gst_message(  a_typ
                      : a_fim
                      : a_mid
                      : a_mdt);
         write wsfctl;
         // ecriture de l'écran
         sfldsp = *on;
         sfldspctl = *on;
         write fore1;

         write forb1;
         // attente lecture
         read fore1;

         // une touche a été actionnée
         // chargement de l'heure
         zheur=%dec(%time());
         // indicateur pour ne pas tester d'autres actions
         g_trt_opt = *on;
         if rollup;
           // page suivante
           exsr chgpag;
           g_trt_opt = *off;
         endif;
         //
         if g_wsnop <> zsnom
         and g_trt_opt;
         // test si selection/ si changé on initialise
           exsr initsf;
           g_trt_opt = *off;
         endif;
         // touches f3 et f12
         if sortie or
               cancel;
           // on met l'indicateur  off = fin du programme
           g_sortie = *on;
           g_trt_opt = *off;
         endif;
         //
         if refresh;
           // f5 rafraichissement de l'écran
           exsr initsf;
           g_trt_opt = *off;
         endif;
         //
         if creer;
           // f6 création d'un nouveau matricule
            a_chx='CR';
            a_nrec=*zero;
            detail_personnel(a_chx:a_nrec);
            exsr initsf;
           g_trt_opt = *off;
         endif;
         if imprimer;
           // f8 impression du fichier
            a_mat=*zero;
            // on appelle le cl de routage sans soumission, sinon pgmf20cl
            impression(a_mat);
            g_trt_opt = *off;
         endif;
         // on ne fait ceci que s'il n'y a eu rien d'autre
         if g_trt_opt;
           exsr trtopt;
         endif;
         // on recommence la boucle d'attente
       endsr;
       // initialisation du sous-fichier
       begsr initsf;
         //    l'indicateur 20 conditionne la zone opt (protection)
         protect = *off;
         // initialisation de la variable de sélection
         g_wsnop=zsnom;
         g_snom=*blank;
         // initialisation de la clé pour positionnement
         Id_Lot =*zero;
         finom=*blank;
         g_selection = *off;
         g_filtre = *off;
         if zsnom <> *blank;
           // si différent de blank il y a sélection
           g_selection = *on;
           g_i=0;
           g_i=%scan('*':zsnom);

           if g_i > 0;
              g_filtre=*on;
              g_i=g_i-1;
              g_snom=%subst(zsnom:1:g_i);
              // on est dans le cas d'une sélection générique
             // on se positionnera juste au bon endroit dans le fichier
              finom=g_snom;
           endif;
         endif;
         // la dernière ligne écrite

         g_lstlig=0;
         // le compteur de ligne par page
         g_nbrlig=0;
         // le fameux wran01
         wran01=0;
         // effacement du sous=fichier
         sflclr = *on;
         sflend = *on;
         sfldsp = *off;
         sfldspctl = *off;
         write fore1;
         sflclr = *off;
         sfldsp = *on;
         sfldspctl = *on;
         // positionnement en début de fichier
         setll ( Id_Lot:description_lot) fic02l;
         // chargement de la première page
         exsr chgpag;
       endsr;
       // traitement des options, on ne lit que les enregistrements modifiés
       begsr trtopt;
         // lecture des enregistrements modifiés
          wran01=1;
          // top pour rafrachir l'écran, si besoin
         g_alimsfl = *off;
         readc sfl01;
         dow not %eof;
             a_nrec=hnrec;
             if htout='1';
                if zopt='2' or zopt='3' or zopt='4' or zopt='5';
               // si l'employé  quitté on ne peut plus rien modifier
                   zopt='5';
                endif;
             endif;
             g_filtre = *on;
             // selection en fonction du choix saisi
             select;
             when (zopt = '2') or (zopt = ' 2');
                a_chx='MO';
             when (zopt = '3') or (zopt = ' 3');
                a_chx='CO';
             when (zopt = '4') or (zopt = ' 4');
                a_chx='SU';
             when (zopt = '5') or (zopt = ' 5');
                a_chx='AF';
             when (zopt = '6') or (zopt = ' 6');
                a_mat=hmatr;
                impression(a_mat);
                g_filtre = *off;
             when (zopt = '99');
                a_chx='PE';
             other;
             // la saisie ne correspond  rien
                g_filtre = *off;
             // envoyer un message pour dire que l'option n'existe pas
                a_typ='1';
                a_fim='FICMSG   ';
                a_mid='MSG0002';
                gst_message(  a_typ
                            : a_fim
                            : a_mid
                            : a_mdt);
             endsl;
             if htout = '0';
             // pour ne pas perdre l'attribut couleur
               rouge = *off;
             else;
               rouge = *on;
             endif;
             // nettoyage
             zopt=*blanks;
             update(e) sfl01;
             // on aurait pu aussi faire if..., en tout cas le choix est bon
             detail_personnel(  a_chx
                              : a_nrec);
             g_alimsfl=*on;
             // on continue de boucler si autre option
           readc(e) sfl01;
         enddo;
         // potentiellement il y a eu mise  jour, on pourrait affiner
         if g_alimsfl;
            exsr initsf;
         ENDIF;
       endsr;
       // chargement d'une page
       begsr chgpag;
         // il faut positionner correctement les indicateurs et les variables
         sflnxtchg = *off;
         //                  seton                                        04
         wran01=g_lstlig;
         // lecture de l'enregistrement suivant
         exec sql fetch curs_listlot
                    into :Id_Lot, :g_numlot, :g_desclot, :g_etape;


         // remise à zéro du compteur de ligne, mais on pourrait faire autrement
         g_nbrlig=0;

         dow not %eof(fic02l)
         and g_nbrlig < 14;
           // remplissage des zones écran
           g_alimsfl = *on;
           // test s'il y a sélection
           if g_selection or g_filtre;
             if g_selection and not g_filtre;
               // on recherche la stricte égalité de nom
               if Id_Lot <> ZSNUMLOT;
                 g_alimsfl = *off;
               endif;
             else;
                // on recherche si le nom commence par la valeur avant le '*'
                g_xnom=%subst( finom:1:g_i);
                if g_xnom <> g_snom;
                 g_alimsfl = *off;
               endif;
             endif;
           endif;
           // l'indicateur est  '1' si sélection ok ou pas de sélection
           if g_alimsfl;
              znumlot = g_numlot;
              zdesclot = g_desclot;
              exec sql select lib_etap
                         into :zetape
                         from etape
                        where iden_etape=:g_etape;
              wdsfic=fic;
              hnrec=wnrcfi;
              hmatr=fimat;
             // les compteurs, attention au wran01
             g_nbrlig+=1;
             g_lstlig+=1;
             wran01+=1;
             // ecriture de la ligne
             write sfl01;
           endif;
           // lecture du suivant
           read fic02l;

         enddo;
         // on quitte la boucle soit en fin de page
         //                     soit en fin de fichier
         if %eof(fic02l);
           // le caractère de suite, on est en fin de fichier
           sflend = *on;
         else;
           sflend = *off;
         endif;
         // si le fichier est vide
         if wran01 = 0;
            g_nbrlig=1;
            g_lstlig=1;
            // un petit message
            wran01=1;
            // pas de saisie d'option
           protect = *on;
           if zsnom = *blank;
             znom = 'sélection vide';
           else;
             znom = 'Fichier vide';
           endif;
           // ne pas oublier de remettre  blanc
           zpr1=*blank;
           zfonc=*blank;
           zmatr=0;
           zcpo=*blank;
           wdsfic=*blank;
           hnrec=0;
           // ecriture du message sur la première ligne
           write sfl01;
         endif;
       endsr;
      /end-free
