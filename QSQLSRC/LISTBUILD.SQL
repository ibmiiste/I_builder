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
   DROP TABLE LIST_OBJET_BUILD;
END;

CREATE TABLE LIST_OBJET_BUILD for system name LSTOBJBLD(
ROWID_BUILD FOR COLUMN ROWIDBUILD ROWID,
Projet CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Application CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Ordre DEC( 6, 0) NOT NULL DEFAULT 0,
Bibliotheque_Source FOR COLUMN BIBSRC CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Fichier_Source FOR COLUMN FICSRC CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Membre_Source FOR COLUMN MBRSRC CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Type_objet FOR COLUMN TYPOBJ CHAR(7) CCSID 297 NOT NULL DEFAULT '',
Bibliotheque_Destination
                    FOR COLUMN BIBDST CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Objet_Destination FOR COLUMN OBJDST CHAR(10) CCSID 297 NOT NULL DEFAULT '',
Type_source FOR COLUMN TYPOBJ CHAR(7) CCSID 297 NOT NULL DEFAULT ''
)
RCDFMT LSTOBJBLDF    ;

LABEL ON TABLE LIST_OBJET_BUILD
	IS 'Liste des objets a créer' ;



GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON LIST_OBJET_BUILD TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON LIST_OBJET_BUILD TO QPGMR WITH GRANT OPTION ;