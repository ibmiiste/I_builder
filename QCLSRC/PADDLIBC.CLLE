/********************************************************************/
/*                                                                  */
/* 5770SS1 V7R1M0 100423 Sortie RTVCLSRC         12/07/17 13:42:06  */
/*                                                                  */
/* Nom du programme . . . . . . . . . . . . :   PADDLIBC          PN*/
/* Nom de la bibliothèque . . . . . . . . . :   BERGER            PL*/
/* Fichier source initial . . . . . . . . . :   QCLSRC            SN*/
/* Nom de la bibliothèque . . . . . . . . . :   MIAUT             SL*/
/* Membre source initial  . . . . . . . . . :   PADDLIBC          SM*/
/* Modification du fichier source                                   */
/*   date/heure . . . . . . . . . . . . . . :   17/01/17 11:08:33 SC*/
/* Option de modification . . . . . . . . . :   *NOPATCH          PO*/
/* Profil utilisateur . . . . . . . . . . . :   *USER             UP*/
/* Texte  . . : Positionnement liste de bibliothèques             TX*/
/* Propriétaire . . . . . . . . . . . . . . :   QPGMR             OW*/
/* Marquage modification utilisateur  . . . :   *YES              UM*/
/* Extraire source inclus   . . . . . . . . :   *NO               RI*/
/*                                                                ED*/
/*    /********************************************************************/
      /* >>PRE-COMPILER<<                                                 */
      /*   >>CRTCMD<<  CRTBNDCL PGM(&LI/&OB) SRCFILE(&SL/&SF) +           */
      /*                 SRCMBR(&SM);                                     */
      /*   >>IMPORTANT<<                                                  */
      /*     >>PARM<<  OPTION(*EVENTF);                                   */
      /*     >>PARM<<  DBGVIEW(*LIST);                                    */
      /*   >>END-IMPORTANT<<                                              */
      /*   >>CMD<<  RUNSQL SQL('DECLARE GLOBAL TEMPORARY TABLE WLIBLST2 + */
      /*                   LIKE FLIBLST2 WITH REPLACE');                  */
      /*   >>EXECUTE<<                                                    */
      /* >>END-PRE-COMPILER<<                                             */
             PGM        PARM(&LSTLIB &RSTCURLIB)

             DCL        VAR(&LSTLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RTNLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SQL) TYPE(*CHAR) LEN(400)
             DCL        VAR(&RSTCURLIB) TYPE(*CHAR) LEN(4)
             DCL        VAR(&RSTCURLIB2) TYPE(*CHAR) LEN(4)

             DCLF       FILE(QTEMP/WLIBLST2)
             MONMSG     MSGID(CPF0000)

             CLOF       OPNID(WLIBLST2)
             MONMSG     MSGID(CPF0000)

             DLTF       FILE(QTEMP/WLIBLST2)
             MONMSG     MSGID(CPF0000)

             IF         COND(%ADDR(&RSTCURLIB) *EQ *NULL) THEN(DO)
                CHGVAR     VAR(&RSTCURLIB2) VALUE('*YES')
             ENDDO
             ELSE       CMD(DO)
                CHGVAR     VAR(&RSTCURLIB2) VALUE(&RSTCURLIB)
             ENDDO

             ADDLIBLE   LIB(BERGER) POSITION(*LAST)
             MONMSG     MSGID(CPF0000)

             RTVOBJD    OBJ(FLIBLST2) OBJTYPE(*FILE) RTNLIB(&RTNLIB)
             CHGVAR     VAR(&SQL) VALUE('DECLARE GLOBAL TEMPORARY TABLE WLIBLST2 AS (SELECT * FROM' *BCAT &RTNLIB *TCAT '.FLIBLST2 WHERE LSTNAME = ''' *TCAT &LSTLIB *TCAT ''') WITH DATA WITH REPLACE')
             RUNSQL     SQL(&SQL) COMMIT(*NONE) NAMING(*SQL)
             MONMSG     MSGID(CPF0000)

             OVRDBF     FILE(WLIBLST2) TOFILE(QTEMP/WLIBLST2) LVLCHK(*NO) SHARE(*YES)
             OPNQRYF    FILE((QTEMP/WLIBLST2)) KEYFLD((SEQLIB *DESCEND))
             CHGLIBL    LIBL(*NONE)
 LOOP:       RCVF
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(FIN))
             IF         COND(&SEQLIB *NE 0) THEN(DO)
             ADDLIBLE   LIB(&LIB)
             MONMSG     MSGID(CPF0000)
             ENDDO
             GOTO       CMDLBL(LOOP)
 FIN:        /*   RMVLIBLE LIB(&LIB)       */
             IF         COND(&LIB *NE ' ' *AND &LIB *NE '*NONE' *AND &RSTCURLIB2 *EQ '*YES') THEN(DO)
                CHGLIBL    CURLIB(&LIB)
             ENDDO
             ELSE       CMD(DO)
                IF         COND(&RSTCURLIB2 *EQ '*YES') THEN(DO)
                   CHGLIBL    CURLIB(*CRTDFT)
                ENDDO
             ENDDO
             CLOF       OPNID(WLIBLST2)
             DLTOVR     FILE(WLIBLST2)
             DLTF       FILE(QTEMP/WLIBLST2)
             MONMSG     MSGID(CPF0000)
             ENDPGM
