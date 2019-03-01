**FREE
// >>PRE-COMPILER<<                                            */
// >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
// >>IMPORTANT<<                                               */
//   >>PARM<<  OBJ(&LI/&OB);                                   */
//   >>PARM<<  COMMIT(*NONE);                                  */
//   >>PARM<<  OBJTYPE(*MODULE);                               */
//   >>PARM<<  OPTION(*EVENTF);                                */
//   >>PARM<<  RPGPPOPT(*LVL2);                                */
//   >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
//   >>PARM<<  DATFMT(*ISO);                                   */
//   >>PARM<<  TIMFMT(*ISO);                                   */
//   >>PARM<<  COMPILEOPT(&U0);                                */
// >>END-IMPORTANT<<                                           */
//  >>EXECUTE<<                                                */
// >>END-PRE-COMPILER<<                                        */
//Option de contrôle du programme
/copy qcpysrc,cpyctlstm
Ctl-opt bnddir('I_BUILDER');

//Héritage des classes de données

/copy Qcpysrc,Inhbuilder

// Procédure externe
/Copy Qcpysrc,Prtbuilder

// --------------------------------------------------
// Procedure name: Recup_erreur
// Purpose:        Lire le fichier des évènement et les cumuler dans u...
//                          ne table
// Returns:
// Parameter:      p_biblio_dest => Bibliothèque du fichier EVFEVENT
// Parameter:      p_Objet_destination => Membre du fichier EVFEVENT à...
//                           traiter
// --------------------------------------------------
DCL-PROC Recup_erreur Export;
  DCL-PI *N;
    p_biblio_dest LIKE(r_Nom_obj_IBMi);
    p_Objet_destination LIKE(r_Nom_obj_IBMi);
  END-PI ;

  Dcl-s l_Instruction_SQL Char(1024);
  Dcl-s l_emplacement Char(50);

  Dcl-ds ds_event_fileid qualified;
    Type_event Char(10) Pos(1);
    Source Char(271) Pos(29);
  End-ds;

  Dcl-ds ds_event_error qualified;
    MSGID Char(7) Pos(49);
    gravite Char(2) Pos(59);
    Ligne char(3) Pos(62);
    Texte_message Char(234) Pos(66);
  End-ds;

  Dcl-ds ds_event Extname('EVFEVENT') Qualified End-ds;

  Monitor;
    EXEC SQL
      SET OPTION COMMIT = *NONE;

    l_instruction_SQL='CREATE ALIAS QTEMP/' + %Trim(p_Objet_destination) +
                      ' FOR ' + %Trim(p_biblio_dest) + '/EVFEVENT (' +
                      %Trim(p_Objet_destination) + ')';

    EXEC SQL
      EXECUTE IMMEDIATE :L_Instruction_Sql;

    l_instruction_SQL='SELECT EVFEVENT ' +
                      'FROM QTEMP/' + %Trim(p_Objet_destination);

    IF NOT exists('ERRORLIST QTEMP     ' :'*FILE');
      EXEC SQL
        DECLARE GLOBAL TEMPORARY TABLE Errorlist
          (Bibliotheque CHAR(10),
                                               Objet CHAR(10),
                                               Gravite CHAR(2),
                                               Id_Message CHAR(7),
                                               Ligne CHAR(3),
                                               Text_Message CHAR(234),
                                               Emplacement CHAR(50))
          WITH REPLACE;
    Endif;

    EXEC SQL
      PREPARE Statment_Event FROM :L_Instruction_Sql;

    EXEC SQL
      DECLARE Curseur_Event CURSOR FOR Statment_Event;

    EXEC SQL
      OPEN Curseur_Event;

    EXEC SQL
      FETCH FROM Curseur_Event INTO :Ds_Event;

    Dow sqlcode<>100 and sqlcode>=0 ;
      If %subst(ds_event:1:10)='FILEID';
        ds_event_fileid=Ds_Event;
        l_emplacement=%subst(ds_event_fileid.source:1:%scan(')':
                                      ds_event_fileid.source));
      Endif;

      If %subst(ds_event:1:10)='ERROR';
        ds_event_error=Ds_Event;
        EXEC SQL
          INSERT INTO Qtemp.Errorlist
            VALUES (:P_Biblio_Dest,
                    :P_Objet_Destination,
                    :Ds_Event_Error.Gravite,
                    :Ds_Event_Error.Msgid,
                    :Ds_Event_Error.Ligne,
                    :Ds_Event_Error.Texte_Message,
                    :L_Emplacement);
      endif;
      EXEC SQL
        FETCH FROM Curseur_Event INTO :Ds_Event;
    Enddo;

    EXEC SQL
      CLOSE Curseur_Event;

    l_instruction_SQL='DROP ALIAS QTEMP/' + %Trim(p_Objet_destination);

    EXEC SQL
      EXECUTE IMMEDIATE :L_Instruction_Sql;

  On-error;
    Dump(a);
    Gest_erreur();
  Endmon;

  RETURN ;
END-PROC ;

