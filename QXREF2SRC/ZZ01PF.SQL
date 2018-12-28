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
   DROP TABLE zz01pf;
END;

CREATE TABLE zz01pf(
type_enregistrement FOR COLUMN zztype CHAR(5) CCSID 297 NOT NULL DEFAULT '',
valeur_enregistrement FOR COLUMN zzvaleur
                                     CHAR(30) CCSID 297 NOT NULL DEFAULT '',
CONSTRAINT q_qgpl_zz01pf_zztype_00001 PRIMARY
                             KEY(type_enregistrement , valeur_enregistrement))
RCDFMT zz01pf;

LABEL ON TABLE zz01pf IS 'X-Ref - Fichier paramètre';

GRANT ALTER,
      DELETE,
      INDEX,
      INSERT,
      REFERENCES,
      SELECT,
      UPDATE ON zz01pf TO PUBLIC
    WITH GRANT OPTION;

GRANT ALTER,
      DELETE,
      INDEX,
      INSERT,
      REFERENCES,
      SELECT,
      UPDATE ON zz01pf TO qpgmr
    WITH GRANT OPTION;