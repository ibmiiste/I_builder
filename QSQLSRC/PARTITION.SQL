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
   DROP TABLE Liste_partition;
END;

CREATE TABLE Liste_partition for system name Partition(
Partition_id FOR COLUMN idpart INTEGER  NOT NULL
GENERATED ALWAYS AS IDENTITY
   (MINVALUE 1
    MAXVALUE 999999999
   INCREMENT BY 1),
Project_Id FOR COLUMN  Idproject INTEGER,
IP_Address FOR COLUMN IPADDRESS CHAR(128),
Host_name FOR COLUMN Hostname CHAR(255))
RCDFMT Partitionf;

LABEL ON TABLE Liste_partition
	IS 'Liste des partition d''un projet' ;

LABEL ON COLUMN Liste_partition 
( Partition_id IS 'Identifiant' , 
	Project_Id IS 'Id projet' , 
	Ip_Address IS 'Adresse Ip' , 
	Host_name IS 'Nom système hôte' ) ; 
  
LABEL ON COLUMN Liste_partition 
( Partition_id TEXT IS 'Identifiant unique de la partition' , 
	Project_Id TEXT IS 'Identifiant du projet' , 
	Ip_Address TEXT IS 'Adresse Ip de la partition' , 
	Host_name TEXT IS 'Nom d''hôte de la partition dans le domaine' ) ; 


GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON Liste_partition TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON Liste_partition TO QPGMR WITH GRANT OPTION ;