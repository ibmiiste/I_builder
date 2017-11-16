        ctl-opt nomain bnddir('SERVICE');
      *--------------------------------------------------------------------*
      * PROGRAMME : GENUUID32                 DATE CREATION : 20/03/2017   *
      * AUTEUR    : P. Baulier                COPYRIGHT Ista cis           *
      *--------------------------------------------------------------------*
      * APPLICATION : Mirus, Sap
      *--------------------------------------------------------------------*
      * DESCRIPTION : Génération d'un identifiant unique sur 32 car.
      *--------------------------------------------------------------------*
      * Maintenance :
      * N°     Auteur         Description de la modif               Date
      *--------------------------------------------------------------------*
      // Prototype de la procédure, tel qu'elle sera défini dans les pgm 'appelant'
      // Ex d'appel : OPE001 = CrtUuid('T'), ou BNG001 = CrtUuid(' ').
        dcl-pr GenUuid32 char(32) end-pr; // Ce que fournit la procédure

        dcl-proc GenUuid32 Export;
           dcl-pi *N char(32) end-pi;  // Ce que fournit la procédure

           // Génère un UUID au format standard
           dcl-pr genUuid char(36) end-pr;

           // cvtUuidStdTo32 : convertit un UUID du format standard au format sans tiret
           dcl-pr cvtUuidStdTo32 char(32);
              Uuid32 char(36) const;
           end-pr;

           Return cvtUuidStdTo32(GenUuid);

        End-Proc GenUuid32;
