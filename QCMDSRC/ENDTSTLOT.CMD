/*  Arréter un lot retire la bibliothèque du lot de la liste des   */
/*  bibliothèques système                                                 */
/*  CPP:  ENDTSTLOT                                                       */
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*     >>PARM<<  TGTRLS(*CURRENT);                                  */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */

        CMD        PROMPT('Arrêt Test du lot')

        PARM       KWD(LOT) TYPE(*DEC) LEN(9 0) MIN(1) PROMPT('Numéro de lot')
