/*  Met en ligne l'environnement du lot avec :                                                    */
/*  - La biblioth�ques lot dans la liste de biblioth�ques syst�me                                 */
/*  -  La mise en ligne de la liste de biblioth�ques param�tr� dans le lot                        */
/*  CPP:  STRTSTLOT                                                                               */
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTCMD CMD(&LI/&OB) SRCFILE(&SL/&SF) +             */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  PGM(&LI/&OB);                                      */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */
             CMD        PROMPT('Chargement environnement lot') PRDLIB(I_BUILDER)

        PARM       KWD(LOT) TYPE(*DEC) LEN(9 0) MIN(1) PROMPT('Num�ro de lot')