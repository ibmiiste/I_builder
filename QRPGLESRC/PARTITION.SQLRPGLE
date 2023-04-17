**FREE
ctl-opt nomain;

/Copy Qcpysrc,DPARTITION


// --------------------------------------------------
// Procedure name: getPartition
// Purpose:        Récupération des propriétés d'une répartition
// Returns:        Propriétés de la partition
// Parameter:      partitionId => Identifiant de la PARTITION interrogée
// --------------------------------------------------
Dcl-Proc getPartitionConnection export;
  Dcl-Pi *N LIKEDS(Partition);
    partitionId LIKE(Partition.idPart) Const;
  End-Pi;
  // Local fields

  Dcl-DS partitionGot LIKEDS(Partition);
  // Calculation specifications
  Exec sql Select system,
                  login,
                  passwd
             into :partitionGot.hostName,
                  :partitionGot.User,
                  :partitionGot.Password
             From Partitionlogins
            Where id = :partitionId;


  return partitionGot;
End-Proc;

