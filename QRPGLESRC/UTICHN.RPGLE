      **************************************************************************
      * MODULE    : UTICHN                  Date Création : 28/07/2017         *
      * AUTEUR    : D.LANDRAGIN                 Copyright : Ista France        *
      *------------------------------------------------------------------------*
      *  APPLICATION :                                                         *
      *  Services                                                              *
      *------------------------------------------------------------------------*
      *  DESCRIPTION :                                                         *
      *  Procédures pour la gestion chaines de caractères                      *
      *                                                                        *
      *------------------------------------------------------------------------*
      * MAINTENANCE :                                                          *
      *  N°    AUTEUR                       OBJET                       DATE   *
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      **************************************************************************
      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) +    */
      *                 SRCMBR(&SM);                                  */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  OPTION(*EVENTF);                                */
      *     >>PARM<<  DBGVIEW(*ALL);                                  */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */

       ctl-opt nomain;
       ctl-opt option(*srcstmt:*nodebugio:*nounref);

       /copy *libl/qcpysrc,utiproc

       // --------------------------------------------------
       // Procedure name: chn_trimrParam
       // Purpose:        renvoyer une chaine trimée à droite sans les
       //                          caractères < ' ' (chaine reçue d'un pgm cl)
       // Returns:        la nouvelle chaine
       // Parameter:      p_chaine => La chaine à traiter
       // --------------------------------------------------
       DCL-PROC chn_trimrParam EXPORT;

         dcl-pi *n like(r_var131072);
           p_chaine like(r_var131072) const;
         end-pi;

         dcl-s retour like(p_chaine);
         dcl-s i int(5);
         dcl-s j like(i);

         retour = %trimr(p_chaine);
         i = %len(retour);

         for j = i downto 1;
           if %subst(retour:j:1) > x'3F';
             leave;
           endif;
           %subst(retour:j:1) = x'40';
         endfor;

         return %trimr(retour);
       END-PROC;

       // --------------------------------------------------
       // Procedure name: chn_toUpperCase
       // Purpose:        Transformer une chaine en capitales d'imprimerie
       // Returns:        La chaine en majuscules
       // Parameter:      p_chaine => la chaine à transformer
       // Parameter:      p_garder_accents => garder les accents (optionnel, non par défaut)
       // --------------------------------------------------
       DCL-PROC chn_toUpperCase EXPORT;

         dcl-pi *n  like(r_var131072);
           p_chaine  like(r_var131072) const;
           p_garder_accents ind const options(*omit:*nopass);
         end-pi;

         dcl-s retfield like(p_chaine);

         dcl-s w_garder_accents ind inz(*off);

         dcl-c MIN     'abcdefghijklmnopqrstuvwxyzàâéèêëîïôöùüû';          //minuscules
         dcl-c MAJ_ACC 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÉÈÊËÎÏÔÖÙÜÛ';          //majuscules accuentées
         dcl-c MAJ     'ABCDEFGHIJKLMNOPQRSTUVWXYZAAEEEEIIOOUUU';          //majuscules non accentuées

         if %parms >= %parmnum(p_garder_accents) and
          %addr(p_garder_accents) <> *null;
           w_garder_accents = p_garder_accents;
         endif;

         if w_garder_accents;
            retfield = %xlate(MIN:MAJ:p_chaine);
         else;
            retfield = %xlate(MIN:MAJ_ACC:p_chaine);
         endif;

         return retField;

       END-PROC;

       // --------------------------------------------------
       // Procedure name: chn_toLowerCase
       // Purpose:        Transformer une chaine en bas de casse
       // Returns:        La chaine en minuscules
       // Parameter:      p_chaine => la chaine à transformer
       // Parameter:      p_garder_accents => garder les accents (optionnel, non par défaut)
       // --------------------------------------------------
       DCL-PROC chn_toLowerCase EXPORT;

         dcl-pi *n  like(r_var131072);
           p_chaine  like(r_var131072) const;
           p_garder_accents ind const options(*omit:*nopass);
         end-pi;

         dcl-s retfield like(p_chaine);

         dcl-s w_garder_accents ind inz(*off);

         dcl-c MAJ     'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÉÈÊËÎÏÔÖÙÜÛ';      //majuscules accuentées
         dcl-c MIN     'abcdefghijklmnopqrstuvwxyzaaeeeeiioouuu';      //minuscules non accentuées
         dcl-c MIN_ACC 'abcdefghijklmnopqrstuvwxyzàâéèêëîïôöùüû';      //minuscules accuentées

         if %parms >= %parmnum(p_garder_accents) and
          %addr(p_garder_accents) <> *null;
           w_garder_accents = p_garder_accents;
         endif;

         if w_garder_accents;
            retfield = %xlate(MAJ:MIN_ACC:p_chaine);
         else;
            retfield = %xlate(MAJ:MIN:p_chaine);
         endif;

         return retField;

       END-PROC;

       // --------------------------------------------------
       // Procedure name: chn_centrer
       // Purpose:        Centre une chaine de caractère dans une variable
       //                          selon sa longueur
       // Returns:        la chaine de retour
       // Parameter:      p_chaine => La chaine de caractères à centrer
       // Parameter:      p_long => Longueur de la chaine réceptrice
       // --------------------------------------------------
       dcl-proc chn_centrer EXPORT;

         dcl-pi *n varchar(131);
           p_chaine varchar(131) const;
           p_long uns(3) const;
         end-pi;

         dcl-s variable char(131);
         dcl-s blancs uns(3);

         if %len(%trim(p_chaine)) >= p_long -1;
           return %trim(p_chaine);
         endif;

         if %len(%trim(p_chaine)) = 0;
           return '';
         endif;

         blancs = p_long - %len(%trim(p_chaine));
         if %rem(blancs:2) = 0;
           blancs /= 2;
         else;
           blancs /= 2;
           blancs += 1;
         endif;

         variable = %subst(variable:1:blancs) + %trim(p_chaine);

         return %trimr(variable);

       end-proc;

