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

       //Option de contrôle du programme
       /copy qcpysrc,cpyctlstm

       /copy qcpysrc,UtiProc

       /copy qcpysrc,Inh32766

       // --------------------------------------------------
       // Prototype for procedure: builder
       // --------------------------------------------------
       DCL-PR builder EXTPGM('BUILDER');
         P_Projet LIKE(R_NomObj);
         P_Biblio_Lot LIKE(R_NomObj);
         P_Env_Dest CHAR(1);
         P_Optim_Compil CHAR(20);
         P_Livr_Env_Dst IND;
         P_Sys_Dst CHAR(32);
         P_User LIKE(R_NomObj);
         P_Mot_De_Passe CHAR(10);
       END-PR ;

       DCL-PI builder;
         P_Projet LIKE(R_NomObj);
         P_Biblio_Lot LIKE(R_NomObj);
         P_Env_Dest CHAR(1);
         P_Optim_Compil CHAR(20);
         P_Livr_Env_Dst IND;
         P_Sys_Dst CHAR(32);
         P_User LIKE(R_NomObj);
         P_Mot_De_Passe CHAR(10);
       END-PI ;

       Dcl-S g_BibSrc LIKE(R_NomObj);
       Dcl-S g_FicSrc LIKE(R_NomObj);
       Dcl-S g_MbrSrc LIKE(R_NomObj);
       Dcl-S g_BibDst LIKE(R_NomObj);
       Dcl-S g_ObjDst LIKE(R_NomObj);
       Dcl-S g_Failed packed(10:0);
       Dcl-S g_TypObj like(R_TypObj);
       Dcl-S g_FileAttach char(10000);

         *InLr=*On;

         exec sql close list_obj;
         // positionnement en début de fichier
         EXEC SQL
           DECLARE list_obj CURSOR FOR
             SELECT projet,
                    bibliotheque_source,
                    fichier_source,
                    membre_source,
                    bibliotheque_destination,
                    objet_destination,
                    type_objet
               FROM list_objet_build
               WHERE projet = :p_projet
               ORDER BY ordre;

         exec sql open list_obj;

         EXEC SQL
           FETCH list_obj
             INTO :p_projet, :g_bibsrc, :g_ficsrc, :g_mbrsrc, :g_bibdst,
               :g_objdst, :g_typobj ;


         dow sqlcode = 0;
           If g_typobj<>'*MSGF';
             Construct( g_BibSrc
                       :g_FicSrc
                       :g_MbrSrc
                       :g_BibDst
                       :g_ObjDst
                       :g_BibSrc
                       :g_FicSrc
                       :g_MbrSrc
                       :P_Optim_Compil
                       :g_Failed);
           Else;
             callp i_MrgMsgf( g_ObjDst + g_BibDst
                             :g_MbrSrc
                             :P_Sys_Dst
                             :P_User
                             :P_Mot_De_Passe);
           EndIf;


           if P_Livr_Env_Dst=*on;
             If g_typobj='*MSGF';
               callp i_MrgMsgf( g_ObjDst + g_BibDst
                               :g_BibSrc
                               :g_MbrSrc
                               :P_Sys_Dst
                               :P_User
                               :P_Mot_De_Passe);
             Else;
               callp i_push( g_ObjDst + g_BibDst
                            :P_Sys_Dst
                            :P_User
                            :P_Mot_De_Passe);
             ENDIF;
           EndIf;

           EXEC SQL
             FETCH list_obj
               INTO :p_projet, :g_bibsrc, :g_ficsrc, :g_mbrsrc, :g_bibdst,
                 :g_objdst, :g_typobj ;
         enddo;

         if g_Failed<>0;
           EnvRapMel(g_FileAttach);
         EndIf;

         Return;
