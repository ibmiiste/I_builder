/*  Archivage du lot dans la biblioth�que ARCHIVELOT                      */
/*  CPP:  SAVBIBLOT                                                       */

             CMD        PROMPT('Archivage du lot')

             PARM       KWD(LOT) TYPE(*DEC) LEN(6 0) MIN(1) PROMPT('Num�ro de lot')


/******************************************************************************/
/*  CRTCMD CMD(library/SAVLOT)                                                */
/*           PGM(*LIBL/SAVLIBLOT)                                             */
/*           SRCFILE(library/QCMDSRC)                                         */
/*           SRCMBR(SAVLOT)                                                   */
/******************************************************************************/
