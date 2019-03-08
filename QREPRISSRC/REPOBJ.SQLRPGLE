**FREE
// >>PRE-COMPILER<<                                              */
//   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
//   >>IMPORTANT<<                                               */
//     >>PARM<<  OBJ(&LI/&OB);                                   */
//     >>PARM<<  OBJTYPE(*PGM);                                  */
//     >>PARM<<  OPTION(*EVENTF);                                */
//     >>PARM<<  RPGPPOPT(*LVL2);                                */
//     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
//     >>PARM<<  DATFMT(*ISO);                                   */
//     >>PARM<<  TIMFMT(*ISO);                                   */
//     >>PARM<<  COMMIT(*NONE);                                  */
//     >>PARM<<  COMPILEOPT(&U0);                                */
//   >>END-IMPORTANT<<                                           */
// >>EXECUTE<<                                                   */
// >>END-PRE-COMPILER<<                                          */
/Copy Qcpysrc,cpyctlstm
/Copy Qcpysrc,inhbuilder
/Copy Qcpysrc,prtbuilder

  Dcl-ds ds_Lots Extname('LOTS') Qualified End-ds;
  Dcl-s i Packed(3:0);
  Dcl-s l_Cmd Char(1024);

  // Positionnement en début de fichier
  For i = 1 to 162;

     l_Cmd='RSTOBJ OBJ(*ALL) ' +
       'SAVLIB(LOT_000' + %Editc(i:'X') + ') ' +
       'DEV(*SAVF) ' +
       'SAVF(ARCHIVELOT/SAV_000' + %Editc(i:'X') + ') ' +
       'RSTLIB(L000000' + %Editc(i:'X') + ')';

     cmd_exec(l_Cmd);
    Endfor;

   *Inlr= *On;
   Return;


