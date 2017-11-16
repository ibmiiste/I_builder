     H nomain
     H option(*srcstmt:*nodebugio)

      /copy *libl/qcpysrc,utiproc
     d w_open          s            200    varying
     d                                     inz('OPNQRYF FILE(${F})')
     d w_open_m        s            200    varying
     d                                     inz('OPNQRYF FILE((${F} ${M}))')
     d w_slt           s           2000    varying
     d                                     inz('QRYSLT(''${S}'')')
     d w_sort          s            200    varying
     d                                     inz('KEYFLD(${K})')
     d w_chn_slt       s          65535    varying
     d w_chn_srt       s           2000    varying

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_init   : initilise un nouvel OPNQRYF            *
      *                                                               *
      *---------------------------------------------------------------*
     p qry_init        b                   export
     d                 pi
     d  fichier                      10    const
     d  membre                       10    const options(*omit:*nopass)

      /free
        reset w_open;
        reset w_slt;
        reset w_sort;
        clear w_chn_slt;
        clear w_chn_srt;
        if %parms < %parmnum(membre)
         or %addr(membre) = *null or membre = *blanks;
           w_open = %replace(%trim(fichier):w_open:%scan('${F}':w_open):4);
           //w_open = %ScanRpl('${F}':%trim(fichier):w_open);
        else;
           w_open = %replace(%trim(fichier):w_open_m:%scan('${F}':w_open_m):4);
           w_open = %replace(%trim(membre):w_open:%scan('${M}':w_open):4);
        endif;
        return;
      /end-free

     p                 e
      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSlt : ajout d'un critère de sélection        *
      *                                                               *
      *---------------------------------------------------------------*
     p qry_addSlt      b                   export
     d                 pi
     d  nomZone                      50    const varying
     d  comparateur                   4    const
     d  valeur                       50    const varying
     d  type                          1    const options(*nopass)

       DCL-S valeur2 like(valeur);

       valeur2 = %ScanRpl('''' : '''''' : valeur);

       if w_chn_slt <> *blanks;
          w_chn_slt += ' *AND ';
       endif;
       w_chn_slt += '('+ %trim(nomZone)+ ' ' + %trim(comparateur);
       if %parms = 3 or type = 'A';
          w_chn_slt += ' "' + %trim(valeur2) + '")';
       elseif  %parms = 4 and type = 'N';
          w_chn_slt += ' ' + %trim(valeur2) +')';
       endif;
       return;

     p                 e

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSlt_beg : ajout d'un critère de sélection    *
      *                            sur les premiers caractères        *
      *---------------------------------------------------------------*
     p qry_addSlt_beg  b                   export
     d                 pi
     d  nomZone                      10    const varying
     d  long                          3  0 const
     d  valeur                       50    const varying

       DCL-S valeur2 like(valeur);

       valeur2 = %ScanRpl('''' : '''''' : valeur);

       if w_chn_slt <> *blanks;
          w_chn_slt += ' *AND ';
       endif;
       w_chn_slt += '(%SST('+ %trim(nomZone)+ ' 1 '
                    + %char(long) + ') '
                    + '*EQ';
       w_chn_slt += ' "' + %trim(valeur2) + '")';
       return;

     p                 e

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSlt_in : ajout d'un critère de sélection     *
      *                           sur une liste de valeurs            *
      * paramètres d'entrée : nomZone                                 *
      *                       valeur élément de la liste de valeurs   *
      *                       position (FIRST ou LAST ou NEXT         *
      *---------------------------------------------------------------*
     p qry_addSlt_in   b                   export
     d                 pi
     d  nomZone                      10    const varying
     d  valeur                    65535    const varying
     d  position                      1    const options(*nopass)

       DCL-S valeur2 like(valeur);

       valeur2 = %ScanRpl('''' : '''''' : valeur);

       if position = FIRST;
          if w_chn_slt <> *blanks;
             w_chn_slt += ' *AND (';
          else;
             w_chn_slt += '(';
          endif;
       endif;
       if position = NEXT or position = LAST;
             w_chn_slt += ' *OR ';
       endif;
       w_chn_slt += %trim(nomZone) + ' *EQ ';
       w_chn_slt += ' "' + %trim(valeur2) + '"';
       if position = LAST;
          w_chn_slt += ')';
       endif;

       return;


     p                 e

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_clrSlt : initialisation de la sélection seule   *
      *                                                               *
      *---------------------------------------------------------------*
     p qry_clrSlt      b                   export
     d                 pi

      /free
         reset w_slt;
         clear w_chn_slt;
         return;
      /end-free

     p                 e
      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSort    : ajout d'un critère de tri          *
      *                                                               *
      *---------------------------------------------------------------*
     p qry_addSort     b                   export
     d                 pi
     d  nomZone                      10    const

      /free
         w_chn_srt += ' ('+ %trim(nomZone)+ ')';
         return;
      /end-free

     p                 e
      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_addSortD   : ajout d'un critère de tri          *
      *                            descendant                         *
      *---------------------------------------------------------------*
     p qry_addSortD    b                   export
     d                 pi
     d  nomZone                      10    const

      /free
         w_chn_srt += ' ('+ %trim(nomZone)+ ' *DESCEND)';
         return;
      /end-free

     p                 e
      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_clrSort    : initialisation critères de tri     *
      *                            seuls                              *
      *---------------------------------------------------------------*
     p qry_clrSort     b                   export
     d                 pi

      /free
         reset w_sort;
         clear w_chn_srt;
         return;
      /end-free

     p                 e
      *---------------------------------------------------------------*
      *                                                               *
      * Procedure qry_bldcmd : Construction de l'OPNQRYF              *
      *                                                               *
      *---------------------------------------------------------------*
     p qry_bldcmd      b                   export
     d                 pi          2000    varying
     d w_query         s           2000    varying

      /free
         w_query = w_open;
         if w_chn_slt <> *blanks;
            w_slt = %replace(%trim(w_chn_slt):w_slt:%scan('${S}':w_slt):4);
            w_query += ' ' + w_slt;
         endif;
         if w_chn_srt <> *blanks;
            w_sort = %replace(%trim(w_chn_srt):w_sort:%scan('${K}':w_sort):4);
            w_query += ' ' + w_sort;
         endif;
         return w_query;
      /end-free

     p                 e
