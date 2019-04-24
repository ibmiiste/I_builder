**FREE

       // --------------------------------------------------
       // Procedure name: Retrieve_default_value
       // Purpose:        Lit la valeur d'un paramètre par défaut de la table...
       //                          parametres
       // Returns:
       // Parameter:      p_cod_parameter => Code paramètre
       // Parameter:      p_Libel_parameter => Libellé du paramètre
       // --------------------------------------------------
       DCL-PROC Retrieve_default_value ;
         DCL-PI *N LIKE(r_value_parameter);
           p_Cod_parameter LIKE(r_cod_parameter) CONST;
           p_Libel_parameter LIKE(r_Libel_parameter) OPTIONS(*NOPASS);
         END-PI ;

         Dcl-s l_value_parameter LIKE(r_value_parameter);
         Dcl-s l_Libel_parameter LIKE(r_Libel_parameter);
         DCL-S retField LIKE(r_value_parameter);

         EXEC SQL
           SET OPTION COMMIT = *NONE;

         EXEC SQL
           SELECT Libelle_Parametre,
                  Valeur_Parametre
             INTO :L_Libel_Parameter,
                  :L_Libel_Parameter
             FROM Parametres
             WHERE Code_Parametre = :P_Cod_Parameter ;

         RETURN Retfield ;

       END-PROC ;

