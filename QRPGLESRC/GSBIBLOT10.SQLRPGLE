**FREE
// --------------------------------------------------
// Procedure name: gestion_bib_lot
// Purpose:        Créé une bibliothèque où travaillé le lot.
// Returns:        Indication de bonne exécution '0' si anomalie '1' s...
//                          i OK.
// Parameter:      l_Num_lot => Numéro du lot concerné par la création...
//                           de la bibliothèque
// Parameter:      p_Libel_lot => Titre du lot qui servira de descript...
//                          ion à la bibliothèque créée
// --------------------------------------------------
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
//     >>PARM<<  COMMIT(*NONE);                                  */
//     >>PARM<<  COMPILEOPT(&U0);                                */
//   >>END-IMPORTANT<<                                           */
// >>EXECUTE<<                                                   */
// >>END-PRE-COMPILER<<                                          */

/copy qcpysrc,cpyctlstm
Ctl-opt bnddir('I_BUILDER');

/Copy Qcpysrc,Inhbuilder

// Prototype des procédures externes
/copy qcpysrc,Prtbuilder



DCL-PROC gestion_bib_lot EXPORT;

  DCL-PI *N IND;
    p_Num_lot Like(r_Num_lot) value;
  END-PI ;

  Dcl-s l_libel_lot Like(r_Lib_lot);
  Dcl-s l_Num_lot_carac Like(r_Num_lot_carac);
  Dcl-s l_nom_bib_lot like(r_Nom_obj_IBMi);
  DCL-S retField IND Inz(*On);
  Dcl-s l_Lettre_prefix like(r_Prefix) Inz('L');

  Monitor;
    EXEC SQL
      SELECT Libelle_Lots
        INTO :L_Libel_Lot
        FROM Lots
        WHERE Lot_Number = :P_Num_Lot;

    If sqlcode<>0;
      Retfield=*off;
      Return Retfield;
    EndIf;

    l_Num_lot_carac=%Editc(p_num_lot:'X');

    Crtbibbld(l_Num_lot_carac:l_libel_lot:l_Nom_bib_lot:l_Lettre_prefix);

    If Retfield=*Off;
      Return Retfield;
    EndIf;

    EXEC SQL
      UPDATE Lots
        SET Biblio_Lot = :L_Nom_Bib_Lot
        WHERE Lot_Number = :P_Num_Lot;

    If sqlcode<>0;
      Retfield=*off;
      Return Retfield;
    EndIf;

  On-error;
    Retfield=*Off;
    Dump(a);
    Gest_erreur();
  Endmon;

  RETURN retfield ;
END-PROC ;



// --------------------------------------------------
// Procedure name: miseEnLigneListeBibsLot
// Purpose:        Mise en ligne de la liste de bibliothèque du lot
// Returns:
// Parameter:      P_Numero_Lot => Numéro de lot de développement
// --------------------------------------------------
Dcl-Proc miseEnLigneListeBibsLot EXPORT;
  Dcl-Pi *N IND;
    P_Numero_Lot LIKE(r_Num_lot);
  End-Pi;

  // Proptotype programme Externe
  Dcl-pr miseEnLigneListeBibs Extpgm('POSLSTLIB');
    p_Save_or_restore Char(4);
    p_Nom_liste Char(10);
    p_Bibliotheque Char(10);
    p_Current_Library Char(4);
  END-PR;

  // Local fields
  Dcl-S l_Code_Retour IND Inz(*On);
  Dcl-S l_Liste_Biblio_Projet Char(10);


  Dcl-s l_save_or_restore Char(4) Inz('*RST');
  Dcl-s l_current_library Char(4) Inz('*NO');
  Dcl-s l_bibliotheque  Char(10) Inz('*NONE');

  // Calculation specifications
  // Récupération du nom de la liste de bibliothèque du lot
  Monitor;
    EXEC SQL
      SELECT Liste_Biblio_Projet
        INTO :L_Liste_Biblio_Projet
        FROM Lots
        WHERE Lot_Number = :P_Numero_Lot;

    If sqlcode<>0;
      l_Code_Retour=*off;
    Else;
      // S'il y a un nom de liste de bibliothèque dans ce lot, on la met en ligne
      miseEnLigneListeBibs( l_save_or_restore
                           :L_Liste_Biblio_Projet
                           :l_bibliotheque
                           :l_current_library);
    EndIf;

  On-error;
    l_Code_Retour=*off;
  ENdmon;

  return l_Code_Retour;
End-Proc;

