/*  Ajout de la bibliothèque du lot dans la liste système des bibliothèques   */
/*  CPP:  CREABIBLOT                                                */

             CMD        PROMPT('Création d''un lot de dev')

             PARM       KWD(DESCLOT) TYPE(*CHAR) LEN(50) MIN(1) PROMPT('Description de lot')


/******************************************************************************/
/*  CRTCMD CMD(library/CRTLOT                                                 */
/*           PGM(*LIBL/CREABIBLOT)                                            */
/*           SRCFILE(library/QCMDSRC)                                         */
/*           SRCMBR(CRTLOT)                                                   */
/******************************************************************************/
