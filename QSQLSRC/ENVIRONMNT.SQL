-- >>PRE-COMPILER<<                                              */
--   >>CRTCMD<<  RUNSQLSTM SRCFILE(&SL/&SF) SRCMBR(&SM);         */
--   >>IMPORTANT<<                                               */
--     >>PARM<<  COMMIT(*NONE);                                  */
--     >>PARM<<  NAMING(*SQL);                                   */
--     >>PARM<<  DFTRDBCOL(&LI);                                 */
--   >>END-IMPORTANT<<                                           */
--   >>EXECUTE<<                                                 */
-- >>END-PRE-COMPILER<<                                          */
BEGIN
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
      BEGIN END;
   DROP TABLE ENVIRONNMENTS;
END;

CREATE TABLE ENVIRONNMENTS for system name ENVIRONMNT(
ID_ENVIR FOR COLUMN IDENV SMALLINT NOT NULL
                     GENERATED ALWAYS AS IDENTITY
                         (START WITH 1 
                          INCREMENT BY 1 
                          CYCLE),
ENVIRONNEMENT FOR COLUMN ENVIRONMNT CHAR(10),
NOM_RESEAU_DNS FOR COLUMN NOMRESE VARCHAR(128), 
SYSTEME_DISTANT FOR COLUMN SYSDIST Char(1),
DESC_ENVIRONNEMENT FOR COLUMN DESCENVIR CHAR(50),
BIB_DATA FOR COLUMN BIBDTA CHAR(10) CCSID 297 NOT NULL DEFAULT '',
BIB_PROGRAMMES FOR COLUMN BIBPGM CHAR(10) CCSID 297 NOT NULL DEFAULT '',
BIB_SOURCES_PGM FOR COLUMN BIBSRCPGM CHAR(10) CCSID 297 NOT NULL DEFAULT '',
BIB_SOURCES_DTA FOR COLUMN BIBSRCDTA CHAR(10) CCSID 297 NOT NULL DEFAULT '')
   
RCDFMT ENVIRNMNTF;

LABEL ON TABLE ENVIRONNMENTS
	IS 'Environnement des applications' ;



GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON ENVIRONNMENTS TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON ENVIRONNMENTS TO QPGMR WITH GRANT OPTION ;   