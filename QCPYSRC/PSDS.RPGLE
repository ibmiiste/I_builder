      /if defined(PSDS_H)
        /eof
      /endif

      /define PSDS_H

      *

       dcl-ds Psds PSDS;
       // Nom de la procdure
         PROCEDURE *PROC;
       // code status
         ERROR *STATUS;
       // code status prcdent
         PRV_STATUS zoned(5) pos(16);
       // numéro line selon source
         LINE_NUM char(8) pos(21);
       // nom routine
         ROUTINE *ROUTINE;
       // nombre de paraèmtres reçus
         PARMS *PARMS;
       // type d'exception
         EXCP_TYPE char(3) pos(40);
       // numéro d'exception
         EXCP_NUM char(4) pos(43);
       // Work area for message
         Work_area_messages Char(30) Pos(51);
       // bib du programme
         PGM_LIB char(10) pos(81);
       // données d'exception
         EXCP_DATA char(80) pos(91);
       // ID exception
         EXCP_ID char(4) pos(171);
       // Name of file on which the last file operation occurred
         File_last_operation Char(10) Pos(175);
       // date (*DATE fmt)
         DATE_JOUR char(8) pos(191);
       // année (*YEAR fmt)
         YEAR zoned(2) pos(199);
       // dernier fichier utilisé
         LAST_FILE char(8) pos(201);
       // infomation erreur fichier
         FILE_INFO char(35) pos(209);
       // nom du travail
         JOB_NAME char(10) pos(244);
       // nom utilisateur
         USER char(10) pos(254);
       // numéro du travail
         JOB_NUM zoned(6) pos(264);
       //  date du travail  (UDATE fmt)
         JOB_DATE zoned(6) pos(270);
       // date lance travail  (UDATE fmt)
         RUN_DATE zoned(6) pos(276);
       // heure lance travail (UDATE fmt)
         RUN_TIME zoned(6) pos(282);
       // date de création
         CRT_DATE char(6) pos(288);
       // heure de création
         CRT_TIME char(6) pos(294);
       //  niveau de compilation
         CPL_LEVEL char(4) pos(300);
       // fichier source
         SRC_FILE char(10) pos(304);
       // bib source
         SRC_LIB char(10) pos(314);
       // membre source
         SRC_MBR char(10) pos(324);
       //  prog procedure is in
         PROC_PGM char(10) pos(334);
       // module procedure is in
         PROC_MOD char(10) pos(344);
       // Source Id matching the statement number from positions 21-28.
         Source_Id_statement_pos_21_28 Bindec(2);
       // Source Id matching the statement number from positions 228-235.
         Source_Id_statement_pos_228_235 Bindec(2);
       // Current user profile name.
         Current_user Char(10);
       // External error code
         External_error_code Int(10:0);
       //  Elements set by XML-INTO or DATA-INTO
         Element_XML_INTO_or_DATA_INTO Int(20:0);
       End-ds;
