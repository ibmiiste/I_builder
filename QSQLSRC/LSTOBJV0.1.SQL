-- >>PRE-COMPILER<<                                              */
--   >>CRTCMD<<  RUNSQLSTM SRCFILE(&SL/&SF) SRCMBR(&SM);         */
--   >>IMPORTANT<<                                               */
--     >>PARM<<  COMMIT(*NONE);                                  */
--     >>PARM<<  NAMING(*SQL);                                   */
--     >>PARM<<  DFTRDBCOL(&LI);                                 */
--   >>END-IMPORTANT<<                                           */
--   >>EXECUTE<<                                                 */
-- >>END-PRE-COMPILER<<                                          */
LABEL ON COLUMN LIST_OBJET_BUILD
(   OBJ_NUMBER IS 'Numéro objet',
	LOT_NUMBER IS 'Numéro de lot',
	ORDRE      IS 'Ordre de création   dans le lot',
	Bibliotheque_Source
	           IS 'Bibliothèque        Source',        
	Fichier_Source
	           IS 'Fichier             Source',
	Membre_Source
	           IS 'Membre              Source',
	Type_source
	           IS 'Type de             Source',
	Bibliotheque_Destination
	           IS 'Bibliothèque        Objet',
	Objet_Destination
	           IS 'Nom objet           Destination',
	Type_objet IS 'Type                Objet',
	Attribut_Objet
	           IS 'Attribut            Objet'
	
) ;
