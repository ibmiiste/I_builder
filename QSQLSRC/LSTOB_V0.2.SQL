-- >>PRE-COMPILER<<                                              */
--   >>CRTCMD<<  RUNSQLSTM SRCFILE(&SL/&SF) SRCMBR(&SM);         */
--   >>IMPORTANT<<                                               */
--     >>PARM<<  COMMIT(*NONE);                                  */
--     >>PARM<<  NAMING(*SQL);                                   */
--     >>PARM<<  DFTRDBCOL(&LI);                                 */
--   >>END-IMPORTANT<<                                           */
--   >>EXECUTE<<                                                 */
-- >>END-PRE-COMPILER<<                                          */

-- Ajout Du suivi des modifs
ALTER TABLE LSTOBJBLD ADD COLUMN
TIMESTAMP_CREATION FOR COLUMN TIMECRT TIMESTAMP NOT NULL DEFAULT;

ALTER TABLE LSTOBJBLD ADD COLUMN
USER_CREATION FOR COLUMN USRCRT CHAR(10) CCSID 1147 NOT NULL DEFAULT '';

ALTER TABLE LSTOBJBLD ADD COLUMN
TIMESTAMP_MAJ FOR COLUMN TIMEMAJ TIMESTAMP FOR EACH ROW ON UPDATE
                                        AS ROW CHANGE TIMESTAMP NOT NULL;
                                        
ALTER TABLE LSTOBJBLD ADD COLUMN                                        
USER_MODIFICATION FOR COLUMN USRMAJ CHAR(10) CCSID 1147 NOT NULL DEFAULT '';            