       //----------------------------------------------------------------
       // MODULE : UtiSqlUdf                      Créé le 23/03/2017
       // AUTEUR : P.Baulier                      Copyright C.I.Services
       //----------------------------------------------------------------
       // APPLICATION :  SQL UDF
       //----------------------------------------------------------------
       //  DESCRIPTION :
       //  Procedures des fonctions SQL definies par Ista
       //    IfNum retourne faux si la chaine n'est pas convertible en numérique
       //----------------------------------------------------------------
       //  MAINTENANCE :
       //  N°    AUTEUR                 OBJET                     DATE
       // ...  ...........  .................................  ../../....
       //----------------------------------------------------------------

       ctl-opt nomain;

       dcl-proc IfNum export;

       dcl-pi IfNum Packed(15:9);
         String char(500) const;
       end-pi;

       monitor;
         Return %Dec(%Trim(string): 15: 9);
       on-error;
         return 0;
       endmon;

       end-proc IfNum;
