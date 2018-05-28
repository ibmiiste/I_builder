/*  Tester un lot Met en ligne la bibliothèque du lot dans la liste des   */
/*  bibliothèques système                                                 */
/*  CPP:  MELLOT                                                          */
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */
        CMD        PROMPT('Test du lot')

        PARM       KWD(LOT) TYPE(*DEC) LEN(6 0) MIN(1) PROMPT('Numéro de lot')


/******************************************************************************/
/*  CRTCMD CMD(library/SAVLOT)                                                */
/*           PGM(*LIBL/SAVLIBLOT)                                             */
/*           SRCFILE(library/QCMDSRC)                                         */
/*           SRCMBR(SAVLOT)                                                   */
/******************************************************************************/
