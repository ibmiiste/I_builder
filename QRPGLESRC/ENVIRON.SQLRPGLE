**FREE

Ctl-opt Nomain;

/Copy Qcpysrc,Inhbuilder



// --------------------------------------------------
// Procedure name: livraisonDistante
// Purpose:        Méthode livraison distante
// Returns:        Indicateur de machine distante
// Parameter:      pEnvironnement => Nom complet ou adresse IP de la machine ...
//                          distante
// --------------------------------------------------
Dcl-Proc livraisonDistante Export;
  Dcl-Pi *N IND;
  // Classe environnement
     livraisonEnvironnement LikeDs(environnement);
  End-Pi;

  // Local fields
  Dcl-S livraisonDistante IND;
  // Calculation specifications
  If livraisonEnvironnement.SYSDIST = '1';
    livraisonDistante=*On;
  Else;
    livraisonDistante=*Off;
  ENDIF;

  return livraisonDistante;
End-Proc;

