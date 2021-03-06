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

      /copy qcpysrc,prtbuilder

      /copy qcpysrc,Inhbuilder

       Dcl-S g_PreBibSrc LIKE(r_Nom_obj_IBMi);
       Dcl-S g_PreFicSrc LIKE(r_Nom_obj_IBMi);
       Dcl-S g_UseSrcMbr LIKE(r_Nom_obj_IBMi);
       Dcl-S g_BibDst LIKE(r_Nom_obj_IBMi);
       Dcl-S g_ObjDst LIKE(r_Nom_obj_IBMi);
       Dcl-S g_BibSrc LIKE(r_Nom_obj_IBMi);
       Dcl-S g_FicSrc LIKE(r_Nom_obj_IBMi);
       Dcl-S g_MbrSrc LIKE(r_Nom_obj_IBMi);
       Dcl-S g_Optimize CHAR(20);
       Dcl-S g_Failed packed(10:0);
       Dcl-S g_FileAttach char(10000);
       Dcl-S g_TypObj like(R_TypObj);
       Dcl-S g_Exists Ind;

       Dcl-Pr Test_Construct_RPG_PGM end-pr;
       Dcl-Pr Test_Construct_RPGLE_MOD_NONE end-pr;
       Dcl-Pr Test_Construct_RPGLE_MOD_FULL end-pr;
       Dcl-Pr Test_Construct_SQLRPGLE_MOD_NONE end-pr;
       Dcl-Pr Test_Construct_SQLRPGLE_MOD_FULL end-pr;
       Dcl-Pr Test_Construct_RPGLE_PGM_NONE end-pr;
       Dcl-Pr Test_Construct_RPGLE_PGM_FULL end-pr;
       Dcl-Pr Test_Construct_SQLRPGLE_PGM_NONE end-pr;
       Dcl-Pr Test_Construct_SQLRPGLE_PGM_FULL end-pr;
       Dcl-Pr Test_Construct_CLLE_MOD_NONE end-pr;
       Dcl-Pr Test_Construct_CLLE_PGM_NONE end-pr;
       Dcl-Pr Test_Construct_TABLE End-Pr;
       Dcl-Pr Test_Construct_INDEX End-Pr;

       Dcl-proc Test_Construct_RPG_PGM export;
       Dcl-pi Test_Construct_RPG_PGM End-Pi;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDRPGPGM';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRRPGP';
         g_typobj='*PGM';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRRPGT';
         g_Optimize='*NONE';

          Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*PGM');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_RPG_PGM;

       Dcl-proc Test_Construct_RPGLE_MOD_NONE export;
       Dcl-pi Test_Construct_RPGLE_MOD_NONE End-Pi;


         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDRPGLMOD';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRRPGLEM';
         g_typobj='*MODULE';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRRPGLET';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*MODULE');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_RPGLE_MOD_NONE;

       Dcl-proc Test_Construct_RPGLE_MOD_FULL export;
       Dcl-pi Test_Construct_RPGLE_MOD_FULL End-Pi;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDRPGLMOD';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRRPGLEM';
         g_typobj='*MODULE';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRRPGLET';
         g_Optimize='*FULL';

          Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*MODULE');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_RPGLE_MOD_FULL;

       Dcl-proc Test_Construct_SQLRPGLE_MOD_NONE export;
       Dcl-pi Test_Construct_SQLRPGLE_MOD_NONE End-Pi;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDSQLRMOD';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRSQRPGLM';
         g_typobj='*MODULE';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRSQRPGLT';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*MODULE');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_SQLRPGLE_MOD_NONE;

       Dcl-proc Test_Construct_SQLRPGLE_MOD_FULL export;
       Dcl-pi Test_Construct_SQLRPGLE_MOD_FULL End-Pi;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDSQLRMOD';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRSQRPGLM';
         g_typobj='*MODULE';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRSQRPGLT';
         g_Optimize='*FULL';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*MODULE');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_SQLRPGLE_MOD_FULL;

       Dcl-proc Test_Construct_RPGLE_PGM_NONE export;
       Dcl-pi Test_Construct_RPGLE_PGM_NONE End-Pi;


         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDRPGLPGM';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRRPGLEP';
         g_typobj='*PGM';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRRPGLET';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*PGM');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_RPGLE_PGM_NONE;

       Dcl-proc Test_Construct_RPGLE_PGM_FULL export;
       Dcl-pi Test_Construct_RPGLE_PGM_FULL End-Pi;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDRPGLPGM';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRRPGLEP';
         g_typobj='*PGM';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRRPGLET';
         g_Optimize='*FULL';

          Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*PGM');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_RPGLE_PGM_FULL;

       Dcl-proc Test_Construct_SQLRPGLE_PGM_NONE export;
       Dcl-pi Test_Construct_SQLRPGLE_PGM_NONE End-Pi;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDSQLRPGM';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRSQRPGLP';
         g_typobj='*PGM';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRSQRPGLT';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*PGM');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_SQLRPGLE_PGM_NONE;

       Dcl-proc Test_Construct_SQLRPGLE_PGM_FULL export;
       Dcl-pi Test_Construct_SQLRPGLE_PGM_FULL End-Pi;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDSQLRPGM';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRSQRPGLP';
         g_typobj='*PGM';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRSQRPGLT';
         g_Optimize='*FULL';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*PGM');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_SQLRPGLE_PGM_FULL;

       Dcl-proc Test_Construct_CLP_PGM export;
       Dcl-pi Test_Construct_CLP_PGM End-Pi;

         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDCLPPGM';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRCLPP';
         g_typobj='*PGM';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRCLPT';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*PGM');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_CLP_PGM;

       Dcl-proc Test_Construct_CLLE_MOD_NONE export;
       Dcl-pi Test_Construct_CLLE_MOD_NONE End-Pi;


         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDCLLEMOD';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRRPGLEM';
         g_typobj='*MODULE';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRCLLET';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*MODULE');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_CLLE_MOD_NONE;


       Dcl-proc Test_Construct_CLLE_PGM_NONE export;
       Dcl-pi Test_Construct_CLLE_PGM_NONE End-Pi;


         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDCLLEPGM';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRCLLEP';
         g_typobj='*PGM';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRCLLET';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*PGM');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_CLLE_PGM_NONE;

       Dcl-proc Test_Construct_TABLE export;
       Dcl-pi Test_Construct_TABLE End-Pi;


         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDTABLE';
         g_BibDst='LOT_000124';
         g_ObjDst='LSTOBJBLD';
         g_typobj='*FILE';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRTABT';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*FILE');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_TABLE;

       Dcl-proc Test_Construct_INDEX export;
       Dcl-pi Test_Construct_INDEX End-Pi;


         g_PreBibSrc='LOT_000124';
         g_PreFicSrc='QBLDSCTSRC';
         g_UseSrcMbr='STDINDEX';
         g_BibDst='LOT_000124';
         g_ObjDst='MBRTABL01';
         g_typobj='*FILE';
         g_BibSrc='LOT_000124';
         g_FicSrc='QTESTUSRC';
         g_MbrSrc='MBRTABL01';
         g_Optimize='*NONE';

         Construct( g_PreBibSrc
                   :g_PreFicSrc
                   :g_UseSrcMbr
                   :g_BibDst
                   :g_ObjDst
                   :g_typobj
                   :g_BibSrc
                   :g_FicSrc
                   :g_MbrSrc
                   :g_Optimize
                   :g_Failed
                   :g_FileAttach);


         g_Exists=exists( g_ObjDst + g_BibDst:'*FILE');
         nEqual( *on:g_Exists);

       End-proc Test_Construct_INDEX;
