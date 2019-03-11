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
   DROP INDEX IDX_GESTION_LISTE_BIBS_01;
END;
 
/* Creating IDX_LOTS02 [Index] */
CREATE UNIQUE INDEX IDX_GESTION_LISTE_BIBS_01 FOR SYSTEM NAME GSTLSTLIB1  
          ON GESTION_LISTE_BIBS(LISTE ASC, SEQUENCE ASC) UNIT ANY;