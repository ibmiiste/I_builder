/*  Ajout de la bibliothèque du lot dans la liste système des bibliothèques   */
/*  CPP:  MELLOT                                                          */

             CMD        PROMPT('Ajout bibliothèque du lot')

             PARM       KWD(LOT) TYPE(*DEC) LEN(6 0) MIN(1) PROMPT('Numéro de lot')


/******************************************************************************/
/*  CRTCMD CMD(library/ADDLIBLOT)                                             */
/*           PGM(*LIBL/MELLOT)                                                */
/*           SRCFILE(library/QCMDSRC)                                         */
/*           SRCMBR(ADDLIBLOT)                                                */
/******************************************************************************/
