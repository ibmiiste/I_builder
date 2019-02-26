**FREE
// Spécification de contrôles
/Copy Qcpysrc,Cpyctlstm
// --------------------------------------------------
// Procedure name: Copie_liste_objet_a_livres
// Purpose:        Liste dans une table les objets à livrer avec les e...
//                          mplacements où les envoyés
// Returns:
// Parameter:      p_Numero_lot => Numéro de lot
// --------------------------------------------------
DCL-PROC Copie_liste_objet_a_livres Export;
DCL-PI *N;
  p_Numero_lot LIKE(r_Num_lot);
END-PI ;


// External subprocedures prototypes globales
// prototype sous-procédures externes
/Copy Qcpysrc,Prtbuilder


// inherited variables
// héritage des types
/copy Qcpysrc,INHBuilder


Dcl-s l_requete_sql Char(1024);


l_requete_sql='Create Table L' + %editc(p_Numero_lot:'X') +
              '.O' +  %editc(p_Numero_lot:'X') +
              ' as ( Select a.*, ' +
                           'b.LISTE_BIBLIO_PROJET ' +
                      'From list_objet_build a, Lots b ' +
                     'Where a.LOT_NUMBER = ' + %Char(p_Numero_lot) +
                      ' And a.LOT_NUMBER = b.LOT_NUMBER) With data';

EXEC SQL
EXECUTE IMMEDIATE :L_Requete_Sql;


  return ;
END-PROC ;
