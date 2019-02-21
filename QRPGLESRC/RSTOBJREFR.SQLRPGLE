**FREE
//Option de contrôle du programme
/copy qcpysrc,cpyctlstm
Ctl-opt bnddir('I_BUILDER');

// --------------------------------------------------
// Procedure name: Restauration_bib_ref
// Purpose:        Restauration des sources dans les bib de références...
//                           et compilation
// Returns:
// Parameter:      p_num_lot => Numéro du lot à traiter
// --------------------------------------------------
DCL-PROC Restauration_bib_ref Export;
  DCL-PI *N IND;
    p_num_lot LIKE(r_num_lot) VALUE;
  END-PI ;
  // Variables locales
  DCL-S retField IND;

  // Déclaration du curseur qui va lire la liste des sources
  Dcl-s l_Bibsrc Like(r_Nom_obj_IBMi);
  Dcl-s l_Ficsrc Like(r_Nom_obj_IBMi);
  Dcl-s l_Mbrsrc Like(r_Nom_obj_IBMi);
  Dcl-s l_Num_lot like(r_Num_lot);

  Monitor;
    l_Num_lot=p_Num_lot;

    EXEC SQL
      CLOSE Csr_Obj_Sav;

    EXEC SQL
      DECLARE Csr_Obj_Sav CURSOR FOR
        SELECT Bibliotheque_source,
               Fichier_source,
               Membre_source
          FROM List_Objet_Build
          WHERE Lot_Number = :L_Num_Lot
          ORDER BY Ordre;

    EXEC SQL
      OPEN Csr_Obj_Sav;

    // Lecture des objets du lot à livrer
    EXEC SQL
      FETCH Csr_Obj_Sav INTO :l_Bibsrc, :l_Ficsrc, :l_Mbrsrc;
    Dow Sqlcode=c_Trouve;

      g_Nom_objet=L_Objdst;
      g_Type_objet=L_Typobj;
      g_Nombre_valeur_Objet+=1;

      g_Objet_desc+=%Size(DS_Object_Desc);


      EXEC SQL
        FETCH Csr_Obj_Sav INTO :l_Bibsrc, :l_Ficsrc, :l_Mbrsrc;
    Enddo;


    EXEC SQL CLOSE Csr_Obj_Sav;
  On-error;
    Dump(a);
    Gest_erreur();
  Endmon;

  return retField ;
END-PROC ;

