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
   DROP TABLE zz03pf;
END;

CREATE TABLE zz03pf(fic03 CHAR(10) CCSID 297 DEFAULT NULL,
                         bib03 CHAR(10) CCSID 297 DEFAULT NULL,
                         usr03 CHAR(10) CCSID 297 DEFAULT NULL,
                         tmsp03 TIMESTAMP DEFAULT NULL,
                         fich03 CHAR(10) CCSID 297 DEFAULT NULL)
    RCDFMT zz03pf;

LABEL ON TABLE zz03pf IS 'X-Ref - Liste des Fichiers Historiques';

GRANT ALTER,
      DELETE,
      INDEX,
      INSERT,
      REFERENCES,
      SELECT,
      UPDATE ON zz03pf TO PUBLIC
    WITH GRANT OPTION;

GRANT ALTER,
      DELETE,
      INDEX,
      INSERT,
      REFERENCES,
      SELECT,
      UPDATE ON zz03pf TO qpgmr
    WITH GRANT OPTION;