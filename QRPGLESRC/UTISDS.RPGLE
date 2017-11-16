       // ne plus utiliser
       // à remplacer par : dcl-ds <nom_ds> psds likeds(pgmds_t)
        /eof

      /if defined(utisds)
       /eof
      /endif

      /define utisds

       DCL-DS pgm_stat PSDS;
          sds_prog *PROC;
          sds_status *STATUS;
          sds_routine *ROUTINE;
          sds_msgid CHAR(7) POS(40);
          sds_msgdta CHAR(80) POS(91);
          sds_jobnm CHAR(10) POS(244);
          sds_usrnm CHAR(10) POS(254);
          sds_jobnr CHAR(6) POS(264);
          sds_user CHAR(10) POS(358);
          sds_parms *PARMS;
          sds_jobDate ZONED(6) POS(276);
       END-DS;

       DCL-S sds_cuser CHAR(10) INZ(*USER);     //utilisteur en cours
