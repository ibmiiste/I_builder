     ?*****************************************************************
     ?* MODULE    : UTISQL                  Date Cr{ation : 20/05/2016
     ?* SRVPGM    : UTISQLSRV
     ?* AUTEUR    : DLN                         Copyright C.I.Services
     ?*----------------------------------------------------------------
     ?*? APPLICATION :
     ?*  xxxxxxxxxxxxxxxx
     ?*----------------------------------------------------------------
     ?*? DESCRIPTION :
     ?*  Construction d'un ordre sql dynamique
     ?*----------------------------------------------------------------
     ?*? REMARQUE    :
     ?*  Destiné à être intégré dans BERGERSRV
     ?*----------------------------------------------------------------
     ?*? MAINTENANCE :
     ?*  N°    AUTEUR                 OBJET                     DATE
     ?* ...  ...........  .................................  ../../....
     ?* ...  ...........  .................................  ../../....
     ?* ...  ...........  .................................  ../../....
     ?*----------------------------------------------------------------
     ?*? INDICATEURS :
     ?*  xx -> xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     ?*****************************************************************
      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) +    */
      *                 SRCMBR(&SM);                                  */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  OPTION(*EVENTF);                                */
      *     >>PARM<<  DBGVIEW(*SOURCE);                               */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */

       ctl-opt nomain;
       ctl-opt option(*srcstmt:*nodebugio:*nounref);

      /copy *libl/qcpysrc,utiproc

       dcl-s w_select varchar(2000);
       dcl-s w_from varchar(600);
       dcl-s w_liste varchar(2000);
       dcl-s w_where varchar(2000);
       dcl-s w_orderby varchar(500);

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_init : Initialisation de la requête                              *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_init export;

          DCL-PI *n END-PI;

          w_select = '*';
          clear w_from;
          clear w_liste;
          clear w_where;
          clear w_orderby;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_from : Ajout de la clause from                                   *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_from export;

          DCL-PI *n;
             fichier varchar(200) const;
             as      varchar(30) const options(*nopass:*omit);
         END-PI;

         dcl-s w_fichier varchar(200);

         if %parms >= %parmnum(as) and %addr(as) <> *null and as <> *blanks;
           w_fichier = %trim(fichier) + ' AS ' +  %trim(as);
         else;
           w_fichier = fichier;
         endif;

         w_from = %trim(w_fichier);

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_addFrom : Ajout d'un fichier à la requête                        *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_addFrom export;

         DCL-PI *n;
           fichier varchar(200) const;
           as      varchar(30) const options(*nopass:*omit);
             join    varchar(16) const options(*nopass:*omit);
             on      varchar(500) const options(*nopass);
          END-PI;

          dcl-s w_fichier varchar(64);
          dcl-s w_join varchar(16);
          dcl-s w_on varchar(200);

          if %parms >= %parmnum(as) and %addr(as)<> *null and as <> *blanks;
             w_fichier = %trim(fichier) + ' AS ' +  %trim(as);
          else;
             w_fichier = fichier;
          endif;

          if %parms >= %parmnum(join)
           and %addr(join)<> *null
           and join <> *blanks;
             w_join = join;
          endif;

          if %parms >= %parmnum(on) and %addr(on)<> *null and on <> *blanks;
             w_on = on;
          endif;


          if w_from = *blanks;
             w_from = %trim(w_fichier);
          elseif w_join = *blanks;
             w_from += ', ' + %trim(w_fichier);
          else;
           w_from += ' ' + %trim(join) + ' ' +  %trim(w_fichier);
            if w_on <> *blanks;
               w_from += ' ON (' + %trim(w_on) + ')';
            endif;
          endif;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_select : Construction de la clause select                        *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_select export;

         DCL-PI *n;
           colonne varchar(500) const;
         END-PI;

         w_select = %trim(colonne);

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_sql_addSelect : Ajout d'une colonne ou d'un groupe de colonnes   *
      *               à sélectionner                                          *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_addSelect export;

          DCL-PI *n;
             colonne varchar(500) const;
          END-PI;

          if w_select = *blanks or w_select = '*';
             w_select = %trim(colonne);
          else;
             w_select += ', ' + %trim(colonne);
          endif;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_eq : Construction d'un critère d'égalité sur une zone numérique  *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_eq_num export;

          DCL-PI *n varchar(233);
             colonne varchar(30) const;
             valeur varchar(200) const;
          END-PI;

          dcl-s w_retour varchar(233);

          w_retour = %trim(colonne) + ' = ' + %trimr(valeur);

          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_eq : Construction d'un critère d'égalité sur une zone alphanum   *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_eq export;

          DCL-PI *n varchar(233);
             colonne varchar(30) const;
             valeur varchar(200) const;
          END-PI;

          dcl-s w_retour varchar(233);

          w_retour = %trim(colonne) + ' = ''' + %trimr(valeur) + '''';
          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_between :                                                        *
      *           Construction d'un critère d'inclusion dans une fourchette   *
      *           de représentation alphanumérique                            *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_between export;

          DCL-PI *n varchar(233);
             colonne varchar(30) const;
             valeurMin varchar(200) const;
             valeurMax varchar(200) const;
          END-PI;

          dcl-s w_retour varchar(433);

          w_retour = %trim(colonne) + ' BETWEEN ''' + %trimr(valeurMin) + '''';
          w_retour += ' AND ''' + %trimr(valeurMax) + '''';
          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_between_num :                                                    *
      *           Construction d'un critère d'inclusion dans une fourchette   *
      *           de représentation numérique                                 *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_between_num export;

          DCL-PI *n varchar(233);
             colonne varchar(30) const;
             valeurMin varchar(200) const;
             valeurMax varchar(200) const;
          END-PI;

          dcl-s w_retour varchar(433);

          w_retour = %trim(colonne) + ' BETWEEN ' + %trimr(valeurMin);
          w_retour += ' AND ' + %trimr(valeurMax);
          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_ne_num: Construction d'un critère d'inégalité numérique          *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_ne_num export;

          DCL-PI *n varchar(233);
             colonne varchar(30) const;
             valeur varchar(200) const;
          END-PI;

          dcl-s w_retour varchar(233);

          w_retour = %trim(colonne) + ' ^= ' + %trimr(valeur);
          return w_retour;

       END-PROC;


      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_ne : Construction d'un critère d'inégalité (colonne alphanum)    *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_ne export;

          DCL-PI *n varchar(233);
             colonne varchar(30) const;
             valeur varchar(200) const;
          END-PI;

          dcl-s w_retour varchar(233);

          w_retour = %trim(colonne) + ' ^= ''' + %trimr(valeur) + '''';
          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_comp_num : Construction d'un discriminant numérique              *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_comp_num export;

          DCL-PI *n varchar(233);
             colonne varchar(30) const;
             comparateur varchar(30) const;
             valeur varchar(200) const;
          END-PI;

          dcl-s w_retour varchar(233);

          w_retour = %trim(colonne) +
                      ' ' +
                      %trim(comparateur) + ' ' +
                      %trimr(valeur);

          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_comp : Construction d'un discriminant                            *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_comp export;

          DCL-PI *n varchar(233);
             colonne varchar(30) const;
             comparateur varchar(30) const;
             valeur varchar(200) const;
          END-PI;

          dcl-s w_retour varchar(233);

            w_retour = %trim(colonne) +
              ' ' +
              %trim(comparateur) +
              ' ''' +
              %trimr(valeur) +
              '''';
          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_initList : Initilisation liste de valeurs                        *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_initList export;

          DCL-PI *n END-PI;

          clear w_liste;

       END-PROC;


      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_addList : Ajout d'une valeur ou d'un groupe de valeurs à une     *
      *                liste                                                  *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_addList export;

          DCL-PI *n varchar(2000);
             valeur varchar(200) const;
          END-PI;

          if w_liste = *blanks;
            w_liste = %trimr(valeur);
          else;
             w_liste += ', ' + %trimr(valeur);
          endif;

          return w_liste;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_rtvList : Récupération de la liste en cours                      *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_rtvList export;

          DCL-PI *n varchar(2000) END-PI;

          return w_liste;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_in : Construction d'un critère d'appartenance à une liste        *
      *           ou à la liste en cours                                      *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_in export;

          DCL-PI *n varchar(2000);
             colonne varchar(30)const;
             liste varchar(500) const options(*nopass);
          END-PI;

          dcl-s w_retour varchar(2000);

          if %parms >= %parmnum(liste);
             w_retour = %trim(colonne) + ' IN (' + %trim(liste) + ')';
          else;
             w_retour = %trim(colonne) + ' IN (' + %trim(w_liste) + ')';
          endif;

          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_and : Concaténation de 2 restrictions par 'and'                  *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_and export;

          DCL-PI *n varchar(2000);
             crit1 varchar(2000) const;
             crit2 varchar(2000) const;
          END-PI;

          dcl-s w_retour varchar(2000);

          if crit1 <> *blanks and crit2 <> *blanks;
             w_retour = '(';
             w_retour += %trim(crit1) + ') AND (' + %trim(crit2);
             w_retour += ')';
          elseif crit1 <> *blanks;
             w_retour = crit1;
          else;
             w_retour = crit2;
          endif;

          return w_retour;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_or : Concaténation de 2 restrictions par 'or'                    *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_or export;

          DCL-PI *n varchar(2000);
             crit1 varchar(2000) const;
             crit2 varchar(2000) const;
          END-PI;

          dcl-s w_retour varchar(2000);

          if crit1 <> *blanks and crit2 <> *blanks;
             w_retour = '(';
             w_retour += %trim(crit1) + ') OR (' + %trim(crit2);
             w_retour += ')';
          elseif crit1 <> *blanks;
             w_retour = crit1;
          else;
             w_retour = crit2;
          endif;

          return w_retour;

       END-PROC;


      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_where : Ajout de la clause WHERE                                 *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_where export;

          DCL-PI *n;
             where varchar(2000) const;
          END-PI;

          w_where = '(' + %trim(where) + ')';

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_addWhere : Ajout à la clause WHERE ou ajout à la clause WHERE    *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_addWhere export;

          DCL-PI *n;
             where varchar(2000) const;
             conj char(2) const options(*nopass);
          END-PI;

          dcl-s w_conjonction char(3);

          if %parms() >= %parmnum(conj) and (conj = 'OR' or conj = 'OU');
            w_conjonction = 'OR';
          else;
            w_conjonction = 'AND';
          endif;

          if w_where <> *blanks;
            if w_conjonction = 'OR';
            w_where = '(' + %trim(w_where) + ') ' + %trim(w_conjonction) +
                      ' (' + %trim(where) + ')';
          else;
              w_where = %trim(w_where) + ' ' + %trim(w_conjonction) +
                        ' ' + %trim(where);
            endif;
          else;
            w_where = %trim(where);
          endif;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_orderBy : Ajout de la clause order by                            *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_orderBy export;

          DCL-PI *n;
             colonnes varchar(500) const;
          END-PI;

          w_orderby = %trim(colonnes);

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_orderby : Ajout d'une colonne ou d'un groupe de colonnes au tri  *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_addOrderby export;

          DCL-PI *n;
             colonne varchar(500) const;
          END-PI;

          if w_orderby = *blanks;
             w_orderby = %trim(colonne);
          else;
             w_orderby += ', ' + %trim(colonne);
          endif;

       END-PROC;

      *-----------------------------------------------------------------------*
      *                                                                       *
      *  sql_bld : Construction de la requête                                 *
      *                                                                       *
      *-----------------------------------------------------------------------*
       DCL-PROC sql_bld export;

          DCL-PI *n varchar(6000) END-PI;

          dcl-s w_requete varchar(6000);

          w_requete = 'SELECT ' + %trim(w_select) + ' FROM ' + %trim(w_from);
          if w_where <> *blanks;
             w_requete += ' WHERE ' + %trim(w_where);
          endif;
          if w_orderby <> *blanks;
             w_requete += ' ORDER BY ' + %trim(w_orderby);
          endif;
          return w_requete;

       END-PROC;

