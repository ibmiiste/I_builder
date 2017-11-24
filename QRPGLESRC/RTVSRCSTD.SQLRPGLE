       // --------------------------------------------------
       // Procedure name: source_standard
       // Purpose:        Récupére le chemnin du membre source de création ST...
       //                          RPREPRC en fonction du type de source et d...
       //                          u type d'objet
       // Returns:        '0' Si le source n'existe pas. '1' si le membre sou...
       //                          rce est trouvé.
       // Parameter:      P_Type_Source => Type de source
       // Parameter:      P_Type_Objet => Type de l'objet
       // Parameter:      P_Biblio_Src_PRE => Bibilothèque contenant le scrip...
       //                          t de création PREPRC Standard
       // Parameter:      P_Fichier_Src_PRE => Bibilothèque contenant le scri...
       //                          pt de création PREPRC Standard
       // Parameter:      P_Membre_Src_PRE => Bibilothèque contenant le scrip...
       //                          t de création PREPRC Standard
       // --------------------------------------------------
      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  OBJ(&LI/&OB);                                   */
      *     >>PARM<<  COMMIT(*NONE);                                  */
      *     >>PARM<<  OBJTYPE(*MODULE);                               */
      *     >>PARM<<  OPTION(*EVENTF);                                */
      *     >>PARM<<  RPGPPOPT(*LVL2);                                */
      *     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
      *     >>PARM<<  DATFMT(*ISO);                                   */
      *     >>PARM<<  TIMFMT(*ISO);                                   */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */
      /copy qcpysrc,cpyctlstm

       DCL-PROC source_standard export;
         DCL-PI *N IND;
           P_Type_Source LIKE(R_NomObj) CONST;
           P_Type_Objet LIKE(R_TypObj) CONST;
           P_Biblio_Src_PRE LIKE(R_NomObj);
           P_Fichier_Src_PRE LIKE(R_NomObj);
           P_Membre_Src_PRE LIKE(R_NomObj);
         END-PI ;

       // Héritage des variables
       /copy Qcpysrc,INH32766

         // Variables Standalone locales
         DCL-S Retour IND;
         // Your calculation code goes here
         EXEC SQL
           SELECT biblio_src_pre,
                  fichier_src_pre,
                  membre_src_pre
             INTO p_biblio_src_pre,
                  p_fichier_src_pre,
                  p_membre_src_pre
             FROM sources_pre_standard
             WHERE type_source = :p_type_source AND
                   type_objet = :p_type_objet;

         If sqlcode=0;
           Retour = *ON;
         Else;
           Retour = *off;
         EndIf;


         RETURN Retour ;

       END-proc ;

