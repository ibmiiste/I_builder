/*  Tester un lot Met en ligne la bibliothèque du lot dans la liste des   */
/*  bibliothèques système                                                 */
/*  CPP:  STRTSTLOT                                                       */
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */
             CMD        PROMPT('Test du lot') PRDLIB(I_BUILDER)

        PARM       KWD(LOT) TYPE(*DEC) LEN(9 0) MIN(1) PROMPT('Numéro de lot')
