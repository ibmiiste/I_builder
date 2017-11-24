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
         P_Optim_Compil CHAR(6);
         P_Livr_Env_Dst IND;
         P_Sys_Dst CHAR(32);
         P_User LIKE(R_NomObj);
         P_Mot_De_Passe CHAR(10);
       END-PR ;

       DCL-PI builder;
         P_Projet LIKE(R_NomObj);
         P_Biblio_Lot LIKE(R_NomObj);
         P_Env_Dest CHAR(1);
         P_Optim_Compil CHAR(6);
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

         *InLr=*Off;

         exec sql close list_obj;
         // positionnement en début de fichier
         exec sql declare list_obj cursor for
                    select Projet,
                           Bibliotheque_Source,
                           Fichier_Source,
                           Membre_Source,
                           Bibliotheque_Destination,
                           Objet_Destination,
                           Type_objet
                      from LIST_OBJET_BUILD
                     where Projet=:P_Projet
                  order by ordre;

         exec sql open list_obj;

         exec sql fetch list_obj
                    into :P_projet,
                         :g_BibSrc,
                         :g_FicSrc,
                         :g_MbrSrc,
                         :g_BibDst,
                         :g_ObjDst,
                         :g_typobj
                         ;


         dow sqlcode<>100;
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

           exec sql fetch list_obj
                     into :P_projet,
                          :g_BibSrc,
                          :g_FicSrc,
                          :g_MbrSrc,
                          :g_BibDst,
                          :g_ObjDst,
                          :g_typobj
                          ;
         enddo;

