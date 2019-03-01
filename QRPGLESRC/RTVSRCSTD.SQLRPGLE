**FREE
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
// >>PRE-COMPILER<<                                              */
//   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
//   >>IMPORTANT<<                                               */
//     >>PARM<<  OBJ(&LI/&OB);                                   */
//     >>PARM<<  COMMIT(*NONE);                                  */
//     >>PARM<<  OBJTYPE(*MODULE);                               */
//     >>PARM<<  OPTION(*EVENTF);                                */
//     >>PARM<<  RPGPPOPT(*LVL2);                                */
//     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
//     >>PARM<<  DATFMT(*ISO);                                   */
//     >>PARM<<  TIMFMT(*ISO);                                   */
//     >>PARM<<  COMPILEOPT(&U0);                                */
//   >>END-IMPORTANT<<                                           */
//   >>EXECUTE<<                                                 */
// >>END-PRE-COMPILER<<                                          */
/copy qcpysrc,cpyctlstm

DCL-PROC source_standard export;
  DCL-PI *N IND;
    P_Type_Objet LIKE(r_Nom_obj_IBMi) CONST;
    P_Type_Source LIKE(r_Nom_obj_IBMi) CONST;
    P_Biblio_Src_PRE LIKE(r_Nom_obj_IBMi);
    P_Fichier_Src_PRE LIKE(r_Nom_obj_IBMi);
    P_Membre_Src_PRE LIKE(r_Nom_obj_IBMi);
  END-PI ;

  // Héritage des variables
  /copy Qcpysrc,Inhbuilder

  // Sous-procédures externe
  /copy Qcpysrc,prtbuilder

  // Variables Standalone locales
  DCL-S Retour IND;

  Monitor;
    EXEC SQL
      SELECT Biblio_Src_Pre,
             Fichier_Src_Pre,
             Membre_Src_Pre
        INTO :P_Biblio_Src_Pre,
             :P_Fichier_Src_Pre,
             :P_Membre_Src_Pre
        FROM Sources_Pre_Standard
        WHERE Type_Source = :P_Type_Source
              AND Type_Objet = :P_Type_Objet;

    If sqlcode=0;
      Retour = *ON;
    Else;
      Retour = *off;
    EndIf;

  On-error;
    Retour = *off;
    Dump(a);
    Gest_erreur();
  Endmon;

  RETURN Retour ;

END-proc ;

