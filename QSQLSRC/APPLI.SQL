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
   DROP TABLE APPLICATIONS;
END;

CREATE TABLE APPLICATIONS for system name APPLI(
ROWID_APPLI FOR COLUMN ROWIDAPPLI ROWID,
Application CHAR(10) CCSID 297 NOT NULL DEFAULT '',
descript_appli CHAR(50) CCSID 297 NOT NULL DEFAULT '')
RCDFMT APPLIF;

LABEL ON TABLE APPLICATIONS
	IS 'Applications-Progiciels-Logiciels' ;



GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON APPLICATIONS TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON APPLICATIONS TO QPGMR WITH GRANT OPTION ;   