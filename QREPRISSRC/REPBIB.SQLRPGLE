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
  Dcl-s l_Cmd Char(1024);


  // Positionnement en début de fichier
  EXEC SQL
    CLOSE Curs_Lots02;
  EXEC SQL
    DECLARE Curs_Lots02 CURSOR FOR
      SELECT Lot_Number,
             LIBELLE_LOTS
        FROM Lots
        ORDER BY Lot_Number ;
  EXEC SQL
    OPEN Curs_Lots02;

   EXEC SQL
     FETCH Curs_Lots02
       INTO :ds_Lots.Numlot,
            :ds_Lots.LIBELLOT;
   DOW Sqlcode = 0;

     ds_Lots.LIBELLOT=%scanrpl('''':'''''':ds_Lots.LIBELLOT);
     l_Cmd='CRTLIB LIB(L' + %Editc(ds_Lots.Numlot:'X') + ') TYPE(*TEST) ' +
            'TEXT(''' + ds_Lots.LIBELLOT + ''')';

     cmd_exec(l_Cmd);

     EXEC SQL
     FETCH Curs_Lots02
       INTO :ds_Lots.Numlot,
            :ds_Lots.LIBELLOT;
   Enddo;

   *Inlr= *On;
   Return;


