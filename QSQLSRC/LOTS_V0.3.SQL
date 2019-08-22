-- >>PRE-COMPILER<<                                              */
--   >>CRTCMD<<  RUNSQLSTM SRCFILE(&SL/&SF) SRCMBR(&SM);         */
--   >>IMPORTANT<<                                               */
--     >>PARM<<  COMMIT(*NONE);                                  */
--     >>PARM<<  NAMING(*SQL);                                   */
--     >>PARM<<  DFTRDBCOL(&LI);                                 */
--   >>END-IMPORTANT<<                                           */
--   >>EXECUTE<<                                                 */
-- >>END-PRE-COMPILER<<                                          */

-- Ajout de lien internet  
ALTER TABLE LOTS ADD COLUMN Lien_ticket FOR COLUMN
                                              LNKTICKET DATALINK
; 

ALTER TABLE LOTS ADD COLUMN Lien_Branche_Git FOR COLUMN
                                              LNKGIT DATALINK
;           