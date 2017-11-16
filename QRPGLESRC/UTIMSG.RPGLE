      **************************************************************************
      * MODULE    : UTIMSG                  Date Création : 24/08/2016         *
      * AUTEUR    : D.LANDRAGIN                 Copyright : Ista France        *
      *------------------------------------------------------------------------*
      *  APPLICATION :                                                         *
      *  Services                                                              *
      *------------------------------------------------------------------------*
      *  DESCRIPTION :                                                         *
      *  Procédures pour la gestion des messages                               *
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
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */
      ******************************************************************
       ctl-opt nomain;
       ctl-opt bnddir('QSNAPI');
       ctl-opt option(*srcstmt:*nodebugio:*nounref);

      /copy qcpysrc,utiproc // prototypes et modèles

       dcl-s w_msglib char(10) inz('*LIBL');            //biblio fichier de messages
       dcl-s w_msgfic char(10) inz('QCPFMSG');          //fichier de messages
       dcl-s w_msgpgm char(10);            //programme de la file d'attente de messages
       dcl-s w_lowKey like(RCVM0300.MsgKey);            //Clé de début de bornage messages
       dcl-s w_hiKey like(RCVM0300.MsgKey);             //Clé de fin de bornage messages

     ***************************************************************************
     **                                                                       **
     **  APIError : Standard API Error data structure used with most APIs     **
     **                                                                       **
     ***************************************************************************
       DCL-DS APIError qualified;
          BytesProvided int(10) inz(%size(APIError));
          BytesAvail    int(10) inz(0);
          MsgId         char(7);
          *n            char(1);
          MsgData       char(240);
       END-DS;

     ***************************************************************************
     **                                                                       **
     **  RCVM0300 : DS returned by QMHRCVPM for format RCVM0300               **
     **                                                                       **
     ***************************************************************************
       DCL-DS RCVM0300 qualified based(DummyPtr);
          ByteReturned    int(10);
          ByteAvail       int(10);
          MsgSeverity     int(10);
          MsgId           char(7);
          MsgType         char(2);
          MsgKey          char(4);
          MsgFileName     char(10);
          MsgLibSpec      char(10);
          MsgLibUsed      char(10);
          AlertOption     char(9);
          CCSIDCnvIndText int(10);
          CCSIDCnvIndData int(10);
          CCSIDMsg        int(10);
          CCSIDReplace    int(10);
          LenReplace1     int(10);
          LenReplace2     int(10);
          LenMsgReturn    int(10);
          LenMsgAvail     int(10);
          LenHelpReturn   int(10);
          LenHelpAvail    int(10);
          LenSenderReturn int(10);
          LenSenderAvail  int(10);
          MsgData         char(5000);

       END-DS;

     ***************************************************************************
     **                                                                       **
     **  RCVM0300SndRcvInfo : Sender structure returned in RCVM0300           **
     **                                                                       **
     ***************************************************************************
       DCL-DS RCVM0300SndRcvInfo qualified based(DummyPtr);
          SendingJob                  char(10);
          SendIngJobProfile           char(10);
          SendingJobNo                char(6);
          DateSent                    char(7);
          TimeSent                    char(6);
          SendingType                 char(1);
          ReceivingType               char(1);
          SendingPgm                  char(12);
          SendingModule               char(10);
          SendingProcedure            char(256);
          *n                          char(1);
          NoStateNosSending           int(10);
          StateNosSending             char(30);
          ReceivingPgm                char(10);
          ReceivingModule             char(10);
          ReceivingProcedure          char(256);
          *n                          char(10);
          NoStateNosReceiving         int(10);
          StateNosReceiving           char(30);
          *n                          char(2);
          LongSendingPgmNameOffset    int(10);
          LongSendingPgmNameLength    int(10);
          LongSendingProcNameOffset   int(10);
          LongSendingProcNameLength   int(10);
          LongReceivingProcNameOffset int(10);
          LongReceivingProcNameLength int(10);
          MicroSeconds                char(6);
          SendingUsrPrf               char(10);
          Names                       char(4000);

       END-DS;

     ***************************************************************************
     **                                                                       **
     **  SndPgmMsg : Send Message to Program Message Queue                    **
     **                                                                       **
     ***************************************************************************
       DCL-PR SndPgmMsg ExtPgm('QMHSNDPM');
          ErrorMsgId   char(7) const;
          MsgFile      char(20) const;
          MsgData      char(3000) const;
          MsgDtaLen    int(10) const;
          MsgType      char(10) const;
          CallStack    char(19) const;
          CallStackCtr int(10) const;
          MsgKey       char(4);
          ErrorForAPI  like(APIError);
       END-PR;

     ***************************************************************************
     **                                                                       **
     **  ReceiveMsg : Receieve Message from Program Message Queue             **
     **                                                                       **
     ***************************************************************************
       DCL-PR ReceiveMsg ExtPgm('QMHRCVPM');
          //MsgInfo      varchar(3000);
          MsgInfo      like(RCVM0300);
          MsgInfoLen   int(10) const;
          FormatName   char(8) const;
          CallStack    char(10) const;
          CallStackCtr int(10) const;
          MsgType      char(10) const;
          MsgKey       char(4) const;
          WaitTime     int(10) const;
          MsgAction    char(10) const;
          ErrorForAPI  like(APIError);
       END-PR;

     ***************************************************************************
     **                                                                       **
     **  RtvMsg : Retrieve Message                                            **
     **                                                                       **
     ***************************************************************************
       DCL-PR RtvMsg ExtPgm('QMHRTVM');
          MsgInfo      like(RTVM0100_t);         //informations
          MsgInfoLen   int(10) const;          //lg informations
          FormatName   char(10) const;         //nom format informations
          MsgId        char(7) const;          //id message
          MsgQualFile  char(20) const;         //nom qualifié fichier messages
          MsgDta       varchar(512) const;     //données du message
          MsgDtaLen    int(10) const;          //lg données
          RplSubVal    char(10) const;
          RtnFmtChr    char(10) const;
          ErrorForAPI  like(APIError);
          RtvOpt       char(10) const options(*nopass);
          CvtCcsId     int(10)  const options(*nopass);
          RplCcsId     int(10)  const options(*nopass);
       END-PR;

       dcl-ds RTVM0100_t qualified template;
         BytRtn        int(10);
         BytAvl        int(10);
         RtnMsgLen     int(10);
         RtnMsgAvl     int(10);
         RtnHlpLen     int(10);
         RtnHlpAvl     int(10);
         Msg           varchar(1024);
       end-ds;

       DCL-DS sav_caughtMessage LikeDs(Base_CaughtMessage) inz; //dernier message traité

     ***************************************************************************
     **                                                                       **
     **  msg_retrieve : Récupération d'un message depuis un msgf              **
     **                 formaté avec des valeurs transmises                   **
     **                                                                       **
     ***************************************************************************
       DCL-PROC msg_retrieve EXPORT;

         dcl-pi *n varchar(1024);
           p_msgid   char(7) const;
           p_msgDta  varchar(512) const options(*omit:*nopass);
           p_msgFile char(10) const options(*nopass);
           p_msgLib  char(10) const options(*nopass);
         end-pi;

         dcl-s msgDta varchar(1024);
         dcl-s msgQualFile char(20);
         dcl-ds rtvm0100 likeds(RTVM0100_t);

         if %parms() >= %parmnum(p_msgDta) and %addr(p_msgDta) <> *null;
           msgdta = p_msgDta;
         endif;

         if %parms() >= %parmnum(p_msgFile);
           %subst(msgQualFile:1) = p_msgFile;
         elseif %subst(p_msgid:1:3) = 'CPF';
           %subst(msgQualFile:1) = 'QCPFMSG';
         elseif w_msgfic <> *blanks;
           %subst(msgQualFile:1) = w_msgfic;
         endif;

         if %parms() >= %parmnum(p_msgLib);
           %subst(msgQualFile:11) = p_msgLib;
         elseif w_msglib <> *blanks;
           %subst(msgQualFile:11) = w_msgLib;
         else;
           %subst(msgQualFile:11) = '*LIBL';
         endif;

         rtvMsg(rtvm0100
                 : %size(rtvm0100)
                 : 'RTVM0100'
                 : p_msgid
                 : msgQualFile
                 : msgdta
                 : %len(msgdta)
                 : '*YES'
                 : '*NO'
                 : APIError
                 );

         if  APIError.bytesAvail = 0;
           return  %subst(rtvm0100.msg:1:rtvm0100.rtnmsglen);
         else;
           return  ' ';
         endif;

       END-PROC;


     ***************************************************************************
     **                                                                       **
     **  msg_throw : Emission d'un message programme                          **
     **                                                                       **
     ***************************************************************************
       DCL-PROC msg_throw EXPORT;

          DCL-PI *n;
             MsgId char(7) const;
             MsgDataIn varchar(3000) const options(*Omit:*NoPass);
             MsgFileIn char(10) const options(*NoPass);
             MsgLibIn char(10) const options(*NoPass);
          END-PI;

          select;
            when %parms() = %parmnum(MsgLibIn);
              msg_send(MsgId:MsgDataIn:'*ESCAPE':MsgFileIn:MsgLibIn);
            when %parms() = %parmnum(MsgFileIn);
              msg_send(MsgId:MsgDataIn:'*ESCAPE':MsgFileIn);
            when %parms() = %parmnum(MsgDataIn);
              msg_send(MsgId:MsgDataIn);
            other;
              msg_send(MsgId);
          endsl;

       END-PROC;

     ***************************************************************************
     **                                                                       **
     **  msg_send : Emission d'un message programme avec choix du type de     **
     **             message                                                   **
     **                                                                       **
     **  Returns:   La clé du message généré                                  **
     ***************************************************************************

       DCL-PROC msg_send EXPORT;

         DCL-PI *n like(RCVM0300.MsgKey);
             MsgId char(7) const;
           MsgDataIn varchar(32767) const options(*omit:*nopass);
           MsgTypeIn char(10) const options(*nopass);
           MsgFileIn char(10) const options(*nopass);
           MsgLibIn char(10) const options(*nopass);
          END-PI;

          DCL-S w_lib char(10);
          DCL-S MsgFile char(20) Inz('QCPFMSG   QSYS      ');
          DCL-S MsgData varchar(32767);
          DCL-S MsgKey char(4);
          DCL-S MsgType char(10) Inz('*ESCAPE');

          //biblio du fichier de message
          if %parms() >= %parmnum(MsgLibIn);
             w_lib = MsgLibIn;
          endif;

          //type de message
          if %parms() >= %parmnum(MsgTypeIn);
            MsgType = MsgTypeIn;
          endif;

          //fichier de message
          if %parms() >= %parmnum(MsgFileIn);
             %subst(MsgFile:1:10) = MsgFileIn;
             if w_lib <> *blanks;
               %subst(MsgFile:11:10) = w_lib;
             else;
               %subst(MsgFile:11:10) = '*LIBL';
             endif;
          else;
             //fichier de messages de base CIS/ISTA
             if %subst(msgId:1:3) = 'BAS';
                %subst(MsgFile:1:10) = 'BASMSG';
                %subst(MsgFile:11:10) = '*LIBL';
             endif;
          endif;

          //données de message
          if %parms() >= %parmnum(MsgDataIn) and %addr(MsgDataIn) <> *Null;
             MsgData = MsgDataIn;
          endif;

          SndPgmMsg( MsgId
                     : MsgFile
                     : MsgData
                    : %Len(%Trimr(MsgData))
                     : MsgType
                     : '*'
                     : 1
                     : MsgKey
                     : APIError);
         return msgKey;

       END-PROC;

     ***************************************************************************
     **                                                                       **
     **  msg_catch : Capture d'un message programme                           **
     **                                                                       **
     ***************************************************************************
       DCL-PROC msg_catch EXPORT;

          DCL-PI *n LikeDs(Base_CaughtMessage) END-PI;

          DCL-DS CaughtMessage LikeDs(Base_CaughtMessage);
          DCL-DS MsgBack LikeDs(RCVM0300) Inz;

          DCL-S SetMsgKey char(4) Inz(*ALLx'00');

          clear CaughtMessage;
          ReceiveMsg( MsgBack
                     : %size(MsgBack)
                     : 'RCVM0300'
                     : '*'
                     : 1
                     : '*PRV'
                     : SetMsgKey
                     : 0
                     : '*REMOVE'
                     : APIError);
          if MsgBack.ByteAvail > 0;
             CaughtMessage.MsgId = MsgBack.MsgId;
             CaughtMessage.MsgFileName = MsgBack.MsgFileName;
             CaughtMessage.MsgLibName = MsgBack.MsgLibUsed;
             CaughtMessage.MsgText =
               %SubSt(MsgBack.MsgData:MsgBack.LenReplace1 + 1
                        :MsgBack.LenMsgReturn);
             if MsgBack.LenReplace1 > 0;
                CaughtMessage.MsgData =
                  %SubSt(MsgBack.MsgData:1:MsgBack.LenReplace1);
             endif;
          endif;
          sav_caughtMessage = CaughtMessage;
          return CaughtMessage;

       END-PROC;

     ***************************************************************************
     **                                                                       **
     **  msg_throw : Réémission d'un message programme                        **
     **                                                                       **
     ***************************************************************************
       DCL-PROC msg_throwBack EXPORT;

          DCL-PI *n;
             cm LikeDs(Base_CaughtMessage) const options(*nopass);
          END-PI;

          if %parms < %parmnum(cm) and sav_caughtMessage.msgId <> *blanks;
            msg_throw(sav_caughtMessage.msgId:
                      sav_caughtMessage.msgdata:
                      sav_caughtMessage.msgFileName:
                      sav_caughtMessage.msgLibName
                     );
          else;
             msg_throw(cm.msgId:cm.msgdata:cm.msgFileName:cm.msgLibName);
          endif;

       END-PROC;

       // --------------------------------------------------
       // Procedure name: msg_inz
       // Purpose:        initialisation de la gestion de messages programme
       // Returns:
       // Parameter:      p_msglib => Bibliothèque du fichier de messages
       // Parameter:      p_msgfic => Nom du fichier de messages
       // Parameter:      p_msgpgm => Programme dont on alimente la file de messages
       //                              (*prv par défaut)
       // --------------------------------------------------
       DCL-PROC msg_inz EXPORT;

         dcl-pi *n;
           p_msgfic char(10) const;
           p_msglib char(10) const options(*omit:*nopass);
           p_msgpgm char(10) const options(*nopass);
         end-pi;


         w_msgfic = p_msgfic;

         if %parms >= %parmnum(p_msglib) and %addr(p_msglib) <> *null;
           w_msglib = p_msglib;
         else;
           reset w_msglib;
         endif;

         if %parms >= %parmnum(p_msgpgm) and %addr(p_msgpgm) <> *null;
           if p_msgpgm = '*PRV' or p_msgpgm = '*prv';
             w_msgpgm = *blanks;
           else;
             w_msgpgm = p_msgpgm;
           endif;
         else;
           clear w_msgpgm;
         endif;


         return;

       END-PROC;

       // --------------------------------------------------
       // Procedure name: msg_clrq
       // Purpose:        RàB de la file d'attente de messages
       // Returns:
       // Parameter:      p_msgpgm => Programme pour lequel remettre la file ...
       //                          à blanc
       // --------------------------------------------------
       DCL-PROC msg_clrq EXPORT;

         dcl-pi *n;
           p_msgpgm char(10) const options(*nopass);
         end-pi;

         dcl-s msgpgm char(10);

         if %parms >= %parmnum(p_msgpgm);
           if p_msgpgm = '*PRV' or p_msgpgm = '*prv';
             msgpgm = *blanks;
           else;
             msgpgm = p_msgpgm;
           endif;
         elseif w_msgpgm <> *blanks;
           msgpgm = w_msgpgm;
         endif;

         EMS010C(w_msglib:
                 w_msgfic:
                 *blanks:
                 msgpgm:
                 *blanks:
                 *blanks:
                 *blanks:
                 *blanks:
                 *blanks:
                 '1');
         return;

       END-PROC;


       // --------------------------------------------------
       // Procedure name: msg_dsp
       // Purpose:        Affichage d'un message dans le s-f de la file du programme
       // Returns:
       // Parameter:      p_msgnum => Id message
       // Parameter:      p_msgdta => Chaine de données unique du message char(100)
       //
       // Remarque:       les chaines de données seront concaténées --> char(100)
       // --------------------------------------------------
       DCL-PROC msg_dsp EXPORT;

         dcl-pi *n;
           p_msgnum char(7) const;
           p_msgdta varchar(100) const options(*nopass);
         end-pi;

         dcl-s w_msgdt1 char(20);
         dcl-s w_msgdt2 char(20);
         dcl-s w_msgdt3 char(20);
         dcl-s w_msgdt4 char(20);
         dcl-s w_msgdt5 char(20);

         dcl-s long uns(3);

         if %parms >= %parmnum(p_msgdta) and %addr(p_msgdta) <> *null;
           long = %len(%trimr(p_msgdta));
           if long > 0;
             w_msgdt1 = %subst(p_msgdta:1);
             if long > 20;
               w_msgdt2 = %subst(p_msgdta:21);
               if long > 40;
                 w_msgdt3 = %subst(p_msgdta:41);
                 if long > 60;
                   w_msgdt4 = %subst(p_msgdta:61);
                   if long > 80;
                     w_msgdt5 = %subst(p_msgdta:81);
                   endif;
                 endif;
               endif;
             endif;
           endif;
         endif;

         EMS010C(w_msglib:
                 w_msgfic:
                 p_msgnum:
                 w_msgpgm:
                 w_msgdt1:
                 w_msgdt2:
                 w_msgdt3:
                 w_msgdt4:
                 w_msgdt5:
                 '0');
         return;

       END-PROC;

       // --------------------------------------------------
       // Procedure name: msg_chrmsg (même usage que la s-r CHRMSG)
       // Purpose:        Affichage d'un message dans le s-f de la file du programme
       // Returns:
       // Parameter:      p_msgnum => Id message
       // Parameter:      p_msgdt1 => Chaine de données 1 du message (optionnel)
       // Parameter:      p_msgdt2 => Chaine de données 2 du message (optionnel)
       // Parameter:      p_msgdt3 => Chaine de données 3 du message (optionnel)
       // Parameter:      p_msgdt4 => Chaine de données 4 du message (optionnel)
       // Parameter:      p_msgdt5 => Chaine de données 5 du message (optionnel)
       //
       // Remarque:       les chaines de données seront concaténées --> char(100)
       // --------------------------------------------------
       DCL-PROC msg_chrmsg EXPORT;

         dcl-pi *n;
           p_msgnum char(7) const;
           p_msgdt1 char(20) const options(*nopass);
           p_msgdt2 char(20) const options(*nopass);
           p_msgdt3 char(20) const options(*nopass);
           p_msgdt4 char(20) const options(*nopass);
           p_msgdt5 char(20) const options(*nopass);
         end-pi;

         dcl-s w_msgdt1 char(20);
         dcl-s w_msgdt2 char(20);
         dcl-s w_msgdt3 char(20);
         dcl-s w_msgdt4 char(20);
         dcl-s w_msgdt5 char(20);


         if %parms >= %parmnum(p_msgdt1) and %addr(p_msgdt1) <> *null;
           w_msgdt1 = p_msgdt1;
           if %parms >= %parmnum(p_msgdt2) and %addr(p_msgdt2) <> *null;
             w_msgdt2 = p_msgdt2;
             if %parms >= %parmnum(p_msgdt3) and %addr(p_msgdt3) <> *null;
               w_msgdt3 = p_msgdt3;
               if %parms >= %parmnum(p_msgdt4) and %addr(p_msgdt4) <> *null;
                 w_msgdt4 = p_msgdt4;
                 if %parms >= %parmnum(p_msgdt5) and %addr(p_msgdt5) <> *null;
                   w_msgdt5 = p_msgdt5;
                 endif;
               endif;
             endif;
           endif;
         endif;

         EMS010C(w_msglib:
                 w_msgfic:
                 p_msgnum:
                 w_msgpgm:
                 w_msgdt1:
                 w_msgdt2:
                 w_msgdt3:
                 w_msgdt4:
                 w_msgdt5:
                 '0');
         return;

       END-PROC;






       // --------------------------------------------------
       // Procedure name: msg_dspCaught
       // Purpose:        Affichage d'un message attrapé
       // Returns:
       // Parameter:      caughtMessage => le message attrapé
       // --------------------------------------------------
       DCL-PROC msg_dspCaught EXPORT;

         DCL-PI *N;
           caughtMessage likeds(base_caughtmessage) const;
         END-PI;

         msg_dsp(caughtMessage.MsgId:caughtMessage.Msgdata);

         return;

       END-PROC;

       // --------------------------------------------------
       // Procedure name: msg_sendStatus
       // Purpose:        Afficher un message de statut pendant le déroulement
       //                 du traitement
       // Returns:
       // Parameter:      msgId  => l'identifiant du message
       // Parameter:      msgDataIn  => les données du message
       // Parameter:      msgFileIn  => le fichier du message
       // Parameter:      msgLibIn  => la biblio du fichier de messages
       // --------------------------------------------------
       DCL-PROC msg_sendStatus EXPORT;

          DCL-PI *n;
             MsgId char(7) const;
             MsgDataIn varchar(32767) const options(*Omit:*NoPass);
             MsgFileIn char(10) const options(*NoPass);
             MsgLibIn char(10) const options(*NoPass);
          END-PI;

          DCL-S w_lib char(10);
          DCL-S w_file char(10);
          DCL-S MsgFile char(20) Inz('QCPFMSG   QSYS      ');
          DCL-S MsgData varchar(32767);
          DCL-S MsgKey char(4);
          DCL-S MsgType char(10) Inz('*STATUS');

          if %subst(msgId:1:3) <> 'CPF';
            //biblio du fichier de message
            if %parms() >= %parmnum(MsgLibIn);
              w_lib = MsgLibIn;
            else;
              w_lib = w_msglib;
            endif;

            //fichier de message
            if %parms() >= %parmnum(MsgFileIn);
              w_file = MsgFileIn;
            else;
              w_file = w_msgfic;
            endif;
            if w_file <> *blanks;
              %subst(MsgFile:1:10) = w_file;
              if w_lib <> *blanks;
                %subst(MsgFile:11:10) = w_lib;
              else;
                %subst(MsgFile:11:10) = '*LIBL';
              endif;
            //fichier de messages de base CIS/ISTA
            elseif %subst(msgId:1:3) = 'BAS';
              %subst(MsgFile:1:10) = 'BASMSG';
              %subst(MsgFile:11:10) = '*LIBL';
            endif;
          endif;

          //données de message
          if %parms() >= %parmnum(MsgDataIn) and %addr(MsgDataIn) <> *Null;
             MsgData = MsgDataIn;
          endif;

          SndPgmMsg( MsgId
                     : MsgFile
                     : %Trim(MsgData)
                     : %Len(%Trim(MsgData))
                     : '*STATUS'
                     : '*EXT'
                     : 0
                     : MsgKey
                     : APIError);
          return;

       END-PROC;




       // --------------------------------------------------
       // Procedure name: msg_dlg
       // Purpose:        Afficher une boite de dialogue et récupérer la répo...
       //                          nse de l'utilisateur
       // Returns:        Réponse sélectionnée par l'utilisateur
       // Parameter:      p_titre => Titre de la boite de dialogue
       // Parameter:      p_message => Message de la boite de dialogue
       // Parameter:      p_boutons => Boutons autorisés (somme des constantes BTN_OK...
       //                              déclarées dans PRSMOD000R)
       // Parameter:      p_dft_choix => Réponse par défaut (sera retenue si appui sur Entrée)
       // Parameter:      p_dspatr => Attributs d'affichage de la zone de texte (bleu par défaut)
       // --------------------------------------------------
       DCL-PROC msg_dlg EXPORT;

         DCL-PI *n uns(5);
           p_titre char(30) const options(*omit);
           p_message varchar(180) const;
           p_boutons uns(5) const;
           p_dft_choix uns(5) const options(*omit:*nopass);
           p_dspatr char(1) const options(*omit:*nopass);
         END-PI ;

         dcl-ds pgmToSys likeds(pgmToSys_t) inz(*likeds);

         dcl-f utimsge workstn indds(indds) infds(dspds) usropn;
         dcl-ds dspds likeds(dspds_t);
         dcl-ds f01ds likerec(f01diag:*all);

         DCL-S retField uns(5);
         DCL-S w_boutons uns(5);
         DCL-S w_mode char(1) inz('0');
         DCL-S w_dft_choix uns(5);
         DCL-S w_dspatr char(1);

         //indicateurs définis pour l'écran
         dcl-ds indds;
           dsp_btn_ok ind pos(61);      //Affichage du bouton OK
           dsp_btn_cancel ind pos(62);  //Affichage du bouton Annuler
           dsp_btn_abort ind pos(63);   //Affichage du bouton Abandonner
           dsp_btn_retry ind pos(64);   //Affichage du bouton réassayer
           dsp_btn_ignore ind pos(65);  //Affichage du bouton ignorer
           dsp_btn_yes ind pos(66);     //Affichage du bouton Oui
           dsp_btn_no ind pos(67);      //Affichage du bouton Non
           dsp_mode_132 ind pos(31);    //Affichage en environnement 27x132 (*ds4)
           dsp_mode_80 ind pos(32);     //Affichage en environnement 24x80  (*ds3)
         end-ds;

         //si aucun bouton autorisé, on n'affiche pas
         if p_boutons = 0;
           return 0;
         endif;

         if not %open(utimsge);
           open utimsge;
         endif;

         clear f01ds;

         //initialisation des indicateurs d'affichage
         %subst(indds:1) = *all'0';

         //adoption du format d'affichage en cours
         dsp_rtvMode(w_mode:*omit:*omit);
         if w_mode = '3';
           dsp_mode_132 = *off;
           dsp_mode_80 = *on;
         else;
           dsp_mode_132 = *on;
           dsp_mode_80 = *off;
         endif;


         //réponse par défaut (préselectionnée)
         if %parms >= %parmnum(p_dft_choix) and %addr(p_dft_choix) <> *null;
           w_dft_choix = p_dft_choix;
         endif;
         f01ds.choix = w_dft_choix; //TODO : NE FONCTIONNE PAS

         //affichage du titre
         if %parms >= %parmnum(p_titre) and %addr(p_titre) <> *null;
           f01ds.titre = p_titre;
         endif;

         //affichage du message d'interrogation
         f01ds.texte = p_message;

         //attributs d'affichage du message
         if %parms >= %parmnum(p_dspatr) and %addr(p_dspatr) <> *null;
           w_dspatr = p_dspatr;
         else;
           w_dspatr = pgmToSys.PR_GRN;
         endif;
         f01ds.atr_texte = w_dspatr;

         //Affichage des boutons autorisés
         w_boutons = p_boutons;

         if w_boutons >= BTN_NO;
           dsp_btn_no = *on;
           w_boutons -= BTN_NO;
         endif;

         if w_boutons >= BTN_YES;
           dsp_btn_yes = *on;
           w_boutons -= BTN_YES;
         endif;

         if w_boutons >= BTN_IGNORE;
           dsp_btn_ignore = *on;
           w_boutons -= BTN_IGNORE;
         endif;

         if w_boutons >= BTN_RETRY;
           dsp_btn_retry = *on;
           w_boutons -= BTN_RETRY;
         endif;

         if w_boutons >= BTN_ABORT;
           dsp_btn_abort = *on;
           w_boutons -= BTN_ABORT;
         endif;

         if w_boutons >= BTN_CANCEL;
           dsp_btn_cancel = *on;
           w_boutons -= BTN_CANCEL;
         endif;

         if w_boutons >= BTN_OK;
           dsp_btn_ok = *on;
           w_boutons -= BTN_OK;
         endif;

         //affichage de la boite de dialogue et récupération du choix
         dou f01ds.choix > 0;
           exfmt f01diag f01ds;
           //touche F12 peut remplacer BCN_CANCEL ou BTN_NO
           if dsp_btn_cancel and dspds.touche = KEY_CANCEL;
             f01ds.choix = BTN_CANCEL;
           elseif dsp_btn_no and dspds.touche = KEY_CANCEL;
             f01ds.choix = BTN_NO;
           elseif dspds.touche = KEY_ENTER and
            f01ds.choix = 0 and w_dft_choix <> 0;
             f01ds.choix = w_dft_choix;
           endif;
         enddo;

         retfield = f01ds.choix;

         close utimsge;

         return retField;
       END-PROC ;

       // --------------------------------------------------
       // Procedure name: msg_rtvByKey
       // Purpose:        Capture d'un message selon une clé
       // Returns:        Le message récupéré
       // Parameter:      La clé par rapport à laquelle on veut récupérer le message
       // Parameter:      l'entrée à récupérer : *ANY pour le message de la clé,
       //                                        *NEXT pour le suivant,
       //                                        *PRV pour le précédent
       // --------------------------------------------------
       DCL-PROC msg_rtvByKey EXPORT;

          DCL-PI *n LikeDs(Base_CaughtMessage);
            p_msgKey like(RCVM0300.MsgKey) const;
            p_msgType char(10) const;
          END-PI;

          DCL-DS caughtMessage LikeDs(Base_CaughtMessage);
          DCL-DS msgBack LikeDs(RCVM0300) Inz;

          DCL-S msgKey char(4) inz(*allx'00');

          if %parms >= %parmnum(p_msgkey) and %addr(p_msgkey) <> *null;
            msgkey = p_msgkey;
          endif;

          clear caughtMessage;
              ReceiveMsg(msgBack
                         : %size(msgBack)
                         : 'RCVM0300'
                         : '*'
                         : 0
                         : p_msgType
                         : msgKey
                         : 0
                         : '*SAME'
                         : APIError);
              if msgBack.ByteAvail > 0;
                caughtMessage.MsgId = msgBack.MsgId;
                caughtMessage.MsgFileName = msgBack.MsgFileName;
                caughtMessage.MsgLibName = msgBack.MsgLibUsed;
                caughtMessage.MsgText =
                  %SubSt(msgBack.MsgData:msgBack.LenReplace1 + 1
                           :msgBack.LenMsgReturn);
                if msgBack.LenReplace1 > 0;
                  caughtMessage.MsgData =
                    %SubSt(msgBack.MsgData:1:msgBack.LenReplace1);
                endif;
                caughtMessage.msgKey = msgBack.msgkey;
              endif;
          return caughtMessage;

       END-PROC;

       // --------------------------------------------------
       // Procedure name: msg_genLowKey
       // Purpose:        Génère une clé de message pour début de bornage historique
       //                   et réinitialise la borne de fin
       // Returns:        La clé du message générée
       // --------------------------------------------------
       DCL-PROC msg_genLowKey EXPORT;

         DCL-PI *n like(RCVM0300.MsgKey) END-PI;

         dcl-s msgKey like(RCVM0300.MsgKey);

         msgKey = msg_send('CPF9898':'Limite de début':'*INFO');
         w_lowKey = msgKey;
         w_HiKey = x'00000000';

         return msgKey;

       END-PROC;


       // --------------------------------------------------
       // Procedure name: msg_genHiKey
       // Purpose:        Génère une clé de message pour fin de bornage historique
       // Returns:        La clé du message générée
       // --------------------------------------------------
       DCL-PROC msg_genHiKey EXPORT;

         DCL-PI *n like(RCVM0300.MsgKey) END-PI;

         dcl-s msgKey like(RCVM0300.MsgKey);

         msgKey = msg_send('CPF9898':'Limite de fin':'*INFO');
         w_hiKey = msgKey;

         return msgKey;

       END-PROC;


       // --------------------------------------------------
       // Procedure name: msg_getLowKey
       // Purpose:        Récupération de la clé de message de début de bornage
       // Returns:        La clé du message de début
       // --------------------------------------------------
       DCL-PROC msg_getLowKey EXPORT;

         DCL-PI *n like(RCVM0300.MsgKey) END-PI;

         return w_lowKey;

       END-PROC;


       // --------------------------------------------------
       // Procedure name: msg_getHiKey
       // Purpose:        Récupération de la clé de message de fin de bornage
       // Returns:        La clé du message de fin
       // --------------------------------------------------
       DCL-PROC msg_getHiKey EXPORT;

         DCL-PI *n like(RCVM0300.MsgKey) END-PI;

         return w_hiKey;

       END-PROC;


