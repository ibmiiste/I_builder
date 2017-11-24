      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */
             CMD        PROMPT('Envoyer objet')

             PARM       KWD(BIBLIO) TYPE(OBJET) MIN(1) PROMPT('Objet')
 OBJET:      QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*CURLIB) SPCVAL((*CURLIB +
                          *CURLIB) (*LIBL)) PROMPT('Bibliothèque')

             PARM       KWD(SYS) TYPE(SYS) MIN(1) PROMPT('Système éloigné')
 SYS:        QUAL       TYPE(*NAME) LEN(10)

             PARM       KWD(USER) TYPE(USER) PROMPT('Profil')   MIN(1)
 USER:       QUAL       TYPE(*NAME) LEN(10) DFT(*CURRENT) SPCVAL((*CURRENT +
                          '*CURRENT'))

             PARM       KWD(MDP) TYPE(MDP) PROMPT('Mot de passe')  MIN(1)
 MDP:        QUAL       TYPE(*NAME) LEN(10) DSPINPUT(*NO)
