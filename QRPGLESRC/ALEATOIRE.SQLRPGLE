**FREE
// >>PRE-COMPILER<<                                              */
//   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
//   >>IMPORTANT<<                                               */
//     >>PARM<<  OBJ(&LI/&OB);                                   */
//     >>PARM<<  OBJTYPE(*MODULE);                               */
//     >>PARM<<  OPTION(*EVENTF);                                */
//     >>PARM<<  RPGPPOPT(*LVL2);                                */
//     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
//     >>PARM<<  DATFMT(*ISO);                                   */
//     >>PARM<<  TIMFMT(*ISO);                                   */
//   >>END-IMPORTANT<<                                           */
//   >>EXECUTE<<                                                 */
// >>END-PRE-COMPILER<<                                          */
ctl-opt nomain;

Dcl-proc aleatoire export;
  Dcl-pi aleatoire packed(15:0);
    mult packed(15:0) const;
  End-Pi;

  Dcl-pr CEERAN0;
    seed int(10);
    ranno float(8);
    fc char(12) options(*omit);
  end-pr;

  Dcl-s seed int(10) inz(0);
  Dcl-s rand Float(8);
  Dcl-s result packed(15:0);

  Monitor;
    CEERAN0( seed : rand : *omit );
    result = %inth(rand * mult);
  On-error;
    Dump(a);
    Gest_erreur();
  Endmon;

  // "result" now contains a number between 1 and mult.
  return result;
End-proc;
