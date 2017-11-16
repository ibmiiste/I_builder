34     ctl-opt nomain;
       ctl-opt option(*srcstmt:*nodebugio:*nounref);
       ctl-opt bnddir('SERVICE');

      /copy berger/qcpysrc,utiproc

     ***************************************************************************
     **                                                                       **
     **  env_loadLibl : Chargement d'une liste de bibliothèques de SESAME     **
     **                                                                       **
     **  paramètres d'entrée : le nom de la liste de bibliothèques            **
     **                                                                       **
     **                                                                       **
     **  paramètre de retour : Vrai si la liste a été chargée                 **
     **                                                                       **
     **                                                                       **
     ***************************************************************************
       DCL-PROC env_loadLibl EXPORT;

         DCL-PI *n ind;
           p_libl char(8);
         END-PI;

         DCL-S liste varchar(150);
         DCL-S curlib varchar(10);

         dcl-s trouve ind inz(*off);
         dcl-s commande varchar(500);

         exec sql
           SELECT substr(PàDSE, 87, 142) as liste,
                  substr(PàDSE, 422, 10) as curlib
             INTO :liste,
                  :curlib
             FROM BFE00 / "PARMà£L"
             WHERE SUBSTR(PàDSE, 1, 3) = 'LSB' AND
                   SUBSTR(PàDSE, 8, 8) = :p_libl
             FETCH FIRST ROW ONLY;

         if sqlcod <> 0;
           msg_throw('BAS9991':'Liste de bibliothèques non trouvée');
         endif;

         if liste = *blanks;
           msg_throw('BAS9991':'Liste de bibliothèques vide');
         endif;

           monitor;
             commande = 'CHGLIBL LIBL(' + %trim(liste) + ')';
             cmd_exec(%trim(commande));
             trouve = *on;
           on-error;
             msg_throw('BAS9991':'Erreur lors du chargement de la liste');
           endmon;

           if curlib <> *blanks;
             monitor;
               commande = 'CHGCURLIB CURLIB(' + %trim(curlib) + ')';
               cmd_exec(%trim(commande));
             on-error;
               msg_throw('BAS9991':'CURLIB non changée');
             endmon;
           else;
             cmd_exec('CHGCURLIB CURLIB(*CRTDFT)');
           endif;


         return trouve;

       END-PROC;
