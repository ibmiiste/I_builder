       //***************************************************************
       // MODULE : BBMOD020R                 Date Cration : 16/02/2016
       // AUTEUR    : O.DRUBIGNY               Copyright C.I.Services
       //----------------------------------------------------------------
       // APPLICATION :
       //  Gnral BESAIF
       //----------------------------------------------------------------
       //  DESCRIPTION :
       //  Procdure Format_date
       //  Formate la date selon le format demand de type date vers char
       //  Format pris en charge *EUR
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

      // dclaration des fichiers

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


       dcl-proc Format_date export;
       dcl-pi Format_date like(r_datechar);
         p_date date const;
         p_format char(5) const;
       END-PI;


      // Local variables
      // variables locales
       dcl-s l_jour packed(2:0);
       dcl-s l_mois packed(2:0);
       dcl-s l_annee packed(4:0);
       dcl-s l_date_formatee like(r_datechar);

       monitor;
         l_jour=%SUBDT(p_date:*days);
         l_mois=%SUBDT(p_date:*months);
         l_annee=%SUBDT(p_date:*years);

         Select;
           When %Subst(p_format:1:4)='*EUR';
             l_date_formatee = %EditC(l_jour:'X')
                             + %Subst(p_format:5:1)
                             + %EditC(l_mois:'X')
                             + %Subst(p_format:5:1)
                             + %EditC(l_annee:'X');
         ENDSL;
       on-error;
         dump(a);
         gest_erreur();
       endmon;
       return l_date_formatee;

       end-proc Format_date;

       // Dtermination du premier jour du mois
       dcl-proc premier_jour_mois export;
       dcl-pi premier_jour_mois date;
         p_date date const;
       END-PI;


      // Local variables
      // variables locales
       dcl-s l_date_1er_mois date;


       monitor;
         l_date_1er_mois=p_date - %days(
                              %subdt(p_date:*days)) + %days(1);

       on-error;
         dump(a);
         gest_erreur();
       endmon;
       return l_date_1er_mois;

       end-proc premier_jour_mois;

       // Dtermination du dernier jour du mois
       dcl-proc dernier_jour_mois export;
       dcl-pi dernier_jour_mois date;
         p_date date const;
       END-PI;


      // Local variables
      // variables locales
       dcl-s l_date_dern_mois date;


       monitor;
          l_date_dern_mois=p_date +%MONTHS(1) - %DAYS(
                               %SUBDT(p_date+%MONTHS(1):*DAYS));

       on-error;
         dump(a);
         gest_erreur();
       endmon;
       return l_date_dern_mois;

       end-proc dernier_jour_mois;
