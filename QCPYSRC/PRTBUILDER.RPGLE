       /If not defined(builder)
       // --------------------------------------------------
       // Prototype for procedure: builder
       // --------------------------------------------------
       DCL-PR builder EXTPGM('BUILDER');
         p_num_lot packed(6:0);
         P_Biblio_Lot LIKE(r_Nom_obj_IBMi) const;
         P_Env_Dest CHAR(1) const;
         P_Optim_Compil CHAR(20);
         P_Livr_Env_Dst IND const;
         P_Sys_Dst CHAR(32) const;
         P_User LIKE(r_Nom_obj_IBMi) const;
         P_Mot_De_Passe CHAR(10) const;
       END-PR ;
       /endif

       /If not defined(Livraison)
       //---------------------------------------------------
       // Préparation de la livraison
       //---------------------------------------------------
       Dcl-pr Livraison;
         p_Objet_qual char(20) Const;
         P_gestion_donnees Char(1) Const;
         p_Sys_Dst char(32) Const;
         P_User Char(10) Const;
         P_Mot_De_Passe Char(10) Const;
       End-Pr;
       /endif

       /If not defined(i_MrgMsgf)
       // --------------------------------------------------
       // Prototype for Programme:Envoi de message vers système distant
       // --------------------------------------------------
       Dcl-Pr i_MrgMsgf;
         P_Objet char(20) Const;
         P_BibSrc like(r_Nom_obj_IBMi) Const;
         P_MbrSrc like(r_Nom_obj_IBMi) Const;
         P_Sys_Dst CHAR(32) Const;
         P_User LIKE(r_Nom_obj_IBMi) Const;
         P_Mot_De_Passe CHAR(10) Const;
       End-Pr;
       /endif

       /If not defined(Cvthc)
       //---------------------------------------------------------
       // Convert Hex to Character
       dcl-pr cvthc extproc(*dclcase);
        *n pointer value; // receiver pointer
        *n pointer value; // source pointer
        *n int(10) value; // receiver length
       end-pr;
       /endif

       /If not defined(CVTCH)
       //---------------------------------------------------------
       // Convert Character to HEX
       dcl-pr cvtch extproc(*dclcase);
        *n pointer value; // receiver pointer
        *n pointer value; // source pointer
        *n int(10) value; // HexLen
       end-pr;
       /endif

       /If not defined(Construct)
       // --------------------------------------------------
       // Prototype for procedure: Construct
       // --------------------------------------------------
       DCL-PR Construct;
         P_PreBibSrc CHAR(10) CONST;
         P_PreFicSrc CHAR(10) CONST;
         P_UseSrcMbr CHAR(10) CONST;
         P_BibDst CHAR(10) CONST;
         P_ObjDst CHAR(10) CONST;
         P_TypObj char(7) CONST;
         P_BibSrc CHAR(10)  CONST;
         P_FicSrc CHAR(10)  CONST;
         P_MbrSrc CHAR(10) CONST;
         P_Optimize CHAR(20);
         P_Failed PACKED(10:0);
         P_FileAttach char(10000);
         P_liste_biblio Like(r_Nom_obj_IBMi);
       END-PR ;
       /Endif

       /If not defined(EnvRapMel)
       // --------------------------------------------------
       // Prototype for procedure: Envoi d'un mail avec des pièces attachées au
       //                          user du job
       // --------------------------------------------------
       DCL-PR EnvRapMel;
         P_FileAttach char(10000);
       END-PR ;
       /Endif

       /If not defined(gest_erreur)
       // Prototype de la gestion d'erreur
       dcl-pr gest_erreur end-pr;
       /Endif

       // --------------------------------------------------
       // Prototype for procedure: gestion_bib_lot
       // --------------------------------------------------
       DCL-PR gestion_bib_lot IND;
         p_Num_lot Like(r_Num_lot);
       END-PR ;

       //---------------------------------------------------
       // Prototype for procédure:Creation_Bib_lot
       //---------------------------------------------------
       DCL-PR Creabiblot;
         P_NOUVLOTC like(r_Num_lot_carac);
         p_LIBEL_lot Like(r_Lib_lot);
         p_BIB_LOT like(r_Nom_obj_IBMi);
       END-PR ;
