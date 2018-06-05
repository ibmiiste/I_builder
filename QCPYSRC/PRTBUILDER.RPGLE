       /If defined(builder)
       // --------------------------------------------------
       // Prototype for procedure: builder
       // --------------------------------------------------
       DCL-PR builder EXTPGM('BUILDER');
         P_Projet LIKE(R_NomObj) const;
         P_Biblio_Lot LIKE(R_NomObj) const;
         P_Env_Dest CHAR(1) const;
         P_Optim_Compil CHAR(20);
         P_Livr_Env_Dst IND const;
         P_Sys_Dst CHAR(32) const;
         P_User LIKE(R_NomObj) const;
         P_Mot_De_Passe CHAR(10) const;
       END-PR ;
       /endif

       /If defined(Livraison)
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

       /If defined(i_MrgMsgf)
       // --------------------------------------------------
       // Prototype for Programme:Envoi de message vers système distant
       // --------------------------------------------------
       Dcl-Pr i_MrgMsgf;
         P_Objet char(20) Const;
         P_BibSrc like(R_NomObj) Const;
         P_MbrSrc like(R_NomObj) Const;
         P_Sys_Dst CHAR(32) Const;
         P_User LIKE(R_NomObj) Const;
         P_Mot_De_Passe CHAR(10) Const;
       End-Pr;
       /endif

       /If defined(Cvthc)
       //---------------------------------------------------------
       // Convert Hex to Character
       dcl-pr cvthc extproc(*dclcase);
        *n pointer value; // receiver pointer
        *n pointer value; // source pointer
        *n int(10) value; // receiver length
       end-pr;
       /endif
