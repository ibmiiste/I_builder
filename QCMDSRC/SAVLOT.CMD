/*  Archivage du lot dans la bibliothèque ARCHIVELOT                      */
/*  CPP:  SAVBIBLOT                                                       */
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*     >>PARM<<  TGTRLS(*CURRENT);                                  */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */


             CMD        PROMPT('Archivage du lot')

             PARM       KWD(LOT) TYPE(*DEC) LEN(6 0) MIN(1) PROMPT('Numéro de lot')


/******************************************************************************/
/*  CRTCMD CMD(library/SAVLOT)                                                */
/*           PGM(*LIBL/SAVLIBLOT)                                             */
/*           SRCFILE(library/QCMDSRC)                                         */
/*           SRCMBR(SAVLOT)                                                   */
/******************************************************************************/
