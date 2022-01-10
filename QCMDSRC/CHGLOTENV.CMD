/*  Met en ligne l'environnement du lot avec :                                                    */
/*  - La bibliothèques lot dans la liste de bibliothèques système                                 */
/*  -  La mise en ligne de la liste de bibliothèques paramétré dans le lot                        */
/*  CPP:  STRTSTLOT                                                                               */
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */
             CMD        PROMPT('Chargement environnement lot') PRDLIB(I_BUILDER)

        PARM       KWD(LOT) TYPE(*DEC) LEN(9 0) MIN(1) PROMPT('Numéro de lot')
