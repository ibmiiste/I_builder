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
   DROP TABLE LOTS;
END;

CREATE TABLE LOTS (
ROWID_LOTS FOR COLUMN ROWIDLOTS ROWID,
LOT_NUMBER FOR COLUMN NUMLOT DECIMAL( 6, 0),
DESCRIPTION_LOTS FOR COLUMN DESCLOT 
                           CHAR(50) CCSID 1147 NOT NULL DEFAULT '',
LISTE_BIBLIO_PROJET FOR COLUMN LISTBIBPRJ CHAR(10) 
                                    CCSID 1147 NOT NULL DEFAULT '',
BIBLIO_LOT FOR COLUMN BIBLOT CHAR(10) CCSID 1147 NOT NULL DEFAULT '')
   
RCDFMT LOTSF;

LABEL ON TABLE LOTS
	IS 'Configuration des lots' ;



GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON LOTS TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON LOTS TO QPGMR WITH GRANT OPTION ;   