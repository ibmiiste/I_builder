      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(I_BUILDER/PLIBLSTR);                           */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */
             CMD        PROMPT('Gestion liste de bibliothèques')

             PARM       KWD(USER) TYPE(*NAME) LEN(10) DFT(*CURRENT) +
                          SPCVAL((*USER *USER) (*CURRENT *CURRENT) +
                          (*ALL *ALL)) PROMPT('Utilisateur')

             PARM       KWD(LSTTYPE) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*ALL) VALUES(*ALL *PRIVATE) +
                          PROMPT('Type de liste')
