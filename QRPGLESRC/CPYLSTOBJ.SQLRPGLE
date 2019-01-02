       // --------------------------------------------------
       // Procedure name: Copie_liste_objet_a_livres
       // Purpose:        Liste dans une table les objets à livrer avec les e...
       //                          mplacements où les envoyés
       // Returns:
       // Parameter:      p_Numero_lot => Numéro de lot
       // --------------------------------------------------
       DCL-PROC Copie_liste_objet_a_livres ;
         DCL-PI *N;
           p_Numero_lot LIKE(r_Numlot);
         END-PI ;

         Dcl-s l_requete_sql Char(1024);


         l_requete_sql='Create Table L' + %editc(p_Numero_lot:'X') +
            '.list_obj as Select * from list_objet_build Where' +
            ' LOT_NUMBER = ' + %Char(p_Numero_lot) +
            ') With data';

         EXEC SQL
           EXECUTE IMMEDIATE :l_requete_sql;


         return ;
       END-PROC ;
