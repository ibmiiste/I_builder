**FREE
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) +
//                 SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*ALL);
//     >>PARM<<  OPTIMIZE(&U0);
//     >>PARM<<  TRUNCNBR(*NO);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
ctl-opt nomain debug;

// Déclaration des fichiers
dcl-f MAILINFOL2 keyed usropn;
dcl-f ERRORLST printer usropn oflind(overflow);

// Prototypes fonctions externes
/Copy Qcpysrc,Prtbuilder

//?Déclaration de le PSDS
//copy qcpysrc,CPY_PSDS
//

// Programme data structure

dcl-ds HlpText;
  HlpText01;
  HlpText02;
  HlpText03;
  HlpText04;
  HlpText05;
  HlpText06;
  HlpText07;
  HlpText08;
  HlpText09;
  HlpText10;
end-ds;
dcl-ds ScreenIn;
  Row8001 pos(1);
  Row8002;
  Row8003;
  Row8004;
  Row8005;
  Row8006;
  Row8007;
  Row8008;
  Row8009;
  Row8010;
  Row8011;
  Row8012;
  Row8013;
  Row8014;
  Row8015;
  Row8016;
  Row8017;
  Row8018;
  Row8019;
  Row8020;
  Row8021;
  Row8022;
  Row8023;

  Row8024;
  Row13201 pos(1);
  Row13202;
  Row13203;
  Row13204;
  Row13205;
  Row13206;
  Row13207;
  Row13208;
  Row13209;
  Row13210;
  Row13211;
  Row13212;
  Row13213;
  Row13214;
  Row13215;
  Row13216;
  Row13217;
  Row13218;
  Row13219;
  Row13220;
  Row13221;
  Row13222;
  Row13223;
  Row13224;
  Row13225;
  Row13226;
  Row13227;
end-ds;

// Prototypage fonctions locales

dcl-s mail char(320);

// Héritages des types
 /copy QCPYSRC,Inhbuilder

// Constantes

// Fonctions locales
dcl-proc gest_erreur export;

dcl-pi gest_erreur end-pi;

// DS locales

// Variables locales

dcl-ds MsgBack likeds(rcvm0300) inz;
dcl-s InfoPtr pointer;
dcl-ds MsgInfo likeds(rcvm0300sndrcvinfo) based(infoptr);
dcl-s i int(10);
dcl-s SetMsgKey char(4) inz(*allx'00');
dcl-s BufferHandle int(10);
dcl-s BytesReturned int(10);
dcl-s DataPtr pointer;
dcl-ds CatchScreen likeds(screenin) based(dataptr);

  // Fonction principale
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
  Mailerr(   program
  : module
  : proced
  : statement
  : mail);
  On-error *all;
  dsply 'Arrrrgghhhh!!!!';
  endmon;

  return;
  end-proc;

  dcl-proc adress_mail;
  dcl-pi adress_mail char(320) end-pi;
  // Variables locales
  dcl-s l_Adress_Mail char(320);

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


  end-proc;

  dcl-proc Comp_Adr;
  dcl-pi Comp_Adr char(320);
    reference char(10);
  end-pi;
  // Variables locales
  dcl-ds *n;
    l_Adress_Mail char(320);
    t_Adress_Mail char(32) dim(10) overlay(l_adress_mail);
  end-ds;
  dcl-s i packed(3);
    reset l_adress_mail;
    reade reference mailinfol2;
    i=0;
    dow not %eof();
      i+=1;
      t_adress_mail(i)=AdrMail;
      reade reference mailinfol2;
    enddo;
    return l_adress_mail;

  end-proc;
