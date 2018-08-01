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

         Monitor;
           EXEC SQL SELECT libelle_lots
                      INTO :l_libel_lot
                      FROM lots
                     WHERE lot_number=:p_num_lot;

           If sqlcode<>0;
             Retfield=*off;
             Return Retfield;
           EndIf;

           l_Num_lot_carac=%Editc(p_num_lot:'X');

           Creabiblot(l_Num_lot_carac:l_libel_lot:l_Nom_bib_lot);

           If Retfield=*Off;
             Return Retfield;
           EndIf;

           EXEC SQL UPDATE lots
                       SET biblio_lot=:l_nom_bib_lot
                     WHERE lot_number=:p_num_lot;

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
