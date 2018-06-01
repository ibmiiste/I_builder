      * >>PRE-COMPILER<<
      *   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);
      *   >>IMPORTANT<<
      *     >>PARM<<  OBJ(&LI/&OB);
      *     >>PARM<<  OBJTYPE(*MODULE);
      *     >>PARM<<  OPTION(*EVENTF);
      *     >>PARM<<  RPGPPOPT(*LVL2);
      *     >>PARM<<  CLOSQLCSR(*ENDACTGRP);
      *     >>PARM<<  DATFMT(*ISO);
      *     >>PARM<<  TIMFMT(*ISO);
      *   >>END-IMPORTANT<<
      *   >>EXECUTE<<
      * >>END-PRE-COMPILER<<

        /copy Qcpysrc,cpyctlstm
       // --------------------------------------------------
       // Prototype for procedure: insertion
       // --------------------------------------------------
       DCL-PR insertion EXTPROC('INSERTION');
         BIBSRC CHAR(10);
         FICSRC CHAR(10);
         MBRSRC CHAR(10);
         TYPSRC CHAR(10);
         BIBDST CHAR(10);
         OBJDST CHAR(10);
         TYPOBJ CHAR(8);
         ATTOBJ CHAR(10);
       END-PR ;



       // --------------------------------------------------
       // Procedure name: insertion
       // Purpose:
       // Returns:
       // Parameter:      BIBSRC
       // Parameter:      FICSRC
       // Parameter:      MBRSRC
       // Parameter:      TYPSRC
       // Parameter:      BIBDST
       // Parameter:      OBJDST
       // Parameter:      TYPOBJ
       // Parameter:      ATTOBJ
       // --------------------------------------------------
       DCL-PROC insertion Export;
         DCL-PI *N;
           BIBSRC CHAR(10);
           FICSRC CHAR(10);
           MBRSRC CHAR(10);
           TYPSRC CHAR(10);
           BIBDST CHAR(10);
           OBJDST CHAR(10);
           TYPOBJ CHAR(8);
           ATTOBJ CHAR(10);
         END-PI ;
         // Your local fields go here
         IF TYPOBJ = '*PGM    '
         Or TYPOBJ = '*SRVPGM '
         OR Typobj = '*MODULE '
         Or Typobj = '*FILE   ';
         If typobj='*PGM    ';
           ficsrc='QPGMSRC';
           mbrsrc=objdst;
           typsrc='PGM';
         EndIf;

         If typobj='*SRVPGM    ';
           ficsrc='QSRVSRC';
           mbrsrc=objdst;
           typsrc='BND';
         EndIf;

         EXEC SQL INSERT INTO lot_000124.lstobjbld
         ( bibliotheque_source,
           fichier_source,
           membre_source,
           type_source,
           bibliotheque_destination,
           objet_destination,
           type_objet,
           attribut_objet)
           VALUES( :bibsrc,
                   :ficsrc,
                   :mbrsrc,
                   :typsrc,
                   :bibdst,
                   :objdst,
                   :typobj,
                   :attobj)
         ;
         Endif;
         // Your calculation code goes here

         RETURN ;
       END-PROC ;

