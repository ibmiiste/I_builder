             CMD        PROMPT('Positionnement biblioth�ques') +
                          PRDLIB(I_BUILDER)

             PARM       KWD(SAVRST) TYPE(*NAME) LEN(4) RSTD(*YES) +
                          DFT(*RST) VALUES(SAV RST) SPCVAL((*RST *RST) +
                          (*SAV *SAV)) PROMPT('Action')

             PARM       KWD(LISTE) TYPE(*NAME) LEN(10) DFT(*USER) +
                          SPCVAL((*USER *USER) (*CURRENT *CURRENT)) +
                          PROMPT('Liste de sauvegarde')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(BERGER) +
                          SPCVAL((*NONE *NONE)) PROMPT('Biblioth�que')

             PARM       KWD(RSTCURLIB) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*NO *YES) +
                          PROMPT('R�tablissement de la CURLIB')