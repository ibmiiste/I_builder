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
   DROP INDEX IDX_DEFINTION_LISTE_01;
END;
 
/* Creating IDX_LOTS02 [Index] */
CREATE UNIQUE INDEX IDX_DEFINTION_LISTE_01 FOR SYSTEM NAME DEFLSTLIB1  
          ON DEFINTION_LISTE(LISTE ASC) UNIT ANY;