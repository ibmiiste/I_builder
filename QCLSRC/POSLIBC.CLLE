      /********************************************************************/
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTBNDCL PGM(&LI/&OB) SRCFILE(&SL/&SF) +           */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  OPTION(*EVENTF);                                   */
      /*     >>PARM<<  DBGVIEW(*LIST);                                    */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */

             PGM        PARM(&SAVRST &LISTE &PLIB &RSTCURLIB)

             DCL        VAR(&SAVRST) TYPE(*CHAR) LEN(4)
             DCL        VAR(&LISTE) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&USER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CURLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&USRLIBL) TYPE(*CHAR) LEN(2750)
             DCL        VAR(&LIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&P) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&RSTCURLIB) TYPE(*CHAR) LEN(4)

             IF         COND(&LISTE *EQ '*CURRENT' *OR &LISTE *EQ '*USER') THEN(DO)
                RTVJOBA    USER(&USER)
                CHGVAR     VAR(&LISTE) VALUE(&USER)
             ENDDO

             IF         COND(&LIB *NE 'BERGER' *AND &PLIB *NE '*NONE') THEN(DO)
                CHKOBJ     OBJ(&PLIB) OBJTYPE(*LIB)
                MONMSG     MSGID(CPF9801) EXEC(DO)
                   SNDPGMMSG  MSG('Bibliothèque' *BCAT &PLIB *BCAT 'non trouvée.') MSGTYPE(*COMP)
                   GOTO       CMDLBL(FIN)
                ENDDO
             ENDDO

             IF         COND(&SAVRST *EQ 'SAV' *OR &SAVRST *EQ '*SAV') THEN(DO)
                CHKOBJ     OBJ(&PLIB/&LISTE) OBJTYPE(*DTAARA)
                MONMSG     MSGID(CPF9801) EXEC(DO)
                   CRTDTAARA  DTAARA(&PLIB/&LISTE) TYPE(*CHAR) LEN(2000) TEXT('Dtaara créé par commande POSLIB')
                ENDDO
                RTVJOBA    CURLIB(&CURLIB) USRLIBL(&USRLIBL)
                CHGDTAARA  DTAARA(&PLIB/&LISTE (11 1990)) VALUE(&USRLIBL)
                CHGDTAARA  DTAARA(&PLIB/&LISTE (1 10)) VALUE(&CURLIB)
                SNDPGMMSG  MSG('Liste des bibliothèque (*USRLIBL) sauvegardée dans DTAARA' *BCAT &LISTE) MSGTYPE(*COMP)
                GOTO       CMDLBL(FIN)
             ENDDO

             IF         COND(&SAVRST *EQ 'RST' *OR &SAVRST *EQ '*RST') THEN(DO)

                IF         COND(&PLIB *EQ '*NONE') THEN(DO)
                   CALL       PGM(PADDLIBC) PARM(&LISTE &RSTCURLIB)
                   GOTO       CMDLBL(FIN)
                ENDDO
                ELSE       CMD(DO)
                   CHKOBJ     OBJ(&PLIB/&LISTE) OBJTYPE(*DTAARA)
                   MONMSG     MSGID(CPF9801) EXEC(DO)
                      SNDPGMMSG  MSG('Dtaara' *BCAT &LISTE *BCAT 'non trouvée dans bibliothèque' *BCAT &PLIB *TCAT +
                                   '.') MSGTYPE(*COMP)
                      GOTO       CMDLBL(FIN)
                   ENDDO
                ENDDO

                RTVJOBA    USRLIBL(&USRLIBL)

                CHGVAR     VAR(&P) VALUE(1)
 LOOP_1:        CHGVAR     VAR(&LIB) VALUE(%SST(&USRLIBL &P 10))
/*           IF         COND(&LIB *NE ' ' *AND &LIB *NE 'QTEMP') +      */
                IF         COND(&LIB *NE ' ') THEN(DO)
                   RMVLIBLE   LIB(&LIB)
                ENDDO
                CHGVAR     VAR(&P) VALUE(&P + 11)
                IF         COND(%SST(&USRLIBL &P 1) *NE ' ') THEN(GOTO CMDLBL(LOOP_1))

                IF         COND(&RSTCURLIB *EQ '*YES') THEN(DO)
                   RTVDTAARA  DTAARA(&PLIB/&LISTE (1 10)) RTNVAR(&CURLIB)

                   IF         COND(&CURLIB *EQ '*NONE') THEN(DO)
                      CHGCURLIB  CURLIB(*CRTDFT)
                   ENDDO
                   ELSE       CMD(DO)
                      CHGCURLIB  CURLIB(&CURLIB)
                      MONMSG     MSGID(CPF0000) EXEC(DO)
                         SNDPGMMSG  MSG('Impossible de rétablir la bibliothèque courante (' *TCAT &CURLIB *TCAT ')') MSGTYPE(*COMP)
                         GOTO       CMDLBL(FIN)
                      ENDDO
                   ENDDO
                ENDDO

                CHGVAR     VAR(&P) VALUE(11)
 LOOP_2:        RTVDTAARA  DTAARA(&PLIB/&LISTE (&P 10)) RTNVAR(&LIB)
                IF         COND(%TRIM(&LIB) *EQ ' ') THEN(DO)
                   SNDPGMMSG  MSG('Liste des bibliothèque (*USRLIBL) restaurée depuis DTAARA' *BCAT &LISTE) MSGTYPE(*COMP)
                   GOTO       CMDLBL(FIN)
                ENDDO
 /*          IF         COND(&LIB *NE 'QTEMP') THEN(DO)   +
             ADDLIBLE   LIB(&LIB) POSITION(*LAST)         +
             ENDDO     */
                ADDLIBLE   LIB(&LIB) POSITION(*LAST)
                CHGVAR     VAR(&P) VALUE(&P + 11)
                GOTO       CMDLBL(LOOP_2)
             ENDDO

 FIN:        ENDPGM
