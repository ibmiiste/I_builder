/*  Arr�ter un lot retire la biblioth�que du lot de la liste des   */
/*  biblioth�ques syst�me                                                 */
/*  CPP:  ENDTSTLOT                                                       */
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */
        CMD        PROMPT('Arr�t Test du lot')

        PARM       KWD(LOT) TYPE(*DEC) LEN(9 0) MIN(1) PROMPT('Num�ro de lot')
