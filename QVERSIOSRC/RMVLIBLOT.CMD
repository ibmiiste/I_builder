/*  Suppression de la bibliothèque du lot dans la liste système des bibliothèques   */
/*  CPP:  RMVLIBLOT                                                          */

             CMD        PROMPT('Suppression bibliothèque lot')

             PARM       KWD(LOT) TYPE(*DEC) LEN(6 0) MIN(1) PROMPT('Numéro de lot')


/******************************************************************************/
/*  CRTCMD CMD(library/ADDLIBLOT)                                             */
/*           PGM(*LIBL/RMVLIBLOT)                                             */
/*           SRCFILE(library/QCMDSRC)                                         */
/*           SRCMBR(ADDLIBLOT)                                                */
/******************************************************************************/
