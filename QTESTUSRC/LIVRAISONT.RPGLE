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

       Dcl-S g_BibDst LIKE(R_NomObj);
       Dcl-S g_ObjDst LIKE(R_NomObj);
       Dcl-s g_option_donnees Char(1);
       Dcl-s P_Sys_Dst Char(32);
       Dcl-s p_User Like(R_NomObj);
       Dcl-s P_mot_de_passe Like(R_NomObj);

       Dcl-Pr Test_Livraison_Fic end-pr;


       Dcl-proc Test_Livraison_Fic export;
       Dcl-pi Test_Livraison_Fic End-Pi;


         g_BibDst='BFMIR';
         g_ObjDst='MIRTDB';
         g_option_donnees='C';
         P_Sys_Dst='CICA95';
         p_User='DRUBIGNY';
         P_mot_de_passe='DANIEL1E01';

         Livraison( g_ObjDst + g_BibDst
                   :g_option_donnees
                   :P_Sys_Dst
                   :P_User
                   :P_Mot_De_Passe);




       End-proc Test_Livraison_Fic;
