      *------------------------------------------------------------------------*
      *  DESCRIPTION :                                                         *
      *  Procédures pour la gestion de la pile d'appel des programmes          *
      *                                                                        *
      *------------------------------------------------------------------------*
      * MAINTENANCE :                                                          *
      *  N°    AUTEUR                       OBJET                       DATE   *
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      **************************************************************************
      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  OBJ(&LI/&OB);                                   */
      *     >>PARM<<  OBJTYPE(*MODULE);                               */
      *     >>PARM<<  OPTION(*EVENTF);                                */
      *     >>PARM<<  RPGPPOPT(*LVL2);                                */
      *     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
      *     >>PARM<<  DATFMT(*ISO);                                   */
      *     >>PARM<<  TIMFMT(*ISO);                                   */
      *   >>END-IMPORTANT<<                                           */
      *   >>CMD<<  POSLIB SAVRST(*SAV) LISTE(*USER) LIB(QTEMP);       */
      *   >>CMD<<  POSLIB LISTE(LIBSAP) LIB(*NONE);                  */
      *   >>EXECUTE<<                                                 */
      *   >>CMD<<  POSLIB SAVRST(*RST) LISTE(*USER) LIB(QTEMP);       */
      * >>END-PRE-COMPILER<<                                          */
      ******************************************************************
       ctl-opt nomain;
       ctl-opt option(*srcstmt:*nodebugio:*nounref);

      * Call Stack
       DCL-PR findCaller extpgm('QWVRCSTK');
         *n char(2000);          //receiver
         *n int(10);             //receiver length
         *n char(8)  const;      //receiver format
         *n char(56);            //job id information
         *n char(8)  const;      //job id information format
         *n char(15);            //error code
       END-PR;

      *  Call Stack Data
       DCL-DS var len(2000) qualified;
         BytAvl      int(10);
         BytRtn      int(10);
         Entries     int(10);
         Offset      int(10);
         EntryCount  int(10);
       END-DS;

      *  Call Stack Job Information
       DCL-DS jobIdInf;
         JIDQName       char(26) inz('*');
         JIDIntID       char(16);
         JIDRes3        char(2) inz(*loval);
         JIDThreadInd   int(10) inz(1);
         JIDThread      char(8) inz(*loval);
       END-DS;

      *  Call Stack Program Names
       DCL-DS entry len(256) qualified;
         EntryLen  int(10);
         ReqstLvl  int(10) pos(21);
         PgmNam    char(10) pos(25);
         PgmLib    char(10) pos(35);
       END-DS;


       DCL-DS pgm_stat PSDS;
          sds_prog *PROC;
       END-DS;


     ***************************************************************************
     **                                                                       **
     **  stk_rtvCaller : récupère le programme appelant                       **
     **                                                                       **
     ***************************************************************************
       DCL-PROC stk_rtvCaller EXPORT;

         DCL-PI *n char(10);
           p_levels uns(5) options(*nopass) CONST; //nombre de niveaux attendus
         END-PI;

         //par défaut : le pgm ayant appelé le pgm appelant cette procédure
         dcl-s w_levels uns(5) inz(2); //le pgm appelant le pgm appelant cette procédure

         dcl-s varLen int(10) inz(%size(Var));
         dcl-s apiErr char(15);
         dcl-s i int(10);
         dcl-s j like(i);
         dcl-s whoCalled char(10);
         dcl-s prv_caller like(whoCalled);

         if %parms >= %parmnum(p_levels);
           w_levels = p_levels;
         endif;

         findCaller(var:varLen:'CSTK0100':jobIdInf:'JIDF0100':apiErr);

         for i = 1 to var.entryCount;
           entry = %subst(var:var.Offset + 1);
           if entry.pgmNam <> prv_caller;
             j +=1;
           endif;
           //le programme de la pile n'est pas ce programme et est d'un niveau suffisant
           If (entry.pgmNam <> sds_prog and j > w_levels);
             whoCalled = entry.pgmNam;
             leave;
           Endif;
           prv_caller = entry.PgmNam;
           var.Offset += entry.entryLen;
         endfor;

         return whoCalled; // le programme appelant

       END-PROC;


     ***************************************************************************
     **                                                                       **
     **  stk_isCaller : le programme désigné est appelant                     **
     **                                                                       **
     ***************************************************************************
       DCL-PROC stk_isCaller EXPORT;

         DCL-PI *n ind;
           p_programme char(10) const; //Programme appelant recherché dans la pile
         END-PI;

         dcl-s varLen int(10) inz(%size(Var));
         dcl-s apiErr char(15);
         dcl-s i int(10);
         dcl-s isCaller ind inz(*off);

         findCaller(var:varLen:'CSTK0100':jobIdInf:'JIDF0100':apiErr);

         for i = 1 to var.EntryCount;
           entry = %subst(var:var.Offset + 1);
           //le programme de la pile n'est pas ce programme et est d'un niveau suffisant
           If (%trim(entry.PgmNam) = %trim(p_programme));
             isCaller = *on;
             leave;
           Endif;
           var.offset += entry.EntryLen;
         endfor;

         return isCaller;

       END-PROC;


