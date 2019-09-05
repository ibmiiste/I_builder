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
   DROP TABLE Liste_livraison_partition;
END;

CREATE TABLE Liste_livraison_partition for system name LIVRPART(
Part_livraison_id FOR COLUMN idpartlivr INTEGER  NOT NULL
GENERATED ALWAYS AS IDENTITY
   (MINVALUE 1
    MAXVALUE 999999999
   INCREMENT BY 1),
Project_Id FOR COLUMN  Idproject INTEGER, 
Partition_id FOR COLUMN  idpart INTEGER,
Ident_ip_dest FOR COLUMN idpartdst INTEGER,
Constraint Partition_id FOREIGN KEY(Partition_id) 
                         REFERENCES Liste_partition(Partition_id),
Constraint Ident_ip_dest FOREIGN KEY(Ident_ip_dest)
                         REFERENCES Liste_partition(Partition_id)) 
RCDFMT Partlivrf;

LABEL ON TABLE Liste_livraison_partition
	IS 'Partitions de livraison' ;

LABEL ON COLUMN Liste_livraison_partition 
( Part_livraison_id IS 'Identifiant' , 
    Project_Id IS 'Id Projet',
	Partition_id IS 'Id partition' , 
	Ident_ip_dest IS 'Id partition destination') ; 
  
LABEL ON COLUMN Liste_livraison_partition 
( Part_livraison_id TEXT IS 'Identifiant de destination' ,
  Project_Id TEXT IS 'Identifiant Projet', 
	Partition_id TEXT IS 'Id partition de départ' , 
	Ident_ip_dest TEXT IS 'Id partition de destination') ; 


GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON Liste_livraison_partition TO PUBLIC WITH GRANT OPTION ;

GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
ON Liste_livraison_partition TO QPGMR WITH GRANT OPTION ;