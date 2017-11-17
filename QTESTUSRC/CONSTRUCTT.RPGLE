      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  RUCRTTST SRCFILE(&SL/&SF) SRCMBR(&SM);          */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  TSTPGM(&LI/&OB);                                */
      *     >>PARM<<  DBGVIEW(*ALL);                                  */
      *     >>PARM<<  POPTION(*EVENTF);                               */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */
       ctl-opt NoMain bnddir('SERVICE');

      /copy RPGUNIT1,TESTCASE

      /copy qcpysrc,UtiProc

      /copy qcpysrc,Inh32766


       Dcl-pr Test_Construct_RPGLE end-pr;


       Dcl-proc Test_Construct_RPGLE export;
       Dcl-pi Test_Construct_RPGLE End-Pi;

         Dcl-S g_PreBibSrc LIKE(R_NomObj);
         Dcl-S g_PreFicSrc LIKE(R_NomObj);
         Dcl-S g_UseSrcMbr LIKE(R_NomObj);
         Dcl-S g_BibDst LIKE(R_NomObj);
         Dcl-S g_ObjDst LIKE(R_NomObj);
         Dcl-S g_BibSrc LIKE(R_NomObj);
         Dcl-S g_FicSrc LIKE(R_NomObj);
         Dcl-S g_MbrSrc LIKE(R_NomObj);
         Dcl-S g_Optimize CHAR(6);
         Dcl-S g_Failed packed(10:0);
         Dcl-S g_Exists Ind;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QTESTUSRC';
         g_UseSrcMbr='PRRPGLEMOD';
         g_BibDst='QTEMP';
         g_ObjDst='MBRRPGLET';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRRPGLET';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed);

         g_Exists=exists( g_ObjDst + g_BibDst:'*MODULE');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_RPGLE;
