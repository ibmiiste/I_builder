-- >>PRE-COMPILER<<                                              */
--   >>CRTCMD<<  RUNSQLSTM SRCFILE(&SL/&SF) SRCMBR(&SM);         */
--   >>IMPORTANT<<                                               */
--     >>PARM<<  COMMIT(*NONE);                                  */
--     >>PARM<<  NAMING(*SQL);                                   */
--     >>PARM<<  DFTRDBCOL(&LI);                                 */
--   >>END-IMPORTANT<<                                           */
--   >>EXECUTE<<                                                 */
-- >>END-PRE-COMPILER<<                                          */

-- Ajout d'un booléen indiquant si l'enregistement est actif ou non : inactif=0 Actif=1 
ALTER TABLE LOTS ADD COLUMN STATUT_ENREG FOR COLUMN
STATENREG NUMERIC ( 1, 0) NOT NULL WITH DEFAULT 1            