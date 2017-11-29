        Dcl-S g_flag packed(1:0);

         dsply 'Test RPGLE';
         EXEC SQL
           SELECT 1
             INTO :g_flag
             FROM sysibm.sysdummy1;

         *inlr=*on;


