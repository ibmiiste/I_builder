       ctl-opt nomain;
       ctl-opt option(*srcstmt:*nodebugio:*nounref);

       /copy *libl/qcpysrc,utiproc

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure exec      : lance une commande                      *
      *                                                               *
      * paramètre en entrée : la commande                             *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PROC cmd_exec EXPORT;

          DCL-PI *n;
             cmd varchar(1024) const;
          END-PI;

          qcmdexc(%trim(cmd):%len(%trim(cmd)));

       END-PROC;

      *---------------------------------------------------------------*
      *                                                               *
      * Procedure cmd_chk   : teste une commande                      *
      *                                                               *
      * paramètre en entrée : la commande                             *
      *                                                               *
      *---------------------------------------------------------------*
       DCL-PROC cmd_chk EXPORT;

          DCL-PI *n;
             cmd varchar(1024) const;
          END-PI;

          DCL-S long packed(15:5);

          long = %len(%trim(cmd));
          qcmdchk(cmd:long);

       END-PROC;
