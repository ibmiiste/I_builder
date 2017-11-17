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
      //   >>EXECUTE<<                                                 */
      // >>END-PRE-COMPILER<<                                          */

       /copy qcpysrc,cpyctlstm
       //*********************************************************************
       // OD 21/07/2015
       // Liste des objets � construire
       //*********************************************************************
       // d�claration des fichiers
       dcl-f listbuilde workstn sfile(sfl01 :wran01) infds(dssfl1) indds(IndDS);


       // main function prototype
       // prototype fonction principale
       // --------------------------------------------------
       // Prototype for procedure: liste_objet_construction
       // --------------------------------------------------
       DCL-PR liste_objet_construction EXTPGM('LISTBUILD');
         projet CHAR(10) CONST;
       END-PR ;

       DCL-PI liste_objet_construction;
         projet CHAR(10) CONST;
       END-PI ;


       // external functions prototypes
       // prototype fonctions externes
       //copy qcpysrc,UtiProc

      // Gestion des messages
       dcl-pr gst_message extpgm('ENVMSG01');
         a_typ like(r_typmsg);
         a_fim like(r_nomobj);
         a_mid like(r_numero_msg);
         a_mdt like(r_msgdta);
       end-pr;

        // Gestion des erreurs non pr�vues
       dcl-pr gest_erreur end-pr;

       // program status data structure
       // structure information programme
       /copy qcpysrc,psds

       // local functions prototypes
       // prototypes fonctions locales

       // global variables
       // variables globales
       dcl-s g_sobjet like(r_nomobj);
       dcl-s g_wsobp like(r_nomobj);

       dcl-s g_nblis1 like(r_nblign);
       dcl-s g_lstlig like(r_nblign);
       dcl-s g_nbrlig like(r_nblign);
       dcl-s g_i packed(3:0);
       dcl-s g_xobjet like(r_nomobj);
       dcl-s a_typ like(r_typmsg);
       dcl-s a_fim like(r_nomobj);
       dcl-s a_mid like(r_numero_msg);
       dcl-s a_mdt like(r_msgdta);

       dcl-s a_chx char(2);
       dcl-s a_nrec like(r_uuid_db2);
       dcl-s a_uuid like(r_uuid_db2);

       // Indicateurs
       dcl-s g_sortie ind;
       dcl-s g_trt_opt ind;
       dcl-s g_selection ind;
       dcl-s g_alimsfl ind;
       dcl-s g_filtre ind;
       dcl-s g_ROWID_BUILD char(40) dim(9999);
       dcl-s g_ROWID_BUILDW sqltype(rowid);

       // Touches de fonction
       /copy qcpysrc,fonction

       // data-structures
       // structures de donn�es
       // Indicateurs renomm�s avec Indara et INDDS
        Dcl-ds IndDS;
          ROLLUP ind pos(2);
          SFLDSP ind pos(4);
          SFLDSPCTL ind pos(5);
          SFLCLR ind pos(6);
          SFLEND ind pos(7);
          SFLNXTCHG ind pos(8);
          SFLENDMSG ind pos(9);
          SFLINZ ind pos(10);
          PCDESC ind pos(15);
          PROTECT ind pos(20);
        end-ds;

       // la ds du sous=fichier
       dcl-ds dssfl1;
         wposc bindec(2:0) pos(370);
         wrrng bindec(2:0) pos(376);
         wrngp bindec(2:0) pos(378);
         wnbrsf bindec(2:0) pos(380);
       end-ds;

       // la ds du fichier
       dcl-ds fic;
         wnrc01 bindec(4:0) pos(397);
       end-ds;

       dcl-ds wdsfic;
         wcdfil char(8);
         wopenf char(1);
         wstsfi packed(5:0);
         wopcod char(5);
         wrpgsq char(8);
         wrpgnr char(8);
         werrfi char(7);
         wnfich char(10);
         wnlibr char(10);
         wspnam char(10);
         wsplib char(10);
         wspnum bindec(2:0);
         wlimbr char(10);
         wnbput bindec(4:0);
         wnbget bindec(4:0);
         wnbpg bindec(4:0);
         wnbio bindec(4:0);
         wrcdft char(10);
         wnbrcd bindec(4:0);
         wnrcfi bindec(4:0);
       end-ds;

       // inherited variables
       // h�ritage des types
       /copy QCPYSRC,INH32766

       // constants
       // constantes



      // main function
      // fonction principale
      /free
       monitor;
         // le nombre de lignes affichables, d�claration à la vol�e
         g_nblis1=18;
         // initialisation des variables g�n�rales
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
         // d�but du traitement,
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
       // les proc�dures
       // traitement de l'�cran
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
         // ecriture de l'�cran
         sfldsp = *on;
         sfldspctl = *on;
         write fore1;

         write forb1;
         // attente lecture
        read fore1;

         // une touche a �t� actionn�e
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
         if g_wsobp <> ZSOBJET
         and g_trt_opt;
           // test si selection/ si chang� on initialise
           exsr initsf;
           g_trt_opt = *off;
         endif;
         // touches f3 et f12
         if sortie or
               cancel;
           // on met l'indicateur � off = fin du programme
           g_sortie = *on;
           g_trt_opt = *off;
         endif;
         //
         if refresh;
           // f5 rafraichissement de l'�cran
           exsr initsf;
           g_trt_opt = *off;
         endif;
         //
         //if creer;
           // f6 cr�ation d'un nouveau matricule
         //  a_chx='CR';
         //  a_nrec=*blank;
         //  detail_personnel(a_chx:a_nrec);
         //  exsr initsf;
         //  g_trt_opt = *off;
         //endif;
         //if imprimer;
           // f8 impression du fichier
         //  a_uuid=*blank;
           // on appelle le cl de routage sans soumission, sinon pgmf20cl
         //  impression(a_uuid);
         //  g_trt_opt = *off;
         //endif;
         // on ne fait ceci que s'il n'y a eu rien d'autre
         if g_trt_opt;
           exsr trtopt;
         endif;
       // on recommence la boucle d'attente
       endsr;
       // initialisation du sous-fichier
       begsr initsf;
         //    l'indicateur 20 conditionne la zone opt (protection)
         PROTECT = *on;
         // initialisation de la variable de s�lection
         g_wsobp=ZSOBJET;
         g_sobjet=*blank;
         // initialisation de la cl� pour positionnement
         zprojet=projet;
         ZOBJDST=*blank;
         g_selection = *off;
         g_filtre = *off;
         if ZSOBJET <> *blank;
           // si diff�rent de blank il y a s�lection
           g_selection = *on;
           g_i=0;
           g_i=%scan('*':ZSOBJET);

           if g_i > 0;
             g_filtre=*on;
             g_i=g_i-1;
             g_sobjet=%subst(ZSOBJET:1:g_i);
             // on est dans le cas d'une s�lection g�n�rique
             // on se positionnera juste au bon endroit dans le fichier
             ZOBJDST=g_sobjet;
           endif;
         endif;
         // la derni�re ligne �crite

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
         exec sql close list_obj;
         // positionnement en d�but de fichier
         exec sql declare list_obj cursor for
                    select rowid_build,
                           Projet,
                           Ordre,
                           Bibliotheque_Source,
                           Fichier_Source,
                           Membre_Source,
                           Bibliotheque_Destination,
                           Objet_Destination,
                           Type_objet
                      from LIST_OBJET_BUILD
                     where Projet=:zprojet
                  order by ordre desc;

         exec sql open list_obj;
         // chargement de la premi�re page
         exsr chgpag;
       endsr;
       // traitement des options, on ne lit que les enregistrements modifi�s
       begsr trtopt;
         // lecture des enregistrements modifi�s
         wran01=1;
         // top pour rafrachir l'�cran, si besoin
         g_alimsfl = *off;
         // Gestion de la cr�ation d'enregistrement
         if (zoptc = '1') or (zoptc = ' 1');
         //  rtvObj( OBJD0400_T
         //         :%len(OBJD0400_T
         //         :'OBJD0400'
         //         :obj:%trim(p_type)
         //         :w_errApi);
         //  if w_errApi.ErrRtn > 0;
         //    clear OBJD0400;
         //  endif;

           exec sql insert into LIST_OBJET_BUILD
           values( default,
                   :zprojet,
                   :zordrec,
                   :zbibsrcc,
                   :zficsrcc,
                   :zmbrsrcc,
                   :zbibdstc,
                   :zobjdstc,
                   :ztypobjc);
           zoptc=*blank;
           zordrec=*zero;
           zbibsrcc=*blank;
           zficsrcc=*blank;
           zmbrsrcc=*blank;
           zbibdstc=*blank;
           zobjdstc=*blank;
           ztypobjc=*blank;
           g_alimsfl=*on;
         EndIf;
         readc sfl01;
         dow not %eof;
           a_nrec=hnrec;
           g_filtre = *on;
           // selection en fonction du choix saisi
           select;
            when (zopt = '2') or (zopt = ' 2');
              a_chx='MO';
              g_ROWID_BUILDW=g_ROWID_BUILD(wran01);
              exec sql update LIST_OBJET_BUILD
                          set projet=:hprojet,
                              Ordre=:zordre,
                              Bibliotheque_Source=:zbibsrc,
                              Fichier_Source=:zficsrc,
                              Membre_Source=:ZMBRSRC,
                              Bibliotheque_Destination=:zbibsrc,
                              Objet_Destination=:zobjdst,
                              Type_objet=:ztypobj
                        where ROWID_BUILD=:g_ROWID_BUILDW;
            when (zopt = '3') or (zopt = ' 3');
              a_chx='CO';
            when (zopt = '4') or (zopt = ' 4');
              g_ROWID_BUILDW=g_ROWID_BUILD(wran01);
              exec sql delete LIST_OBJET_BUILD
                         where ROWID_BUILD=:g_ROWID_BUILDW;
            when (zopt = '5') or (zopt = ' 5');
              a_chx='AF';
            when (zopt = '6') or (zopt = ' 6');
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
            // nettoyage
           zopt=*blanks;
           update(e) sfl01;
           // on aurait pu aussi faire if..., en tout cas le choix est bon
           //detail_personnel(  a_chx
           //                 : a_nrec);
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
         exec sql fetch list_obj
                   into :g_ROWID_BUILDW,
                        :hprojet,
                        :ZORDRE,
                        :ZBIBSRC,
                        :ZFICSRC,
                        :ZMBRSRC,
                        :ZBIBDST,
                        :ZOBJDST,
                        :ztypobj;
                 // remise �z�ro du compteur de ligne, mais on pourrait faire autrement
         g_nbrlig=0;

         dow sqlcode<>100
         and g_nbrlig < 18;
           // remplissage des zones �cran
           g_alimsfl = *on;
           // test s'il y a s�lection
           if g_selection or g_filtre;
             if g_selection and not g_filtre;
               // on recherche la stricte �galit� de nom
               if ZOBJDST <> ZSOBJET;
                 g_alimsfl = *off;
               endif;
             else;
               // on recherche si le nom commence par la valeur avant le '*'
               g_xobjet=%subst( ZOBJDST:1:g_i);
               if g_xobjet <> g_sobjet;
                 g_alimsfl = *off;
               endif;
             endif;
           endif;
           // l'indicateur est  '1' si s�lection ok ou pas de s�lection
           // les compteurs, attention au wran01
           if g_alimsfl;
             g_nbrlig+=1;
             g_lstlig+=1;
             wran01+=1;
             g_ROWID_BUILD(wran01)=g_ROWID_BUILDW;
             if PROTECT=*on;
               PROTECT=*off;
             EndIf;
             // ecriture de la ligne
             write sfl01;
           endif;
           // lecture du suivant
           exec sql fetch list_obj
                   into :g_ROWID_BUILDW,
                        :hprojet,
                        :ZORDRE,
                        :ZBIBSRC,
                        :ZFICSRC,
                        :ZMBRSRC,
                        :ZBIBDST,
                        :ZOBJDST,
                        :ztypobj;
           enddo;
         // on quitte la boucle soit en fin de page
         //                     soit en fin de fichier
         if sqlcode=100;
           // le caract�re de suite, on est en fin de fichier
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
           PROTECT = *on;
           if ZSOBJET <> *blank;
             ZDESCOBJET = 's�lection vide';
           else;
             ZDESCOBJET = 'Fichier vide';
           endif;
           // ne pas oublier de remettre � blanc
           ZOBJDST=*blank;
           ZBIBDST=*blank;
           ZBIBSRC=*blank;
           ZFICSRC=*blank;
           ZMBRSRC=*blank;
           ZORDRE=0;
           hnrec=*blank;
           // ecriture du message sur la premi�re ligne
           write sfl01;
         endif;
       endsr;
      /end-free
