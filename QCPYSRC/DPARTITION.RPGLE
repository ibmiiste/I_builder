**FREE
// Partition
Dcl-ds Partition Extname('PARTITION') Qualified Template END-DS;


// --------------------------------------------------
// Procedure name: getPartitionConnection
// Purpose:        Récupération des propriétés de connexion d'une répartition
// Returns:        Paramètres de connexion de la partition
// Parameter:      partitionId => Identifiant de la PARTITION interrogée
// --------------------------------------------------
Dcl-Pr getPartitionConnection LIKEDS(Partition);
  partitionId LIKE(Partition.idPart) Const;
End-Pr;

