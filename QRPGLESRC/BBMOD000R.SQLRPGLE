       //***************************************************************
       // MODULE : BBMOD000R                 Date Cration : 09/02/2016
       // AUTEUR    : O.DRUBIGNY               Copyright C.I.Services
       //----------------------------------------------------------------
       // APPLICATION :
       //  Général BESAIF
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
       // >>PRE-COMPILER<<                                              */
       //   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
       //   >>IMPORTANT<<                                               */
       //     >>PARM<<  OBJ(&LI/&OB);                                   */
       //     >>PARM<<  OBJTYPE(*MODULE);                               */
       //     >>PARM<<  OPTION(*EVENTF);                                */
       //     >>PARM<<  RPGPPOPT(*LVL2);                                */
       //     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
       //     >>PARM<<  DATFMT(*ISO);                                   */
       //     >>PARM<<  TIMFMT(*ISO);                                   */
       //   >>END-IMPORTANT<<                                           */
       //   >>EXECUTE<<                                                 */
       // >>END-PRE-COMPILER<<                                          */
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
       /copy qcpysrc,Prtbuilder

       // global variables
       // variables globales

       // Indicateurs

       // data-structures
       // structures de donnes


       // inherited variables
       // héritage des types
       /copy qcpysrc,INH32766
       /copy Qcpysrc,Inhbuilder
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



       // --------------------------------------------------
       // Procedure name: infos_objet
       // Purpose:        Récupérer les informations relatives à un objet comme pdm
       // Returns:
       // Parameter:      p_Object_name => Object name + Library name
       // Parameter:      p_Object_type => Object type
       // --------------------------------------------------
       DCL-PROC infos_objet Export;
         DCL-PI *N IND;
           Obj LIKE(r_qualified_name) CONST;
           ObjType LIKE(r_Nom_obj_IBMi) CONST;
           p_Base_infos_obj_light likeDS(OBJD0200_t);
         END-PI ;

         DCL-S retField IND;
         Dcl-s ObjL char(20);
         Dcl-ds Objd likeDS(OBJD0200_t);
         Dcl-ds ErrDS likeDS(ERRAPI);

         monitor;
           ObjL = Obj;
           if %Subst( ObjL : 11 : 10) = *BLANK;
             %Subst( ObjL : 11 : 10) = '*LIBL';
           endif;
           RtvObj( Objd : %len(ObjD) : 'OBJD0200' : Objl : ObjType : ErrDS);
           if ErrDS.ErrRtn > 0;
             retField=*OFF;
           endif;
           retField=*ON;
         on-error;
           dump(a);
           gest_erreur();
           retField=*off;
         endmon;

         p_Base_infos_obj_light=Objd;
         return retField ;
       END-PROC ;
