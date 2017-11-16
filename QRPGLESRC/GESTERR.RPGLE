     h nomain debug

      * Déclaration des fichiers
     fMailInfol2if   e           k disk    USROPN
     FERRORLST  O    e             printer
     F                                     USROPN
     F                                     OFlInd(OverFlow)

      *?Déclaration de le PSDS
     d*copy qcpysrc,CPY_PSDS
      *
      * Copie API

      /Copy qcpysrc,STDMSGINFO

      * Programme data structure

     D  HlpText        DS
     D  HlpText01
     D  HlpText02
     D  HlpText03
     D  HlpText04
     D  HlpText05
     D  HlpText06
     D  HlpText07
     D  HlpText08
     D  HlpText09
     D  HlpText10
     D ScreenIn        DS
     D  Row8001                            OverLay(ScreenIn:1)
     D  Row8002                            OverLay(ScreenIn:*Next)
     D  Row8003                            OverLay(ScreenIn:*Next)
     D  Row8004                            OverLay(ScreenIn:*Next)
     D  Row8005                            OverLay(ScreenIn:*Next)
     D  Row8006                            OverLay(ScreenIn:*Next)
     D  Row8007                            OverLay(ScreenIn:*Next)
     D  Row8008                            OverLay(ScreenIn:*Next)
     D  Row8009                            OverLay(ScreenIn:*Next)
     D  Row8010                            OverLay(ScreenIn:*Next)
     D  Row8011                            OverLay(ScreenIn:*Next)
     D  Row8012                            OverLay(ScreenIn:*Next)
     D  Row8013                            OverLay(ScreenIn:*Next)
     D  Row8014                            OverLay(ScreenIn:*Next)
     D  Row8015                            OverLay(ScreenIn:*Next)
     D  Row8016                            OverLay(ScreenIn:*Next)
     D  Row8017                            OverLay(ScreenIn:*Next)
     D  Row8018                            OverLay(ScreenIn:*Next)
     D  Row8019                            OverLay(ScreenIn:*Next)
     D  Row8020                            OverLay(ScreenIn:*Next)
     D  Row8021                            OverLay(ScreenIn:*Next)
     D  Row8022                            OverLay(ScreenIn:*Next)
     D  Row8023                            OverLay(ScreenIn:*Next)
     D  Row8024                            OverLay(ScreenIn:*Next)

     D  Row13201                           OverLay(ScreenIn:1)
     D  Row13202                           OverLay(ScreenIn:*Next)
     D  Row13203                           OverLay(ScreenIn:*Next)
     D  Row13204                           OverLay(ScreenIn:*Next)
     D  Row13205                           OverLay(ScreenIn:*Next)
     D  Row13206                           OverLay(ScreenIn:*Next)
     D  Row13207                           OverLay(ScreenIn:*Next)
     D  Row13208                           OverLay(ScreenIn:*Next)
     D  Row13209                           OverLay(ScreenIn:*Next)
     D  Row13210                           OverLay(ScreenIn:*Next)
     D  Row13211                           OverLay(ScreenIn:*Next)
     D  Row13212                           OverLay(ScreenIn:*Next)
     D  Row13213                           OverLay(ScreenIn:*Next)
     D  Row13214                           OverLay(ScreenIn:*Next)
     D  Row13215                           OverLay(ScreenIn:*Next)
     D  Row13216                           OverLay(ScreenIn:*Next)
     D  Row13217                           OverLay(ScreenIn:*Next)
     D  Row13218                           OverLay(ScreenIn:*Next)
     D  Row13219                           OverLay(ScreenIn:*Next)
     D  Row13220                           OverLay(ScreenIn:*Next)
     D  Row13221                           OverLay(ScreenIn:*Next)
     D  Row13222                           OverLay(ScreenIn:*Next)
     D  Row13223                           OverLay(ScreenIn:*Next)
     D  Row13224                           OverLay(ScreenIn:*Next)
     D  Row13225                           OverLay(ScreenIn:*Next)
     D  Row13226                           OverLay(ScreenIn:*Next)
     D  Row13227                           OverLay(ScreenIn:*Next)

      * Prototypage fonction externe
     d mail_erreur     pr                  extproc(*cl : 'MAILERR')
     d a_program                           like(r_nomobj)
     d a_module                            like(r_nomobj)
     d a_procedure                   60
     d a_statement                         like(r_nomobj)
     d a_mail                       320

      * Prototypage fonctions locales
     d gest_erreur     pr
     d adress_mail     pr           320
     d Comp_Adr        pr           320
     d reference                     10

     d mail            s            320
      * Héritages des types
     d/copy QCPYSRC,INH32766

      * Constantes

      * Fonctions locales
     p gest_erreur     b                   export

     d gest_erreur     pi

      * DS locales

      * Variables locales

     D MsgBack         DS                  LikeDs(RCVM0300) Inz
     D InfoPtr         S               *
     D MsgInfo         DS                  LikeDs(RCVM0300SndRcvInfo)
     D                                     Based(InfoPtr)
     D i               S             10I 0
     D SetMsgKey       S              4    Inz(*ALLx'00')
     D BufferHandle    S             10I 0
     D BytesReturned   S             10I 0
     D DataPtr         S               *
     D CatchScreen     DS                  LikeDS(ScreenIn)
     D                                     Based(DataPtr)

      * Fonction principale
      /free
       Monitor;

       Open ErrorLst;
       Open MailInfol2;
       Write Head;
       ReceiveMsg(  MsgBack
                  : %size(MsgBack)
                  : 'RCVM0300'
                  : '*'
                  : 1
                  : '*PRV'
                  : SetMsgKey
                  : 0
                  : '*SAME'
                  : APIError);
       If MsgBack.ByteAvail > 0;
          MsgText = %SubSt(MsgBack.MsgData:
          MsgBack.LenReplace1 + 1:
          MsgBack.LenMsgReturn);
          HlpText = %SubSt(MsgBack.MsgData:
                           MsgBack.LenReplace1 +
                           MsgBack.LenMsgReturn + 1:
                           MsgBack.LenHelpReturn);
          InfoPtr = %Addr(MsgBack.MsgData)
                    + MsgBack.LenReplace1
                    + MsgBack.LenMsgReturn
                    + MsgBack.LenHelpReturn;
          Program = MsgInfo.ReceivingPgm;
          Module = MsgInfo.ReceivingModule;
          Proced = MsgInfo.ReceivingProcedure;
          Statement = MsgInfo.StateNosReceiving;

          Write Detail;
          If OverFlow;
             Write Head;
             OverFlow = *Off;
          EndIf;
       EndIf;

       BufferHandle = CreateInputBuffer( 27 * 132
                                       : *Omit
                                       : *Omit
                                       : *Omit
                                       : APIError );
       If APIError.BytesAvail = 0;
          BytesReturned = ReadScreen( *Omit
                                    : BufferHandle
                                    : *Omit
                                    : *Omit
                                    : *Omit );
          DataPtr = RetrieveDataPtr( BufferHandle
                                   : *Omit
                                   : *Omit );
          ScreenIn = %SubSt(CatchScreen:1:BytesReturned);
          For i = 1 to BytesReturned;
             If (%SubSt(ScreenIn:i:1) > x'19') And
                (%SubSt(ScreenIn:i:1) < x'40');
                %SubSt(ScreenIn:i:1) = *Blank;
             EndIf;
          EndFor;

          If BytesReturned = 1920;
             Write Screen80;
          Else;
             Write Screen132;
          EndIf;
       EndIf;
       Write Footer;
       mail=adress_mail();
       Close ErrorLst;
       Close MailInfol2;
         mail_erreur(   program
                      : module
                      : proced
                      : statement
                      : mail);
         return;

       On-error *all;
         dsply 'Arrrrgghhhh!!!!';
       endmon;
      /end-free
     p gest_erreur     e

     p adress_mail     b
     d adress_mail     pi           320
      * Variables locales
     d l_Adress_Mail   s            320

      /free
       reference=program;
       setll reference mailinfol2;
       if %equal();
          l_Adress_Mail=Comp_Adr(reference);
       else;
          reference='defaut';
          setll reference mailinfol2;
          if %equal();
             l_Adress_Mail=Comp_Adr(reference);
          endif;
       endif;

       return l_Adress_Mail;

      /end-free

     p adress_mail     e

     p Comp_Adr        b
     d Comp_Adr        pi           320
     d reference                     10
      * Variables locales
     d                 ds
     d l_Adress_Mail                320
     d t_Adress_Mail                 32    dim(10)
     d                                     overlay(l_Adress_Mail)
     d i               s              3  0
      /free
       reset l_adress_mail;
       reade reference mailinfol2;
       i=0;
       dow not %eof();
           i+=1;
           t_adress_mail(i)=AdrMail;
           reade reference mailinfol2;
       enddo;
       return l_adress_mail;
      /end-free

     p Comp_Adr        e
