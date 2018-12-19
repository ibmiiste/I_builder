             CMD        PROMPT('Gestion liste de bibliothèques')

             PARM       KWD(USER) TYPE(*NAME) LEN(10) DFT(*CURRENT) +
                          SPCVAL((*USER *USER) (*CURRENT *CURRENT) +
                          (*ALL *ALL)) PROMPT('Utilisateur')

             PARM       KWD(LSTTYPE) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*ALL) VALUES(*ALL *PRIVATE) +
                          PROMPT('Type de liste')
