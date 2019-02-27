**FREE
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
       END-PR ;


       // --------------------------------------------------
       // Prototype for procedure: Lecture_curseur_list_obj
       // --------------------------------------------------
       DCL-PR Lecture_curseur_list_obj LIKE(sqlcode);
       END-PR ;


       // --------------------------------------------------
       // Procedure name: Copie_sources
       // Purpose:
       // Returns:
       // Parameter:      p_Num_lot
       // --------------------------------------------------
       DCL-PROC Copie_sources ;
         DCL-PI *N IND;
           p_Num_lot LIKE(r_Num_lot);
         END-PI ;
         // Variables locales
         Dcl-s l_num_lot Like(r_Num_lot);
         DCL-S retField IND;
         Dcl-s l_Biblio_Lot Like(r_Nom_obj_IBMi);

         // Your calculation code goes here
         l_Num_lot=p_Num_lot;

        l_Biblio_Lot= 'L' + E%ditc(l_Num_lot:'X');

        Ouvrir_curseur_list_obj();

         Lecture_curseur_list_obj();

         dow sqlcode = 0;

         Copie_source( l_Biblio_Lot
                      :l_Ficsrc
                      :l_Mbrsrc
                      :l_Bibsrc);


         Lecture_curseur_list_obj();

         enddo;

         return retField ;
       END-PROC ;

       // --------------------------------------------------
       // Procedure name: Ouvrir_curseur
       // Purpose:        Ouvrir le curseur de lecture de LSTOBJBLD
       // Returns:
       // --------------------------------------------------
       DCL-PROC Ouvrir_curseur_list_obj;
         DCL-PI *N LIKE(sqlcode);
         END-PI ;

         EXEC SQL
           CLOSE List_Obj;
         // positionnement en début de fichier
         EXEC SQL
           DECLARE List_Obj CURSOR FOR
             SELECT Lot_Number,
                    Bibliotheque_Source,
                    Fichier_Source,
                    Membre_Source,
                    Bibliotheque_Destination,
                    Objet_Destination,
                    Type_Objet,
                    Attribut_Objet
               FROM List_Objet_Build
               WHERE Lot_Number = :G_Num_Lot
               ORDER BY Ordre;

         EXEC SQL
           OPEN List_Obj;

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
           FETCH List_Obj
             INTO :G_Num_Lot , :G_Bibsrc, :G_Ficsrc, :G_Mbrsrc, :G_Bibdst, :G_Objdst, :G_Typobj,
               :G_Attribut_Objet;

         return Sqlcode ;
       END-PROC ;
