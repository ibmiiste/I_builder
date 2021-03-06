--  G�n�rer SQL 
--  Version :                   	V7R3M0 160422 
--  G�n�r�e le :              	11/03/19 11:31:11 
--  Base donn�es relation :    	CICA00 
--  Option normes :          	Db2 for i 
BEGIN
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
      BEGIN END;
   DROP TABLE DEFINTION_LISTE;
END;

CREATE TABLE DEFINTION_LISTE FOR SYSTEM NAME DEFLSTLIB ( 
--  SQL150B   10   REUSEDLT(*NO) de la table DEFLSTLIB de I_BUILDER ignor�. 
--  SQL1506   30   Cl� ou attribut ignor� pour DEFLSTLIB de I_BUILDER. 
	LISTE FOR COLUMN LSTNAME CHAR(10) CCSID 297 NOT NULL DEFAULT '' , 
	DESCRIPTION FOR COLUMN LSTDESC CHAR(50) CCSID 297 NOT NULL DEFAULT '' , 
	TYPE_LISTE FOR COLUMN LSTTYPE CHAR(1) CCSID 297 NOT NULL DEFAULT '' , 
	DATE_CREATION FOR COLUMN LSTDATE DATE NOT NULL DEFAULT CURRENT_DATE , 
--  SQL150D   10   DATFMT ignor� pour la colonne LSTDATE. 
	HEURE_CREATION FOR COLUMN LSTTIME TIME NOT NULL DEFAULT CURRENT_TIME , 
	UTILISATEUR FOR COLUMN LSTUSER CHAR(10) CCSID 297 NOT NULL DEFAULT '' )   
	  
	RCDFMT FLIBLS1R   ; 
  
LABEL ON TABLE DEFLSTLIB 
	IS 'D�finition des listes de biblioth�que' ; 
  
LABEL ON COLUMN DEFLSTLIB 
( LSTNAME IS 'Liste' , 
	LSTDESC IS 'Description' , 
	LSTTYPE IS 'P=Public            V=Private' , 
	LSTDATE IS 'Date                cr�ation' , 
	LSTTIME IS 'Heure               cr�ation' , 
	LSTUSER IS 'Utilisateur' ) ; 
  
LABEL ON COLUMN DEFLSTLIB 
( LSTNAME TEXT IS 'Liste' , 
	LSTDESC TEXT IS 'Description' , 
	LSTTYPE TEXT IS 'P=Public V=Private' , 
	LSTDATE TEXT IS 'Date cr�ation' , 
	LSTTIME TEXT IS 'Heure cr�ation' , 
	LSTUSER TEXT IS 'Utilisateur' ) ; 
  
GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE   
ON DEFLSTLIB TO PUBLIC WITH GRANT OPTION ; 
  
GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE   
ON DEFLSTLIB TO QPGMR WITH GRANT OPTION ; 
  
