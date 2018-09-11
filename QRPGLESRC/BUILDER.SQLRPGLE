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

       //Option de contrôle du programme
       /copy qcpysrc,cpyctlstm
       Ctl-opt bnddir('I_BUILDER');

       //Héritage des classes de données
       /copy qcpysrc,Inh32766
       /copy Qcpysrc,Inhbuilder

       /Copy Qcpysrc,Prtbuilder

       DCL-PI builder;
         p_num_lot Like(r_Num_lot);
         P_Biblio_Lot LIKE(R_NomObj) const;
         P_Env_Dest CHAR(1) const;
         P_Optim_Compil CHAR(20);
         P_Livr_Env_Dst IND const;
         P_Sys_Dst CHAR(32) const;
         P_User LIKE(R_nomobj) const;
         P_Mot_De_Passe CHAR(10) const;
       END-PI ;


       Dcl-S g_rowid_char Char(100);
       Dcl-s g_Rowid_lots SQLTYPE(ROWID);

       Dcl-S g_BibSrc LIKE(R_NomObj);
       Dcl-S g_FicSrc LIKE(R_NomObj);
       Dcl-S g_MbrSrc LIKE(R_NomObj);
       Dcl-S g_BibSrc_pre LIKE(R_NomObj);
       Dcl-S g_FicSrc_pre LIKE(R_NomObj);
       Dcl-S g_MbrSrc_pre LIKE(R_NomObj);
       Dcl-S g_BibDst LIKE(R_NomObj);
       Dcl-S g_ObjDst LIKE(R_NomObj);
       Dcl-S g_Failed packed(10:0);
       Dcl-S g_TypObj like(R_NomObj);
       Dcl-S g_FileAttach char(10000);
       Dcl-S g_optimize char(20);
       Dcl-s g_option_donnees Char(1);
       Dcl-s g_list_biblio Char(10);
       Dcl-s g_num_lot Like(r_Num_lot);

       // --------------------------------------------------
       // Prototype for procedure: Ouvrir_curseur
       // --------------------------------------------------
       DCL-PR Ouvrir_curseur_list_obj LIKE(sqlcode);
       END-PR ;


       // --------------------------------------------------
       // Prototype for procedure: Lecture_curseur_list_obj
       // --------------------------------------------------
       DCL-PR Lecture_curseur_list_obj LIKE(sqlcode);
       END-PR ;


         *InLr=*On;
         g_Num_lot=p_Num_lot;

         //Récupération de la list de bibliothèque
         EXEC SQL
           SELECT liste_biblio_projet
             INTO :g_list_biblio
             FROM lots
             WHERE lot_number = :g_num_lot ;

         Ouvrir_curseur_list_obj();

         Lecture_curseur_list_obj();

         dow sqlcode = 0;
           If g_typobj<>'*MSGF';
             g_optimize='*NONE';
             g_BIBSRC_pre=g_BIBSRC;
             g_FicSrc_pre=g_FicSrc;
             g_MbrSrc_pre=g_MbrSrc;
             Construct( g_BIBSRC_pre
                       :g_FicSrc_pre
                       :g_MbrSrc_pre
                       :g_BibDst
                       :g_ObjDst
                       :g_typobj
                       :g_BibSrc
                       :g_FicSrc
                       :g_MbrSrc
                       :g_optimize
                       :g_Failed
                       :g_FileAttach
                       :g_list_biblio);
           Else;
             i_MrgMsgf( g_ObjDst + g_BibDst
                       :g_BibSrc
                       :g_MbrSrc
                       :P_Sys_Dst
                       :P_User
                       :P_Mot_De_Passe);
           EndIf;



           Lecture_curseur_list_obj();

         enddo;

         if P_Livr_Env_Dst=*on;

           Ouvrir_curseur_list_obj();

           Lecture_curseur_list_obj();


           dow sqlcode = 0;

             If g_typobj='*MSGF';
               i_MrgMsgf( g_ObjDst + g_BibDst
                         :g_BibSrc
                         :g_MbrSrc
                         :P_Sys_Dst
                         :P_User
                         :P_Mot_De_Passe);
             Else;
               IF g_typobj='PF';
                 g_option_donnees ='C';
               Else;
                 g_option_donnees ='';
               EndIf;
               Livraison ( g_ObjDst + g_BibDst
                          :g_option_donnees
                          :P_Sys_Dst
                          :P_User
                          :P_Mot_De_Passe);
             ENDIF;
           EndIf;

           Lecture_curseur_list_obj();
         Enddo;

         if g_Failed<>0;
           EnvRapMel(g_FileAttach);
         EndIf;

         Return;



       // --------------------------------------------------
       // Procedure name: Ouvrir_curseur
       // Purpose:        Ouvrir le curseur de lecture de LSTOBJBLD
       // Returns:
       // --------------------------------------------------
       DCL-PROC Ouvrir_curseur_list_obj;
         DCL-PI *N LIKE(sqlcode);
         END-PI ;

         EXEC SQL CLOSE list_obj;
         // positionnement en début de fichier
         EXEC SQL
           DECLARE list_obj CURSOR FOR
             SELECT lot_number,
                    bibliotheque_source,
                    fichier_source,
                    membre_source,
                    bibliotheque_destination,
                    objet_destination,
                    type_objet
               FROM list_objet_build
               WHERE lot_number = :g_num_lot
               ORDER BY ordre;

         exec sql open list_obj;

         return Sqlcode;
       END-PROC ;

       // --------------------------------------------------
       // Procedure name: Lecture_curseur_list_obj
       // Purpose:        Lecture du curseur d'un enregistrement de LSTOBJBLD
       // Returns:
       // --------------------------------------------------
       DCL-PROC Lecture_curseur_list_obj ;
         DCL-PI *N LIKE(sqlcode);
         END-PI ;


         EXEC SQL
           FETCH list_obj
             INTO :g_num_lot , :g_bibsrc, :g_ficsrc, :g_mbrsrc, :g_bibdst,
               :g_objdst, :g_typobj ;

         return Sqlcode ;
       END-PROC ;

