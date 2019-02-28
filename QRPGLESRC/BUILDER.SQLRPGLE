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

       /copy Qcpysrc,Inhbuilder

       // Procédure externe
       /Copy Qcpysrc,Prtbuilder

       // --------------------------------------------------
       // Prototype for Programme:Envoi de message vers système distant
       // --------------------------------------------------
       Dcl-Pr i_MrgMsgf Extpgm('I_MRGMSGF');
         P_Objet char(20) Const;
         P_BibSrc like(r_Nom_obj_IBMi) Const;
         P_MbrSrc like(r_Nom_obj_IBMi) Const;
         P_Sys_Dst CHAR(32) Const;
         P_User LIKE(r_Nom_obj_IBMi) Const;
         P_Mot_De_Passe CHAR(10) Const;
       End-Pr;

       DCL-PI builder;
         p_num_lot Like(r_Num_lot);
         P_Biblio_Lot LIKE(r_Nom_obj_IBMi) const;
         P_Env_Dest CHAR(1) const;
         P_Optim_Compil CHAR(20);
         P_Livr_Env_Dst IND const;
         P_Sys_Dst CHAR(32) const;
         P_User LIKE(r_Nom_obj_IBMi) const;
         P_Mot_De_Passe CHAR(10) const;
       END-PI ;


       Dcl-S g_rowid_char Char(100);
       Dcl-s g_Rowid_lots SQLTYPE(ROWID);

       Dcl-S g_BibSrc LIKE(r_Nom_obj_IBMi);
       Dcl-S g_FicSrc LIKE(r_Nom_obj_IBMi);
       Dcl-S g_MbrSrc LIKE(r_Nom_obj_IBMi);
       Dcl-S g_BibSrc_pre LIKE(r_Nom_obj_IBMi);
       Dcl-S g_FicSrc_pre LIKE(r_Nom_obj_IBMi);
       Dcl-S g_MbrSrc_pre LIKE(r_Nom_obj_IBMi);
       Dcl-S g_BibDst LIKE(r_Nom_obj_IBMi);
       Dcl-S g_ObjDst LIKE(r_Nom_obj_IBMi);
       Dcl-S g_Failed packed(10:0);
       Dcl-S g_TypObj like(r_Nom_obj_IBMi);
       Dcl-S g_attribut_objet like(r_Nom_obj_IBMi);
       Dcl-S g_FileAttach char(10000);
       Dcl-S g_optimize char(20);
       Dcl-s g_option_donnees Char(1);
       Dcl-s g_list_biblio Char(10);
       Dcl-s g_num_lot Like(r_Num_lot);
       Dcl-s g_cmd like(r_commande_CLLE);

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

         Construction( p_num_lot
                      :P_Biblio_Lot
                      :P_Optim_Compil);

         if g_Failed<>0;
           EnvRapMel( p_num_lot
                     :P_Biblio_Lot
                     :P_Env_Dest
                     :P_Optim_Compil);
         Else;
           If P_Livr_Env_Dst;
             Livraison( g_num_lot
                       :P_Sys_Dst
                       :P_User
                       :P_Mot_De_Passe);
           Endif;
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
                    type_objet,
                    attribut_objet
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
               :g_objdst, :g_typobj, :g_attribut_objet;

         return Sqlcode ;
       END-PROC ;



       // --------------------------------------------------
       // Procedure name: Construction_lot
       // Purpose:
       // Returns:
       // --------------------------------------------------
       DCL-PROC Construction;
         Dcl-pi Construction;
           p_num_lot Like(r_Num_lot);
           P_Biblio_Lot LIKE(r_Nom_obj_IBMi) const;
           P_Optim_Compil CHAR(20);
         End-pi;

         Ouvrir_curseur_list_obj();

         Lecture_curseur_list_obj();

         dow sqlcode = 0;
           If g_typobj<>'*MSGF';
             If g_attribut_objet='PF';
               g_option_donnees ='C';
             Else;
               g_option_donnees ='';
             EndIf;
             g_optimize=P_Optim_Compil;
             If P_Biblio_Lot<>*Blank;
               g_BIBSRC_pre=P_Biblio_Lot;
               g_BibSrc=P_Biblio_Lot;
               g_BibDst =P_Biblio_Lot;
             Else;
               g_BIBSRC_pre=g_BIBSRC;
             Endif;
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
                       :g_list_biblio
                       :g_option_donnees);
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

         return ;
       END-PROC ;

