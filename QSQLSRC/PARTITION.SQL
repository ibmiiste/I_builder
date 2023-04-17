-- >>PRE-COMPILER<<                                              */
--   >>CRTCMD<<  RUNSQLSTM SRCFILE(&SL/&SF) SRCMBR(&SM);         */
--   >>IMPORTANT<<                                               */
--     >>PARM<<  COMMIT(*NONE);                                  */
--     >>PARM<<  NAMING(*SQL);                                   */
--     >>PARM<<  DFTRDBCOL(&LI);                                 */
--   >>END-IMPORTANT<<                                           */
--   >>EXECUTE<<                                                 */
-- >>END-PRE-COMPILER<<                                          */


CREATE OR REPLACE TABLE Liste_partition for system name Partition(
Partition_id FOR COLUMN idpart INTEGER  NOT NULL
GENERATED ALWAYS AS IDENTITY
   (MINVALUE 1
    MAXVALUE 999999999
   INCREMENT BY 1),
Project_Id FOR COLUMN  Idproject INTEGER,
IP_Address FOR COLUMN IPADDRESS CHAR(128),
Host_name FOR COLUMN Hostname CHAR(255),
User_connection FOR COLUMN User CHAR(10),
User_Password FOR COLUMN Password  VARCHAR(1024) FOR BIT DATA,
PRIMARY KEY(Partition_id))
RCDFMT Partitionf;

LABEL ON TABLE Liste_partition
	IS 'Liste des partitions d''un projet' ;

LABEL ON COLUMN Liste_partition 
( Partition_id IS 'Identifiant' , 
	Project_Id IS 'Id projet' , 
	Ip_Address IS 'Adresse Ip' , 
	Host_name IS 'Nom syst�me h�te',
	user_connection IS 'User connexion partition',
	User_Password IS 'Mot de Passe') ; 
  
LABEL ON COLUMN Liste_partition 
( Partition_id TEXT IS 'Identifiant unique de la partition' , 
	Project_Id TEXT IS 'Identifiant du projet' , 
	Ip_Address TEXT IS 'Adresse Ip de la partition' , 
	Host_name TEXT IS 'Nom d''h�te de la partition dans le domaine',
	user_connection TEXT IS 'Utilisateur IBMde  connexion partition',
	User_Password TEXT IS 'Mot de Passe') ; 


GRANT DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON Liste_partition TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON Liste_partition TO QPGMR WITH GRANT OPTION ;

SET ENCRYPTION PASSWORD = 'qEPiwICF35RuGIUjd3w2';        

CREATE OR REPLACE VIEW Partitionlogins( id, system, login, passwd) AS 
 SELECT Partition_id, Host_name,user_connection, DECRYPT_BIT(User_Password) 
 FROM Liste_partition;
 
GRANT SELECT
ON Partitionlogins TO PUBLIC WITH GRANT OPTION ;

GRANT ALL PRIVILEGES
ON Partitionlogins TO QPGMR WITH GRANT OPTION ;
 
 