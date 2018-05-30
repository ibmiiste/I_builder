       //***************************************************************
       // MODULE : BBMOD000R                 Date Cration : 09/02/2016
       // AUTEUR    : O.DRUBIGNY               Copyright C.I.Services
       //----------------------------------------------------------------
       // APPLICATION :
       //  Gnral BESAIF
       //----------------------------------------------------------------
       //  DESCRIPTION :
       //  La procdure Exists vrifie l'existence d'un objet
       //  Elle renvoie la valeur boolenne 1 si l'objet existe
       //  et 0 si l'objet n'existe pas
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
       // Prototype des modules centraliss programmes de services BERGER/BERGERSRV
      /copy qcpysrc,prsmod000r

      // global variables
      // variables globales

      // Indicateurs

      // data-structures
      // structures de donnes


      // inherited variables
      // hritage des types
      /copy qcpysrc,INH32766

      // constants
      // constantes

      //====================================================================
      // Test existence objet
      //====================================================================
       dcl-proc Exists export;
       dcl-pi Exists ind;
         Obj char(20) CONST;
         ObjType char(10) CONST;
       end-pi;

       Dcl-s ObjL char(20);
       Dcl-ds Objd likeDS(OBJD0100_t);
       Dcl-ds ErrDS likeDS(ERRAPI);

       monitor;
       ObjL = Obj;
       if %Subst( ObjL : 11 : 10) = *BLANK;
         %Subst( ObjL : 11 : 10) = '*LIBL';
       endif;
       RtvObj( Objd : %len(ObjD) : 'OBJD0100' : Objl : ObjType : ErrDS);
       if ErrDS.ErrRtn > 0;
          return *OFF;
       endif;
       return *ON;
       on-error;
         dump(a);
         gest_erreur();
         return *off;
       endmon;
       end-proc Exists;
