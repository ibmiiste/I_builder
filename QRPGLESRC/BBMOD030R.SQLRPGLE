       //***************************************************************
       // MODULE : BBMOD020R                 Date Cration : 16/02/2016
       // AUTEUR    : O.DRUBIGNY               Copyright C.I.Services
       //----------------------------------------------------------------
       // APPLICATION :
       //  Général BESAIF
       //----------------------------------------------------------------
       //  DESCRIPTION :
       //  Procédures sur les mails
       //  adresse_valide:vérifie la syntaxe de l'adresse mail
       //  Reste à faire controle des différentes parties selon les règles
       //  énoncées à cet emplacement https://tools.ietf.org/html/rfc3696
       //----------------------------------------------------------------
       //  MAINTENANCE :
       //  N    AUTEUR                 OBJET                     DATE
       // ...  ...........  .................................  ../../....
       // ...  ...........  .................................  ../../....
       // ...  ...........  .................................  ../../....
       //----------------------------------------------------------------
       //  INDICATEURS :
       //  xx -> xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
       //****************************************************************

       // Option de compilation et de programme
       ctl-opt nomain;

      // déclaration des fichiers


      // external functions prototypes
      // prototype fonctions externes


      // program status data structure
      // structure information programme
      /copy qcpysrc,psds


      // local functions prototypes
      // prototypes fonctions locales
      /copy qcpysrc,prbmod000r
       // Prototype des modules centraliss programmes de services BERGER/BERGERSRV
      /copy qcpysrc,prsmod000r


      // global variables
      // variables globales


      // Indicateurs


      // data-structures
      // structures de donnes
      // Indicateurs renomms avec Indara et INDDS


      // inherited variables
      // hritage des types
      /copy qcpysrc,INH32766


      // constants
      // constantes


       dcl-proc adresse_valide export;
       dcl-pi adresse_valide ind;
         p_adresse_mail like(r_adress_email) const;
       END-PI;


      // Local variables
      // variables locales
       dcl-s l_adresse_mail like(r_adress_email);
       dcl-s l_controle ind;
       dcl-s l_pos packed(3:0);
       dcl-s l_pos2 packed(3:0);
       dcl-s l_prefixe char(50);
       dcl-s l_suffixe char(50);
       dcl-s l_domaine char(50);
       dcl-s l_pays char(2);

       monitor;
         l_adresse_mail=p_adresse_mail;
         l_controle=*on;

         // découpage de l'adresse en 3 parties
         // - Préfixe
         // - domaine
         // - Pays
         l_pos=%scan('@':l_adresse_mail);
         if l_pos>0;
           l_prefixe=%subst(l_adresse_mail:1:l_pos-1);
           l_suffixe=%subst(l_adresse_mail:l_pos+1);
           l_pos2=%scan('.':l_suffixe);
           if l_pos>0;
             l_domaine=%subst(l_suffixe:1:l_pos2-1);
             l_pays=%subst(l_suffixe:l_pos2+1);
           endif;
         endif;
         if l_pos=0
         or l_pos2=0;
           l_controle=*off;
         ENDIF;

       on-error;
         dump(a);
         gest_erreur();
       endmon;
       return l_controle;

       end-proc adresse_valide;
