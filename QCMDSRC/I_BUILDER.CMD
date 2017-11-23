      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */

/*  Construction des objets du lot                                  */
/*  CPP:  CREABIBLOT                                                */

             CMD        PROMPT('Construction du lot')

             PARM       KWD(NOMCLOT) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Bibliothèque du lot')



