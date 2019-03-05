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
   DROP TABLE SOURCES_PRE_STANDARD;
END;

CREATE TABLE SOURCES_PRE_STANDARD for system name SRCPRESTD(
IDENTITY_SRCSTD FOR COLUMN IDENSRCST INTEGER  NOT NULL
GENERATED ALWAYS AS IDENTITY
   (MINVALUE 1
    MAXVALUE 999999999
   INCREMENT BY 1),
Type_Source FOR COLUMN TYPSRC CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Type_Objet FOR COLUMN TYPOBJ CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Biblio_Src_PRE FOR COLUMN PREBIBSRC CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Fichier_Src_PRE FOR COLUMN PREFICSRC CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Membre_Src_PRE FOR COLUMN PREMBRSRC CHAR(10) CCSID 297 NOT NULL DEFAULT ''
)
	
	RCDFMT SRCPRESTD;

LABEL ON TABLE SOURCES_PRE_STANDARD
	IS 'Liste des scripts PREPRC standards de création' ;



GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON SOURCES_PRE_STANDARD TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON SOURCES_PRE_STANDARD TO QPGMR WITH GRANT OPTION ;