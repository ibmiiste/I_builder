**FREE
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OBJ(&LI/&OB);
//     >>PARM<<  OBJTYPE(*MODULE);
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  RPGPPOPT(*LVL2);
//     >>PARM<<  CLOSQLCSR(*ENDACTGRP);
//     >>PARM<<  DATFMT(*ISO);
//     >>PARM<<  TIMFMT(*ISO);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<

/copy qcpysrc,cpyctlstm
Ctl-opt bnddir('I_BUILDER');

//Héritage des classes de données

/copy Qcpysrc,Inhbuilder

// Procédure externe
/Copy Qcpysrc,Prtbuilder

// --------------------------------------------------
// Prototype for procedure: Ouvrir_curseur
// --------------------------------------------------
DCL-PR Ouvrir_curseur_list_obj LIKE(sqlcode);
  p_Num_lot Like(r_Num_lot);
  p_Objet_number Like(r_Auto_Number) Options(*Nopass);
END-PR ;


// --------------------------------------------------
// Prototype for procedure: Lecture_curseur_list_obj
// --------------------------------------------------
DCL-PR Lecture_curseur_list_obj LIKE(sqlcode);
  p_num_lot Like(r_Num_lot);
  p_BibSrc LIKE(r_Nom_obj_IBMi);
  p_FicSrc LIKE(r_Nom_obj_IBMi);
  p_MbrSrc LIKE(r_Nom_obj_IBMi);
  p_BibSrc_pre LIKE(r_Nom_obj_IBMi);
  p_FicSrc_pre LIKE(r_Nom_obj_IBMi);
  p_MbrSrc_pre LIKE(r_Nom_obj_IBMi);
  p_BibDst LIKE(r_Nom_obj_IBMi);
  p_ObjDst LIKE(r_Nom_obj_IBMi);
  p_TypObj like(r_Nom_obj_IBMi);
  p_attribut_objet like(r_Nom_obj_IBMi);
END-PR ;


// --------------------------------------------------
// Procedure name: Copie_sources
// Purpose:
// Returns:
// Parameter:      p_Num_lot
// --------------------------------------------------
DCL-PROC Copie_sources Export;
  DCL-PI *N IND;
    p_Num_lot LIKE(r_Num_lot);
    p_Objet_number Like(r_Auto_Number) Options(*Nopass);
  END-PI ;

  // Variables locales
  Dcl-s l_num_lot Like(r_Num_lot);
  DCL-S retField IND;
  Dcl-s l_Biblio_Lot Like(r_Nom_obj_IBMi);
  Dcl-S l_BibSrc LIKE(r_Nom_obj_IBMi);
  Dcl-S l_FicSrc LIKE(r_Nom_obj_IBMi);
  Dcl-S l_MbrSrc LIKE(r_Nom_obj_IBMi);
  Dcl-S l_BibSrc_pre LIKE(r_Nom_obj_IBMi);
  Dcl-S l_FicSrc_pre LIKE(r_Nom_obj_IBMi);
  Dcl-S l_MbrSrc_pre LIKE(r_Nom_obj_IBMi);
  Dcl-S l_BibDst LIKE(r_Nom_obj_IBMi);
  Dcl-S l_ObjDst LIKE(r_Nom_obj_IBMi);
  Dcl-S l_attribut_objet like(r_Nom_obj_IBMi);
  Dcl-S l_TypObj like(r_Nom_obj_IBMi);


  Monitor;
    l_Num_lot=p_Num_lot;

    l_Biblio_Lot= 'L' + %Editc(l_Num_lot:'X');

    If %Parms=2;
      Ouvrir_curseur_list_obj( l_Num_lot
                             :p_Objet_number);
    Else;
      Ouvrir_curseur_list_obj( l_Num_lot);
    ENDIF;

    Lecture_curseur_list_obj( l_num_lot
                             :l_BibSrc
                             :l_FicSrc
                             :l_MbrSrc
                             :l_BibSrc_pre
                             :l_FicSrc_pre
                             :l_MbrSrc_pre
                             :l_BibDst
                             :l_ObjDst
                             :l_TypObj
                             :l_attribut_objet);


    dow sqlcode = 0;

      Cpymbrsrc( l_Biblio_Lot
                :l_Ficsrc
                :l_Mbrsrc
                :l_Bibsrc
                :l_Ficsrc
                :l_Mbrsrc);


      Lecture_curseur_list_obj( l_num_lot
                               :l_BibSrc
                               :l_FicSrc
                               :l_MbrSrc
                               :l_BibSrc_pre
                               :l_FicSrc_pre
                               :l_MbrSrc_pre
                               :l_BibDst
                               :l_ObjDst
                               :l_TypObj
                               :l_attribut_objet);

    enddo;

    EXEC SQL
      CLOSE Csr_List_Obj;
  On-error;
    Dump(a);
    Gest_erreur();
  Endmon;
  return retField ;
END-PROC ;

// --------------------------------------------------
// Procedure name: Ouvrir_curseur
// Purpose:        Ouvrir le curseur de lecture de LSTOBJBLD
// Returns:
// --------------------------------------------------
DCL-PROC Ouvrir_curseur_list_obj;
  DCL-PI *N LIKE(sqlcode);
    p_num_lot Like(r_Num_lot);
    p_Objet_number Like(r_Auto_Number) Options(*Nopass);
  END-PI ;

  Dcl-s l_requete Char(1024);

  EXEC SQL
    CLOSE Csr_List_Obj;

  // positionnement en début de fichier
  l_Requete='SELECT Lot_Number, ' +
            'Bibliotheque_Source, ' +
            'Fichier_Source, ' +
            'Membre_Source, ' +
            'Bibliotheque_Destination, ' +
            'Objet_Destination, ' +
            'Type_Objet, ' +
            'Attribut_Objet ' +
       'FROM List_Objet_Build ' +
       'WHERE Lot_Number = ' + %Char(P_Num_Lot)
  ;

  If %Parms = 2;
    l_requete=l_requete + ' And OBJ_NUMBER = ' + %Char(p_Objet_number) +
                          ' ORDER BY Ordre;';
  Else;
    l_requete=l_requete + ' ORDER BY Ordre;';
  ENDIF;

  EXEC SQL
    PREPARE List_Obj FROM :L_Requete;

  EXEC SQL
    DECLARE Csr_List_Obj CURSOR FOR List_Obj;

  EXEC SQL
    OPEN Csr_List_Obj;

  return Sqlcode;
END-PROC ;

// --------------------------------------------------
// Procedure name: Lecture_curseur_list_obj
// Purpose:        Lecture du curseur d'un enregistrement de LSTOBJBLD
// Returns:
// --------------------------------------------------
DCL-PROC Lecture_curseur_list_obj ;
  DCL-PI *N LIKE(sqlcode);
    p_num_lot Like(r_Num_lot);
    p_BibSrc LIKE(r_Nom_obj_IBMi);
    p_FicSrc LIKE(r_Nom_obj_IBMi);
    p_MbrSrc LIKE(r_Nom_obj_IBMi);
    p_BibSrc_pre LIKE(r_Nom_obj_IBMi);
    p_FicSrc_pre LIKE(r_Nom_obj_IBMi);
    p_MbrSrc_pre LIKE(r_Nom_obj_IBMi);
    p_BibDst LIKE(r_Nom_obj_IBMi);
    p_ObjDst LIKE(r_Nom_obj_IBMi);
    p_TypObj like(r_Nom_obj_IBMi);
    p_attribut_objet like(r_Nom_obj_IBMi);
  END-PI ;


  EXEC SQL
    FETCH Csr_List_Obj
      INTO :P_Num_Lot,
           :P_Bibsrc,
           :P_Ficsrc,
           :P_Mbrsrc,
           :P_Bibdst,
           :P_Objdst,
           :P_Typobj,
           :P_Attribut_Objet;

  return Sqlcode ;
END-PROC ;
