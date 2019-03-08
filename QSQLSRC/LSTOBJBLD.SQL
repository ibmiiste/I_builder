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
OBJ_NUMBER FOR COLUMN NUMOBJBLD INTEGER  NOT NULL
GENERATED ALWAYS AS IDENTITY
   (MINVALUE 1
    MAXVALUE 999999999
   INCREMENT BY 1),
LOT_NUMBER FOR COLUMN NUMLOT INTEGER,
Ordre DEC( 6, 0) NOT NULL DEFAULT 0,
Bibliotheque_Source FOR COLUMN BIBSRC CHAR(10) CCSID 1147 NOT NULL DEFAULT '',
Fichier_Source FOR COLUMN FICSRC CHAR(10) CCSID 1147 NOT NULL DEFAULT '',
Membre_Source FOR COLUMN MBRSRC CHAR(10) CCSID 1147 NOT NULL DEFAULT '',
Type_source FOR COLUMN TYPSRC CHAR(10) CCSID 1147 NOT NULL DEFAULT '',
Bibliotheque_Destination
                   FOR COLUMN BIBDST CHAR(10) CCSID 1147 NOT NULL DEFAULT '',
Objet_Destination FOR COLUMN OBJDST CHAR(10) CCSID 1147 NOT NULL DEFAULT '',
Type_objet FOR COLUMN TYPOBJ CHAR(10) CCSID 1147 NOT NULL DEFAULT '',
Attribut_Objet FOR COLUMN ATTOBJ CHAR(10) CCSID 1147 NOT NULL DEFAULT ''
)
RCDFMT LSTOBJBLDF;

LABEL ON TABLE LIST_OBJET_BUILD
	IS 'Liste des objets a créer' ;



GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON LIST_OBJET_BUILD TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON LIST_OBJET_BUILD TO QPGMR WITH GRANT OPTION ;