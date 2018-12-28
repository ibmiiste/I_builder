       // >>PRE-COMPILER<<                                            */
       // >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
       // >>IMPORTANT<<                                               */
       //   >>PARM<<  OBJ(&LI/&OB);                                   */
       //   >>PARM<<  COMMIT(*NONE);                                  */
       //   >>PARM<<  OBJTYPE(*PGM);                                  */
       //   >>PARM<<  OPTION(*EVENTF);                                */
       //   >>PARM<<  RPGPPOPT(*LVL2);                                */
       //   >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
       //   >>PARM<<  DATFMT(*ISO);                                   */
       //   >>PARM<<  TIMFMT(*ISO);                                   */
       //   >>PARM<<  COMPILEOPT(&U0);                                */
       // >>END-IMPORTANT<<                                           */
       //  >>EXECUTE<<                                                */
       // >>END-PRE-COMPILER<<                                        */

       ctl-opt debug option( *srcstmt: *nodebugio )
       copyright('Olivier Drubigny 2017-2018 X-Ref <Version v1.9.3>')
       datfmt(*eur) timfmt(*hms) datedit(*ymd) actgrp(*new) dftactgrp(*no);

     ?**----------------------------------------------------------------------**
     ?**---ZZ01 : outils d'analyse iSeries------------------------------------**
     ?**----------------------------------------------------------------------**

     ?**---Définition du fichier écran----------------------------------------**
       dcl-f ZZ01D workstn sfile(fzzsfl:fzzrrn) sfile(f02sfl:f02rrn)  // Sfl Principal
       sfile(f03sfl:f03rrn) sfile(f04sfl:f04rrn) sfile(f05sfl:f05rrn)
       sfile(f06sfl:f06rrn) sfile(f12sfl:f12rrn) indds(indicators) usropn;

     ?**---Fichier à description interne--------------------------------------**
       dcl-f FILE disk(32766) usage(*input: *output) usropn infds(psds);

     ?**---Définition du fichier Dump du Query--------------------------------**
       dcl-f DMPFIL disk(528) usropn block(*no);

     ?**---Définition du fichier imprimante en interne------------------------**
       dcl-f QSYSPRT printer(132) oflind(*inoa) formofl(66) formlen(66) usropn;

     ?**---Définition du fichier écran en interne-----------------------------**
       dcl-f ££ZZ01D workstn(80) usage(*output) usropn;

     ?**---Définition des Constantes------------------------------------------**
       dcl-c mdf const(300); // Longueur Texte
       dcl-c Version const('v1.9.3 '); // N° Version
       dcl-c lo const('abcdefghijklmnopqrstuvwxyz'); // Minuscules
       dcl-c up const('ABCDEFGHIJKLMNOPQRSTUVWXYZ'); // Majuscules
       dcl-c Clibl const('*LIBL'); // Liste Utilisateur
       dcl-c Cfile const('*FILE'); // Type fichier
       dcl-c Czz01pf const('ZZ01PF    '); // Fichier paramètre
       dcl-c Czz01ot const('ZZ01OUT   '); // Fichier paramètre
       dcl-c CPgmRef const('PGMREF    '); // Fichier PgmRef
       dcl-c CPgmRef1 const('PGMREF1   '); // Vue 1 sur Pgmref
       dcl-c CPgmRef2 const('PGMREF2   '); // Vue 2 sur Pgmref
       dcl-c CPgmRef3 const('PGMREF3   '); // Vue 3 sur Pgmref
       dcl-c Cobjd0200 const('OBJD0200'); // Description Objet
       dcl-c Cobjd0400 const('OBJD0400'); // Description Objet
       dcl-c EndOfFile const(100); // Fin de fichier SQL
       dcl-c InitAlloc const(100); // Taille Initiale Allo
       dcl-c SubsAlloc const(100); // Taille Allouée suppl
       dcl-c MaxTab const(32767); // Taille Max tableau
       dcl-c Auth_None x'0000'; // Autorisation objet
     ?**---Tableau chargé à la compilation------------------------------------**
       dcl-s Tb_Plugin char(55) dim(20) ctdata;
       dcl-s Nouv_Tab char(100) dim(20) ctdata;
       dcl-s Modifencours char(100) dim(mdf) ctdata;
       dcl-s F04desTab char(80) dim(24) ctdata;
       dcl-s Desc_Entete char(60) dim(48) ctdata;

     ?**---Autorisation par type d'objet--------------------------------------**
?    ?**   31 - 02|F02 - X-Ref                    |                           **
?    ?**   32 - 14|F14 - Where Used               ||                          **
?    ?**   33 - 07|F07 - Description Fichier      |||                         **
?    ?**   34 - 08|F08 - Logiques Fichier         ||||                        **
?    ?**   35 - 09|F22 - Recherche de caractères  |||||                       **
?    ?**   36 - 15|F15 - Carto. Programme         ||||||                      **
?    ?**   37 - 16|F16 - Carto. Source            |||||||                     **
?    ?**   38 - 20|F20 - Carto. Ile               ||||||||                    **
?    ?**   39 -                                   |||||||||                   **
?    ?**   40 - 06|F06 - Lancement d'une requête  ||||||||||                  **
       dcl-c OptFile const('0111100001'); // Autorisation fichier
       dcl-c OptPgm const('1100111100'); // Autorisation prog.
       dcl-c OptSrvPgm const('1110111100'); // Autorisation srvpgm
       dcl-c OptModule const('1000101100'); // Autorisation module
       dcl-c OptDtaara const('0100100000'); // Autorisation Dtaara
       dcl-c OptVide const('0000111000'); // Autorisation Analyse
       dcl-c OptQuery const('1100100001'); // Autorisation Query

?    ?**---Variables Types----------------------------------------------------**
       dcl-s £SysPtr pointer(*proc) based(dummy);
       dcl-s £Dyna char(128); // Type de tableau
       dcl-s £Heap int(10); // Heap Id
       dcl-s £Index int(10); // Index de tableau
       dcl-s £MasterTaille int(20); // Taille du tableau Ma
       dcl-s £StIndex int(5); // Index de sous-tablea
       dcl-s £Tab char(10); // Nom de tableau
       dcl-s £StTab char(20); // Nom de sous-tableau
       dcl-s £FeedBack char(12); // Message d'erreur
     ?**---Attributs d'un User Space------------------------------------------**
       dcl-ds £QUsAttr;
        *n int(10) inz(1); // QUsNumRec
        *n int(10) inz(3); // QUsKey
        *n int(10) inz(1); // QUsRecLen
        *n char(1) inz('1'); // QUsRecData
       end-ds;

     ?**---Définition des variables globales----------------------------------**
      **---Pointeur-----------------------------------------------------------**
       dcl-s PtrPlug pointer(*proc);
      **---Booléen------------------------------------------------------------**
       dcl-s Bib_Ok ind; // Liste Ok
       dcl-s Bib_Ok_Sav ind; // Liste Ok
       dcl-s Bib_Ok_Init ind inz(*on); // Liste Ok
       dcl-s Ctl_Fonct ind;
       dcl-s Car_Carte_C ind;
       dcl-s Car_Carte_D ind;
       dcl-s Car_Carte_F ind;
       dcl-s Car_Carte_P ind;
       dcl-s Car_Free ind;
       dcl-s Car_Proto ind;
       dcl-s F06_Obj ind;
       dcl-s F06_Src ind;
       dcl-s F06_Ref ind;
       dcl-s F06_Lig_Obj ind;
       dcl-s F06_Lig_Src ind;
       dcl-s F06_Lig_Ref ind;
       dcl-s F06ClrRef ind;
       dcl-s First ind;
       dcl-s First_Chk ind inz('1');
      **---Date/Heure/Timestamp-----------------------------------------------**
       dcl-s Datedujour date;
       dcl-s Heure time;
       dcl-s Zztmst timestamp;
      **---Alphanumérique-----------------------------------------------------**
       dcl-s OverRide char(1);
       dcl-s Stat char(1);
       dcl-s SpaceValue char(1) inz(x'00'); // Valeur du User Space
       dcl-s Spkg char(1); // Sql : WhSpkg
       dcl-s TrslScan char(1);
       dcl-s TrimScan char(1);
       dcl-s WildScan char(1);
       dcl-s SfRule char(1);
       dcl-s SfCompare char(2);
       dcl-s Lib_Temp char(6);
       dcl-s FormatName char(8);
       dcl-s FileFmt char(8) inz('FILD0100');
       dcl-s LstOutFmt char(8) inz('DBRL0100');
       dcl-s CJobI0700 char(8) inz('JOBI0700');
       dcl-s Outputsv char(8);
       dcl-s Qry char(10);
       dcl-s LZone char(10);
       dcl-s fmt char(10);
       dcl-s ObjEntry_Sav char(10);
       dcl-s ZzComp char(10);
       dcl-s ZzBib char(10);
       dcl-s ZzType char(10);
       dcl-s ZzFonc char(10); // Fonction utilisée
       dcl-s JobEntry char(10);
       dcl-s SpaceAuth char(10) inz('*USE'); // Autorisation User Sp
       dcl-s SpaceReplc char(10) inz('*YES'); // Remplacement du User
       dcl-s ObjectType char(10) inz('*ALL'); // Type d'objet
       dcl-s SpaceAttr char(10) inz; // Attribut du User Spa
       dcl-s CLPgmRef char(10); // Bibliothèque PgmRef
       dcl-s Nom_Comp char(10);
       dcl-s Bib char(10); // Bilbiothèque
       dcl-s Fnam char(10); // Objet Référencé
       dcl-s Pnam char(10); // Programme appelant
       dcl-s Lnam char(10); // Biblitohèque du réfé
       dcl-s Otyp char(10); // Type du référencé
       dcl-s Rfnm char(10); // Sql : WhRfnm
       dcl-s System char(10) inz('*LCL'); // Système
       dcl-s ObjChk char(10);
       dcl-s Format char(10);
       dcl-s XFile char(10);
       dcl-s XLib char(10);
       dcl-s Type char(10);
       dcl-s TypChk char(10);
       dcl-s LibChk char(10);
       dcl-s FmtType char(10) inz('*EXT');
       dcl-s Ignore char(10) inz;
       dcl-s RecordFmt char(10) inz('*FIRST');
       dcl-s LibRef char(10);
       dcl-s ListeBib char(10);
       dcl-s SrclibW char(11);
       dcl-s Trt char(12);
       dcl-s Rfsn char(13); // Sql : WhRfsn
       dcl-s Usage char(14); // Usage du fichier
       dcl-s Max_Date char(13);
       dcl-s Desc char(15); // Sql : WhText
       dcl-s Blan char(16) inz;
       dcl-s Object char(20);
       dcl-s Procedure char(20);
       dcl-s SFileLib char(20);
       dcl-s Proto_Name char(20); // nom du prototype
       dcl-s Proc_Encours char(20); // nom du prototype
       dcl-s RFileLib char(20);
       dcl-s Output char(30);
       dcl-s SfValue char(50);
       dcl-s Etoile char(26) inz('*');
       dcl-s InputDs char(28);
       dcl-s SavComp char(30);
       dcl-s SpaceText char(50) inz('User Space Temporaire'); // Libellé User Space
       dcl-s Text char(50);
       dcl-s Lst_Bnd char(50);
       dcl-s hd02 char(80);
       dcl-s hd03 char(80);
       dcl-s Ent01 char(132); // Ligne de l'Entête
       dcl-s Ent02 char(132); // Ligne de l'Entête
       dcl-s Ent03 char(132); // Ligne de l'Entête
       dcl-s Ent04 char(132); // Ligne de l'Entête
       dcl-s Ent05 char(132); // Ligne de l'Entête
       dcl-s Lig01 char(132); // Ligne de l'Entête
       dcl-s Det01 char(132); // Ligne de l'Entête
       dcl-s OvrCmd char(200); // Commande AS400
       dcl-s Fld char(256);
       dcl-s Req_Crt char(1000);
       dcl-s Req_Sql char(1000);
       dcl-s Requete0 char(1000); // Requête SQL
       dcl-s Requete1 char(1000); // Requête SQL
       dcl-s Requete2 char(1000); // Requête SQL
       dcl-s Requete4 char(1000); // Requête SQL
       dcl-s Requete5 char(1000); // Requête SQL
       dcl-s Requete6 char(1000); // Requête SQL
       dcl-s InPut char(1280);
       dcl-s SqlDefn char(10000);
       dcl-s All_File char(32767);
      **---Packé--------------------------------------------------------------**
       dcl-s StrScan packed(3);
       dcl-s LenSrcDta packed(3);
       dcl-s LenF01Obj packed(3);
       dcl-s SrcRet packed(3);
       dcl-s NbrL packed(5);
       dcl-s Rec packed(5);
      **---Etendu-------------------------------------------------------------**
       dcl-s Fusg packed(2); // Usage du fichier
       dcl-s I1 packed(4);
       dcl-s I2 packed(4);
       dcl-s NbrLogics packed(4);
       dcl-s FzzRrn packed(5) inz(0); // Rang d'enreg. FZZ
       dcl-s F02Rrn packed(5) inz(0); // Rang d'enreg. F02
       dcl-s F03Rrn packed(5) inz(0); // Rang d'enreg. F02
       dcl-s F04Rrn packed(5) inz(0); // Rang d'enreg. F02
       dcl-s F05Rrn packed(5) inz(0); // Rang d'enreg. F05
       dcl-s F06Rrn packed(5) inz(0); // Rang d'enreg. F06
       dcl-s F12rrn packed(5) inz(0); // Rang d'enreg. F12
       dcl-s i packed(5) inz(1); // Compteur
       dcl-s CptF22 packed(5) inz(1); // Compteur
       dcl-s Index_X packed(5);
       dcl-s SqlCpt packed(5) inz(1); // Compteur
       dcl-s IOff packed(5) inz(1); // Compteur
       dcl-s j packed(5) inz; // Compteur
       dcl-s k packed(5) inz; // Compteur
       dcl-s Nbr packed(5);
       dcl-s NbrMbr packed(5);
       dcl-s NbrFmt packed(5);
       dcl-s Pos_Comp packed(5);
       dcl-s Ind_Rappel packed(5);
       dcl-s IndRapWrk packed(5);
       dcl-s Cpt1 packed(5); // Compteur 1
       dcl-s Cpt2 packed(5); // Compteur 2
       dcl-s Cpt3 packed(5); // Compteur 3
       dcl-s Cpt4 packed(5); // Compteur 4
       dcl-s Cpt6 packed(5); // Compteur 6
       dcl-s Cpt7 packed(5); // Compteur 7
       dcl-s Cpt8 packed(5); // Compteur 8
       dcl-s Cpt_I packed(5); // Compteur 8
       dcl-s Id_Ile packed(5);
       dcl-s I_Ile packed(5);
       dcl-s Id_Ile_Premier packed(5);
       dcl-s Cpt_Ile packed(5);
       dcl-s prctage packed(5: 2);
       dcl-s Cpt_Ligne packed(8);
       dcl-s S packed(10);
       dcl-s OvrCmdLen packed(15: 5); // Longueur de la comma
      **---Entier signé-------------------------------------------------------**
       dcl-s lenmat int(5);
       dcl-s lenmatp int(5);
       dcl-s x int(5);
       dcl-s y int(5);
       dcl-s f int(10);
       dcl-s g int(10);
       dcl-s IndRef int(10);
       dcl-s Nbr_Poste int(10);
      **---Binaire------------------------------------------------------------**
       dcl-s Date_Null bindec(4);
       dcl-s jobilen bindec(4) inz(9999);
       dcl-s SpaceLen bindec(9) inz(maxtab); // Longueur du User Spa
       dcl-s StartPosit bindec(9); // Position dans le Use
       dcl-s StartLen bindec(9); // Longueur dans le Use
       dcl-s ReceiveLen bindec(9);
       dcl-s SaveLen bindec(9);
       dcl-s SaveStart bindec(9);
      **---Spécial Gestion Tableau--------------------------------------------**
       dcl-s NameTab dim(maxtab) like(£tab);
       dcl-s DynArrDsà pointer dim(maxtab);
       dcl-s Mat_Matrice dim(10) like(matriceds) inz;
       dcl-s HeapTab dim(maxtab) like(heapdef);
       dcl-s DynArr dim(maxtab) based(dynarrà) like(£dyna);
       dcl-s Name_Tab dim(maxtab) like(£sttab);
       dcl-s Master_Tab dim(maxtab) like(£tab);
       dcl-s Master_Size dim(maxtab) like(£index);
       dcl-s HeapMax like(£heap);
       dcl-s Identifiant like(£stindex) inz;
       dcl-s Heap_Tab dim(maxtab) like(heapdef);
      **---Entier non signé---------------------------------------------------**
       dcl-s Car_Copy uns(3);
       dcl-s Car_Slash uns(3);
       dcl-s Car_PtVirg uns(3);
       dcl-s Car_FreeBegin uns(3);
       dcl-s Car_FreeEnd uns(3);
       dcl-s Car_Comment uns(3);
       dcl-s Car_FiRoutine uns(3);
       dcl-s Car_SsRoutine uns(3);
       dcl-s Car_ExRoutine uns(3);
       dcl-s Car_Libl uns(3);
       dcl-s Car_Cas uns(3);
       dcl-s Niveau uns(3);
       dcl-s NbrProto uns(5) inz;
       dcl-s Cpt uns(5);

     ?**---Définition fichiers en entrée--------------------------------------**
       dcl-ds Lib_In qualified;
        File char(10);
        Lib char(10);
        *n char(10); // Mbr
        Fmt char(10);
       end-ds;
     ?**---Définition fichier en sortie---------------------------------------**
       dcl-ds Lib_Out qualified;
        File char(10);
        Lib char(10);
        *n char(10); // Mbr
       end-ds;
     ?**---DS du sous-fichier F06 : Gestion liste de bibliothèque-------------**
       dcl-s F06Fld char(132);
       dcl-ds F06_Ds;
        F06Opt;
        F06Lib char(10);
        F06Des;
        F06Maj;
        F06Date;
       end-ds;
     ?**---DS du sous-fichier F04 : Gestion des analyses----------------------**
       dcl-ds F04_Ds;
        Obj04 char(10);
        Lib04 char(10);
        Type04 char(7);
        Fonc04 char(10);
        Tmst04 char(26);
        Mode04 char(12);
        Opt04 char(1);
       end-ds;
     ?**---Affichage XREF : Ligne---------------------------------------------**
       dcl-ds LigXref;
        XrefNom char(10) pos(1);
        XrefTxtDsc char(50) pos(11);
        XrefUsage char(15) pos(63);
        *n char(1) inz(x'20') pos(78);
        XrefRfnm char(10) pos(79);
        XrefOtyp char(11) pos(89);
        XrefLnam char(11) pos(101);
        XrefRfsn char(14) pos(112);
       end-ds;
     ?**---Affichage [F04] : Ligne--------------------------------------------**
       dcl-ds LigF04;
        F04Nom char(10) pos(1);
        F04Texte char(50) pos(11);
        F04Lib char(10) pos(61);
       end-ds;
     ?**---Affichage de la description d'un fichier : Ligne-------------------**
       dcl-ds LigDescFile;
        DescNom char(10) pos(1);
        DescDes char(50) pos(11);
        DescTyp char(1) pos(63);
        DescLon char(7) pos(64);
        DescDec char(2) pos(74);
        DescDeb char(4) pos(77);
        DescFin char(7) pos(81);
        DescInt char(10) pos(90);
        DescAlt char(30) pos(101);
       end-ds;
     ?**---Affichage de la recherche de caractère : Ligne---------------------**
       dcl-ds LigScan;
        ScanPnam char(10) pos(1);
        ScanDes char(50) pos(11);
        ScanBib char(10) pos(63);
        ScanFil char(10) pos(75);
       end-ds;
     ?**---DS Paramètres en entrée--------------------------------------------**
       dcl-ds ParmEntry1;
        Entry_Obj char(10);
        Entry_Lib char(10);
        Entry_typ char(7);
        Entry_Fct char(10);
        Entry_Output char(8);
        Entry_Trt char(12);
        *n bindec(4);
        Entry_FicSrc char(10);
        Entry_BibSrc char(10);
        Entry_MbrSrc char(10);
        Entry_Text char(50) pos(90);
       end-ds;
     ?**---DS Paramètre Plugin------------------------------------------------**
       dcl-ds DataPlugin len(1024);
        x_Date char(10); // Date du jour
        x_heure char(8); // Heure
        x_User char(10); // Utilisateur
        x_Job char(10); // Travail
        x_NJob char(6); // N° de Job
        x_Os400 char(6); // OS/400
        x_Version char(7); // Version X-Ref
        x_Plugin char(35); // Nom du Plugin
        x_SrvPgm char(10); // Programme de service
        x_SrvLib char(10); // Bibliothèque du Prg
        x_Mode char(1); // Mode de lancement
        x_Output char(1); // Format de sortie
        x_Objet char(10); // Nom du composant
        x_Bib char(10); // Nom de la bibliothèq
        x_Type char(10); // Type de l'objet
        x_Texte char(50); // Texte de l'objet
        x_FicSrc char(10); // Fichier Source
        x_BibSrc char(10); // Bibliothèque source
        x_MbrSrc char(10); // Membre source
        x_NivSrc char(1); // Niveau d'analyse du
        x_LastFunct char(10); // Dernière fonction ut
        x_BibRef char(10); // bibliothèque du fich
       end-ds;
     ?**---List Data Program--------------------------------------------------**
       dcl-ds Lst_dta_Pgm;
        Lst_Size bindec(8);
        *n char(10); // Lst_Pgm
        *n char(10); // Lst_PgmLib
        Lst_Mod char(10);
        *n char(10); // Lst_ModLib
       end-ds;
     ?**---List Data Program--------------------------------------------------**
       dcl-ds Lst_dta_Srv;
        Lst_Srv_Size bindec(8);
        *n char(10); // Lst_Srv_Pgm
        *n char(10); // Lst_Srv_PgmLi
        Lst_Srv_Mod char(10);
        *n char(10); // Lst_Srv_ModLi
       end-ds;
     ?**---List Data Service Program------------------------------------------**
       dcl-ds Lst_dta_SrvPgm;
        Program_name char(10);
        *n char(10);
        Lst_Srv char(10);
        *n char(10); // Lst_SrvLib
        *n char(16); // Lst_SrvSign
       end-ds;
     ?**---List Data Module---------------------------------------------------**
       dcl-ds ListData;
        List_Size bindec(6);
        *n char(10); // List_Module
        *n char(10); // List_ModLib
        *n char(1); // List_ProcType
        *n bindec(4); // List_OffProc
        *n bindec(4); // List_SizProc
        *n char(10); // List_ArgProc
        List_ProcName char(82) pos(47);
       end-ds;
     ?**---List Data Program--------------------------------------------------**
       dcl-ds Lst_dta_Bnd;
        Lst_BndSize bindec(8);
        *n char(10); // Lst_ModBnd
        *n char(10); // Lst_ModBndLib
        Lst_BndTyp char(10);
        *n char(10); // Lst_BndLib
        Lst_BndOffSet bindec(8);
        Lst_BndLength bindec(8);
       end-ds;
     ?**---Rang d'enregistrement dans le fichier------------------------------**
       dcl-ds PsDs;
        NbrEnregs int(10) pos(156);
        Rrn int(10) pos(397);
       end-ds;
     ?**---Définition d'un source---------------------------------------------**
       dcl-ds DSSource;
        SrcLib char(10);
        SrcFil char(10);
        SrcMbr char(10);
        SrcRrn zoned(5);
        SrcMax zoned(5);
       end-ds;
     ?**---Ds statut du programme---------------------------------------------**
       dcl-ds WsPsDs PSDS;
        WsPsDs1 char(256);
        WsPsds2 char(256);
        Routine char(7) pos(29);
        Travail char(10) pos(244);
        Utilisateur char(10) pos(254);
        User char(10) pos(254);
        Numero zoned(6) pos(264);
        *n char(7) pos(40); // Excp_MsgId
        *n char(80) pos(91); // Excp_Data
       end-ds;
     ?**---Ds pour la définition de la clé d'un fichier-----------------------**
       dcl-ds KeyData;
        DependKey char(10) pos(1);
        AscendDes char(1) pos(14);
       end-ds;
     ?**---Ds pour la définition des sélection/ommissions d'un LF-------------**
       dcl-ds FindSelect len(32767) inz;
        Physical char(20) pos(50);
        FindFormat char(10) pos(70);
        NbrKeys int(5) pos(117);
        NbrSelOmit int(5) pos(130);
        OffSelOmit int(10) pos(132);
        OffSet int(10) pos(136);
       end-ds;
     ?**---Ds pour la définition des sélection/ommissions d'un LF-------------**
       dcl-ds KeySelect len(150) inz;
        Rule char(1) pos(3);
        Compare char(2) pos(4);
        CompName char(10) pos(6);
        NbrSO int(5) pos(16);
        OffsetSO int(10) pos(29);
       end-ds;
     ?**---Définition d'un Heap-----------------------------------------------**
       dcl-ds HeapDef;
        HeapId int(10);
        HeapSize int(10);
        HeapElems int(10);
       end-ds;
     ?**---Définition d'une matrice-------------------------------------------**
       dcl-ds MatriceDs;
        Mat_Y int(5) dim(maxtab) inz(0);
       end-ds;
     ?**---Ds pour la définition des Clés d'un LF-----------------------------**
       dcl-ds KeySOS len(150) inz;
        POffset int(10) pos(1);
        NL int(5) pos(5);
        SelectVar char(28) pos(21);
       end-ds;
     ?**---Ds pour la liste des LF d'un PF------------------------------------**
       dcl-ds ListDs;
        DependFil char(10) pos(21);
        DependLib char(10) pos(31);
       end-ds;
     ?**---Ds du récepteur pour le nombre de format par fichier---------------**
       dcl-ds Receiver len(4096) inz;
        NbrFormats int(5) pos(62);
        DBFileOffS int(10) pos(317);
        *n char(2) pos(337); // AccessType
       end-ds;
     ?**---Description d'un fichier source------------------------------------**
       dcl-ds RcdSrc len(32766);
        SrcSeq zoned(6: 2);
        *n zoned(6); // SrcDat
        SrcDta char(150);
       end-ds;
     ?**---Description d'un fichier Dump--------------------------------------**
       dcl-ds DmpFilDs;
        SavfDta char(512) pos(1);
        NoOMH char(256) pos(257);
        *n char(16) pos(513); // ChkSum
       end-ds;
     ?**---Description d'un scan----------------------------------------------**
       dcl-ds ScanDsRes;
        SourcePgm char(10) pos(1);
        *n char(10) pos(11); // SourceTyp
        SourceTxt char(49) pos(47);
       end-ds;
     ?**---Description des logiques-------------------------------------------**
       dcl-ds AccPthDs;
        SfLibrary char(10);
        SfFilename char(10);
        SfKeyField char(10);
        SfFormat char(10);
        SfAsendDec char(1);
        SfText char(50);
       end-ds;
     ?**---Description d'un fichier-------------------------------------------**
       dcl-ds *n based(pentry);
        FieldName char(10) pos(1);
        DataType char(1) pos(11);
        *n char(1) pos(12); // Use
        OutBufPos int(10) pos(13);
        *n int(10) pos(17); // InBufPos
        ByteLeng int(10) pos(21);
        Digits int(10) pos(25);
        DecPos int(10) pos(29);
        FieldText char(50) pos(33);
        *n char(2) pos(83); // EditCode
        *n int(10) pos(85); // EditWordLen
        *n char(64) pos(89); // EditWord
        *n char(20) pos(153); // ColHead1
        *n char(20) pos(173); // ColHead2
        *n char(20) pos(193); // ColHead3
        IntName char(10) pos(213);
        AltName char(30) pos(223);
        *n int(10) pos(253); // LenAltFld
        *n int(10) pos(257); // NumDBCS
        *n ind pos(261); // AlwNull
        *n ind pos(262); // HostVarInd
        *n char(4) pos(263); // DatTimFmt
        *n char(1) pos(267); // DatTimSep
        VaryingInd ind pos(268);
       end-ds;
     ?**---Description d'un objet---------------------------------------------**
       dcl-ds *n;
        WLiblOk char(10);
        TxtDscOk char(50);
        SrcMbrOk char(10);
        SrcFOk char(10);
        SrcLibOk char(10);
       end-ds;
     ?**---Liste des Objets---------------------------------------------------**
       dcl-ds DsList; // Liste d'objet
        DsListFile char(10); // Objet
        DsListLib char(10); // Bibliothèque
        DsListTyp char(10); // Type d'objet
       end-ds;
     ?**---OBJD0400-----------------------------------------------------------**
       dcl-ds Objd0400;
        *n int(10); // Bytes Returned
        *n int(10); // Bytes Available OdBy
        OdObjNam char(10); // Object Name
        OdObjLib char(10); // Object Library Name
        OdObjTypRt char(10); // Object Type
        *n char(10); // Return Library
        OdObjASP int(10); // Object ASP Number
        OdObjOwn char(10); // Object Owner
        OdObjDmn char(2); // Object Domain
        OdObjCrtDts char(13); // Creat. Date and Time
        OdObjChgDts char(13); // Chge Date and Time
        OdObjExtAtt char(10); // External Attribute
        OdObjTxtDes char(50); // Text Description
        OdObjSrcFil char(10); // Source File
        OdObjSrcLib char(10); // Source Library
        OdObjSrcMbr char(10); // Source Member
        OdObjLast char(7) pos(461); // Date Last Used
       end-ds;
     ?**---Indicateurs du fichier écran---------------------------------------**
       dcl-ds Indicators;
        OptAide ind pos(1); // Aide
        OptXref ind pos(2); // XRef
        AffSrc ind pos(2); // Touche de Fonction [
        Exit ind pos(3); // Exit
        OptRecDesc ind pos(4); // Recherche Descriptio
        OptPlugin ind pos(5); // Appel plugin
        OptRunQry ind pos(6); // RunQry
        OptDesc ind pos(7); // Description
        OptAccpth ind pos(8); // Affichage des logiqu
        OptRappel ind pos(9); // Rappel Analyse
        OptRappelP ind pos(10); // Rappel Analyse En Av
        OptRecProc ind pos(11); // Recherche Module
        Retour ind pos(12); // Retour
        OptImpr ind pos(13); // Impression du sous-f
        OptWhereUsed ind pos(14); // Where Used
        OptCarto ind pos(15); // Cartographie
        OptCartoSrc ind pos(16); // Cartographie Source
        OptRecZone ind pos(17); // Recherche d'une zone
        OptSplf ind pos(18); // Wrksplf
        OptAffObj ind pos(19); // Affichage de la desc
        OptCartoIle ind pos(20); // CartoGraphie ILE
        OptLigCmd ind pos(21); // Ligne de Commande
        OptSrch ind pos(22); // Recherche de caractè
        OptAnalyse ind pos(23); // Gestion Analyse
        OptBib ind pos(24); // Gestion de la liste
        DspPr ind pos(41); // Zone protégée
        DspNd ind pos(42); // Zone non affichée
        DspPc ind pos(43); // Zone Positionnement
        Dsp_Bib ind pos(44); // Couleur sur Biblioth
        Dsp_Repro ind pos(45); // Appel Chk_Composant
        SflDsp ind pos(48); // Affichage sous fichi
        SflDspCtl ind pos(49); // Affichage sous fichi
        SflClr ind pos(50); // Clear du sous fichie
        SflInd ind pos(50); // Clear du sous fichie
        AutRecDesc ind pos(60); // Autorisation recherc
        OptDspMaj ind pos(72); // MàJ référence Biblio
        OptDspPr ind pos(73); // blocage des zones
        ClrRed ind pos(74); // Couleur Rouge
        ClrBlu ind pos(75); // Couleur Bleu
        ClrPnk ind pos(76); // Couleur Vert
        AutObj char(10) pos(31); // Liste Autorisation
        Fonc_Ind char(24) pos(1); // Touche de fonction u
       end-ds;
     ?**---Description d'un composant-----------------------------------------**
       dcl-ds Composant; // Composant
        Obj char(10); // Objet
        Lib char(10); // Bibliothèque
       end-ds;
     ?**---Description du job-------------------------------------------------**
       dcl-ds Jobi;
        NCurLib int(5) pos(75);
       end-ds;
     ?**---User Space Générique-----------------------------------------------**
       dcl-ds UserSpace;
        SpaceName char(10);
        SpaceLib char(10);
       end-ds;
     ?**---Entête d'un User Space---------------------------------------------**
       dcl-ds GenHeadDs based(puserspace);
        InputSize int(10) pos(113); // Taille de l'entête
        *n int(10) pos(117); // Offset de l'entête H
        *n int(10) pos(121); // Taille de l'entête H
        ListOffset int(10) pos(125); // Offset des données
        *n int(10) pos(129); // Taille de la liste L
        NumberList int(10) pos(133); // Nombre de données
        EntrySize int(10) pos(137); // Taille des données
       end-ds;
     ?**---Code Erreur standard API : ERRC0100--------------------------------**
       dcl-ds ApiError;
        *n int(10) inz(%size(apierror)); // AeB
        AeBytAvl int(10) inz; // Bytes Available
        *n char(7); // Exception Id     AeM
        *n char(1); // Reserved
        *n char(128); // Exception Data   AeM
       end-ds;
     ?**----------------------------------------------------------------------**
       dcl-ds RslvTemplt;
        Gen_Mat_Id char(32);
        TypeSubtyp char(2) overlay(gen_mat_id:1);
        ObjectPtr char(30) overlay(gen_mat_id:3);
        *n char(2) inz(auth_none); // Req_Auth
       end-ds;
     ?**----------------------------------------------------------------------**
       dcl-ds ABP_Info;
        *n int(10) inz(%size(abp_info)); // ABP_Ret
        *n int(10); // ABP_Avail
        *n char(8) inz(*allx'00');
        *n int(10); // ABP_ActGrp
        *n int(10); // ABP_ActMark
        *n char(7) inz(*allx'00');
        *n char(1); // ABP_Flags
        *n char(1) inz(*allx'00');
       end-ds;
     ?**---Code Erreur--------------------------------------------------------**
       dcl-ds ErrCode;
        *n int(10) inz(0); // ErrProv
       end-ds;
     ?**---Récupération de la version d'OS/400--------------------------------**
       dcl-ds Os400 dtaara(*auto:*USRCTL:'QSS1MRI'); // DTAARA OS/400
        Version_Os char(6) pos(1); // Version OS/400
        *n char(750) pos(1); // Dummy
       end-ds;

     ?**---Appel de ZZ01------------------------------------------------------**
       dcl-pr Zz01;
        *n char(150); // parm  Paramètres Com
       end-pr;

      **----------------------------------------------------------------------**
      **---Gestion des tableaux et des matrices-------------------------------**
      **----------------------------------------------------------------------**
     ?**---Get Heap Storage---------------------------------------------------**
       dcl-pr CeeGtSt;
        *n like(£heap); // parm  Heap Id
        *n like(£index); // parm  Taille du Heap
        *n pointer; // parm  Adresse Mémoir
        *n options(*omit) like(£feedback); // parm  Retour
       end-pr;
     ?**---Create Heap--------------------------------------------------------**
       dcl-pr CeeCrHp;
        *n like(£heap); // parm  Heap Id
        *n like(£index); // parm  Taille Initial
        *n const like(£index); // parm  Incrément
        *n const like(£index); // parm  Stratégie de m
        *n options(*omit) like(£feedback); // parm  Retour
       end-pr;
     ?**---Discard Heap-------------------------------------------------------**
       dcl-pr CeeDsHp;
        *n const like(£heap); // parm  Heap Id
        *n options(*omit) like(£feedback); // parm  Retour
       end-pr;
     ?**---Initialisation du tableau------------------------------------------**
     ?**---Alimentation du tableau--------------------------------------------**
     ?**---Récupération du tableau--------------------------------------------**
     ?**---Information sur le tableau-----------------------------------------**
     ?**---Longueur Maxi d'un élément-----------------------------------------**
     ?**---Suppression du tableau---------------------------------------------**
     ?**---Recherche dans le tableau------------------------------------------**
     ?**---Transfert d'un tableau dans un autre tableau-----------------------**
     ?**---Incrément d'un élément---------------------------------------------**
     ?**---Allocation du Heap-------------------------------------------------**
     ?**---Fabrication du tableau---------------------------------------------**
     ?**---Formatage du nom de tableau----------------------------------------**
     ?**---Information sur le sous-tableau------------------------------------**
     ?**---Calcul Index réduit et numéro de sous-tableau----------------------**
     ?**---Longueur Maxi d'un élément-----------------------------------------**
     ?**---Information sur le tableau-----------------------------------------**
     ?**---Nom du Sous-Tableau------------------------------------------------**
     ?**---Alimentation du tableau--------------------------------------------**
     ?**---Récupération du tableau--------------------------------------------**
     ?**---Suppression du tableau---------------------------------------------**
     ?**---Recherche dans le tableau------------------------------------------**
     ?**---Transfert d'un tableau dans un autre tableau-----------------------**
     ?**---Incrément d'un élément---------------------------------------------**
     ?**---Alimentation de la matrice-----------------------------------------**
     ?**---Récupération de la matrice-----------------------------------------**
     ?**---Taille de la matrice en X------------------------------------------**
     ?**---Taille de la matrice en Y------------------------------------------**
     ?**---Longueur Maxi d'un élément d'une matrice---------------------------**
     ?**---Longueur Maxi d'un élément d'une matrice sur une colonne-----------**
     ?**---Suppression de la matrice------------------------------------------**
     ?**---Tri Tableau--------------------------------------------------------**

      **----------------------------------------------------------------------**
      **---Analyse du source--------------------------------------------------**
      **----------------------------------------------------------------------**
     ?**---Procédure : Src_Analyse--------------------------------------------**
     ?**---Procédure : Get_Caractere------------------------------------------**
     ?**---Procédure : Get_Bloc-----------------------------------------------**
     ?**---Procédure : Clr_Car------------------------------------------------**
     ?**---Procédure : Ovr_SrcFile--------------------------------------------**
     ?**---Procédure : Get_OvrFile--------------------------------------------**
     ?**---Procédure : Get_SrcLib---------------------------------------------**

      **----------------------------------------------------------------------**
      **---API OS/400---------------------------------------------------------**
      **----------------------------------------------------------------------**
     ?**---RTVQRYINF----------------------------------------------------------**
     ?**---List ILE Module  Information pour un programme de service----------**
       dcl-pr QbnlSpgm extpgm('QBNLSPGM');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---List ILE Module  Information pour un programme---------------------**
       dcl-pr QbnlPgmi extpgm('QBNLPGMI');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---List Procédures dans un module-------------------------------------**
       dcl-pr QbnlModi extpgm('QBNLMODI');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---Liste des membres--------------------------------------------------**
       dcl-pr QUsLMbr extpgm('QUSLMBR');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n char(10); // parm
        *n char(1); // parm
       end-pr;
     ?**---Liste des formats--------------------------------------------------**
       dcl-pr QUsLRcd extpgm('QUSLRCD');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n char(1); // parm
       end-pr;
     ?**---Recherche des dépendances d'un fichier-----------------------------**
       dcl-pr Qdbldbr extpgm('QDBLDBR');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n char(10); // parm
        *n char(10); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---Recherche de l'adresse d'un User Space-----------------------------**
       dcl-pr Qusptrus extpgm('QUSPTRUS');
        *n char(20); // parm
        *n pointer; // parm
       end-pr;
     ?**---Lancement de Commande----------------------------------------------**
       dcl-pr QUsCmdLn extpgm('QUSCMDLN') end-pr;
     ?**---Liste des objets---------------------------------------------------**
       dcl-pr QUsLObj extpgm('QUSLOBJ');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n char(10); // parm
       end-pr;
     ?**---Description d'un objet---------------------------------------------**
       dcl-pr QusrObjd extpgm('QUSROBJD');
        *n char(32767) options(*varsize); // parm  Receiver Varia
        *n int(10) const; // parm  Length of Rece
        *n char(8) const; // parm  Format Name
        *n char(20) const; // parm  Object and Lib
        *n char(10) const; // parm  Object Type
        *n char(32767) options(*varsize); // parm  Api Error
       end-pr;
     ?**---Lancement de Commande----------------------------------------------**
       dcl-pr QCmdExc extpgm('QCMDEXC');
        *n char(100); // parm  Commande
        *n packed(15: 5); // parm  Longueur de la
       end-pr;
     ?**---Recherche de chaine  de caractères---------------------------------**
       dcl-pr QClScan extpgm('QCLSCAN');
        *n char(150); // parm
        *n packed(3); // parm
        *n packed(3); // parm
        *n char(10); // parm
        *n packed(3); // parm
        *n char(1); // parm
        *n char(1); // parm
        *n char(1); // parm
        *n packed(3); // parm
       end-pr;
     ?**---Réception d'un User Space------------------------------------------**
       dcl-pr Qusrtvus extpgm('QUSRTVUS');
        *n char(20); // parm
        *n bindec(9); // parm
        *n bindec(9); // parm
        *n char(2000) options(*varsize); // parm
       end-pr;
     ?**---Affichage des zones d'un fichier-----------------------------------**
       dcl-pr Quslfld extpgm('QUSLFLD');
        *n char(20); // parm
        *n char(10); // parm
        *n char(20); // parm
        *n char(10); // parm
        *n char(1); // parm
       end-pr;
     ?**---Création d'un User Space-------------------------------------------**
       dcl-pr QusCrtUs extpgm('QUSCRTUS');
        *n char(20); // parm
        *n char(10); // parm
        *n bindec(9); // parm
        *n char(1); // parm
        *n char(10); // parm
        *n char(50); // parm
        *n char(10); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---Changment des attributs d'un User Space----------------------------**
       dcl-pr QusCusAt extpgm('QUSCUSAT');
        *n char(10); // Parm
        *n char(20); // Parm
        *n like(£qusattr); // Parm
        *n pointer; // Parm
       end-pr;
     ?**---Suppression d'un User Space----------------------------------------**
       dcl-pr QusdltUs extpgm('QUSDLTUS');
        *n char(20); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---Description d'un fichier-------------------------------------------**
       dcl-pr Qdbrtvfd extpgm('QDBRTVFD');
        *n char(20); // parm
        *n bindec(9); // parm
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n char(10); // parm
        *n char(1); // parm
        *n char(10); // parm
        *n char(10); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---Prototype  de procédure information de job-------------------------**
       dcl-pr QUsrJobI extpgm('QUSRJOBI');
        *n char(32767) options(*varsize); // parm
        *n bindec(4); // parm
        *n char(8); // parm
        *n char(26); // parm
        *n char(16); // parm
       end-pr;
     ?**---Prototypes and templates for calling ResolveSystemPtr (RSLVSP.H)---**
       dcl-pr RslvSp2 extproc('_RSLVSP2');
        *n like(£sysptr); // parm  Ptr
        *n like(rslvtemplt) const; // parm  Template
       end-pr;
       dcl-pr RslvSp4 extproc('_RSLVSP4');
        *n like(£sysptr); // parm  Ptr
        *n like(rslvtemplt) const; // parm  Template
        *n like(£sysptr) const; // parm  LibPtr
       end-pr;
       dcl-pr ActBndPgm extproc('QleActBndPgm');
        *n like(£sysptr) const; // parm  SrvpgmPtr
        *n int(10); // parm  ActMark
        *n like(abp_info); // parm  ABPInfo
        *n int(10) const; // parm  ABPInfoLen
        *n like(errcode); // parm  ErrorCode
       end-pr;
       dcl-pr GetExport extproc('QleGetExp');
        *n int(10); // parm  SrvpgmMark
        *n int(10) const; // parm  ExportId
        *n int(10) const; // parm  NameLen
        *n char(100) const; // parm  ExportName
        *n pointer(*proc) const; // parm  ExportPtr
        *n int(10); // parm  ExportType
        *n like(errcode); // parm  ErrorCode
       end-pr;
?     **---Dump d'un objet Query----------------------------------------------**
     ?**---Définition de l'entête de sous-fichier-----------------------------**
     ?**---Filtre des zones textes--------------------------------------------**
     ?**---Gestion des analyses-----------------------------------------------**
     ?**---DSPPGMREF----------------------------------------------------------**
     ?**---Decription d'un fichier--------------------------------------------**
     ?**---Outils XRef--------------------------------------------------------**
     ?**---Extraction des références------------------------------------------**
     ?**---Algorithme de recherche--------------------------------------------**
     ?**---Alimentation des tableaux de recherche-----------------------------**
     ?**---Dessin de l'algorithme---------------------------------------------**
     ?**---Prototype de recherche de procédures-------------------------------**
     ?**---Mise à jour des références techniques------------------------------**
     ?**---Contrôle de la résolution del'écran--------------------------------**
     ?**---Récupération pointeur de procédure---------------------------------**
     ?**---Outils XRef--------------------------------------------------------**

     ?**----------------------------------------------------------------------**
     ?**---M A I N------------------------------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-pi Xref;
        ParmEntry char(150);
       end-pi;


       Monitor;
?      //---Initialisation----------------------------------------------------//
       ExSr Initialisation;

?      //---Si tout s'est bien passé au démarrage-----------------------------//
       If Not Exit;
?      //---Boucle tant que pas de sortie demandée----------------------------//
         Dou Exit;
            Exsr Driver;
         EndDo;
       EndIf;

?      //---Fin du programme--------------------------------------------------//
       ExSr Fin;
       On-error;
         Exsr *Pssr;
       EndMon;

       *Inlr = *On;

?      //---------------------------------------------------------------------//
?      //---Initialisation----------------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Initialisation;

?      //---Récupération de la version de l'OS400-----------------------------//
       In Os400;
       Unlock os400;

?      //---Récupération des paramètres en entrée-----------------------------//
       ParmEntry1 = ParmEntry;

?      //---Formatage du composant en entrée----------------------------------//
       Entry_Obj = %Xlate(lo:up:Entry_Obj);

?      //---Contrôle mode de traitement---------------------------------------//
       Trt = Entry_Trt;
       If Trt = '*INTERACTIVE';
         F01Mode = 1;
       Else;
         F01Mode = 2;
       EndIf;

?      //---Contrôle mode de sortie-------------------------------------------//
       Select;
       When Entry_OutPut = '*DISPLAY';
         F01OutPut = 1;
       When Entry_OutPut = '*OUTFILE';
         F01OutPut = 2;
       When Entry_OutPut = '*PRINTER';
         F01OutPut = 3;
       EndSl;

?      //---Mode de traitement------------------------------------------------//
       If Trt <> '*INTERACTIVE';
         Entry_OutPut = '*OUTFILE';
       EndIf;

?      //---Alimentation tableau des fonctions--------------------------------//
       For i = 1 to 24;
         Tab_Set('Fonction':i :%subst(F04desTab(i):1 :59));
         Tab_Set('Fonc'    :i :%subst(F04desTab(i):60:10));
       EndFor;

?      //---Alimentation de l'aide en ligne-----------------------------------//
       If Entry_OutPut ='*DISPLAY';
         ExSr Alim_Fonct;
       EndIf;

?      //---Source------------------------------------------------------------//
       Exsr Info_source;

?      //---Contrôle de la résolution de l'écran------------------------------//
       If Trt = '*INTERACTIVE';
         Exit = Ctl_Dsp();
       EndIf;

       If Trt = '*INTERACTIVE';
?      //---Création du fichier de sortie-------------------------------------//
         ExSr Crt_Output;
?      //---Création du fichier paramètre-------------------------------------//
         ExSr Crt_Parameter;
?      //---Alimentation des zones par défaut---------------------------------//
         F01Version = Version;
       EndIf;

?      //---Affichage du titre X-Ref------------------------------------------//
       F01Titre = '[ X-Ref : Analyse iSeries ]';

?      //---Mise à jour des tableaux des bibliothèques------------------------//
       ExSr Maj_Tab_Bib;

?      //---Alimentation obligatoire de la liste de bibliothèque--------------//
       If Not(F06_Obj and F06_Src and F06_Ref);
         Bib_Ok_Init = *Off;
         ExSr Liste_Bib;
         Bib_Ok_Init = *On;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Mise à jour tableau des bibliothèques-----------------------------//
?      //---------------------------------------------------------------------//

       Begsr Maj_Tab_Bib;

?      //---Chargement de la liste de bibliothèque Objet----------------------//
       ExSr Get_Bib_Obj;

?      //---Chargement de la liste de bibliothèque Source---------------------//
       ExSr Get_Bib_Src;

?      //---Recherche emplacement de PGMREF-----------------------------------//
       ExSr Choix_PgmRef;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Alimentation des info source--------------------------------------//
?      //---------------------------------------------------------------------//

       Begsr Info_source;

       If %Subst(Entry_Fct:1:9) = '*CARTOSRC';

?      //---Membre source-----------------------------------------------------//
         If Entry_MbrSrc = '*OBJ';
           If Entry_Obj = '*NONE';
             Entry_MbrSrc = *Blanks;
           Else;
             Entry_MbrSrc = Entry_Obj;
           EndIf;
         EndIf;

?      //---Bibliothèque source-----------------------------------------------//
         If Entry_BibSrc = '*LIBOBJ';
           If Entry_Lib = '*LIBL';
             Entry_BibSrc = *Blanks;
           Else;
             Entry_BibSrc = Entry_Lib;
           EndIf;
         EndIf;

?      //---Alimentation zone écran-------------------------------------------//
         F12Mbr = %Xlate(lo:up:Entry_MbrSrc);
         F12Src = Entry_FicSrc;
         F12Lib = Entry_BibSrc;
       Else;

?      //---Mise à blanc des infos--------------------------------------------//
         Entry_MbrSrc = *Blanks;
         Entry_FicSrc = *Blanks;
         Entry_BibSrc = *Blanks;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Création du fichier de sortie-------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Crt_Output;

?      //---Contrôle Existence du fichier paramètre---------------------------//
       QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                Czz01ot+Clibl:Cfile:ApiError);

?      //---Recherche Curlib--------------------------------------------------//
       QusrJobI(JobI:jobilen:CJobi0700:Etoile:Blan);

?      //---Si inexistant, création du fichier--------------------------------//
       If AeBytAvl > *Zero;
         If NCurLib = 0;
?      //---Si pas de curlib alors création du fichier dans QTEMP-------------//
           Lib_Temp = 'Qtemp/';
         Else;
?      //---Sinon dans la curlib----------------------------------------------//
           Lib_Temp = *blanks;
         EndIf;

?      //---Définition de la requête------------------------------------------//
         Requete6='Create Table '+Lib_Temp+'Zz01out (ZzTmst Timestamp Not Null -
         with Default, ZzComp Char ( 10) Not Null With Default, ZzType Char (  -
         10) Not Null With Default, ZzBib Char ( 10) Not Null With             -
         Default, ZzFonc Char ( 10) Not Null With Default, ZzMode Char (       -
         12) Not Null With Default, ZzFld Char ( 256) Not Null With Default)';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :requete6
     C/END-EXEC
     C/EXEC SQL
     C+  LABEL ON TABLE zz01out IS 'X-Ref - Fichier de Sortie'
     C/END-EXEC

       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //-- Création du fichier paramètre-------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Crt_Parameter;

?      //---Contrôle Existence du fichier paramètre---------------------------//
       QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                Czz01pf+Clibl:Cfile:ApiError);

?      //---Recherche Curlib--------------------------------------------------//
       QusrJobI(JobI:jobilen:CJobi0700:Etoile:Blan);

?      //---Si inexistant, création du fichier--------------------------------//
       If AeBytAvl > *Zero;
         If NCurLib = 0;
?      //---Si pas de curlib alors création du fichier dans QTEMP-------------//
           Lib_Temp = 'QTemp/';
         Else;
?      //---Sinon dans la curlib----------------------------------------------//
           Lib_Temp = *Blanks;
         EndIf;

?      //---Définition de la requête------------------------------------------//
        Requete6='Create table '+Lib_Temp+'Zz01pf (Type_Enregistrement For Colu-
       mn zzType Char(5) Not Null With Default, Valeur_Enregistrement For Colum-
       n ZzValeur Char(30) Not Null With Default, Primary Key                -
        (Type_Enregistrement, Valeur_Enregistrement))';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :requete6
     C/END-EXEC
     C/EXEC SQL
     C+  LABEL ON TABLE zz01pf IS 'X-Ref - Fichier paramètre'
     C/END-EXEC

       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F24] : Gestion de la liste de bibliothèque Objet-----------------//
?      //---------------------------------------------------------------------//
       BegSr Liste_Bib;

       Bib_Ok = *Off;
       Dou Bib_ok = *on;

?      //---Alimentation de la liste de bibliothèque--------------------------//
         ExSr Alim_Liste_Tab;

?      //---Contrôle de la liste de bibliothèque------------------------------//
         ExSr Alim_Liste_Sfl;
         Bib_Ok_Sav = Bib_Ok;
         Bib_Ok = *Off;

         If Entry_OutPut <> '*OUTFILE';

?      //---Affichage de la liste de bibliothèque-----------------------------//
         Dow Not Bib_Ok And Not Exit and Not Retour;
?      //---Sauvegarde de la liste de bibliothèque----------------------------//
           Tab_Trf('ListeBib':'SV');

           If Entry_OutPut = '*DISPLAY' or Entry_OutPut = '*PRINTER';
             OptDspMaj = *On;
?      //---Si au moins une bib Objet n'est pas définie-----------------------//
             If Not F06_Obj and Not F06_Lig_Obj;
               F06Rrn += 1 ;
               F06Opt = 'O';
               F06Lib = '<Bib_Obj>';
               Write F06Sfl;
             EndIf;
?      //---Il faut une bibliothèque de référence-----------------------------//
             If Not F06_Ref and Not F06_Lig_Ref;
               F06Rrn += 1 ;
               F06Opt = 'S';
               F06Lib = '<Bib_Ref>';
               Write F06Sfl;
             EndIf;
?      //---Si au moins une bib Source n'est pas définie----------------------//
             If Not F06_Src and Not F06_Lig_Src;
               F06Rrn += 1 ;
               F06Opt = 'S';
               F06Lib = '<Bib_Src>';
               Write F06Sfl;
             EndIf;
?      //---Lignes à blanc----------------------------------------------------//
             F06_Ds = *Blanks;
             For i = 1 to 5;
               OptDspMaj = *On;
               F06Rrn +=1;
               Write F06Sfl;
             EndFor;

             OptDspMaj = *Off;

?      //---Affichage du sous-fichier-----------------------------------------//
             If F06Rrn > 0;
               ExFmt F06Ctl;
?      //---Gestion du changement de la liste---------------------------------//
               If Exit <> *On and Retour <> *On;
                 F06_Src = *Off;
                 F06_Ref = *Off;
                 F06_Obj = *Off;
?      //---Comparaison entre sauvegarde et liste en cours--------------------//
                 For i = 1 to Tab_Inf('SV') + 5;
                   Chain i F06Sfl;
                   If Tab_Get('SV':i) <> F06Opt+F06Lib+F06Maj+F06Date
                   or F06Opt = 'C';
                     Bib_Ok = *Off;
                     If F06Opt = 'O';
                       F06Maj = 'X';
                     Else;
                       F06Maj = *Blanks;
                     EndIf;
                   EndIf;
?      //---Mise à jour de la liste en cours----------------------------------//
                   Tab_Set('ListeBib':i:F06Opt+F06Lib+F06Maj+F06Date);
                   F06_Ds = *Blanks;
                 EndFor;

               EndIf;
?      //---Suprression de la liste de sauvegarde-----------------------------//
               Tab_Term('SV');

             EndIf;
           EndIf;

?      //---Chargement du sous-fichier----------------------------------------//
           ExSr Alim_Liste_Sfl;

         EndDo;

?      //---Affichage du sous-fichier-----------------------------------------//
         If Exit <> *On and Retour <> *On and Bib_Ok;
           OptDspPr = *On;
           ExSr Alim_Liste_Sfl;
           OptDspPr = *Off;

           If Entry_OutPut = '*DISPLAY' or Entry_OutPut = '*PRINTER';
             ExFmt F06Ctl;

             If Not(Exit or Retour);
?      //---Suppression des enregistrements dans ZZ01PF-----------------------//
     C/EXEC SQL
     C+  DELETE FROM zz01pf
     C/END-EXEC

?      //---Sauvegarde des enregistrements dans ZZ01PF------------------------//
               For i = 1 to Tab_Inf('ListeBib');
?      //---Récupération de la bibliothèque-----------------------------------//
                 Bib = %subst(Tab_Get('ListeBib':i):2:10);
?      //---Sauvegarde si bibliothèque différent de blanc---------------------//
                 If %subst(Tab_Get('ListeBib':i):1:1) <> ' ' and Bib <> *Blanks;
                   Select;
                   When %subst(Tab_Get('ListeBib':i):1:1) = 'O';
                     ListeBib = 'OBLIB';
                   When %subst(Tab_Get('ListeBib':i):1:1) = 'S';
                     ListeBib = 'SCLIB';
                   When %subst(Tab_Get('ListeBib':i):1:1) = 'R';
                     ListeBib = 'LIBRF';
?      //---Suppression de l'alias de QTEMP-----------------------------------//
       Req_Sql = 'DROP ALIAS QTEMP/PGMREF ';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :req_sql
     C/END-EXEC
?      //---Création Alias PGMREF dans QTEMP----------------------------------//
       Req_Sql = 'CREATE ALIAS QTEMP/PGMREF FOR ' + %Trim(Bib) + '/PGMREF';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :req_sql
     C/END-EXEC
                   EndSl;
     C/EXEC SQL
     C+  INSERT INTO zz01pf
     C+    VALUES (:listebib, :bib)
     C/END-EXEC
                 EndIf;
?      //---Mise à jour des références Technique------------------------------//
                 If %subst(Tab_Get('ListeBib':i):12:1) = 'X';
                   F06Lib = %subst(Tab_Get('ListeBib':i):2:10);
                   Maj_Ref(F06Lib);
                 EndIf;
               EndFor;

           EndIf;
?      //---Suppression des tableaux------------------------------------------//
             Tab_Term('ListeBib');
             Tab_Term('OBLIB');
             Tab_Term('SCLIB');

?      //---Chargement de la liste de bibliothèque Objet----------------------//
             ExSr Maj_Tab_Bib;

           EndIf;
         EndIf;

?      //---Si liste incorrecte au départ et sortie alors sortie complète-----//
         If Bib_Ok_Init = *Off and (Exit or Retour);
           Exit = *On;
           Retour = *On;
         EndIf;

?      //---Si liste incorrecte et demande de sortie alors restaure liste-----//
         If Bib_Ok = *Off and (Exit or Retour);
           Tab_Term('ListeBib');
           Tab_Term('OBLIB');
           Tab_Term('SCLIB');
           ExSr Maj_Tab_Bib;
           Bib_Ok = *On;
         Else;

?      //---Si Sortie ou retour alors retour----------------------------------//
         If Retour = *On or Exit = *On;
           Retour = *Off;
           Exit = *Off;
         EndIf;
       EndIf;
         Else;
           Bib_Ok = *On;
         EndIf;
       EndDo;

?      //---Mise à jour du composant sauvegardé-------------------------------//
       If Entry_OutPut = '*DISPLAY' or Entry_OutPut = '*PRINTER';
         If Not Exit and Not Retour;
           Entry_Obj = SavComp;
           SavComp = *Blanks;
         EndIf;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Alimentation de la liste principale de bibliothèque---------------//
?      //---------------------------------------------------------------------//

       BegSr Alim_Liste_Tab;

?      //---Alimentation de la liste de bibliothèque principal----------------//
       i = *Zeros;

?      //---Alimentation Liste de bibliothèque Référence----------------------//
       If %Trim(LibRef) <> *Blanks;
         i += 1;
         Tab_set('ListeBib': i : 'R' + %trim(LibRef));
         ClPgmRef = %Trim(LibRef);
       EndIf;

?      //---Alimentation Liste de bibliothèque Objet--------------------------//
       For j = 1 To Tab_Inf('OBLIB');
         i += 1;
         F06Lib = Tab_Get('OBLIB':j);
?      //---Recherche de la dernière date de MàJ des références---------------//
     C/EXEC SQL
     C+  SELECT MAX(whdttm)
     C+    INTO :max_date:date_null
     C+    FROM qtemp / pgmref
     C+    WHERE whlib = :f06lib
     C/END-EXEC
?      //---Si date non trouvée alors proposition de mise à jour--------------//
         If Max_Date = *Blanks;
           F06Maj = 'X';
           F06Date = *Blanks;
         Else;
?      //---Sinon formatage de la date----------------------------------------//
           F06Date = %subst(Max_Date:6:2) + '/' + %Subst(Max_Date:4:2) + '/' +
           '20' + %Subst(Max_Date:2:2) + ' ' + %Subst(Max_Date:8:2) + 'h' +
           %Subst(Max_Date:10:2) + 'mn' + %subst(Max_Date:12:2) + 's';
           Max_Date = *Blanks;
           F06Maj = ' ';
         EndIf;
?      //---Alimentation de la liste de bibliothèque objet--------------------//
         Tab_set('ListeBib': i : 'O' + F06Lib + F06Maj + F06Date );
       EndFor;

?      //---Alimentation Liste de bibliothèque Source-------------------------//
       For j = 1 To Tab_Inf('SCLIB');
         i += 1;
         Tab_set('ListeBib': i : 'S'+ %Trim(Tab_Get('SCLIB':j)));
       EndFor;

?      //---Ajout des enregistrements s'il manque un type de bibliothèque-----//
       F06_Ds = *Blanks;
       If Not F06_Ref;
         i += 1;
         Tab_set('ListeBib': i : 'R<Bib_Ref>');
       EndIf;
       If Not F06_Obj;
         i += 1;
         Tab_set('ListeBib': i : 'O<Bib_Obj>');
       EndIf;
       If Not F06_Src;
         i += 1;
         Tab_set('ListeBib': i : 'S<Bib_Src>');
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Création/Clear du fichier des références techniques---------------//
?      //---------------------------------------------------------------------//

       BegSr Crt_Pgmref;

       QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:CPgmRef+ClPgmRef:Cfile
                :ApiError);

?      //---Si inexistant, Création du physique et du logique-----------------//
       If AeBytAvl > *Zero;
?      //---Création du fichier physique--------------------------------------//
         OvrCmd= 'DSPPGMREF PGM('+%Trim(F06Lib)+'/*ALL) OUTPUT(*OUTFILE)';
         OvrCmd= %Trim(OvrCmd) + ' OBJTYPE(*ALL) OUTFILE(';
         OvrCmd= %Trim(OvrCmd) + %Trim(F06Lib) + '/PGMREF)';
         OvrCmd= %Trim(OvrCmd) + ' OUTMBR(*FIRST *REPLACE)';
         OvrCmdLen = 200;
         QcmdExc(OvrCmd:OvrCmdLen);
?      //---Ajout du libellé sur le fichier-----------------------------------//
         OvrCmd = 'CHGPF FILE(' + %Trim(F06Lib) + '/PGMREF)';
         Ovrcmd = %Trim(OvrCmd)+' TEXT(''X-Ref - Fichier Référence'')';
         OvrCmd = %Trim(OvrCmd) + ' SIZE(*NOMAX) REUSEDLT(*YES)';
         OvrCmdLen = 200;
         QcmdExc(OvrCmd:OvrCmdLen);
?      //---Sinon clear du fichier--------------------------------------------//
       Else;
         OvrCmd = 'CLRPFM FILE(' +%Trim(ClPgmRef) +'/PGMREF)';
         OvrCmdLen = 200;
         QcmdExc(OvrCmd:OvrCmdLen);
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Création/Clear des LF pour les références techniques--------------//
?      //---------------------------------------------------------------------//

       Begsr Crt_Pgmref_Lf;

       QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                CPgmRef+ClPgmRef:Cfile:ApiError);

?      //---Si inexistant, Affichage message et impossibilité de sortir-------//
       If AeBytAvl > *Zero;
         Bib_Ok = *Off;
         F06Des = x'22' + '     *** Fichier Réf. Tech. Absent ***';
       Else;
?      //---Sinon contrôle et création des LF associés------------------------//
         CLPgmRef = F06Lib;
?      //---LF N° 1 : WHFNAM/WHOTYP-------------------------------------------//
         QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
         CPgmRef1 + ClPgmRef:Cfile:ApiError);
         If AeBytAvl > *Zero;
           Req_Crt = 'CREATE INDEX '+CPgmref1+ ' ON '+%Trim(ClPgmRef) +'/' +
                     CPgmRef + '(WHFNAM ASC, WHOTYP ASC)';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :req_crt
     C/END-EXEC
           OvrCmd = 'CHGLF FILE(' + %Trim(ClPgmRef) + '/'+ CPgmref1 + ')       -
            TEXT(''X-Ref - Index PGMREF : WHFNAM/WHOTYP'')';
           OvrCmdLen = 200;
           QcmdExc(OvrCmd:OvrCmdLen);
         EndIf;

?      //---LF N° 2 : WHSPKG/WHPNAM/WHLIB-------------------------------------//
         QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
         CPgmRef2 + ClPgmRef:Cfile:ApiError);
         If AeBytAvl > *Zero;
           Req_Crt='CREATE INDEX '+Cpgmref2+' ON '+%Trim(ClPgmRef)+'/'+CPgmRef +
                    '(WHSPKG ASC, WHPNAM ASC, WHLIB ASC)';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :req_crt
     C/END-EXEC
           OvrCmd = 'CHGLF FILE(' + %Trim(ClPgmRef) + '/'+ CPgmRef2 +')        -
            TEXT(''X-Ref - Index PGMREF : WHSPKG/WHPNAM/WHLIB'')';
           OvrCmdLen = 200;
           QcmdExc(OvrCmd:OvrCmdLen);
         EndIf;

?      //---LF N° 3 : WHOBJT/WHPNAM-------------------------------------------//
         QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
         CPgmRef3 + ClPgmRef:Cfile:ApiError);
         If AeBytAvl > *Zero;
           Req_Crt = 'CREATE INDEX '+CPgmRef3+ ' ON '+%Trim(ClPgmRef) +'/' +
           CPgmRef + ' (WHOBJT ASC, WHPNAM ASC)';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :req_crt
     C/END-EXEC
           OvrCmd = 'CHGLF FILE(' + %Trim(ClPgmRef) + '/'+CPgmRef3 +')         -
            TEXT(''X-Ref - Index PGMREF : WHOBJT/WHPNAM'')';
           OvrCmdLen = 200;
           QcmdExc(OvrCmd:OvrCmdLen);
         EndIf;

?      //---Recherche du nombre d'enregistrement pour information-------------//
         OvrCmd = 'OVRDBF FILE(FILE) TOFILE('+%trim(F06Lib)+'/PGMREF)';
         OvrCmdLen = 200;
         QcmdExc(OvrCmd:OvrCmdLen);
         Open(e) File;
         If Not %Error;
           F06Des = 'PGMREF Présent avec ' + %char(NbrEnregs)
                     + ' enregistrement(s) ';
         EndIf;
         Close file;
         OvrCmd = 'DLTOVR FILE(FILE)';
         OvrCmdLen = 200;
         QcmdExc(OvrCmd:OvrCmdLen);
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Alimentation de la liste de bibliothèque dans Sous-fichier--------//
?      //---------------------------------------------------------------------//

       BegSr Alim_Liste_Sfl;

       Bib_Ok = *On;
       F06Rrn = 0;
       F06ClrRef = *Off;
     C/EXEC SQL
     C+  SET :zztmst = CURRENT_TIMESTAMP
     C/END-EXEC

?      //---Clear du sous-fichier---------------------------------------------//
       If Entry_OutPut = '*DISPLAY' or Entry_OutPut = '*PRINTER';
         SflInd = *On;
         Write F06Ctl;
         SflInd = *Off;
       EndIf;

       For i = 1 to Tab_Inf('ListeBib');

?      //---Initialisation des codes couleurs---------------------------------//
         ClrRed = *Off;
         ClrBlu = *Off;
         ClrPnk = *Off;

?      //---Récupération des infos Bibliothèques------------------------------//
         F06Opt  = %subst(Tab_Get('ListeBib':i):01:01);
         F06Lib  = %subst(Tab_Get('ListeBib':i):02:10);
         F06Maj  = %subst(Tab_Get('ListeBib':i):12:01);
         F06Date = %subst(Tab_Get('ListeBib':i):13:21);

         If F06Opt = 'O';
           OptDspMaj = *Off;
         Else;
           OptDspMaj = *On;
         EndIf;

         If F06Opt = 'O' and F06ClrRef;
           F06Maj = 'X';
         EndIf;
?      //---Contrôle Existence de la bibliothèque et description--------------//
         QusrObjd(Objd0400:%Size(Objd0400):COBJD0200:
                 F06Lib + 'QSYS':'*LIB':ApiError);
         If Not(AeBytAvl > *Zero);
           F06Des = OdObjTxtDes;
         Else;
           If F06Lib <> *Blanks;
             F06Des = *All'?';
             Bib_Ok = *Off;
           Else;
             F06Des = *Blanks;
           EndIf;
         EndIf;

?      //---Création du fichier de référence avec le code C-------------------//
         If F06Opt = 'C';
           CLPgmRef = F06Lib;
           ExSr Crt_Pgmref;
           F06Opt = 'R';
           Tab_Set('ListeBib':i:F06Opt+F06Lib+F06Maj+F06Date);
           F06ClrRef = *On;
         EndIf;

?      //---Contrôle Existence du fichier PgmRef------------------------------//
         If F06Opt = 'R';
           CLPgmRef = F06Lib;
           Exsr Crt_Pgmref_Lf;
?      //---Si clear du fichier de référence, MàJ liste de bib.---------------//
           If F06ClrRef;
             Tab_Set('SV':i:F06Opt+F06Lib+F06Maj+F06Date);
             Tab_Set('ListeBib':i:F06Opt+F06Lib+F06Maj+F06Date);
           EndIf;
         EndIf;

?      //---Couleur en fonction du type de bilbiothèque-----------------------//
         Select;
           When F06Opt = 'R' or F06Opt ='C';
             ClrRed = *On;
           When F06Opt = 'O';
             ClrBlu = *On;
           When F06Opt = 'S';
             ClrPnk = *On;
         EndSl;

?      //---Alimentation du Sous-fichier pour une sortie écran----------------//
         If Entry_OutPut = '*DISPLAY' or Entry_OutPut = '*PRINTER';
           F06Rrn +=1;
           Write F06Sfl;
         Else;
?      //---Sortie fichier----------------------------------------------------//
           F06Fld = F06Opt+' '+F06Lib+' '+F06Des+' '+F06Maj+' '+F06Date;
     C/EXEC SQL
     C+  INSERT INTO zz01out
     C+    VALUES (:zztmst, :zzcomp, :zztype, :zzbib, :zzfonc, :trt, :f06fld)
     C/END-EXEC
         EndIf;

?      //---Contrôle Existence Bibliothèque Source----------------------------//
         If F06Opt = 'S' and F06Lib <>'<Bib_Src>';
           F06_Src = *On;
         EndIf;

?      //---Contrôle Existence Bibliothèque Objet-----------------------------//
         If F06Opt = 'O' and F06Lib <>'<Bib_Obj>';
           F06_Obj = *On;
         EndIf;

?      //---Contrôle Existence Bibliothèque Référence-------------------------//
         If (F06Opt = 'R' or F06Opt = 'C') and F06Lib <>'<Bib_Ref>';
           F06_Ref = *On;
         EndIf;

?      //---Contrôle Enreg. incorrect-----------------------------------------//
         If F06Lib ='<Bib_Src>';
           F06_Lig_Src = *On;
         EndIf;

?      //---Contrôle Enreg. incorrect-----------------------------------------//
         If F06Lib = '<Bib_Obj>';
           F06_Lig_Obj = *On;
         EndIf;

?      //---Contrôle Enreg. incorrect-----------------------------------------//
         If F06Lib = '<Bib_Ref>';
           F06_Lig_Ref = *On;
         EndIf;

       EndFor;

?      //---Si Bib. objet et bib. Source non définie alors on ne passe pas----//
       If not (F06_Obj and F06_Src and F06_Ref);
         Bib_Ok = *Off;
       EndIf;

?      //---Initialisation des couleurs---------------------------------------//
       ClrRed = *Off;
       ClrBlu = *Off;
       ClrPnk = *Off;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Chargement de la liste des bibliothèques Sources------------------//
?      //---------------------------------------------------------------------//
       BegSr Get_Bib_Src;

?      //---Requete sur fichier paramètre pour bibliothèque objet-------------//
       Requete0 = 'select zzvaleur from zz01pf where zztype =''SCLIB''         -
                  Order by zzValeur';

?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s2 FROM :requete0
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c2 CURSOR FOR s2
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c2
     C/END-EXEC

     C/EXEC SQL
     C+  FETCH NEXT FROM c2 INTO :lib
     C/END-EXEC

       i = 1;
       F06_Src = *Off;
?      //---Alimentation du tableau SCLIB pour la bibliothèque source---------//
       Dow Sqlcod <> EndOfFile;
         F06_Src = *On;
         Tab_Set('SCLIB':i:lib);
         i += 1;
     C/EXEC SQL
     C+  FETCH NEXT FROM c2 INTO :lib
     C/END-EXEC
       EndDo;

     C/EXEC SQL
     C+  CLOSE c2
     C/END-EXEC

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Chargement de la liste des bibliothèques Objets-------------------//
?      //---------------------------------------------------------------------//
       BegSr Get_Bib_Obj;

?      //---Requete sur fichier paramètre pour bibliothèque objet-------------//
       Requete0 = 'select zzValeur from zz01pf where zztype =''OBLIB''         -
                  Order by zzValeur';

?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s1 FROM :requete0
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c1 CURSOR FOR s1
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c1
     C/END-EXEC
     C/EXEC SQL
     C+  FETCH NEXT FROM c1 INTO :lib
     C/END-EXEC

       i = 1;
       F06_Obj = *Off;
?      //---Alimentation du tableau OBLIB pour la bibliothèque objet----------//
       Dow Sqlcod <> EndOfFile;
         F06_Obj = *On;
         Tab_Set('OBLIB':i:lib);
         i += 1;
     C/EXEC SQL
     C+  FETCH NEXT FROM c1 INTO :lib
     C/END-EXEC
       EndDo;

     C/EXEC SQL
     C+  CLOSE c1
     C/END-EXEC

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Alimentation de l'aide en ligne-----------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Alim_Fonct;

?      //---Ligne 1 de touches de fonctions-----------------------------------//
       Fonct01 = 'F01= Aide    F03= Sortir    F05= Outils    F09/F10= +/-    F1-
       2= Retour    F13= Impr.    F18= Gestion Spooles    F21= Ligne de Cmde';

?      //---Ligne 2 de touches de fonctions-----------------------------------//
       Fonct02 = 'F02= X-Ref  F06= Query  F07= Desc. Fichier  F08= Desc. LF/VUE-
         F14= Where Used  F15= Carto. Pgm  F16= Carto. Src  F19= Desc. Objet';

?      //---Ligne 3 de touches de fonctions-----------------------------------//
       Fonct03 = 'F04= Rec./Description F11= Rec.Proc./Modul F17= Rec.zone/Fich-
       ier F20= Carto.Ile F22= Rec. Carac. F23= Lst Analyses F24= Paramètres';

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Choix du PgmRef---------------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Choix_PgmRef;

       LibRef = *Blanks;

     C/EXEC SQL
     C+  SET :libref = (SELECT SUBSTR(zzvaleur, 1, 10)
     C+                   FROM zz01pf
     C+                   WHERE zztype = 'LIBRF')
     C/END-EXEC
       If LibRef <> *Blanks;
         F06_Ref = *On;
         ClPgmRef = LibRef;
       Else;
         F06_Ref = *Off;
       EndIf;
?      //---Création Alias PGMREF dans QTEMP----------------------------------//
       Req_Sql = 'CREATE ALIAS QTEMP/PGMREF FOR ' + %Trim(LibRef) + '/PGMREF';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :req_sql
     C/END-EXEC

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Driver modal------------------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Driver;

       Select;
?      //---Mode interactif---------------------------------------------------//
         When Trt ='*INTERACTIVE';
           ExSr Dsply_Selection;
         When Trt = '*BATCH';
?      //---Mode batch--------------------------------------------------------//
           ExSr ModeBatch;
         When Trt = '*NOPROMPT';
?      //---En mode NoPrompt--------------------------------------------------//
           F01Obj = %Xlate(lo:up:Entry_Obj);
           F01Bib = Entry_Lib;
           F01Typ = Entry_typ;
           ExSr Chk_Composant;
           ExSr Call_Option;
       EndSl;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Mode batch--------------------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr ModeBatch;
?      //---Sortie Ecran------------------------------------------------------//
       If %Open(ZZ01D);
         DspPr = *On;
         ExFmt F01;
         Entry_Obj = F01Obj;
?      //---Alimentation par défaut de la bibliothèque------------------------//
         If F01Bib <> *Blanks;
           Entry_Lib = F01Bib;
         Else;
           Entry_Lib = '*LIBL';
         EndIf;
?      //---Alimentation par défaut du type du composant----------------------//
         If F01Typ <> *Blanks;
           Entry_Typ = F01Typ;
         Else;
           Entry_Typ = '*ALL';
         EndIf;
?      //---Sélection fonction------------------------------------------------//
         DspPr = *Off;
         i = %Scan('1':Fonc_Ind);
         If i = *Zero;
           Entry_Fct = '*NONE';
         Else;
           Entry_Fct = Tab_Get('Fonc':i);
         EndIf;

?      //---Sortie fichier----------------------------------------------------//
       Else;
         ParmEntry = ParmEntry1;
       EndIf;

?      //---Soumission du job-------------------------------------------------//
       If Entry_Fct <> '*NONE';
         Entry_Trt = '*NOPROMPT';
         OvrCmdLen = 200;
         If Entry_Obj = '*NONE';
           JobEntry = 'NONE';
         Else;
           JobEntry = Entry_Obj;
         EndIf;

?      //---Commande du job---------------------------------------------------//
         OvrCmd = 'SBMJOB CMD(XREF COMPOSANT(' + %Trim(Entry_Lib) + '/' +
         %Trim(Entry_Obj) + ')' + ' TYPE('+ %Trim(Entry_Typ) + ') FONCTION('
         + %Trim(Entry_Fct) + ') OUTPUT(*OUTFILE) ' + 'MODE(*NOPROMPT)';
         If Entry_Fct = '*CARTOSRC' or Entry_Fct = '*CARTOSRC2';
           OvrCmd = %trim(OvrCmd) + ' SOURCE(' + %Trim(Entry_FicSrc) + ' ' +
           %Trim(Entry_BibSrc) + ' ' + %Trim(Entry_MbrSrc) + ')';
         EndIf;
         If Entry_Fct = '*RECDESC' or Entry_Fct = '*RECPROC';
           OvrCmd = %trim(OvrCmd) + ' TEXTE(' + Entry_Text + ')';
         EndIf;
         OvrCmd = %trim(OvrCmd) + ') JOB(' + %Trim(JobEntry)  + ')';
         ovrcmd = %Trim(ovrcmd) + ' JOBQ(QS36EVOKE)' ;
         QcmdExc(OvrCmd:OvrCmdLen);

       EndIf;

?      //---Après lancement en mode batch-------------------------------------//
       If Not %Open(ZZ01D);

?      //---En mode sortie fichier--------------------------------------------//
         Exit = *On;

       Else;

?      //---En mode sortie écran----------------------------------------------//
         Trt ='*INTERACTIVE';
         Entry_Fct = '*NONE';
         F01Mode = 1;
         DspPr= *Off;
         Clear Fonc_Ind;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Affichage de l'écran de sélection---------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Dsply_Selection;

?      //---Affichage Info du jour--------------------------------------------//
       DateduJour = %Date;
       Heure = %Time;
       F01Info = 'Date:' + x'20' + %char(DateduJour:*DMY);
       F01Info = %Trim(F01Info) + x'22' + ' ' + 'Heure:'+ x'20' + %char(Heure);
       F01Info = %Trim(F01Info) + x'22' +'Travail:' + x'20';
       F01Info = %Trim(F01Info) + '(' +%Trim(Travail) + '/'  ;
       F01Info = %Trim(F01Info) + %Trim(Utilisateur) + '/';
       F01Info = %Trim(F01Info) +  %char(Numero) + ') ';
       F01Info = %Trim(F01Info) + x'22' + 'O/S:' + x'20' + Version_Os;

?      //---Affichage Version-------------------------------------------------//
       If %Subst(Version:7:1)<>*Blanks;
         F01Info = %Trim(F01Info) + ' ' + x'29' + 'Version en cours de test';
         F01Info = %Trim(F01Info) +  x'20';
       Else;
         F01Info = %Trim(F01Info) + '  ' + x'23' +
?        'http://github.com/ibmiiste/XREF' + x'20';
       EndIf;

?      //---Choix des options disponibles-------------------------------------//
       ExSr Chk_Options;

?      //---Alimentation du type de l'objet-----------------------------------//
       If Entry_Typ <> *Blanks and Entry_Typ <> '*ALL';
         F01Typ   = Entry_Typ;
         Entry_Typ = *Blanks;
       EndIf;

?      //---Alimentation de la bilbiothèque-----------------------------------//
       If Entry_Lib <> *Blanks and Entry_Lib <> '*LIBL';
         F01Bib   = Entry_Lib;
         Entry_Lib= *Blanks;
       EndIf;

?      //---Affichage du pied de l'écran--------------------------------------//
       Write Foot;

?      //---Affichage de l'écran----------------------------------------------//
       i = %Scan('1':Fonc_Ind);
?      //---Si pas d'appel de Fonction préalable------------------------------//
       If (%Addr(Entry_Obj) = *Null or Entry_Obj = *Blanks or Entry_Obj=*Loval)
         and (%Addr(Entry_Text)=*Null or Entry_Text=*Blanks or
         Entry_Text=*Loval) and i = 0;
         ExFmt F01;
       Else;
?      //---Si appel de fonction préalable------------------------------------//
         Write F01;
?      //---Initialisation des zones------------------------------------------//
         If Entry_Obj ='*NONE' or Entry_Obj = *Blanks;
           Entry_Obj = *Blanks;
         Else;
           F01Obj = Entry_Obj;
         EndIf;
?      //---Remise à blanc de l'objet de départ-------------------------------//
         Entry_Obj = *Blanks;
       EndIf;

?      //---Choix du mode de traitement---------------------------------------//
       If F01Mode = 1;
         Trt ='*INTERACTIVE';
       Else;
         Trt ='*BATCH';
       EndIf;

?      //---Choix du format de sortie-----------------------------------------//
       Select;
       when F01OutPut = 1;
         Entry_OutPut ='*DISPLAY';
       when F01OutPut = 2;
         Entry_OutPut = '*OUTFILE';
       when F01OutPut = 3;
         Entry_OutPut = '*PRINTER';
       EndSl;

       If Exit = *Off;
?      //---Check du composant------------------------------------------------//
         If F01Obj <> %subst(SavComp:1:10) Or Dsp_Repro;

?      //---Contrôle du composant---------------------------------------------//
           If Dsp_bib or Dsp_Repro or Not First_Chk;
             F01Bib = *Blanks;
             F01Typ = *Blanks;
           EndIf;
           First_Chk = *Off;
           ExSr Chk_Composant;

?      //---Sauvegarde du composant-------------------------------------------//
           SavComp = *Blanks;
           SavComp = F01Obj + F01Bib + F01Typ;

?      //---Choix des options disponibles-------------------------------------//
           ExSr Chk_Options;

?      //---Appel de l'option-------------------------------------------------//
           If Entry_Fct <> '*NONE' and Trt ='*INTERACTIVE';
             ExSr Call_Option;
           EndIf;

         Else;
?      //---Appel de l'option-------------------------------------------------//
           ExSr Call_Option;
         EndIf;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Finalisation------------------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Fin;

?      //---Suppression de l'alias de QTEMP-----------------------------------//
       Req_Sql = 'DROP ALIAS QTEMP/PGMREF ';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :req_sql
     C/END-EXEC

?      //---Fermeture du fichier écran----------------------------------------//
       If %Open(zz01d);
         Close zz01d;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Affichage des modifications en cours------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Dsp_Chg;

?      //---Clear du sous-fichier---------------------------------------------//
       F03Rrn = 0;
       SflInd = *On;
       Write F03Ctl;
       SflInd = *Off;

?      //---Définitions des touches de fonction-------------------------------//
       F03Des = x'26' + 'Nouveautés avec la version '+ Version + x'22';
       F03Rrn = F03Rrn + 1;
       Write F03Sfl;

       For i = 1 To 20;
         F03des = Nouv_Tab(i);
         F03Rrn = F03Rrn + 1;
         Write F03Sfl;
       EndFor;

?      //---Définitions des touches de fonction-------------------------------//
       F03Des = x'26' + 'Touches de fonctions' + x'22';
       F03Rrn = F03Rrn + 1;
       Write F03Sfl;

       F03Des = '';
       F03Rrn = F03Rrn + 1;
       Write F03Sfl;

       For i = 1 To 24;
         If %subst(F04DesTab(i):7:15) <> *Blanks;
           F03des = F04DesTab(i);
           %Subst(F03Des:9:1) = x'22';
           F03Rrn = F03Rrn + 1;
           Write F03Sfl;
         EndIf;
       EndFor;
?      //---Définitions des Dernières Modifications---------------------------//
       F03Des = '';
       F03Rrn = F03Rrn + 1;
       Write F03Sfl;

       %subst(F03Des:35:20) = x'22' + '.:._____________.:.';
       F03Rrn = F03Rrn + 1;
       Write F03Sfl;

       F03Des = '';
       F03Rrn = F03Rrn + 1;
       Write F03Sfl;

       F03Des = x'26' + 'Dernières Modifications' + x'22';
       F03Date = x'26' + 'Dt Modif.';
       F03Rrn = F03Rrn + 1;
       Write F03Sfl;

       F03Date = *Blanks;
       F03Des = *Blanks;
       F03Rrn = F03Rrn + 1;
       Write F03Sfl;

       For i = 1 to Mdf;
         If Modifencours(i) <> *Blanks;
           F03Date = %subst(ModifEnCours(i):83:10);
           F03Des = %subst(ModifEnCours(i):1:80);
           F03Rrn += 1;
           Write F03Sfl;
           F03Date = *Blanks;
         Endif;
       EndFor;

?      //---Affichage du sous-fichier-----------------------------------------//
       If F03Rrn > 0;
         ExFmt F03Ctl;
         Exit = *Off;
         Retour = *Off;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Contrôle du composant---------------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Chk_Composant;

       F01Des = *Blanks;
?      //---Contrôle Existence de la bibliothèque et description--------------//
       QusrObjd(Objd0400:%Size(Objd0400):COBJD0200:
               F01Bib+'QSYS':'*LIB':ApiError);
B01    If Not(AeBytAvl <=*Zero);
         F01Bib = '*ALL';
E01    EndIf;

?      //---Clear du sous-fichier---------------------------------------------//
B01    If Trt = '*INTERACTIVE';
         F02Rrn = 0;
         SflInd = *On;
         Write F02Ctl;
         SflInd = *Off;
E01    EndIf;

?      //---Traduction du Composant-------------------------------------------//
B01    If Dsp_Repro;
         F01Obj = ObjComp;
E01    EndIf;

       ObjEntry_Sav = F01Obj;
       ObjComp = ObjEntry_Sav;
       F01Obj = %XLate(lo:up:F01Obj);

?      //---Create User Space List Fichier------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

B01    If (F01Bib <> '*LIBL' and F01Bib <>'' and F01Bib <>'*ALL');
?      //---Liste des objets avec le nom ObjNam-------------------------------//
         Obj = F01Obj;
         Lib = F01Bib;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         FormatName = 'OBJL0100';
         QUslObj(UserSpace:FormatName:Composant:ObjectType);

?      //---Retrieve user space General information---------------------------//
         StartPosit = 1;
         StartLen = 1024;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
         StartPosit = ListOffset + 1;
         StartLen = EntrySize;
         NbrMbr = NumberList;

?      //---Lecture de tous les composants------------------------------------//
B02      For Nbr = 1 To NbrMbr;
           SpaceName = 'USERSPACE';
           SpaceLib = 'QTEMP';
           QUsRtvUs(UserSpace:StartPosit:StartLen:DsList);
           StartPosit = StartPosit + StartLen;
?      //---Alimentation du Sous-fichier de sélection-------------------------//
B03        If F01Typ = *Blanks or F01Typ = DsListTyp;
             F02Obj = DsListFile;
             F02Lib = DsListLib;
             F02Typ = DsListTyp;
             QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                     F02Obj + F02Lib:F02Typ:ApiError);
             F02Des = OdObjTxtDes;
B04          If Trt <> '*INTERACTIVE';
               Nbr = NbrMbr;
               i = Tab_Inf('OBLIB');
               F02Rrn = 1;
X04          Else;
               F02Rrn += 1;
               Write F02Sfl;
E04          EndIf;
E03        EndIf;
E02      EndFor;
X01    Else;
?      //---Liste des objets avec le nom ObjNam-------------------------------//
         Obj = F01Obj;
         Lib = '*ALL';
         ObjectType = '*ALL';
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         FormatName = 'OBJL0100';
         QUslObj(UserSpace:FormatName:Composant:ObjectType);

?      //---Retrieve user space General information---------------------------//
         StartPosit = 1;
         StartLen = 1024;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
         StartPosit = ListOffset + 1;
         StartLen = EntrySize;
         NbrMbr = NumberList;

?      //---Lecture de tous les composants------------------------------------//
B02      For Nbr = 1 To NbrMbr;
           SpaceName = 'USERSPACE';
           SpaceLib = 'QTEMP';
           QUsRtvUs(UserSpace:StartPosit:StartLen:DsList);
           StartPosit = StartPosit + StartLen;
?      //---Alimentation du Sous-fichier de sélection-------------------------//
           If Tab_Srch('OBLIB':DsListLib:1) > 0;
B03        If F01Typ = *Blanks or F01Typ = DsListTyp;
             F02Obj = DsListFile;
             F02Lib = DsListLib;
             F02Typ = DsListTyp;
             QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                   F02Obj + F02Lib:F02Typ:ApiError);
             F02Des = OdObjTxtDes;
?      //---Bibliothèque existe dans la liste ?-------------------------------//
B04          If Tab_Srch('OBLIB':F02Lib:1) = 0;
               Dsp_Bib = *On;
X04          Else;
B05            If Not DspPc;
                 DspPc = *On;
E05            EndIf;
               Dsp_Bib = *Off;
E04          EndIf;
?      //---Remplissage du sous-fichier---------------------------------------//
B04          If Trt <> '*INTERACTIVE';
               Nbr = NbrMbr;
               i = Tab_Inf('OBLIB');
               F02Rrn = 1;
X04          Else;
               F02Rrn += 1;
               Write F02Sfl;
E04          EndIf;
E03        EndIf;
           EndIf;
E02      EndFor;
?      //---Liste des objets avec le nom ObjNam-------------------------------//
         Obj = F01Obj;
         Lib = '*ALL';
         ObjectType = '*ALL';
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         FormatName = 'OBJL0100';
         QUslObj(UserSpace:FormatName:Composant:ObjectType);

?      //---Retrieve user space General information---------------------------//
         StartPosit = 1;
         StartLen = 1024;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
         StartPosit = ListOffset + 1;
         StartLen = EntrySize;
         NbrMbr = NumberList;

B02      For Nbr = 1 To NbrMbr;
           SpaceName = 'USERSPACE';
           SpaceLib = 'QTEMP';
           QUsRtvUs(UserSpace:StartPosit:StartLen:DsList);
           StartPosit = StartPosit + StartLen;
           If Tab_Srch('OBLIB':DsListLib:1) = 0;
?      //---Alimentation du Sous-fichier de sélection-------------------------//
B03        If F01Typ = *Blanks or F01Typ = DsListTyp;
             F02Obj = DsListFile;
             F02Lib = DsListLib;
             F02Typ = DsListTyp;
             QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                   F02Obj + F02Lib:F02Typ:ApiError);
             F02Des = OdObjTxtDes;
?      //---Bibliothèque existe dans la liste ?-------------------------------//
B04          If Tab_Srch('OBLIB':F02Lib:1) = 0;
               Dsp_Bib = *On;
X04          Else;
B05            If Not DspPc;
                 DspPc = *On;
E05            EndIf;
               Dsp_Bib = *Off;
E04          EndIf;
?      //---Remplissage du sous-fichier---------------------------------------//
B04          If Trt <> '*INTERACTIVE';
               Nbr = NbrMbr;
               i = Tab_Inf('OBLIB');
               F02Rrn = 1;
X04          Else;
               F02Rrn += 1;
               Write F02Sfl;
E04          EndIf;
E03        EndIf;
           EndIf;
E02      EndFor;
E01    EndIf;

?      //---Si un seul enregistrement, retour à l'écran principal sinon ...---//
B01    If F02Rrn = 1;
         F01Obj = F02Obj;
         QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                 F02Obj + F02Lib:F02Typ:ApiError);
         F01Des = OdObjTxtDes;
         F01Bib = F02Lib;
         F01typ = F02Typ;
X01    Else;
?      //---...Affichage du sous-fichier--------------------------------------//
B02      If F02Rrn > 0;
           ExFmt F02Ctl;
E02      EndIf;

?      //---Récupération de l'objet sélectionné-------------------------------//
B02      If F02Cur > 0 and not exit and not retour;
           Chain F02Cur F02Sfl;
B03        If %Found;
             F01Obj = F02Obj;
?      //---Récupération de la description de l'objet-------------------------//
             QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                     F02Obj + F02Lib:F02Typ:ApiError);
             F01Des = OdObjTxtDes;
             F01Bib = F02Lib;
             F01typ = F02Typ;
E03        EndIf;
X02      Else;
B03        If Tab_Get('Rappel1':IndRapWrk) <> *Blanks;
             F01Obj = Tab_Get('Rappel1':IndRapWrk);
             F01Des = Tab_Get('Rappel2':IndRapWrk);
             F01Bib = Tab_Get('Rappel3':IndRapWrk);
             F01Typ = Tab_Get('Rappel4':IndRapWrk);
E03        EndIf;
           Retour = *Off;
           Exit = *Off;
E02      EndIf;
E01    EndIf;

?      //---Couleur de la bibliothèque sur écran principale-------------------//
B01    If Tab_Srch('OBLIB':F01Bib:1) = 0 and F01Bib <> *Blanks;
         Dsp_Bib = *On;
X01    Else;
         Dsp_Bib = *Off;
E01    EndIf;
       DspPc = *Off;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

?      //---Ajout de la bibliothèque dans PGMREF si inexistante---------------//
       If Tab_Srch('OBLIB':F01Bib:1) = 0 and F01Bib <> '*ALL' And
       F01Bib <> '*LIBL' and F01Bib <> '';
         F15Bib = F01Bib;
         ExFmt F15;
         If Not Retour;
     C/EXEC SQL
     C+  INSERT INTO zz01pf
     C+    VALUES ('OBLIB', :f01bib)
     C/END-EXEC
           Maj_Ref(F01Bib);
           Tab_Term('OBLIB');
           ExSr Get_Bib_Obj;
           Dsp_Bib = *Off;
         EndIf;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Contrôle des options disponibles----------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Chk_Options;

       Select ;
         When F01Typ = *Blanks;
           AutObj = OptVide;
         When F01Typ = '*FILE';
           AutObj = OptFile;
         When F01Typ = '*PGM';
           AutObj = OptPgm;
         When F01Typ = '*MODULE';
           AutObj = OptModule;
         When F01Typ = '*DTAARA';
           AutObj = OptDtaara;
         When F01Typ = '*SRVPGM';
           AutObj = OptSrvPgm;
         When F01Typ = '*QRYDFN';
           AutObj = OptQuery;
       EndSl;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Appel de l'option-------------------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Call_Option;

?      //---Initialisation des zones de travail-------------------------------//
       Reset LigXref;
       Ctl_Fonct = *Off;

?      //---ORIENTATION SUIVANT FONCTIONNALITE--------------------------------//
       Select;

?      //---[F01]------------------------------------------------------------*//
         When OptAide or Entry_Fct = '*HELP';
           ZzFonc = '*HELP';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Dsp_Chg;
?      //---[F02]------------------------------------------------------------*//
         When OptXref or Entry_Fct = '*XREF';
           Tab_Term2('££WRK');
           ZzFonc = '*XREF';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr XRefOBJ;
           Ctl_Fonct = *On;
?      //---[F04]------------------------------------------------------------*//
         When OptRecDesc or Entry_Fct = '*RECDESC';
           Tab_Term2('££WRK');
           ZzFonc = '*RECDESC';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Rec_Desc;
           Ctl_Fonct = *On;
?      //---[F05]------------------------------------------------------------*//
         When OptPlugin;
           ExSr Plugin;
           Ctl_Fonct = *On;
?      //---[F06]-------------------------------------------------------------//
         When OptRunQry Or Entry_Fct = '*RUNQRY';
           ZzFonc = '*RUNQRY';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Run_Qry;
           Ctl_Fonct = *Off;
?      //---[F07]-------------------------------------------------------------//
         When OptDesc or Entry_Fct ='*DESCFILE';
           Tab_Term2('££WRK');
           ZzFonc = '*DESCFILE';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           Exsr Dsp_File;
           Ctl_Fonct = *On;
?      //---[F08]-------------------------------------------------------------//
         When OptAccPth or Entry_Fct = '*LSTLF';
           Tab_Term2('££WRK');
           ZzFonc = '*LSTLF';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Dsp_Accpth;
           Ctl_Fonct = *On;
?      //---[F09]-------------------------------------------------------------//
         When OptRappel;
           If IndRapWrk = Ind_Rappel;
             IndRapWrk = Ind_Rappel;
           EndIf;
           IndRapWrk -= 1;
           If IndRapWrk < 1;
             IndRapWrk = 1;
           EndIf;
           If IndRapWrk > 0;
             F01Obj = Tab_Get('Rappel1':IndRapWrk);
             F01Des = Tab_Get('Rappel2':IndRapWrk);
             F01Bib = Tab_Get('Rappel3':IndRapWrk);
             F01Typ = Tab_Get('Rappel4':IndRapWrk);
             ZzFonc = Tab_Get('Rappel5':IndRapWrk);
             SavComp = *Blanks;
             SavComp = F01Obj + F01Bib + F01Typ;
             FzzDesc = Rtv_entete(ZzFonc);
             Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
             Tab_Trf2(%Char(IndRapWrk):'££WRK');
             Ctl_Fonct = *On;
           EndIf;
?      //---[F10]-------------------------------------------------------------//
         When OptRappelP;
           IndRapWrk += 1;
           If IndRapWrk > Ind_Rappel;
             IndRapWrk = Ind_rappel;
           EndIf;
           If IndRapWrk > 0;
             F01Obj = Tab_Get('Rappel1':IndRapWrk);
             F01Des = Tab_Get('Rappel2':IndRapWrk);
             F01Bib = Tab_Get('Rappel3':IndRapWrk);
             F01Typ = Tab_Get('Rappel4':IndRapWrk);
             ZzFonc = Tab_Get('Rappel5':IndRapWrk);
             SavComp = *Blanks;
             SavComp = F01Obj + F01Bib + F01Typ;
             FzzDesc = Rtv_entete(ZzFonc);
             Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
             Tab_Trf2(%Char(IndRapWrk):'££WRK');
             Ctl_Fonct = *On;
           EndIf;
?      //---[F11]-------------------------------------------------------------//
         When OptRecProc or Entry_Fct = '*RECPROC';
           Tab_Term2('££WRK');
           ZzFonc = '*RECPROC';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Rec_Procedure;
           Ctl_Fonct = *On;
?      //---[F13]-------------------------------------------------------------//
         When OptImpr;
           ExSr Prt_Sfl;
?      //---[F14]-------------------------------------------------------------//
         When OptWhereUsed or Entry_Fct = '*WHEREUSED';
           Tab_Term2('££WRK');
           ZzFonc = '*WHEREUSED';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Where_Used;
           Ctl_Fonct = *On;
?      //---[F15]-------------------------------------------------------------//
         When OptCarto or Entry_Fct = '*CARTOPGM'
           and F01Obj <> *Blanks;
           Tab_Term2('££WRK');
           ZzFonc ='*CARTOPGM';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           Exsr AlgoPgm;
           Ctl_Fonct = *On;
?      //---[F16]-------------------------------------------------------------//
         When OptCartoSrc or Entry_Fct = '*CARTOSRC'
           or Entry_Fct ='*CARTOSRC2';
           Tab_Term2('££WRK');
           ZzFonc ='*CARTOSRC';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Analyse;
           Ctl_Fonct = *On;
?      //---[F17]-------------------------------------------------------------//
         When OptRecZone or Entry_Fct = '*RECZONE' and F01Obj <> *Blanks;
           ZzFonc = '*RECZONE';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Rec_Zone;
           Ctl_Fonct = *On;
?      //---[F18]-------------------------------------------------------------//
         When OptSplf or Entry_Fct = '*WRKSPLF';
           ExSr Wrk_Splf;
           Ctl_fonct = *On;
?      //---[F19]-------------------------------------------------------------//
         When OptAffObj or Entry_Fct = '*DESCOBJ';
           Tab_Term2('££WRK');
           ZzFonc = '*DESCOBJ';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Aff_Obj;
           Ctl_Fonct = *On;
?      //---[F20]-------------------------------------------------------------//
         When OptCartoIle or Entry_Fct = '*CARTOILE';
           Tab_Term2('££WRK');
           ZzFonc = '*CARTOILE';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           ExSr Carto_Ile;
           Ctl_Fonct = *On;
?      //---[F21]-------------------------------------------------------------//
         When OptLigCmd or Entry_Fct = '*CMD';
           ZzFonc = '*CMD';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           QUsCmdLn();
?      //---[F22]-------------------------------------------------------------//
         When OptSrch or Entry_Fct = '*RECCAR' and F01Obj <> *Blanks;
           Tab_Term2('££WRK');
           ZzFonc = '*RECCAR';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           Exsr Scan;
           Ctl_Fonct = *On;
?      //---[F23]-------------------------------------------------------------//
         When OptAnalyse or Entry_Fct = '*ANALYSE';
           Tab_Term2('££WRK');
           ZzFonc = '*ANALYSE';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           Gst_Analyse();
           Ctl_Fonct = *On;
?      //---[F24]-------------------------------------------------------------//
         When OptBib or Entry_Fct = '*LIBRARY';
           ZzFonc = '*LIBRARY';
           FzzDesc = Rtv_entete(ZzFonc);
           Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
           Exsr Liste_Bib;
?      //---[Fxx]-------------------------------------------------------------//
         When Entry_Fct = '*PGMREF';
           If Tab_Srch('OBLIB':F01Obj:1) = 0;
     C/EXEC SQL
     C+  INSERT INTO zz01pf
     C+    VALUES ('OBLIB', :f01obj)
     C/END-EXEC
           EndIf;
           Maj_Ref(F01Obj);
           Ctl_Fonct = *Off;

       EndSl;

?      //---Mise en mémoire des dernières recherches--------------------------//
       If %Trim(F01Obj) + %Trim(F01Bib) + %Trim(F01Typ) +%Trim(ZzFonc) <>
          %Trim(Tab_Get('Rappel1':Ind_Rappel)) +
          %Trim(Tab_Get('Rappel3':Ind_Rappel)) +
          %Trim(Tab_Get('Rappel4':Ind_Rappel)) +
          %Trim(Tab_Get('Rappel5':Ind_Rappel))
           And Not OptRappel And Not OptRappelP
           And ZzFonc <> '*LIBRARY' And ZzFonc <> '*ANALYSE'
           And ZzFonc <> *Blanks And Ctl_Fonct;
         Ind_Rappel += 1;
         IndRapWrk = Ind_Rappel;
         Tab_Set('Rappel1':Ind_Rappel:F01Obj);
         Tab_Set('Rappel2':Ind_Rappel:F01Des);
         Tab_Set('Rappel3':Ind_Rappel:F01Bib);
         Tab_Set('Rappel4':Ind_Rappel:F01Typ);
         Tab_Set('Rappel5':Ind_Rappel:ZzFonc);
         Tab_Trf2('££WRK':%Char(Ind_Rappel));
       EndIf;

?      //---Sortie Impression-------------------------------------------------//
       If F01Output = 3;
         Exsr Prt_Sfl;
       EndIf;

?      //---Sortie Fichier----------------------------------------------------//
       If F01Output = 2;
         Exsr Ins_Fichier;
       EndIf;

?      //---Reset des indicateurs de touches----------------------------------//
       If Exit = *On;
         Fonc_Ind = *All'0';
         Exit = *On;
       Else;
         Fonc_Ind = *All'0';
       EndIf;

?      //---Affichage des résultats-------------------------------------------//
       If Entry_OutPut = '*DISPLAY';

         If Ctl_Fonct;
?      //---Affichage de l'entête---------------------------------------------//
           Write F01;
?      //---Affichage du pied de page-----------------------------------------//
           Write Foot;
?      //---Affichage du sous-fichier-----------------------------------------//
           ExSr Aff_Sfl;
         EndIf;

?      //---Gestion de la touche entrée---------------------------------------//
         If FzzCur > 0 and Exit <> *On and Retour <> *On and OptRappel <> *On
            and OptRappelP <> *On;
           Chain FzzCur FzzSfl;
           If %Found;
             LigXref = FzzZone;
             F01Obj = XrefNom;
             F01Des = XrefTxtDsc;
             F01Bib = XrefLnam;
             F01Typ = XrefOtyp;
             SavComp = *Blanks;
             SavComp = F01Obj + F01Bib + F01Typ;
             Exsr Chk_Composant;
           EndIf;
           FzzCur = *Zero;
         Else;
           If F01Obj <> %Subst(SavComp:1:10);
             F01Typ = *Blanks;
             F01Bib = *Blanks;
             Exsr Chk_Composant;
             SavComp = *Blanks;
             SavComp = F01Obj + F01Bib + F01Typ;
           EndIf;
         EndIf;
         F01OutPut = 1;
         Entry_Fct = '*NONE';
       Else;
?      //---Sortie fichier----------------------------------------------------//
         Entry_Fct= *Blanks;
       EndIf;

?      //---Si Mode *NOPROMPT, sortie immédiate-------------------------------//
       If Trt= '*NOPROMPT';
         Exit = *On;
       EndIf;

       DspPr = *Off;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Gestion des plugins-----------------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Plugin;

?      //---Clear du sous-fichier---------------------------------------------//
       If Entry_OutPut = '*DISPLAY' or Entry_OutPut = '*PRINTER';
         F05Rrn = 0;
         SflInd = *On;
         Write F05Ctl;
         SflInd = *Off;

         For i=1 to 20;
?      //---Alimentation du sous-fichier--------------------------------------//
           If Tb_Plugin(i) <> '';
             Plug05 =  Tb_Plugin(i);
             F05Rrn += 1;
             write f05sfl;
           EndIf;
         EndFor;

?      //---Si pas de plugin--------------------------------------------------//
         If F05Rrn = 0;
           Plug05 = 'Aucun Plugin détecté';
           F05Rrn += 1;
           write f05sfl;
         EndIf;

?      //---Affichage du sous-fichier-----------------------------------------//
         ExFmt F05ctl;
?      //---Appel du plugin---------------------------------------------------//
         If F05Cur > 0 and not Retour and not Exit;
?      //---Récupération de l'objet sélectionné-------------------------------//
           Chain F05Cur F05Sfl;
           If %Found;
?      //---Alimentation des paramètres en entrée-----------------------------//
             Exsr Alim_DataPlugin;
?      //---Appel du Plugin---------------------------------------------------//
             Select;
               When  F05Cur = 1;
                 Rec_Avc(DataPlugin);
               When  F05Cur = 2;
                 Taille_Bib(DataPlugin);
               When  F05Cur = 3;
                 Net_PgmRef(DataPlugin);
               When  F05Cur = 4;
                 Zone_Prog(DataPlugin);
               When  F05Cur = 5;
                 Arc_Trigg(DataPlugin);
             EndSl;
?      //---Récupération des paramètres en sortie-----------------------------//
             Exsr Extr_DataPlugin;
           EndIf;
         EndIf;
       EndIf;
       EndSr;

?      //---------------------------------------------------------------------//
?      //---Alimentation des paramètres pour les plugin-----------------------//
?      //---------------------------------------------------------------------//

       BegSr Alim_DataPlugin;
       x_Date      = %Char(%Date);
       x_heure     = %char(%Time);
       x_User      = %Trim(Utilisateur);
       x_Job       = %Trim(Travail);
       x_NJob      = %Char(Numero);
       x_Os400     = Version_Os;
       x_Version   = Version;
       x_Plugin    = Plug05;
       x_SrvPgm    = ''      ;
       x_SrvLib    = ''      ;
       x_Mode      = %Char(F01Mode);
       x_Output    = %Char(F01Output);
       x_Objet     = F01Obj;
       x_Bib       = F01Bib;
       x_Type      = F01Typ;
       x_Texte     = F01Des;
       x_FicSrc    = OdObjSrcFil;
       x_BibSrc    = OdObjSrcLib;
       x_MbrSrc    = OdObjSrcMbr;
       x_NivSrc    = F12Mod;
       x_LastFunct = ZzFonc;
       x_BibRef    = LibRef;
       EndSr;

?      //---------------------------------------------------------------------//
?      //---Extraction des paramètres pour les plugin--  ---------------------//
?      //---------------------------------------------------------------------//

       BegSr Extr_DataPlugin;
       F01Obj = x_Objet;
       F01Bib = x_Bib;
       F01Typ = x_Type;
       F01Des = x_Texte;
       F12Src = x_FicSrc;
       F12Lib = x_BibSrc;
       F12Mbr = x_MbrSrc;
       F12Mod = x_NivSrc;
       ZzFonc = x_LastFunct;
       LibRef = x_BibRef;
       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F02] : XREF------------------------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr XRefOBJ;

?      //---Traduction du type d'objet----------------------------------------//
       Select;
       when F01Typ = '*PGM';
         Spkg = 'P';
       when F01Typ = '*MODULE';
         Spkg = 'M';
       when F01Typ = '*SRVPGM';
         Spkg = 'V';
       when F01Typ = '*QRYDFN';
         Spkg = 'Q';
       EndSl;

?      //---Requete sur PGMREF------------------------------------------------//
       Requete1 = 'select whfnam, whlnam, whfusg, whOtyp, whrfsn, whrfnm from '+
       LibRef + '/pgmref where whpnam = ''' + %Trim(F01Obj) +
       ''' and whlib = ''' + %Trim(F01Bib) + ''' and whSpkg = ''' + Spkg + '''';

?      //---Préparation, Déclaration, Ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s1_pgmref FROM :requete1
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c1_pgmref CURSOR FOR s1_pgmref
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c1_pgmref
     C/END-EXEC

     C/EXEC SQL
     C+  FETCH NEXT FROM c1_pgmref INTO :fnam, :lnam, :fusg, :otyp, :rfsn, :rfnm
     C/END-EXEC

       Cpt_I = 0;
       Dow SqlCod <> EndOfFile;
         ObjChk = Fnam;
         TypChk = Otyp;
         LibChk = Lnam;
         Exsr Chk_Obj;
         Exsr Chk_Usage;
?      //---Alimentation des zones--------------------------------------------//
         XrefNom    = Fnam;
         XrefTxtDsc = TxtDscOk;
         XrefUsage  = Usage;
         XrefRfnm   = Rfnm;
         XrefOTyp   = OTyp;
         XrefLnam   = Lnam;
         XrefRfsn   = Rfsn;
         FzzZone    = *Blanks;
         FzzZone    = LigXref;

?      //---Alimentation du tableau principal---------------------------------//
         Cpt_I += 1;
         Tab_Set2('££WRK':Cpt_I:FzzZone);

     C/EXEC SQL
     C+  FETCH NEXT FROM c1_pgmref INTO :fnam, :lnam, :fusg, :otyp, :rfsn, :rfnm
     C/END-EXEC
       Enddo;

     C/EXEC SQL
     C+  CLOSE c1_pgmref
     C/END-EXEC

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Contrôle de l'objet-----------------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Chk_Obj;

       WLiblOk  = *Blanks;
       TxtDscOk = *Blanks;
       SrcMbrOk = *Blanks;
       SrcFOk   = *Blanks;
       SrcLibOk = *Blanks;

?      //---Traduction du composant-------------------------------------------//
       ObjChk = %XLate(lo:up:ObjChk);

?      //---Recherche de la description de l'objet----------------------------//
       QusrObjd(ObjD0400:%Size(ObjD0400):CObjD0400
              :ObjChk+LibChk:TypChk:ApiError);
?      //---Objet non trouvé--------------------------------------------------//
       If AeBytAvl > *Zero;
         WLiblOk = *All'?';
         TxtDscOk = *All'?';
         SrcMbrOk = *Blanks;
         SrcFOk = *Blanks;
         SrcLibOk = *Blanks;
       Else;
?      //---Objet trouvé------------------------------------------------------//
         WLiblOk = OdObjLib;
         TxtDscOk = OdObjTxtDes;
         SrcMbrOk = OdObjSrcMbr;
         SrcFOk = OdObjSrcFil;
         SrcLibOk = OdObjSrcLib;
         i = Tab_Inf('OBLIB');
       EndIf;

       If AeBytAvl > *Zero;
         For i=1 to Tab_Inf('OBLIB');
  ?      //---Recherche de la description de l'objet--------------------------//
           QusrObjd(ObjD0400:%Size(ObjD0400):CObjD0400
                   : ObjChk + %subst(Tab_Get('OBLIB':i):1:10)
                   : TypChk:ApiError);
  ?      //---Objet non trouvé------------------------------------------------//
           If AeBytAvl > *Zero;
             WLiblOk = *All'?';
             TxtDscOk = *All'?';
             SrcMbrOk = *Blanks;
             SrcFOk = *Blanks;
             SrcLibOk = *Blanks;
           Else;
  ?      //---Objet trouvé----------------------------------------------------//
             WLiblOk = OdObjLib;
             TxtDscOk = OdObjTxtDes;
             SrcMbrOk = OdObjSrcMbr;
             SrcFOk = OdObjSrcFil;
             SrcLibOk = OdObjSrcLib;
             i = Tab_Inf('OBLIB');
           EndIf;
         EndFor;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Contrôle de l'usage d'un fichier----------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Chk_Usage;

       Select;
         When Fusg  = 0;
           Usage =' N/A';
         When Fusg  = 1;
           Usage =' Lecture';
         When Fusg  = 2;
           Usage =X'22' + 'Ecriture';
         When Fusg  = 3;
           Usage= X'22' + 'Lect./Ecrit.';
         When Fusg  = 4;
           Usage= X'22' + 'Mise à jour';
         When Fusg  = 5;
           Usage= X'22' + 'Lecture/MàJ';
         When Fusg  = 6;
           Usage= X'22' + 'Ecriture/MàJ';
         When Fusg  = 7;
           Usage= X'22' + 'Le./Ec./MàJ';
         When Fusg  = 8;
           Usage= ' Non indiqué';
         When Fusg  = 9;
           Usage= ' Lecture/NI';
         When Fusg  = 10;
           Usage= X'22' + 'Ecriture/NI';
         When Fusg  = 11;
           Usage= X'22' + 'Le./Ec./NI';
         When Fusg  = 12;
           Usage= X'22' + 'MàJ/NI';
       EndSl;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F19] : Affichage de la description d'un objet--------------------//
?      //---------------------------------------------------------------------//

       BegSr Aff_Obj;

?      //---Recherche information de l'objet----------------------------------//
       QusrObjd(Objd0400:%size(Objd0400):Cobjd0400:
                   F01Obj + F01Bib:F01Typ:ApiError);
?      //---Nom de l'objet---------------------------------------------Lig. 1-//
       FzzZone = 'Nom de l''Objet..:' + x'22'+ OdObjNam;

?      //---Alimentation du tableau principal---------------------------------//
       Cpt_I = 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Bibliothèque de l'objet------------------------------------Lig. 2-//
       FzzZone = 'Bibliothèque....:'+ x'22' + OdObjLib;
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Type de l'objet--------------------------------------------Lig. 3-//
       FzzZone = 'Type de l''Objet.:' + x'22'+ OdObjTypRt;
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Description de l'objet-------------------------------------Lig. 4-//
       FzzZone = 'Description.....:' + x'22'+ OdObjTxtDes;
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---ASP de l'Objet---------------------------------------------Lig. 5-//
       FzzZone = 'ASP.............:' + x'22'+ %Char(OdObjASP);
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Propriétaire de l'objet------------------------------------Lig. 6-//
       FzzZone = 'Propriétaire....:' + x'22'+ OdObjOwn;
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Domaine de l'objet-----------------------------------------Lig. 7-//
       FzzZone = 'Domaine.........:' + x'22'+ OdObjDmn;
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Info Création/Modification/Source--------------------------Lig. 8-//
       FzzZone = 'Création';
       %Subst(fzzZone:33:12)= 'Modification';
       %Subst(fzzZone:65:20)= 'Dernière utilisation';
       %Subst(fzzZone:93:6)= 'Source';
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Date création----------------------------------------------Lig. 9-//
       FzzZone = '    Date........:' + x'22'+
       %subst(OdObjCrtDts:4:2) + '/' + %Subst(OdObjCrtDts:4:2) + '/' +
       %char(%Dec(%Subst(OdObjCrtDts:1:1):1:0) + 19) + %Subst(OdObjCrtDts:2:2);
       %subst(FzzZone:33:28) =  x'20' + '   Date........:' + x'22'+
       %subst(OdObjChgDts:6:2) + '/' + %Subst(OdObjChgDts:4:2) + '/' +
       %char(%Dec(%Subst(OdObjChgDts:1:1):1:0) + 19) + %Subst(OdObjChgDts:2:2);
       //---Date Dernière utilisation----------------------------------Lig. 9-//
       %subst(FzzZone:65:17) = x'20' + '  Date........:' + x'22';
       IF OdObjLast<>*Blank;
         %subst(FzzZone:82:10) = %subst(OdObjLast:6:2) + '/' +
         %Subst(OdObjLast:4:2) + '/' +  %char(%Dec(%Subst(OdObjLast:1:1):1:0)
          + 19) + %Subst(OdObjLast:2:2);
       Endif;

       %subst(FzzZone:93:35) = x'20' + '   Fichier.........:' + x'22'
                               + OdObjSrcFil;
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Heure création---------------------------------------------Lig. 10//
       FzzZone = '    Heure.......:' + x'22'+ %Subst(OdObjCrtDts:8:2) +
       'h' + %Subst(OdObjCrtDts:10:2) + 'mn'+%subst(OdObjCrtDts:12:2) + 's';
       %subst(FzzZone:33:28) = x'20' + '   Heure.......:' +
        x'22'+ %Subst(OdObjChgDts:8:2) +
       'h' + %Subst(OdObjChgDts:10:2) + 'mn'+%subst(OdObjChgDts:12:2) + 's';
       %subst(FzzZone:93:35) = x'20' + '   Bibliothèque....:' + x'22'
                               + OdObjSrcLib;

       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Membre Source----------------------------------------------Lig. 11//
       FzzZone = *Blanks;
       %subst(FzzZone:93:35) = '    Membre..........:' + x'22'+ OdObjSrcMbr;
       Cpt_I += 1;
       Tab_Set2('££WRK':Cpt_I:FzzZone);

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F14] : Recherche Where Used--------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Where_Used;

       ExSr Srch_logics;

?      //---Requete sur PGMREF------------------------------------------------//
       Requete0 = 'Select whlib, whpnam, whfusg, whspkg, whtext                +
                , whfnam, whrfsn from ' + %Trim(LibRef) + '/pgmref where       +
                whfnam in ' + %Trim(all_File)                                  +
                 ' and whotyp = ''' + %Trim(F01Typ)                            +
                  ''' and whlib in (select zzvaleur from '                     +
                  'zz01pf where zztype=''OBLIB'' ) order by Whlib';

?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s2_pgmref FROM :requete0
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c2_pgmref CURSOR FOR s2_pgmref
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c2_pgmref
     C/END-EXEC

     C/EXEC SQL
     C+  FETCH NEXT FROM c2_pgmref
     C+    INTO :lib, :pnam, :fusg, :spkg, :desc, :rfnm, :rfsn
     C/END-EXEC

       Cpt_I = 0;
       Dow SqlCod <> EndOfFile;
?      //---Alimentation du Sous Fichier--------------------------------------//
         Select;
           When Spkg = 'P';
             Otyp = '*PGM';
           When Spkg = 'F';
             Otyp = '*FILE';
           when Spkg = 'M';
             Otyp = '*MODULE';
           when Spkg = 'V';
             Otyp = '*SRVPGM';
           when Spkg = 'Q';
             Otyp = '*QRYDFN';
         Other;
             Otyp = *all'?';
         EndSl;

         ObjChk = Pnam;
         TypChk = Otyp;
         LibChk = Lib;
         ExSr Chk_Obj;
         Exsr Chk_Usage;
?      //---Alimentation des zones--------------------------------------------//
         FzzZone    = *Blanks;
         XrefNom    = Pnam;
         XrefTxtDsc = TxtDscOk;
         XrefUsage  = Usage;
         XrefRfnm   = Rfnm;
         XrefOTyp   = OTyp;
         XrefLnam   = Lib;
         XrefRfsn   = Rfsn;
         FzzZone    = LigXref;

?      //---Alimentation du tableau principal---------------------------------//
         Cpt_I += 1;
         Tab_Set2('££WRK':Cpt_I:FzzZone);

     C/EXEC SQL
     C+  FETCH NEXT FROM c2_pgmref
     C+    INTO :lib, :pnam, :fusg, :spkg, :desc, :rfnm, :rfsn
     C/END-EXEC
       Enddo;

     C/EXEC SQL
     C+  CLOSE c2_pgmref
     C/END-EXEC


       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F07] : Affichage description du fichier--------------------------//
?      //---------------------------------------------------------------------//

       BegSr Dsp_File;

       Obj = F01Obj;
       Lib = F01Bib;
       Cpt_I = 0;
?      //---Create User Space-List Fichier------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       SpaceLen = MaxTab;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);
?      //---Liste des formats d'un fichier------------------------------------//
       FormatName = 'RCDL0100';
       OverRide = '1';
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QUslRcd(UserSpace:FormatName:Composant:OverRide);

?      //---Retrieve user space General information---------------------------//
       StartPosit = 1;
       StartLen = 1024;
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       Qusptrus(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
       StartPosit = ListOffset + 1;
       StartLen = EntrySize;
       NbrFmt = NumberList;
       K = 1;

?      //---Lecture de tous les Membres d'un fichier source-------------------//
       For j = 1 To NbrFmt;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         Qusptrus(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:fmt);
         StartPosit = StartPosit + StartLen;
         Tab_Set('FMT':k:Fmt);
         k += 1;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       For j = 1 to Tab_Inf('FMT');
         FzzZone = 'Format : ' + x'22' + Tab_Get('FMT':j);
?      //---Alimentation du tableau principal---------------------------------//
         Cpt_I += 1;
         Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Create User Space-------------------------------------------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                  SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---Get the list of all the fields------------------------------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         OverRide = '1';
         Type = Tab_Get('FMT':j);
         Format  = 'FLDL0100';
         Quslfld(UserSpace:Format:Composant:Type:OverRide);

?      //---Get a pointer to the user space containing the list---------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         Qusptrus(UserSpace:pUserSpace);

         For i = 1 to  NumberList;
           LigDescFile = *Blanks;
           pEntry = pUserSpace + listOffset + ((i-1)*entrySize);
           DescNom = FieldName;
           DescDes = FieldText;
           DescInt = IntName;
           DescAlt = AltName;
           Evalr DescTyp = DataType;
           Evalr DescDeb = %char(OutBufPos);
           Evalr DescFin = %char(OutBufPos + ByteLeng - 1);

           If Digits = 0;
             Evalr DescLon = %char(ByteLeng);
           Else;
             Evalr DescLon = %char(Digits);
           EndIf;

           If DescTyp = 'A';
             DescDec = *Blanks;
             If VaryingInd <> '0';
               DescDec = '~';
             EndIf;
           Else;
             DescDec = %char(DecPos);
           EndIf;

           FzzZone = LigDescFile;
           If %Subst(%trim(FzzZone):1:3) <> '*IN';
?      //---Alimentation du tableau principal---------------------------------//
             Cpt_I += 1;
             Tab_Set2('££WRK':Cpt_I:FzzZone);
           EndIf;

         EndFor;
?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       EndFor;

       Tab_Term('FMT');

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F16] : Analyse du programme--------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr Analyse;

       Cpt_I = 0;

       If Trt = '*INTERACTIVE';
?      //---Recherche du fichier source si possible---------------------------//
         If F01Obj <> *Blanks;
           ObjChk = F01Obj;
           TypChk = F01Typ;
           Exsr Chk_Obj;
           F12Mod = '0';
           If OdObjSrcFil = *Blanks;
             OdObjSrcMbr = F01Obj;
             OdObjSrcLib = F01Bib;
           EndIf;
         Else;
           OdObjSrcMbr = *Blanks;
           OdObjSrcLib = *Blanks;
           OdObjSrcFil = *Blanks;
         EndIf;
       Else;
         If Entry_Fct= '*CARTOSRC2';
           F12Mod ='1';
         Else;
           F12Mod ='0';
         EndIf;
       EndIf;

       If Trt = '*INTERACTIVE' and Entry_FicSrc = *Blanks;
         F12Mbr = F01Obj;
         F12Mbr = OdObjSrcMbr;
         F12Lib = OdObjSrcLib;
         F12Src = OdObjSrcFil;
         Dou (F12Mbr <> *Blanks and F12Lib <> *Blanks and F12Src <> *Blanks)
         or Exit or Retour;
           ExFmt F12;
         EndDo;
       Else;
         Entry_MbrSrc = *Blanks;
         Entry_FicSrc = *Blanks;
         Entry_BibSrc = *Blanks;
       EndIf;

       If F12Mod = '0';
         ZzFonc = '*CARTOSRC';
       Else;
         ZzFonc = '*CARTOSRC2';
       EndIf;

       If Not Exit and Not Retour;

?      //---Appel de l'algorithme de cartographie-----------------------------//
         If Src_Analyse(F12Lib:F12Src:F12Mbr:F12Mod);

?      //---Appel de l'algorithme de cartographie-----------------------------//
           Algo();

?      //---Affichage du sous-fichier-----------------------------------------//
           For g = 1 To Mat_Infy(1);
             FzzZone = *Blanks;
             For f = 1 To Mat_Infx(1);
               LenMat = Mat_lenCol(1:f);
               If f > 1;
                 LenMatP = LenMatP + Mat_LenCol(1:f-1);
               Else;
                 LenMatP = 1;
               EndIf;
               %subst(FzzZone:LenMatP:LenMat) = %subst(Mat_Get(1:f:g):1:LenMat);
             EndFor;

?      //---Affichage Statut--------------------------------------------------//
             If Trt ='*INTERACTIVE';
               Stat001 = 'Affichage du Sous-Fichier';
               Stat002 = 'Rang = ' + %char(FzzRrn);
               Stat003 = *blanks;
               write F13;
             EndIf;

?      //---Alimentation du tableau de travail--------------------------------//
             Cpt_I += 1;
             Tab_Set2('££WRK':Cpt_I:FzzZone);

           EndFor;

?      //---Suppression des tableaux------------------------------------------//
           Tab_Term('1');
           Tab_Term('2');
           Tab_Term('3');
           Tab_Term('4');
           Tab_Term('5');
           Tab_Term('6');
           Tab_Term('7');
           Mat_Term(1);
           Close QSysPrt;
         Else;
           Exit = *Off;
           Retour = *Off;
         EndIf;
       EndIf;

?      //---Mise à jour des touches F03 et F12--------------------------------//
       Exit = *Off;
       Retour = *Off;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F20] : Cartogrpahie ILE------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Carto_Ile;

?      //---Initialisation avec le composant renseigné------------------------//
       OutputSv = Entry_OutPut;
       Id_Ile = 1;
       Cpt_Ile = 0;
       Cpt_I = 0;
       Tab_Set('Objet' : Id_Ile : F01Obj);
       Tab_Set('Type'  : Id_Ile : F01Typ);
?      //---Recensement des objets--------------------------------------------//
       For I_Ile = 1 to Id_Ile;
         Select;
           when Tab_get('Type':I_Ile) = '*PGM';
             ExSr Carto_Pgm;
           when Tab_get('Type':I_Ile) = '*MODULE';
             ExSr Carto_Module;
           when Tab_get('Type':I_Ile) = '*SRVPGM';
             ExSr Carto_SrvPgm;
           when Tab_get('Type':I_Ile) = '*BNDDIR';
             ExSr Carto_BndDir;
          EndSl;
       EndFor;
?      //---Appel de l'algorithme de cartographie-----------------------------//
       For i = 1 to Tab_Inf('A');
         Tab_set('1':i:%Trim(Tab_Get('Objet':%Dec(Tab_Get('A':i):5:0))) + ' - '+
                       %Trim(Tab_Get('Type':%Dec(Tab_Get('A':i):5:0))));
         Tab_set('2':i:%Trim(Tab_Get('Objet':%Dec(Tab_Get('B':i):5:0))) + ' - '+
                       %Trim(Tab_Get('Type':%Dec(Tab_Get('B':i):5:0))));
       EndFor;
?      //---Formattage Procédure Exportées------------------------------------//
       For i = 1 To Tab_Inf('1');
         If %Scan('*PROC ':Tab_Get('2':i)) > 0;
           Index_X = Tab_Srch('2':%Trim(Tab_Get('2':i)) +'-X':1);
           If Index_X > 0;
             Tab_Set('1':Index_X:*Blanks);
             Tab_Set('2':Index_X:*Blanks);
             Tab_Set('2':i:x'28' + %Trim(Tab_Get('2':i)) + x'20');
           EndIf;
         EndIf;
       EndFor;
?      //---Formattage Procédure Importées------------------------------------//
       For i = 1 To Tab_Inf('1');
         If %Scan('*PROC-I':Tab_Get('2':i)) > 0;
           Tab_Set('2':i:x'30' + %Trim(Tab_Get('2':i)) + x'20');
         EndIf;
       EndFor;
       Entry_Output = OutPutSv;
       Algo();
?      //---Affichage du sous-fichier-----------------------------------------//
       For g = 1 To Mat_Infy(1);
         FzzZone = *Blanks;
         For f = 1 To Mat_Infx(1);
          LenMat = Mat_lenCol(1:f);
          If f > 1;
            LenMatP = LenMatP + Mat_LenCol(1:f-1);
          Else;
            LenMatP = 1;
          EndIf;
          %subst(FzzZone:LenMatP:LenMat) = %subst(Mat_Get(1:f:g):1:LenMat);
         EndFor;
         FzzZone = %xlate(x'00':x'40':FzzZone);

?      //---Alimentation du tableau principal---------------------------------//
         Cpt_I += 1;
         Tab_Set2('££WRK':Cpt_I:FzzZone);

       EndFor;
?      //---Suppression des tableaux------------------------------------------//
       Tab_Term('A');
       Tab_Term('B');
       Tab_Term('1');
       Tab_Term('2');
       Tab_Term('3');
       Tab_Term('4');
       Tab_Term('5');
       Tab_Term('6');
       Tab_Term('7');
       Mat_Term(1);

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Cartographie ILE d'un programme-----------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Carto_Pgm;
       Id_Ile_Premier = I_Ile;
?      //---Liste des Modules-------------------------------------------------//
?      //---Create User Space-List Fichier------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       FormatName = 'PGML0110';
       Object = %Subst(Tab_Get('Objet':Id_Ile_Premier):1:10) + F01Bib;
       QBnlPgmi(UserSpace:FormatName:Object:ApiError);
?      //---Retrieve Header Information---------------------------------------//
       StartPosit = 1;
       StartLen   = 1024;
       SpaceName  = 'USERSPACE';
       SpaceLib   = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

       For i=1 to NumberList;
?      //---Retrieve List Information-----------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = 1024;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:Lst_Dta_Pgm);
         Id_Ile += 1;
         Cpt_Ile += 1;
         Tab_Set('A':Cpt_Ile:%Char(Id_Ile_Premier));
         Tab_Set('B':Cpt_Ile:%Char(Id_Ile));
         Tab_Set('Objet' : Id_Ile : Lst_Mod);
         Tab_Set('Type'  : Id_Ile : '*MODULE');
         ListOffset = ListOffset + Lst_Size;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);
?      //---Liste des Programmes de services----------------------------------//
?      //---Create User Space-List Fichier------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       FormatName = 'PGML0200';
       Object = %Subst(Tab_Get('Objet':Id_Ile_Premier):1:10) + F01Bib;
       QBnlPgmi(UserSpace:FormatName:Object:ApiError);
?      //---Retrieve Header Information---------------------------------------//
       StartPosit = 1;
       StartLen   = 1024;
       SpaceName  = 'USERSPACE';
       SpaceLib   = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

       For i=1 to NumberList;
?      //---Retrieve List Information-----------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = 1024;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:Lst_Dta_SrvPgm);
         Id_Ile += 1;
         Cpt_Ile += 1;
         Tab_Set('A':Cpt_Ile:%Char(Id_Ile_Premier));
         Tab_Set('B':Cpt_Ile:%Char(Id_Ile));
         Tab_Set('Objet' : Id_Ile : Lst_Srv);
         Tab_Set('Type'  : Id_Ile : '*SRVPGM');
         ListOffset = ListOffset + 56;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);
       EndSr;

?      //---------------------------------------------------------------------//
?      //---Cartographie ILE d'un module--------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Carto_Module;
       Id_Ile_Premier = I_Ile;
?      //---Liste des Procédures Définies-------------------------------------//
?      //---Create the User Space---------------------------------------------//
       SpaceName  = 'USERSPACE' ;
       SpaceLib   = 'QTEMP'     ;
       SpaceAttr  = *Blanks     ;
       SpaceLen   = 4096        ;
       SpaceValue = x'00'       ;
       SpaceAuth  = '*CHANGE'   ;
       SpaceText  = *Blanks     ;
       SpaceReplc = '*YES'      ;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---Call the API------------------------------------------------------//
       Object = %Subst(Tab_Get('Objet':Id_Ile_Premier):1:10) + F01Bib;
       SpaceName = 'USERSPACE';
       SpaceLib  = 'QTEMP';
       Format    = 'MODL0300';
       QBnlModi(UserSpace:Format:Object:ApiError);

?      //---Retrieve Header Information---------------------------------------//
       StartPosit = 1;
       StartLen   = 1024;
       SpaceName  = 'USERSPACE';
       SpaceLib   = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

       For i=1 to NumberList;
?      //---Retrieve List Information-----------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = 1024;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);

?      //---Retrieve List Information-2---------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = List_Size;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);
         Procedure = %Subst(List_ProcName:1:List_Size - 46);
         Id_Ile += 1;
         Cpt_Ile += 1;
         Tab_Set('A':Cpt_Ile:%Char(Id_Ile_Premier));
         Tab_Set('B':Cpt_Ile:%Char(Id_Ile));
         Tab_Set('Objet' : Id_Ile : Procedure);
         Tab_Set('Type'  : Id_Ile : '*PROC');
         ListOffset = ListOffset + List_Size;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

?      //---Liste des Procédures Exportées------------------------------------//
?      //---Create the User Space---------------------------------------------//
       SpaceName  = 'USERSPACE' ;
       SpaceLib   = 'QTEMP'     ;
       SpaceAttr  = *Blanks     ;
       SpaceLen   = 1024        ;
       SpaceValue = x'00'       ;
       SpaceAuth  = '*CHANGE'   ;
       SpaceText  = *Blanks     ;
       SpaceReplc = '*YES'      ;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---Call the API------------------------------------------------------//
       Object = %Subst(Tab_Get('Objet':Id_Ile_Premier):1:10) + F01Bib;
       SpaceName = 'USERSPACE';
       SpaceLib  = 'QTEMP';
       Format    = 'MODL0100';
       QBnlModi(UserSpace:Format:Object:ApiError);

?      //---Retrieve Header Information---------------------------------------//
       StartPosit = 1;
       StartLen   = 1024;
       SpaceName  = 'USERSPACE';
       SpaceLib   = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

       For i=1 to NumberList;
?      //---Retrieve List Information-----------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = 1024;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);

?      //---Retrieve List Information-2---------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = List_Size;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);
         Procedure = %Subst(List_ProcName:1:List_Size - 46);
         Id_Ile += 1;
         Cpt_Ile += 1;
         Tab_Set('A':Cpt_Ile:%Char(Id_Ile_Premier));
         Tab_Set('B':Cpt_Ile:%Char(Id_Ile));
         Tab_Set('Objet' : Id_Ile : Procedure);
         Tab_Set('Type'  : Id_Ile : '*PROC-X');
         ListOffset = ListOffset + List_Size;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

?      //---Liste des Procédures Importées------------------------------------//
?      //---Create the User Space---------------------------------------------//
       SpaceName  = 'USERSPACE' ;
       SpaceLib   = 'QTEMP'     ;
       SpaceAttr  = *Blanks     ;
       SpaceLen   = 4096        ;
       SpaceValue = x'00'       ;
       SpaceAuth  = '*CHANGE'   ;
       SpaceText  = *Blanks     ;
       SpaceReplc = '*YES'      ;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---Call the API------------------------------------------------------//
       Object = %Subst(Tab_Get('Objet':Id_Ile_Premier):1:10) + F01Bib;
       SpaceName = 'USERSPACE';
       SpaceLib  = 'QTEMP';
       Format    = 'MODL0200';
       QBnlModi(UserSpace:Format:Object:ApiError);

?      //---Retrieve Header Information---------------------------------------//
       StartPosit = 1;
       StartLen   = 1024;
       SpaceName  = 'USERSPACE';
       SpaceLib   = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

       For i=1 to NumberList;
?      //---Retrieve List Information-----------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = 1024;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);

?      //---Retrieve List Information-2---------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = List_Size;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);
         Procedure = %Subst(List_ProcName:1:List_Size - 46);
         Id_Ile += 1;
         Cpt_Ile += 1;
         Tab_Set('A':Cpt_Ile:%Char(Id_Ile_Premier));
         Tab_Set('B':Cpt_Ile:%Char(Id_Ile));
         Tab_Set('Objet' : Id_Ile : Procedure);
         Tab_Set('Type'  : Id_Ile : '*PROC-I');
         ListOffset = ListOffset + List_Size;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

?      //---Liste des Répertoires de liage------------------------------------//
?      //---Create the User Space---------------------------------------------//
       SpaceName  = 'USERSPACE' ;
       SpaceLib   = 'QTEMP'     ;
       SpaceAttr  = *Blanks     ;
       SpaceLen   = 4096        ;
       SpaceValue = x'00'       ;
       SpaceAuth  = '*CHANGE'   ;
       SpaceText  = *Blanks     ;
       SpaceReplc = '*YES'      ;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---Call the API------------------------------------------------------//
       Object = %Subst(Tab_Get('Objet':Id_Ile_Premier):1:10) + F01Bib;
       SpaceName = 'USERSPACE';
       SpaceLib  = 'QTEMP';
       Format    = 'MODL0400';
       QBnlModi(UserSpace:Format:Object:ApiError);

?      //---Retrieve Header Information---------------------------------------//
       StartPosit = 1;
       StartLen   = 1024;
       SpaceName  = 'USERSPACE';
       SpaceLib   = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

       For i=1 to NumberList;
?      //---Retrieve List Information-----------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = 1024;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);

?      //---Retrieve List Information-2---------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = List_Size;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:Lst_Dta_Bnd);
         StartPosit = Lst_BndOffset + 1;
         StartLen   = Lst_BndLength;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:Lst_Bnd);
         Id_Ile += 1;
         Cpt_Ile += 1;
         Tab_Set('A':Cpt_Ile:%Char(Id_Ile_Premier));
         Tab_Set('B':Cpt_Ile:%Char(Id_Ile));
         Tab_Set('Objet' : Id_Ile : %Subst(Lst_Bnd:1:Lst_BndLength));
         Tab_Set('Type'  : Id_Ile : Lst_BndTyp);
         ListOffset = ListOffset + Lst_BndSize;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);
       EndSr;

?      //---------------------------------------------------------------------//
?      //---Cartographie ILE d'un programme de service------------------------//
?      //---------------------------------------------------------------------//

       BegSr Carto_SrvPgm;
       Id_Ile_Premier = I_Ile;
?      //---Liste des Modules-------------------------------------------------//
?      //---Create User Space-List Fichier------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       FormatName = 'SPGL0110';
       Object = %Subst(Tab_Get('Objet':Id_Ile_Premier):1:10) + F01Bib;
       QBnlSPgm(UserSpace:FormatName:Object:ApiError);
?      //---Retrieve Header Information---------------------------------------//
       StartPosit = 1;
       StartLen   = 1024;
       SpaceName  = 'USERSPACE';
       SpaceLib   = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

       For i=1 to NumberList;
?      //---Retrieve List Information-----------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = 1024;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:Lst_Dta_Srv);
         Id_Ile += 1;
         Cpt_Ile += 1;
         Tab_Set('A':Cpt_Ile:%Char(Id_Ile_Premier));
         Tab_Set('B':Cpt_Ile:%Char(Id_Ile));
         Tab_Set('Objet' : Id_Ile : Lst_Srv_Mod);
         Tab_Set('Type'  : Id_Ile : '*MODULE');
         ListOffset = ListOffset + Lst_Srv_Size;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);
?      //---Liste des Programme de services-----------------------------------//
?      //---Liste des Procédures Exportées------------------------------------//
       EndSr;

?      //---------------------------------------------------------------------//
?      //---Cartographie ILE d'un répertoire de liage-------------------------//
?      //---------------------------------------------------------------------//

       BegSr Carto_BndDir;
?      //---Liste des Modules-------------------------------------------------//
?      //---Liste des Programmes de service-----------------------------------//
       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F22] : Recherche-d'une chaine de caractères----------------------//
?      //---------------------------------------------------------------------//

       BegSr Scan;

       Cpt_Ligne = 0;
       Cpt_I = 0;

?      //---Create User Space-List Fichier------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       SpaceLen = MaxTab;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

       j = 0;
?      //---------------------------------------------------------------------//
       For CptF22 = 1 To Tab_Inf('SCLIB');

         FormatName = 'OBJL0100';
         Obj = '*ALL';
         Lib = Tab_Get('SCLIB':CptF22);
         ObjectType = '*FILE';
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUslObj(UserSpace:FormatName:Composant:ObjectType);

?      //---Retrieve user space General information---------------------------//
         StartPosit = 1;
         StartLen = 1024;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         Qusptrus(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
         StartPosit = ListOffset + 1;
         StartLen = EntrySize;
         NbrMbr = NumberList;

         For k = 1 to NbrMbr;
           SpaceName = 'USERSPACE';
           SpaceLib = 'QTEMP';
           Qusptrus(UserSpace:pUserSpace);
           QUsRtvUs(UserSpace:StartPosit:StartLen:DsList);
           StartPosit = StartPosit + StartLen;
?      //---Alimentation du tableau-------------------------------------------//
           j += 1;
           Tab_Set2('MBRFIL':j:DsListFile);
           Tab_Set2('MBRLIB':j:DsListLib);
         EndFor;

       EndFor;

       k = 1;
       For CptF22 = 1 to Tab_Inf2('MBRFIL');

?      //---Ne faire la recherche que sur des PF------------------------------//
         Obj = Tab_Get2('MBRFIL':CptF22);
         Lib = Tab_Get2('MBRLIB':CptF22);
        QusrObjd(ObjD0400:%Size(ObjD0400):CObjD0400:Composant:'*FILE':ApiError);
         If OdObjExtAtt = 'PF';
?      //---Ne prendre que les fichiers source--------------------------------//
           If RtvFd(composant);
?      //---Liste des membres d'un fichier source-----------------------------//
             FormatName = 'MBRL0200';
             ObjectType = '*ALL';
             OverRide = '1';
             SpaceName = 'USERSPACE';
             SpaceLib = 'QTEMP';
             QUslMbr(UserSpace:FormatName:Composant:ObjectType:OverRide);

?      //---Retrieve user space General information---------------------------//
             StartPosit = 1;
             StartLen = 1024;
             SpaceName = 'USERSPACE';
             SpaceLib = 'QTEMP';
             Qusptrus(UserSpace:pUserSpace);
             QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
             StartPosit = ListOffset + 1;
             StartLen = EntrySize;
             NbrMbr = NumberList;

?      //---Lecture de tous les Membres d'un fichier source-------------------//
             For j = 1 To NbrMbr;
               SpaceName = 'USERSPACE';
               SpaceLib = 'QTEMP';
               Qusptrus(UserSpace:pUserSpace);
               QUsRtvUs(UserSpace:StartPosit:StartLen:ScanDsRes);
               StartPosit = StartPosit + StartLen;
               Tab_Set2('MBRMBR':k:SourcePgm);
               Tab_Set2('MBRLIE':k:%char(CptF22));
               Tab_Set2('MBRDES':k:SourceTxt);
               k += 1;

?      //---Affichage Statut--------------------------------------------------//
               If Trt = '*INTERACTIVE';
                 Stat001 = 'Recherche Membre ...';
                 Stat002 = 'Fichier Source = ' + Obj;
                 Stat003 = 'Bibliothèque = ' + Lib;
                 Stat004 = 'Membre = ' + SourcePgm;
                 write F13;
               EndIf;

             EndFor;

           EndIf;

         EndIf;

       EndFor;

?      //---Recherche de la zone dans le fichier source-----------------------//
       For CptF22 = 1 to Tab_Inf2('MBRMBR');
?      //---Affichage Statut--------------------------------------------------//
         If Trt = '*INTERACTIVE';
           Stat001 = 'Recherche Membre ...';
           Stat002 = 'Membre = ' + Tab_Get2('MBRMBR':CptF22);
           Prctage = 100 * (CptF22 / Tab_Inf2('MBRMBR'));
           Stat003 = 'Avancement = ' + %trim(%char(prctage)) + ' %';
           Stat004 = 'Tot. lig. = ' + %char(Cpt_Ligne);
           write F13;
         EndIf;

         OvrCmd = 'OVRDBF FILE(FILE) TOFILE(' +
                 %Trim(Tab_Get2('MBRLIB':%Dec(Tab_Get2('MBRLIE':CptF22):15:0)))+
                 '/' +
                 %Trim(Tab_Get2('MBRFIL':%Dec(Tab_Get2('MBRLIE':CptF22):15:0)))+
                 ') MBR(' +
                 %Trim(Tab_Get2('MBRMBR':CptF22)) +
                 ') OVRSCOPE(*job) RCDFMTLCK((' +
                 %Trim(Tab_Get2('MBRFIL':%Dec(Tab_Get2('MBRLIE':CptF22):15:0)))+
                 ' *SHRRD))';

         OvrCmdLen = %len(OvrCmd);
         QcmdExc(OvrCmd:OvrCmdLen);
         Open(e) File;
         If Not %Error;
         SrcRet = 0;
         Read File RcdSrc;
         Dow  not %eof And SrcRet = 0;

           Cpt_Ligne += 1;
           StrScan  = 1;
           TrslScan = '1';
           TrimScan = '1';
           WildScan = '';
           LenSrcDta = %Len(SrcDta);
           LenF01Obj = %Len(%Trim(F01Obj));
           QClScan(SrcDta:LenSrcDta:StrScan:F01Obj:LenF01Obj:TrslScan:
                   TrimScan:WildScan:SrcRet);

           If SrcRet > 0;

             k = %Dec(Tab_Get2('MBRLIE':CptF22):15:0);
             ScanPNam = Tab_Get2('MBRMBR':CptF22);
             Scandes = Tab_Get2('MBRDES':CptF22);
             ScanFil = Tab_Get2('MBRFIL':k);
             ScanBib = Tab_Get2('MBRLIB':k);
             FzzZone = LigScan;

?      //---Alimentation du tableau principal---------------------------------//
             Cpt_I += 1;
             Tab_Set2('££WRK':Cpt_I:FzzZone);

           EndIf;

           read file RcdSrc;
         Enddo;
         Close File;
         EndIf;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F15] : Recherche XRef--------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr AlgoPgm;

       IndRef = 0;
       Cpt_I = 0;

?      //---Extraction des tableaux-------------------------------------------//
       If Ext_Ref(F01Obj);
?      //---Appel de l'algorithme de cartographie-----------------------------//
       Algo();

?      //---Affichage du sous-fichier-----------------------------------------//
       For g = 1 To Mat_Infy(1);
         FzzZone = *Blanks;
         For f = 1 To Mat_Infx(1);
          LenMat = Mat_lenCol(1:f);
          If f > 1;
            LenMatP = LenMatP + Mat_LenCol(1:f-1);
          Else;
            LenMatP = 1;
          EndIf;
          %subst(FzzZone:LenMatP:LenMat) = %subst(Mat_Get(1:f:g):1:LenMat);
         EndFor;
?      //---Affichage nom du programme----------------------------------------//
         Pos_Comp = %Scan('.'+x'22':FzzZone) + 2;
         If Pos_Comp > 2;
           Nom_Comp = %subst(FzzZone:Pos_comp:20);
           ObjChk = Nom_Comp;
           TypChk = '*PGM';
           Exsr Chk_Obj;
           If TxtDscOk = *all'?';
             TxtDscOk = *Blanks;
           EndIf;
           FzzZone = %Trim(FzzZone) + ' ' + x'20' +  %Trim(TxtDscOk);
         EndIf;

?      //---Affichage Statut--------------------------------------------------//
         If Trt = '*INTERACTIVE';
           Stat001 = 'Affichage du Sous-Fichier';
           Stat002 = 'Rang = ' + %char(FzzRrn);
           Stat003 = *blanks;
           write F13;
         EndIf;

?      //---Alimentation du tableau de travail--------------------------------//
         Cpt_I += 1;
         Tab_Set2('££WRK':Cpt_I:FzzZone);

       EndFor;

?      //---Suppression des tableaux------------------------------------------//
       Tab_Term('1');
       Tab_Term('2');
       Tab_Term('3');
       Tab_Term('4');
       Tab_Term('5');
       Tab_Term('6');
       Tab_Term('7');
       Mat_Term(1);
       EndIf;
       Close QsysPrt;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F08] : Affichage des Logiques/Clés d'un physique-----------------//
?      //---------------------------------------------------------------------//
       BegSr Dsp_Accpth;

       SFileLib = %Subst(F01Obj:1:10) + F01Bib;
       First = *On;
       Cpt_I = 0;

?      //---Write Access Path-------------------------------------------------//
       ExSr GetFil;
       Tab_Term('AR');
       Tab_Term('A2');
       Clear AccPthDs;
       Clear SfValue;

       First = *Off;
       SpaceName = 'USRSPC';
       SpaceLib = 'QTEMP';

?      //---Create User Space-------------------------------------------------//
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                 SpaceAuth:SpaceText:SpaceReplc:ApiError);

       SpaceName = 'USRSPC';
       SpaceLib = 'QTEMP';
?      //---List database relations to user space-----------------------------//
       RecordFmt = '*FIRST';
       Ignore = *Blanks;
       QDblDbr(UserSpace:LstOutFmt:SFileLib:RecordFmt:
               Ignore:ApiError);

?      //---Retrieve user space general information---------------------------//
       StartPosit = 1;
       StartLen = 140;
       SpaceName = 'USRSPC';
       SpaceLib = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
       StartPosit = 1;
       StartLen = InputSize;
       SpaceName = 'USRSPC';
       SpaceLib = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:InputDs);

?      //---Retrieve the list by walking trough the user space----------------//
       StartPosit = (ListOffset + 1);
       StartLen = EntrySize;
       SaveLen = EntrySize;
       NbrLogics = NumberList;

       For NbrL = 1 to Nbrlogics;
         SpaceName = 'USRSPC';
         SpaceLib = 'QTEMP';
         SaveStart = StartPosit;
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListDs);

         SpaceName = 'USRSPC';
         SpaceLib = 'QTEMP';
         SFileLib = DependFil;
         %SubSt(SFileLib:11:10) = DependLib;
         ExSr GetFil;
         FzzZone = *Blanks;
?      //---Alimentation du tableau principal---------------------------------//
         Cpt_I += 1;
         Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Suppression des tableaux------------------------------------------//
         Tab_Term('AR');
         Tab_Term('A2');
         Clear AccPthDs;
         Clear SfValue;
         StartPosit = (SaveStart + SaveLen);
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USRSPC';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Description des champs--------------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr GetFil;

       ReceiveLen = 4096;
       OverRide = '0';
       QdbRtvFd(Receiver:ReceiveLen:RfileLib:FileFmt:
               SFileLib:RecordFmt:OverRide:System:
               FmtType:ApiError);

       For Rec = 1 To %Len(Receiver);
         Tab_Set('AR':Rec:%Subst(Receiver:Rec:1));
       EndFor;

       IOff = DbFileOffs;
       For Cpt1 = 1 to NbrFormats;
         For Cpt2 = 1 To 150;
           %subst(FindSelect:Cpt2:1) = Tab_Get('AR':Cpt2 + IOff - 1);
         EndFor;
         For i = 1 to 20;
           If %Subst(Physical:i:1) < x'40';
             %Subst(Physical:i:1) = x'40';
           EndIf;
         EndFor;
         s = OffSet + 1;
         If First = *Off;
?      //---Récupération de la description de l'objet-------------------------//
           QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:SfileLib:cFile:ApiError);
           FzzZone = *Blanks;
           FzzZone = %subst(SfileLib:1:10) + ' ' + %subst(SfileLib:11:10) +
                     '   Fmt : ' + FindFormat + x'22' + OdObjTxtDes +
                      x'20' + Physical;
?      //---Alimentation du tableau principal---------------------------------//
           Cpt_I += 1;
           Tab_Set2('££WRK':Cpt_I:FzzZone);
         EndIf;
         If OffSet > *Zeros and NbrKeys > *Zeros;
           GetTxt(%Subst(RFileLib:1:10):%subst(RFileLib:11:10):FindFormat);
           For Cpt3 = 1 To NbrKeys;
             For Cpt4 = 1 To 14;
               %subst(KeyData:Cpt4:1) = Tab_Get('AR':Cpt4 + s - 1);
             EndFor;
             If AscendDes = x'C1';
               SfAsendDec = 'D';
             Else;
               SfAsendDec = 'A';
             EndIf;
             If (%subst(dependkey:1:1)) < x'40';
               Dependkey = *Blanks;
             EndIf;

             SfKeyField = DependKey;
             For Cpt4 = 1 to Tab_inf('ARYF');
               If Tab_Get('ARYF':Cpt4) = DependKey;
                SfValue = %Trim(SfValue) + ' ' + Tab_Get('ARYT':Cpt4);
               EndIf;
             EndFor;
             SfText = SfValue;
             FzzZone = AccPthDs;
?      //---Alimentation du tableau principal---------------------------------//
             Cpt_I += 1;
             Tab_Set2('££WRK':Cpt_I:FzzZone);
?      //---Create User Space-------------------------------------------------//
             SfLibrary = *Blanks;
             SfFileName = *Blanks;
             SfFormat = *Blanks;
             SfValue = *Blanks;
             S += 32;
           EndFor;
         Else;
           XFile = %Subst(RfileLib:1:10);
           XLib  = %Subst(RfileLib:11:10);
     C/EXEC SQL
     C+  SELECT view_definition
     C+    INTO :sqldefn
     C+    FROM sysviews
     C+    WHERE system_view_name = :xfile
     C+          AND system_view_schema = :xlib
     C/END-EXEC
           If SqlCod = *Zeros;
             SqlDefn = Filtre(SqlDefn:*Omit:*Omit);
             SqlDefn = %Xlate(x'25':x'40':SqlDefn);
             SqlCpt = 1;
             Dou %Subst(SqlDefn:SqlCpt:124) = *Blanks;
               FzzZone = x'22'+ %XLate(up:lo:%Subst(sqlDefn:SqlCpt:124));
?      //---Alimentation du tableau principal---------------------------------//
               Cpt_I += 1;
               Tab_Set2('££WRK':Cpt_I:FzzZone);
               SqlCpt +=124;
             EndDo;
           EndIf;
         EndIf;
         If OffSet > *Zeros and NbrSelOmit <> *Zeros;
           ExSr SelOmt;
         EndIf;
         SfCompare = *Blanks;
         SfRule = *Blanks;
         IOff += 160;
       EndFor;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Sélections/Ommissions---------------------------------------------//
?      //---------------------------------------------------------------------//

        BegSr SelOmt;

        I1 = (OffSelOmit + 1);
        For Cpt6 = 1 To NbrSelOmit;
          For Cpt7 = 1 to 150;
           %subst(KeySelect:Cpt7:1) = Tab_Get('AR':Cpt7 + I1 - 1);
          EndFor;
          If Compare = 'AL';
            Iter;
          EndIf;
          SfCompare = Compare;
          SfRule = Rule;
          I2 = OffSetSo + 1;
          For Cpt7 = 1 To NbrSo;
            For Cpt8 = 1 To 150;
             %subst(KeySos:Cpt8:1) = Tab_Get('AR':Cpt8 + I2 - 1);
            EndFor;
            For Cpt8 = 1 To 27;
              Tab_Set('A2':Cpt8:%Subst(SelectVar:Cpt8:1));
            EndFor;
            Nl -= 19;
            If Nl > *Zeros;
              For Cpt8 = Nl To 28;
                Tab_Set('A2':Cpt8:*Blanks);
              EndFor;
            EndIf;
            For Cpt8 = 1 To 28;
              %subst(SfValue:Cpt8:1) = Tab_Get('A2':Cpt8);
            EndFor;
            SfKeyField = CompName;
            SfAsendDec = *Blanks;
            SfText = (SfRule + ' ' + SfCompare + ' ' + SfValue);
            FzzZone = AccPthDs;
?      //---Alimentation du tableau principal---------------------------------//
            Cpt_I += 1;
            Tab_Set2('££WRK':Cpt_I:FzzZone);
            I2 = POffset + 1;
          EndFor;
          I1 = (I1 + 32);
        EndFor;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Affichage et gestion du sous-fichier(Impression)------------------//
?      //---------------------------------------------------------------------//

       BegSr Aff_Sfl;

?      //---Clear du sous-fichier---------------------------------------------//
       ExSr Clr_Sfl;

?      //---Alimentation du sous-fichier si tableau est rempli----------------//
       If Tab_Inf2('££WRK') > 0;
?      //---Clear du sous-fichier---------------------------------------------//
         FzzRrn = 0;
         For i = 1 to Tab_Inf2('££WRK');
           If Tab_Get2('££WRK':i) <> ' ';
             FzzZone = Tab_Get2('££WRK':i);
             If FzzRrn < 9999;
               FzzRrn += 1;
               Write FzzSfl;
             Else;
               i = Tab_Inf2('££WRK');
             EndIf;
           EndIf;
         EndFor;
       Else;
         FzzRrn = 0;
       EndIf;

       F01Nbr = fzzRrn;
       write f01;
?      //---Affichage du Sous Fichier-----------------------------------------//
       If FzzRrn > 0;
         FzzRcd = 1;
         Exfmt FzzCtl;
         read(e) f01;
       Else;
         FzzZone = *Blanks;
         FzzRrn = 1;
         write FzzSfl;
         %subst(FzzZone:50:23) = '*** Aucun résultat ***';
         FzzRrn += 1;
         write FzzSfl;
         FzzRcd = 1;
         write FzzCtl;
         Fonc_Ind = *all'0';
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Alimentation Fichier de sortie------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Ins_Fichier;

       ZzComp = F01Obj;
       ZzType = F01Typ;
       ZzBib = F01Bib;
     C/EXEC SQL
     C+  SET :zztmst = CURRENT_TIMESTAMP
     C/END-EXEC

       If Tab_Inf2('££WRK') > 0;
         For i = 1 To Tab_Inf2('££WRK');
            Fld = Tab_Get2('££WRK':i);
     C/EXEC SQL
     C+  INSERT INTO zz01out
     C+    VALUES (:zztmst, :zzcomp, :zztype, :zzbib, :zzfonc, :trt, :fld)
     C/END-EXEC
         EndFor;
       EndIf;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F13] : Impression du sous-fichier--------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Prt_Sfl;
?      //---Ouverture du fichier----------------------------------------------//
       Open Qsysprt;
       OptImpr = *Off;

?      //---Impression de l'entête--------------------------------------------//
       Ent01 = %subst(F01Info:1:33);
       %subst(Ent01:85:48) = %subst(F01Info:35:48);
       Ent02 = 'Nom du composant : ' + x'22' + F01Obj;
       Ent02 = %trim(Ent02) + '  ' + F01Des + 'Bibliothèque : ' + F01Bib;
       %subst(Ent03:41:50) = Titre;
       Ent04 = FzzDesc;
       Ent05 = *all'=';
       *In75 = *On;
       Except;
       *In75 = *Off;

  ?    //---Gestion de la sortie tableau--------------------------------------//
       For i = 1 To Tab_Inf2('££WRK');
         Det01 = Tab_Get2('££WRK':i);
  ?    //---Gestion du saut de page-------------------------------------------//
         If *InOa;
           *InOa = *Off;
  ?    //---Impression de l'entête--------------------------------------------//
           *In75 = *On;
           Except;
           *In75 = *Off;
         EndIf;
  ?    //---Impression de la ligne de détails---------------------------------//
         Lig01 = Tab_Get2('££WRK':i);
         *In76 = *on;
         Except;
         *In76 = *off;
       EndFor;

  ?    //---Fermeture du fichier imprimante-----------------------------------//
       Close Qsysprt;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Clear du sous-fichier---------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Clr_Sfl;

       FzzRrn = 0;
       SflInd = *On;
       write FzzCtl;
       SflInd = *Off;
       FzzZone = *Blanks;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F18] : WrkSplf---------------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Wrk_Splf;

       OvrCmd = 'WRKJOB OPTION(*SPLF)';
       OvrCmdLen = %len(OvrCmd);
       QcmdExc(OvrCmd:OvrCmdLen);

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F04] : Recherche par Description---------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Rec_Desc;

       AutRecDesc = *On;
       DspNd = *On;
       DspPc = *On;

       Write Foot;
       If Entry_text = *Blanks;
         ExFmt F01;
       Else;
         F01Des = Entry_Text;
         Entry_Text = *Blanks;
       EndIf;

       Cpt_I = 0;

       If F01Des <> *Blanks and Not Exit and Not Retour;

?      //---Alimentation de l'entête------------------------------------------//
       F01Des = %Trim(%Xlate(' ':'%':%Trim(F01Des)));

?      //---Requete sur PGMREF------------------------------------------------//
       requete2 = 'Select whpnam, whlib, whText from '                         +
                  LibRef + '/pgmref where upper(whtext) like ''%'              +
                  %trim(%Xlate(Lo:Up:F01Des)) + '%'''                          +
                  ' Group by whpnam, whlib, whtext'                            +
                  ' Order by whlib, whpnam, whtext' ;

?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s3_pgmref FROM :requete2
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c3_pgmref CURSOR FOR s3_pgmref
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c3_pgmref
     C/END-EXEC

     C/EXEC SQL
     C+  FETCH NEXT FROM c3_pgmref INTO :fnam, :lib, :text
     C/END-EXEC

       Dow SqlCod <> EndOfFile;
         ObjChk = Fnam;
         TypChk = Otyp;
         Exsr Chk_Obj;
         Exsr Chk_Usage;
?      //---Alimentation des zones--------------------------------------------//
         FzzZone = *Blanks;
         F04Nom = Fnam;
         F04Texte = Text;
         F04Lib = Lib;
         FzzZone = LigF04;
?      //---Ecriture du Sous Fichier------------------------------------------//
         Cpt_I += 1;
         Tab_Set2('££WRK':Cpt_I:FzzZone);

     C/EXEC SQL
     C+  FETCH NEXT FROM c3_pgmref INTO :fnam, :lib, :text
     C/END-EXEC

       EndDo;

     C/EXEC SQL
     C+  CLOSE c3_pgmref
     C/END-EXEC

       EndIf;

       AutRecDesc = *Off;
       DspNd = *Off;
       DspPc = *Off;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F06] : Lancement d'une requête-----------------------------------//
?      //---------------------------------------------------------------------//

       BegSr Run_Qry;

       OvrCmd = '?RUNQRY *N QRYFILE((' + %Trim(F01Bib) + '/' +
                 %trim(F01Obj) + '))';
       OvrCmdLen = %len(OvrCmd);
       Callp(e) QcmdExc(OvrCmd:OvrCmdLen);

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F17] : Recherche de la zone d'un fichier-------------------------//
?      //---------------------------------------------------------------------//

       BegSr Rec_Zone;

       Cpt_I = 0;
?      //---Alimentation de l'entête------------------------------------------//
       FzzDesc = *Blanks;
       FzzZone = *Blanks;
       %subst(FzzDesc:1:5)    = 'Objet';
       %subst(FzzDesc:12:11)  = 'Description';
       %subst(FzzDesc:65:4)   = 'Zone';
       %subst(FzzDesc:101:10) = 'Biblio.';

?      //---Requete sur PGMREF------------------------------------------------//
       Requete1 = 'Select System_table_Name, System_Table_Schema, '            +
                  'System_Column_Name from '                                   +
                  'SysColumns Where System_Column_Name like ''%'               +
                  %Trim(F01Obj)   +
                  '%''';

?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s1_reczon FROM :requete1
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c1_reczon CURSOR FOR s1_reczon
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c1_reczon
     C/END-EXEC

     C/EXEC SQL
     C+  FETCH NEXT FROM c1_reczon INTO :fnam, :lnam, :lzone
     C/END-EXEC

       Dow SqlCod <> EndOfFile;
         ObjChk = Fnam;
         TypChk = '*FILE';
         Exsr Chk_Obj;
?      //---Alimentation des zones--------------------------------------------//
         %subst(FzzZone:1:10)   = Fnam;
         %subst(FzzZone:12:50)  = TxtDscOk;
         If Tab_Srch('OBLIB':Lnam:1) = 0;
           %Subst(FzzZone:100:1) = x'27';
           %Subst(FzzZone:111:1) = x'20';
         EndIf;
         %subst(FzzZone:101:10) = Lnam;
         %Subst(FzzZone:65:10) = LZone;

?      //---Alimentation du tableau de travail--------------------------------//
         Cpt_I += 1;
         Tab_Set2('££WRK':Cpt_I:FzzZone);

     C/EXEC SQL
     C+  FETCH NEXT FROM c1_reczon INTO :fnam, :lnam, :lzone
     C/END-EXEC
       Enddo;
     C/EXEC SQL
     C+  CLOSE c1_reczon
     C/END-EXEC

       EndSr;

?      //---------------------------------------------------------------------//
?      //---[F11] : Recherche d'une procédure dans un module------------------//
?      //---------------------------------------------------------------------//

       Begsr Rec_Procedure;

       AutRecDesc = *On;
       Cpt_I = 0;

       Write Foot;
       If Entry_text = *Blanks;
         ExFmt F01;
       Else;
         F01Des = Entry_Text;
         Entry_Text = *Blanks;
       EndIf;

       If F01Des <> *Blanks and Not Exit and Not Retour;

         For i = 1 to Tab_Inf('OBLIB');
           Rec_Mod(Tab_Get('OBLIB':i):%XLate(lo:up:F01Des));
         EndFor;

         If Tab_Inf2('Module') > 0;
           For i = 1 to Tab_Inf2('Module');

             FzzZone = Tab_Get2('Module':i) + Tab_Get2('Procedure':i);
             FzzZone = %xlate(x'00':x'40':FzzZone);
             If FzzZone <> *Blanks;

?      //---Alimentation du tableau principal---------------------------------//
               Cpt_I += 1;
               Tab_Set2('££WRK':Cpt_I:FzzZone);

             Endif;

           EndFor;

         EndIf;

         Tab_Term2('Module');
         Tab_Term2('Procedure');
       EndIf;

       AutRecDesc = *Off;
       DspNd = *Off;
       DspPc = *Off;

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Recherche des logiques d'un fichier physique----------------------//
?      //---------------------------------------------------------------------//

       Begsr Srch_Logics;
       All_File = '(''' + %trim(F01Obj) + '''';
       If F01Typ = '*FILE';
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';

?      //---Create User Space-------------------------------------------------//
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                 SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---List database relations to user space-----------------------------//
       RecordFmt = '*FIRST';
       Ignore = *Blanks;
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       SFileLib = %Subst(F01Obj:1:10) + F01Bib;

       QDblDbr(UserSpace:LstOutFmt:SFileLib:RecordFmt:
               Ignore:ApiError);

?      //---Retrieve user space general information---------------------------//
       StartPosit = 1;
       StartLen = 140;
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       Qusptrus(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
       StartPosit = 1;
       StartLen = InputSize;
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QUsRtvUs(UserSpace:StartPosit:StartLen:InputDs);

?      //---Retrieve the list by walking trough the user space----------------//
       StartPosit = (ListOffset + 1);
       StartLen = EntrySize;
       SaveLen = EntrySize;
       NbrLogics = NumberList;

       For NbrL = 1 to Nbrlogics;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         SaveStart = StartPosit;
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListDs);
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         SFileLib = DependFil;
         If DependFil <> '*NONE';
           All_file = %Trim(All_File) + ',''' + %Trim(DependFil) + '''';
         EndIf;
         %SubSt(SFileLib:11:10) = DependLib;
         StartPosit = (SaveStart + SaveLen);
       EndFor;
       EndIf;

       All_File = %Trim(All_File) + ')';

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       EndSr;

?      //---------------------------------------------------------------------//
?      //---Recherche des logiques d'un fichier physique----------------------//
?      //---------------------------------------------------------------------//

       Begsr *Pssr;
       Trt = '*ERROR';
       Routine = '*CANCL';
       Dump(a);
     C/EXEC SQL
     C+  SET :zztmst = CURRENT_TIMESTAMP
     C/END-EXEC

     C/EXEC SQL
     C+  INSERT INTO zz01out
     C+    VALUES (:zztmst, :zzcomp, :zztype, :zzbib, :zzfonc, :trt, :wspsds1)
     C/END-EXEC

     C/EXEC SQL
     C+  INSERT INTO zz01out
     C+    VALUES (:zztmst, :zzcomp, :zztype, :zzbib, :zzfonc, :trt, :wspsds2)
     C/END-EXEC
       If Not Ctl_Dsp() and F01Mode = 1;
         ExFmt F07;
       EndIf;

       endsr;


     ?**---Fichier Imprimante-------------------------------------------------**
     oQSysPrt   e    75                     1
     o         or    oa
     o                       Ent01              132                             Info Travail
     o          e    75                     1
     o                       Ent02              132                             Info Composant
     o          e    75                     1
     o                       Ent03              132                             Info Fonction
     o          e    75                     1
     o                       Ent04              132                             Info Colonne
     o          e    75                     1
     o                       Ent05              132                             Ligne de séparation
     o          ef   76                     1
     o                       Lig01              132
     ?**---Fichier Ecran pour résolution 80x24 (**Erreur**)-------------------**
     o££zz01d   e            Head2
     o                       hd02                80
     o          e            head3
     o                       hd03                80

     ?**----------------------------------------------------------------------**
     ?**---Détermination fichier source---------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc RtvFd;

       dcl-pi RtvFd ind;
        Composant char(20);
       end-pi;
     ?**---Définition des variables-------------------------------------------**
       dcl-s FdFormat char(10);
       dcl-s FdMember char(10);
       dcl-s FdOverride char(1);
       dcl-s FdSystem char(10);
       dcl-s FdType char(10);
       dcl-s Rtc ind;
       dcl-s SpaceLen bindec(9) inz(4096);
     ?**---Description d'un fichier-------------------------------------------**
       dcl-ds RtvFdDs;
        FdSrc char(1) pos(9);
        *n char(11) pos(10); // dummy
       end-ds;
       FdFormat = 'FILD0100';
       FdMember = '*FIRST';
       FdOverride = '0';
       FdSystem = '*LCL';
       FdType = '*EXT';
       QDbrtvfd(RtvFdDs:Spacelen:Composant:FdFormat:Composant:
                FdMember:Fdoverride:FdSystem:FdType:ApiError);

       If FdSrc = x'08';
         Rtc = *on;
       Else;
         Rtc = *off;
       EndIf ;

       return Rtc;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure Extraction des références--------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Ext_Ref;
     ?**---Prototype d'interface----------------------------------------------**
       dcl-pi Ext_Ref ind;
        RefObj char(10) value;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Indice packed(5);
       dcl-s CodeRetour ind;
       If DspPgmRef(RefObj);

       Indice = 1;
         Dow Indice <= Tab_Inf('2');
           If Tab_Srch('1':Tab_Get('2':Indice):1) <= 0;
             CodeRetour = DspPgmRef(Tab_Get('2':Indice));
           EndIf;
?      //---Affichage Statut--------------------------------------------------//
           If Trt = '*INTERACTIVE';
             Stat001 = 'DspPgmRef en cours...';
             Stat002 = '';
             Stat003 = '';
             Stat004 = %char(Indice) + '/' + %char(Tab_Inf('1'));
             write F13;
           EndIf;
           Indice += 1;
         EndDo;
         Return *On;
       Else;
         Return *Off;
       EndIf;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure DSPPGMREF------------------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc DspPgmRef;

       dcl-pi DspPgmRef ind;
        RefObj char(10) value;
       end-pi;
     ?**---Déclaration des variables locales----------------------------------**
       dcl-s Requete char(80);
       dcl-s WrkObj char(10);
       dcl-s LibRef char(10);
       dcl-s Nbr_Poste int(10);
       dcl-s z int(10);
       dcl-s zz int(10);
     ?**---Déclaration des constantes-----------------------------------------**
       dcl-c EndOfFile const(100); // Fin de fichier SQL
       LibRef = *Blanks;

     C/EXEC SQL
     C+  SET :libref = (SELECT SUBSTR(zzvaleur, 1, 10)
     C+                   FROM zz01pf
     C+                   WHERE zztype = 'LIBRF')
     C/END-EXEC

?      //---Requete sur fichier paramètre pour bibliothèque objet-------------//
       Requete = 'select whfnam from ' + LibRef + '/pgmref where whpnam =''' +
                RefObj + ''' and whobjt = ''P''';

?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s5 FROM :requete
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c5 CURSOR FOR s5
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c5
     C/END-EXEC

     C/EXEC SQL
     C+  FETCH NEXT FROM c5 INTO :wrkobj
     C/END-EXEC

       Dow Sqlcod <> EndOfFile;
         IndRef += 1;
         Tab_Set('1'  : IndRef : RefObj );
         Tab_Set('2'  : IndRef : WrkObj );
?      //---Affichage Statut--------------------------------------------------//
         If Trt = '*INTERACTIVE';
           Stat001 = 'DspPgmRef en cours...';
           Stat002 = 'Pgm A = ' + Tab_Get('1':IndRef);
           Stat003 = 'Pgm B = ' + Tab_Get('2':IndRef);
           Stat004 = %char(IndRef) + '/' + %char(Tab_Inf('1'));
           Write F13;
         EndIf;
     C/EXEC SQL
     C+  FETCH NEXT FROM c5 INTO :wrkobj
     C/END-EXEC
       EndDo;
     C/EXEC SQL
     C+  CLOSE c5
     C/END-EXEC

       If IndRef > 0;
         Return *on;
       Else;
         Return *off;
       EndIf;

       Nbr_Poste = Tab_Inf('1');
?      //---Nettoyage des tableaux-Recursif-----------------------------------//
       For z = 1 To Nbr_Poste;
         If Tab_Get('1':z) = Tab_Get('2':z);
           Tab_Set('1':z:*blanks);
           Tab_Set('2':z:*blanks);
         EndIf;
       EndFor;

?      //---Nettoyage des tableaux-Doublons-----------------------------------//
       For z = 1 To Nbr_Poste;
         If Tab_Get('1':z)<> *Blanks;
           zz = Tab_Srch('2':Tab_Get('2':z):z+1);
           If zz > 0 and Tab_Get('1':zz) = Tab_Get('1':z);
             Tab_Set('1':zz:*blanks);
             Tab_Set('2':zz:*blanks);
             z = 0;
           EndIf;
         EndIf;
       EndFor;

?      //---Compactage des tableaux-------------------------------------------//
       For z = 1 To Nbr_Poste;
         If Tab_Get('1':z) = *Blanks;
           For zz = z To Nbr_Poste;
             Tab_Set('1':zz:Tab_Get('1':zz+1));
             Tab_Set('2':zz:Tab_Get('2':zz+1));
           EndFor;
           Nbr_Poste -= 1;
           z -= 1;
         EndIf;
       EndFor;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure description des champs-----------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc GetTxt;

       dcl-pi GetTxt;
        RefObj char(10) value;
        RefLib char(10) value;
        RefFmt char(10) value options(*nopass);
       end-pi;
?      //---Create User Space-------------------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---Get the list of all the fields------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       OverRide = '1';
       RefFmt = %Xlate(x'00':x'40':RefFmt);
       If RefFmt <> *Blanks;
         Type = RefFmt;
       Else;
         Type = '*FIRST';
       EndIf;
       Format  = 'FLDL0100';
       Obj = RefObj;
       Lib = RefLib;
       Quslfld(UserSpace:Format:Composant:Type:OverRide);

?      //---Get a pointer to the user space containing the list---------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       Qusptrus(UserSpace:pUserSpace);

       For i = 1 to  NumberList;
         pEntry = pUserSpace + listOffset + ((i-1)*entrySize);
         Tab_Set('ARYF':i:FieldName);
         Tab_Set('ARYT':i:FieldText);
       EndFor;
?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédures Rec_Mod : Recherche de modules--------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Rec_Mod;
       dcl-pi Rec_Mod;
        Rec_Lib char(10) value;
        Rec_Proc char(50) value;
       end-pi;
     ?**---User Space Générique-----------------------------------------------**
       dcl-ds UserSpace;
        SpaceName char(10) inz('USERSPACE');
        SpaceLib char(10) inz('QTEMP');
       end-ds;
     ?**---List Data----------------------------------------------------------**
       dcl-ds ListData;
        List_Size bindec(6);
        List_Module char(10);
        *n char(10); // List_ModLib
        *n char(1); // List_ProcType
        *n bindec(4); // List_OffProc
        *n bindec(4); // List_SizProc
        *n char(10); // List_ArgProc
        List_ProcName char(82) pos(47);
       end-ds;
     ?**---Déclaration des variables------------------------------------------**
       dcl-s SpaceAttr char(10);
       dcl-s SpaceAuth char(10);
       dcl-s SpaceReplc char(10);
       dcl-s SpaceLen bindec(9) inz(4096);
       dcl-s SpaceText char(50);
       dcl-s Format char(10);
       dcl-s Prg char(20);
       dcl-s Procedure char(20);
       dcl-s StartPosit bindec(9);
       dcl-s StartLen bindec(9);
       dcl-s i like(numberlist);
       dcl-s Cpt_Proc like(numberlist);
     ?**---Entête d'un User Space---------------------------------------------**
       dcl-ds GenHeadDs;
        *n int(10) pos(113); // Taille de l'entête
        *n int(10) pos(117);
        *n int(10) pos(121);
        ListOffset int(10) pos(125); // Offset des données
        *n int(10) pos(129);
        *n int(10) pos(133); // Nombre de données
        *n int(10) pos(137); // Taille des données
       end-ds;

?      //---Create the User Space---------------------------------------------//
       SpaceName  = 'USERSPACE' ;
       SpaceLib   = 'QTEMP'     ;
       SpaceAttr  = *Blanks     ;
       SpaceLen   = 1024        ;
       SpaceValue = x'00';
       SpaceAuth  = '*CHANGE'   ;
       SpaceText  = *Blanks     ;
       SpaceReplc = '*YES'      ;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---Call the API------------------------------------------------------//
       Prg       = '*ALL      '+ Rec_Lib;
       SpaceName = 'USERSPACE';
       SpaceLib  = 'QTEMP';
       Format    = 'MODL0300';
       QBnlModi(UserSpace:Format:Prg:ApiError);

?      //---Retrieve Header Information---------------------------------------//
       StartPosit = 1;
       StartLen   = 1024;
       SpaceName  = 'USERSPACE';
       SpaceLib   = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

       For i=1 to NumberList;
?      //---Retrieve List Information-----------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = 80;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);

?      //---Retrieve List Information-2---------------------------------------//
         StartPosit = ListOffset + 1;
         StartLen   = List_Size;
         SpaceName  = 'USERSPACE';
         SpaceLib   = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:ListData);
         Procedure = %trim(List_ProcName);
         Procedure = %Subst(List_ProcName:1:List_Size - 46);
         If %Trim(Procedure) = %Trim(Rec_Proc);
           cpt_proc += 1;
           Tab_Set2('Module':cpt_proc:List_Module) ;
           Tab_Set2('Procedure':Cpt_proc:Procedure);
         EndIf;
         ListOffset = ListOffset + List_Size;
       EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure Maj_Ref : Mise à jour des références technique-----------**
     ?**----------------------------------------------------------------------**
       dcl-proc Maj_Ref;

       dcl-pi Maj_Ref;
        Libname char(10) value;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s OvrCmd char(200);
       dcl-s OvrLen packed(15: 5);
       dcl-s Dat_Sys char(13);

?      //---Suppression des anciennes références------------------------------//
       Req_Sql = 'Delete From ' + %trim(ClPgmRef) +
                 '/Pgmref Where whlib = ''' + %Trim(LibName) + '''';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :req_sql
     C/END-EXEC
?      //---Contrôle Existence de la bibliothèque et description--------------//
       QusrObjd(Objd0400:%Size(Objd0400):COBJD0200:
               LibName + 'QSYS':'*LIB':ApiError);
       If Not(AeBytAvl > *Zero);
?      //---Mise à jour des références à jour---------------------------------//
       OvrCmd = 'DSPPGMREF PGM(' + %Trim(LibName) + '/*ALL) OUTPUT(*OUTFILE) ' +
       'OBJTYPE(*ALL) OUTFILE('+%Trim(ClPgmRef)+'/PGMREF) OUTMBR(*FIRST *ADD)';
       OvrLen = %Len(OvrCmd);
       Dat_Sys = '1' + %subst(%char(Datedujour):9:2) +
                       %subst(%char(Datedujour):4:2) +
                       %subst(%char(Datedujour):1:2) +
                       %subst(%char(Heure):1:2) +
                       %subst(%char(Heure):4:2) +
                       %subst(%char(Heure):7:2);
       Callp(e) QCmdExc(OvrCmd:OvrLen);
       If %Error;
     C/EXEC SQL
     C+  INSERT INTO qtemp/pgmref(whlib, whdttm)
     C+    VALUES (:libname, :dat_sys)
     C/END-EXEC
       EndIf;

?      //---Ajout des Querys--------------------------------------------------//

?      //---Create User Space-List Fichier------------------------------------//
       SpaceName = 'USERSPAC';
       SpaceLib = 'QTEMP';
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

?      //---Liste des objets avec le nom ObjNam-------------------------------//
       Composant = '*ALL      ' + LibName;
       ObjectType = '*QRYDFN';
       SpaceName = 'USERSPAC';
       SpaceLib = 'QTEMP';
       FormatName = 'OBJL0100';
       QUslObj(UserSpace:FormatName:Composant:ObjectType);

?      //---Retrieve user space General information---------------------------//
       StartPosit = 1;
       StartLen = 1024;
       SpaceName = 'USERSPAC';
       SpaceLib = 'QTEMP';
       QUsPtrUs(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
       StartPosit = ListOffset + 1;
       StartLen = EntrySize;
       NbrMbr = NumberList;

?      //---Lecture de tous les composants------------------------------------//
       For Nbr = 1 To NbrMbr;
         SpaceName = 'USERSPAC';
         SpaceLib = 'QTEMP';
         QUsRtvUs(UserSpace:StartPosit:StartLen:DsList);
         StartPosit = StartPosit + StartLen;
?      //---Alimentation du Sous-fichier de sélection-------------------------//
          Qry = DsListFile;
          RtvQryF(Qry:Lib:Input:OutPut:Stat);
?      //---Recherche description du Query------------------------------------//
          QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:Qry + LibName:'*FILE':
          ApiError);
          Desc = OdObjTxtDes;
          If Stat = '0';
?      //---Initialisation-fichier en sortie----------------------------------//
            Lib_Out = Output;

?      //---Si Fichier en sortie----------------------------------------------//
            If Lib_Out.File <> *Blanks;
     C/EXEC SQL
     C+  INSERT INTO qtemp/pgmref
     C+    VALUES (:libname,
     C+            :qry,
     C+            :desc,
     C+            0,
     C+            :dat_sys,
     C+            :lib_out.file,
     C+            :lib_out.lib,
     C+            ' ',
     C+            0,
     C+            2,
     C+            ' ',
     C+            ' ',
     C+            0,
     C+            'F',
     C+            '*FILE',
     C+            ' ',
     C+            'Q',
     C+            0)
     C/END-EXEC
            EndIf;

?      //---Traitement fichiers en entrée-------------------------------------//
            For J = 0 to 31;
              Lib_In = %subst(Input:j*40+1:40);
              If Lib_In.File <> *Blanks;
     C/EXEC SQL
     C+  INSERT INTO qtemp/pgmref
     C+    VALUES (:libname,
     C+            :qry,
     C+            :desc,
     C+            0,
     C+            :dat_sys,
     C+            :lib_in.file,
     C+            :lib_in.lib,
     C+            ' ',
     C+            0,
     C+            1,
     C+            :lib_in.fmt,
     C+            ' ',
     C+            0,
     C+            'F',
     C+            '*FILE',
     C+            ' ',
     C+            'Q',
     C+            0)
     C/END-EXEC
              EndIf;
            EndFor;
          EndIf;
        EndFor;
        EndIf;
?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPAC';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure principale-----------------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Algo;

       dcl-pi Algo end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s i int(10);
       dcl-s j int(10);
       dcl-s IndRec int(10);
       dcl-s Ind_Suivant int(10);
       dcl-s Ind_Precedent int(10);
       dcl-s Tab3_Libre ind;
       First = *On;
       Nbr_Poste = Tab_Inf('1');
       Tab_Set('3':1:*Blanks);
       Tab_Set('4':1:*Blanks);
       Tab_Set('5':1:*Blanks);
       Tab_Set('6':1:*Blanks);
?      //---Calcul des tableaux-----------------------------------------------//
       AlgoAlim();
?      //---Traitement Principal----------------------------------------------//
       i = 1;
       x = 1;
       y = 1;

?      //---Recherche du point d'entrée---------------------------------------//
       Tab_Set('7':i:Tab_Get('4':Tab_Srch('6':'0':1)));

?      //---Traçage de la carte-----------------------------------------------//
       Mat_Set(1:x:y:Tab_Get('7':i));

?      //---Affichage Statut--------------------------------------------------//
       If Trt ='*INTERACTIVE';
         Stat001 = 'Algorithme en cours...';
         Stat002 = 'Itération = ' + %char(i);
         Stat003 = 'x = ' + %char(x) + ' y = ' + %char(y);
         Stat004 = Mat_Get(1:x:y);
         Write F13;
       EndIf;

?      //---Recherche du chemin suivant---------------------------------------//
       Dow i > 0 ;
         IndRec = 0;
         Tab3_Libre = *Off;
         Dou Tab3_Libre = *On or IndRec > Nbr_Poste;
           IndRec += 1;
           Ind_Suivant = Tab_Srch('1':Tab_Get('7':i):IndRec);
           If Ind_Suivant = 0;
             Tab3_Libre = *On;
           Else;
             If Tab_Get('3':Ind_Suivant) = *Blanks;
               Tab3_Libre = *On;
             EndIf;
           EndIf;

?      //---Affichage Statut--------------------------------------------------//
           If Trt ='*INTERACTIVE';
             Stat001 = 'Algorithme en cours...';
             Stat002 = 'Itération = ' + %char(i);
             Stat003 = 'x = ' + %char(x) + ' y = ' + %char(y) ;
             Write F13;
           EndIf;

         EndDo;

?      //---Chemin trouvé-----------------------------------------------------//
         If Ind_Suivant > 0 and Tab_Get('1':Ind_Suivant) <> *Blanks;
           Tab_Set('3':Ind_Suivant:'**');
           i += 1;
           x = i;
           y += 1;
           Tab_Set('7':i:Tab_Get('2':Ind_Suivant));
?      //---Traçage de la carte-----------------------------------------------//
           Mat_Set(1:x:y:Tab_Get('7':i));

?      //---Affichage Statut--------------------------------------------------//
           If Trt ='*INTERACTIVE';
             Stat001 = 'Algorithme en cours...';
             Stat002 = 'Itération = ' + %char(i);
             Stat003 = 'x = ' + %char(x) + ' y = ' + %char(y);
             Stat004 = Mat_Get(1:x:y);
             Write F13;
           EndIf;

?      //---Recalcul----------------------------------------------------------//
           AlgoAlim();

?      //---Recherche du chemin suivant---------------------------------------//
           If Tab_Srch('4':Tab_Get('2':Ind_Suivant):1) < 1;
             i -= 1;
             x -= 1;
           Else;
             If Tab_Get('5':Tab_Srch('4':Tab_Get('2':Ind_Suivant):1)) = '0';
               i -= 1;
               x -= 1;
             EndIf;
           EndIf;
         Else;
?      //---Chemin non trouvé-------------------------------------------------//
           j = i ;
?      //---Recherche du chemin précédent-------------------------------------//
           Dou Tab_Get('7':j) = *Blanks;
             Dou Ind_Precedent = 0;
               Ind_Precedent = Tab_Srch('1':Tab_Get('7':j):Ind_Precedent + 1);
               If Ind_Precedent > 0;
                 Tab_Set('3':Ind_Precedent:*Blanks);
               EndIf;

?      //---Affichage Statut--------------------------------------------------//
               If Trt = '*INTERACTIVE';
                 Stat001 = 'Algorithme en cours...';
                 Stat002 = 'Itération = ' + %char(i);
                 Stat003 = 'x = ' + %char(x) + ' y = ' + %char(y);
                 Write F13;
               EndIf;

             EndDo;
             Tab_Set('7':j:*Blanks);
             j += 1;
           EndDo;
           i -= 1;
           AlgoAlim();
         EndIf;

       EndDo;
       AlgoDessin();

       end-proc;
     ?**----------------------------------------------------------------------**
     ?**---Alimentation des tableaux------------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc AlgoAlim;

       dcl-pi AlgoAlim end-pi;

     ?**---Définition des variables-------------------------------------------**
       dcl-s z int(10);
       dcl-s zz int(10);
       dcl-s Poste int(10);

       Poste = 0;
       If First = *On;
?      //---Affichage Statut--------------------------------------------------//
         If Trt ='*INTERACTIVE';
           Stat001 = 'Algorithme en cours...';
           Stat002 = 'Nettoyage des Tab. Récursif';
           Stat003 = 'z = ' + %char(z) + ' sur ' + %Char(Nbr_Poste);
           Stat004 = *Blanks;
           Write F13;
         EndIf;
?      //---Nettoyage des tableaux-Recursif-----------------------------------//
         For z = 1 To Nbr_Poste;
           If Tab_Get('1':z) = Tab_Get('2':z);
             Tab_Set('1':z:*blanks);
             Tab_Set('2':z:*blanks);
           EndIf;
         EndFor;

?      //---Affichage Statut--------------------------------------------------//
         If Trt ='*INTERACTIVE';
           Stat001 = 'Algorithme en cours...';
           Stat002 = 'Nettoyage des Tab. doublons';
           Stat003 = *Blanks;
           Stat004 = *Blanks;
           Write F13;
         EndIf;
?      //---Nettoyage des tableaux-Doublons-----------------------------------//
         For z = 1 To Nbr_Poste;
           If Tab_Get('1':z)<> *Blanks;
             zz = Tab_Srch('2':Tab_Get('2':z):z+1);
             If zz > 0 and Tab_Get('1':zz) = Tab_Get('1':z);
               Tab_Set('1':zz:*blanks);
               Tab_Set('2':zz:*blanks);
               z = 0;
             EndIf;
           EndIf;
         EndFor;

?      //---Affichage Statut--------------------------------------------------//
         If Trt ='*INTERACTIVE';
           Stat001 = 'Algorithme en cours...';
           Stat002 = 'Compactage des Tableaux';
           Stat003 = 'z = ' + %char(z) + ' sur ' + %Char(Nbr_Poste);
           Stat004 = *Blanks;
           Write F13;
         EndIf;
?      //---Compactage des tableaux-------------------------------------------//
         For z = 1 To Nbr_Poste;
           If Tab_Get('1':z) = *Blanks;
             For zz = z To Nbr_Poste;
               Tab_Set('1':zz:Tab_Get('1':zz+1));
               Tab_Set('2':zz:Tab_Get('2':zz+1));
             EndFor;
             Nbr_Poste -= 1;
             z -= 1;
           EndIf;
         EndFor;
         First = *Off;
       EndIf;

?      //---Affichage Statut--------------------------------------------------//
       If Trt ='*INTERACTIVE';
         Stat001 = 'Algorithme en cours...';
         Stat002 = 'Calcul des Tableaux';
         Stat003 = 'Nbre de Poste : ' + %Char(Nbr_Poste);
         Stat004 = *Blanks;
         Write F13;
       EndIf;

?      //---Calcul des compteurs-Tableau (1)----------------------------------//
       For z = 1 To Nbr_Poste;
         If Tab_Get('3':z)= *Blanks;

           If Tab_Srch('4':Tab_Get('1':z):1) > 0;
             Tab_Incr('5':Tab_Srch('4':Tab_Get('1':z):1));
           Else;
             Poste += 1;
             Tab_Set('4':Poste:Tab_Get('1':z));
             Tab_Set('5':Poste:'1');
             Tab_Set('6':Poste:'0');
           EndIf;
?      //---Calcul des compteurs-Tableau (2)----------------------------------//
           If Tab_Srch('4':Tab_Get('2':z):1) > 0;
             Tab_Incr('6':Tab_Srch('4':Tab_Get('2':z):1));
           Else;
             Poste += 1;
             Tab_Set('4':Poste:Tab_Get('2':z));
             Tab_Set('5':Poste:'0');
             Tab_Set('6':Poste:'1');
           EndIf;

         EndIf;
       EndFor;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Dessin de la carte ------------------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc AlgoDessin;

       dcl-pi AlgoDessin end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s i int(10);
       dcl-s j int(10);
       dcl-s Infx int(10);
       dcl-s Infy int(10);
     ?**---Définition des constantes locales----------------------------------**
       dcl-c w0Coin const('|...........................');
       dcl-c w0Trait const('|');

       Infy = Mat_Infy(1);
       Infx = Mat_Infx(1);

B01    For j = 1 To Infy;
B02      For i = 1 To Infx;
B03        If Mat_Get(1:i+1:j) <> *Blanks;

?      //---Affichage Statut--------------------------------------------------//
B04         If Trt = '*INTERACTIVE';
              Stat001 = 'Tracé des embranchements';
              Stat002 = 'xmax = ' + %char(Infx) + ' ymax = ' + %char(Infy);
              Stat003 = 'x =    ' + %char(i) +    '  y =   ' + %char(j);
              Write F13;
E04         EndIf;

             Mat_Set(1:i:j:%subst(w0Coin:1:Mat_LenCol(1:i)-1)+x'22');
E03        EndIf;
E02      EndFor;
E01    EndFor;

B01    For j = Infy-1 downto 1;
B02      For i = 1 To Infx;
B03        If Mat_Get(1:i:j) = *Blanks;
B04          If %subst(Mat_Get(1:i:j+1):1:1) =  w0Trait;

?      //---Affichage Statut--------------------------------------------------//
B05            If Trt = '*INTERACTIVE';
                 Stat001 = 'Tracé des liens';
                 Stat002 = 'xmax = ' + %char(Infx) + ' ymax = ' + %char(Infy);
                 Stat003 = 'x =    ' + %char(i) +    '  y =   ' + %char(j);
                 Write F13;
E05            EndIf;

               Mat_Set(1:i:j:w0Trait);
E04          EndIf;
E03        EndIf;
E02      EndFor;
E01    EndFor;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure Src_Analyse : Analyse du source--------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Src_Analyse; // Procédure Analyse
     ?**---Prototype d'interface----------------------------------------------**
       dcl-pi Src_Analyse ind; // Procédure Analyse
        LibA char(10); // Bibliothèque Source
        Src char(10); // Fichier Source
        Mbr char(10); // Membre Source
        ModeDet char(1) value;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s CodeRetour ind;
?      //---Source en cours---------------------------------------------------//
       Niveau = 1;
       SrcLib = LibA;
       SrcFil = Src;
       SrcMbr = Mbr;
       SrcRrn = 1;
       Cpt = 1;
       NbrProto = 0;
       Clr_Car();
       Proc_Encours = 'Main';
?      //---Sélection du source-----------------------------------------------//
B01    If Ovr_SrcFile(DSSource);
         Tab_Set('ProtoTab':1:*Blanks);
         SrcMax = NbrEnregs;
         Tab_Set('SrcCpy':Niveau:DSSource);
?      //---Lecture du source-------------------------------------------------//
         read file RcdSrc;

B02      Dow not %Eof;

           RcdSrc.SrcDta = %Xlate(lo:up:RcdSRc.Srcdta);
?      //---Recherche des caractères spéciaux---------------------------------//
           Get_Caractere(RcdSrc.Srcdta);
?      //---Recherche des blocs-----------------------------------------------//
B03        If Car_Comment = 0 and %trim(RcdSrc.SrcDta) <> *Blanks;
             Get_Bloc(RcdSrc.Srcdta);
E03        EndIf;
?      //---Choix du source à lire--------------------------------------------//
B03        If Car_Copy > 0 and Car_Comment = 0  and ModeDet = '1';
             Get_OvrFile(RcdSrc.SrcDta);
E03        EndIf;
?      //---Affichage Statut--------------------------------------------------//
B03        If Trt = '*INTERACTIVE';
             Stat001 = 'Lecture du source';
             Stat002 = %trim(RcdSrc.SrcDta);
             Stat003 = DsSource;
             Stat004 = 'Niveau = ' + %Char(Niveau) + '  Séquence = ' +
                      %Char(RcdSrc.SrcSeq);
             write F13;
E03        EndIf;
?      //---Reset des indicateurs---------------------------------------------//
           Clr_Car();

           read file RcdSrc;
?      //---Fin de source ou fin de /copy ?-----------------------------------//
B03        Dow Niveau > 1 and %Eof;
?      //---Affichage Statut--------------------------------------------------//
B04          If Trt ='*INTERACTIVE';
               Stat001 = 'Lecture du source';
               Stat002 = RcdSrc.SrcDta;
               Stat003 = DsSource;
               Stat004 = 'Niveau = ' + %Char(Niveau) + '  Séquence = ' +
                        %Char(RcdSrc.SrcSeq);
               write F13;
E04          EndIf;

B04          If %Open(File);
               Close File;
E04          EndIf;

             Niveau -= 1;
             DsSource = Tab_Get ('SrcCpy':Niveau);
             SrcRrn += 1;
B04          If SrcRrn <= SrcMax;
?      //---Sélection du source-----------------------------------------------//
               CodeRetour = Ovr_SrcFile(DSSource);
               Read File RcdSRc ;
E04          EndIf;
E03        EndDo;
E02      EndDo;

         Close File;
         Tab_Term('ProtoTab');
         Return *On;
X01    Else;
         Return *Off;
E01    EndIf;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure Get_Caractere : Recherche des Caractères spéciaux--------**
     ?**----------------------------------------------------------------------**
       dcl-proc Get_Caractere; // Recherche caractère
     ?**---Prototype d'interface----------------------------------------------**
       dcl-pi Get_Caractere; // Recherche caractère
        SrcDta char(80); // Ligne de Code
       end-pi;
     ?**---Définitions des constantes-----------------------------------------**
       dcl-c Cst_Copy const('/COPY');
       dcl-c Cst_Slash const('/');
       dcl-c Cst_PtVirg const(';');
       dcl-c Cst_FreeBegin const('/FREE');
       dcl-c Cst_FreeEnd const('/END-FREE');
       dcl-c Cst_comment const('//');
       dcl-c Cst_Carte_C const('C');
       dcl-c Cst_Carte_D const('D');
       dcl-c Cst_Carte_P const('P');
       dcl-c Cst_Carte_F const('F');
       dcl-c Cst_SsRoutine const('BEGSR');
       dcl-c Cst_FiRoutine const('ENDSR');
       dcl-c Cst_ExRoutine const('EXSR');
       dcl-c Cst_Star const('*');
       dcl-c Cst_Proto const('PR');
       dcl-c Cst_Libl const('*LIBL/');
       dcl-c Cst_Cas const('CASEQ');
?      //---Recherche des mots spécifiques------------------------------------//
       Car_PtVirg    = %Scan( Cst_PtVirg     : SrcDta );
       Car_FreeBegin = %Scan( Cst_FreeBegin  : SrcDta );
       Car_FreeEnd   = %Scan( Cst_FreeEnd    : SrcDta );
       Car_Comment   = %Scan( Cst_Comment    : SrcDta );
       Car_Ssroutine = %Scan( Cst_SsRoutine  : SrcDta );
       Car_Firoutine = %Scan( Cst_FiRoutine  : SrcDta );
       Car_ExRoutine = %Scan( Cst_ExRoutine  : SrcDta );
       Car_Libl      = %Scan( Cst_Libl       : SrcDta );
       Car_Cas       = %Scan( Cst_Cas        : SrcDta );
?      //---Source en Free----------------------------------------------------//
B01    If Car_FreeBegin > 0;
         Car_FreeEnd = *Zeros;
         Car_Free = *On;
E01    EndIf;

B01    If Car_FreeEnd > 0;
         Car_FreeBegin = *Zeros;
         Car_Free = *Off;
E01    EndIf;
?      //---Ligne de commentaire----------------------------------------------//
B01    If %subst(SrcDta:7:1) = Cst_Star and Not(Car_Free);
         Car_Comment = 1;
E01    EndIf;
?      //---Ligne de définition de prototype----------------------------------//
B01    If %subst(SrcDta:24:2) = Cst_Proto and Car_Comment = 0;
         Car_Proto = *On;
E01    EndIf;
?      //---Ligne de /Copy----------------------------------------------------//
B01    If %subst(SrcDta:7:5) = Cst_Copy;
         Car_Copy = 7;
         Car_Slash = %scan(Cst_Slash:SrcDta:Car_Copy + 1);
E01    EndIf;
?      //---Type de ligne de code---------------------------------------------//
B01    select;
X01      When %subst(SrcDta:6:1) = Cst_Carte_C;
           Car_Carte_C = *on;
X01      When %subst(SrcDta:6:1) = Cst_Carte_D;
           Car_Carte_D = *on;
X01      When %subst(SrcDta:6:1) = Cst_Carte_P;
           Car_Carte_P = *on;
X01      When %subst(SrcDta:6:1) = Cst_Carte_F;
           Car_Carte_F = *on;
X01      Other;
           Car_Carte_C = *off;
           Car_Carte_D = *off;
           Car_Carte_P = *off;
E01    EndSl;
       end-proc; // Recherche caractère

     ?**----------------------------------------------------------------------**
     ?**---Procédure Get_Bloc : Recherche des blocs de programme--------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Get_Bloc; // Recherche des blocs
     ?**---Prototype d'interface----------------------------------------------**
       dcl-pi Get_Bloc; // Recherche des Blocs
        SrcDta char(80); // Ligne de Code
       end-pi;
     ?**---Déclaration des variables locales----------------------------------**
       dcl-s i packed(5);
       dcl-s PosRoutine packed(5);
       dcl-s LongRoutine packed(5);
       dcl-s Routine char(20);
?      //---Liste des Prototypes----------------------------------------------//
B01    If Car_Carte_D and Car_Proto;
         Proto_Name = %Trim(%Subst(SrcDta:7:15));
B02      If Tab_Srch('ProtoTab':Proto_Name: 1) = 0 and Proto_Name <> *Blanks;
           NbrProto += 1;
           Tab_Set('ProtoTab':NbrProto:Proto_Name);
E02      EndIf;
E01    EndIf;

?      //---Appel de procédure------------------------------------------------//
B01    If NbrProto > *Zero;
B02      If Not(Car_Carte_D) and Not(Car_Carte_P) and Not(Car_Carte_F);
B03        For i = 1 to NbrProto;
B04          If %Scan(%Trim(Tab_Get('ProtoTab':i)):SrcDta) > 0;
               Tab_Set('1':Cpt:Proc_Encours);
               Tab_Set('2':Cpt:%Trim(Tab_Get('ProtoTab':i)));
               Cpt += 1;
E04          EndIf;
E03        EndFor;
E02      EndIf;
E01    EndIf;

?      //---Appel de sous-routine---------------------------------------------//
B01    If Car_ExRoutine > 0;
B02      If Car_Free;
           PosRoutine = Car_ExRoutine + 4;
           LongRoutine = Car_PtVirg - PosRoutine;
B03        If LongRoutine > 0;
             Routine = %trim(%Subst(SrcDta:PosRoutine:LongRoutine));
             Tab_Set('1':Cpt:Proc_Encours);
             Tab_Set('2':Cpt:Routine);
             Cpt += 1;
E03        EndIf;
X02      Else;
           Routine = %Trim(%Subst(SrcDta:Car_Exroutine + 4:20));
           Tab_Set('1':Cpt:Proc_Encours);
           Tab_Set('2':Cpt:Routine);
           Cpt += 1;
E02      EndIf;
E01    EndIf;

?      //---Appel de Caseq et Cabeq-------------------------------------------//
B01    If Not Car_Free;
B02      If Car_Cas > 0 and Not(Car_Carte_D);
           PosRoutine = 50;
           LongRoutine = 14;
           Routine = %trim(%Subst(SrcDta:PosRoutine:LongRoutine));
           Tab_Set('1':Cpt:Proc_Encours);
           Tab_Set('2':Cpt:Routine);
           Cpt += 1;
E02      EndIf;
E01    EndIf;
?      //---Changement de sous-routine----------------------------------------//
B01    If Car_SsRoutine > 0 ;
B02      If Car_Free;
           PosRoutine = Car_SsRoutine + 5;
           LongRoutine = Car_PtVirg - PosRoutine;
B03        If LongRoutine > 0;
             Routine = %trim(%Subst(SrcDta:PosRoutine:LongRoutine));
             Proc_Encours = Routine;
E03        EndIf;
X02      Else;
           Routine = %Trim(%subst(SrcDta:12:Car_SsRoutine - 12));
           Proc_Encours = Routine;
E02      EndIf;
E01    EndIf;
?      //---Fin de sous-routine-----------------------------------------------//
B01    If Car_FiRoutine > 0
          or (Car_Carte_P and %Subst(SrcDta:8:1) = 'E');
         Proc_Encours = 'Main';
E01    EndIf;

?      //---Changement de procédure-------------------------------------------//
B01    If Car_Carte_P and %Subst(SrcDta:8:1) = 'B';
         Proc_Encours = %Trim(%Subst(SrcDta:7:15));
E01    EndIf;

       end-proc; // Recherche des Blocs

     ?**----------------------------------------------------------------------**
     ?**---Procédure Clr_Car : Reset des indicateurs--------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Clr_Car; // Reset des indicateur
     ?**---Prototype d'interface----------------------------------------------**
       dcl-pi Clr_Car end-pi; // Reset des indicateur

       Car_Copy        = 0   ;
       Car_PtVirg      = 0   ;
       Car_FreeBegin   = 0   ;
       Car_FreeEnd     = 0   ;
       Car_Comment     = 0   ;
       Car_FiRoutine   = 0   ;
       Car_SsRoutine   = 0   ;
       Car_Proto       = *off;
       Car_Carte_C     = *off;
       Car_Carte_D     = *off;
       Car_Carte_P     = *off;
       Car_Carte_F     = *off;

       end-proc; // Reset des indicateur

     ?**----------------------------------------------------------------------**
     ?**---Procédure Get_OvrFile : Override des copy source-------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Get_OvrFile; // Override des copy so
     ?**---Prototype d'interface----------------------------------------------**
       dcl-pi Get_OvrFile; // Override des copy so
        SrcDta char(80);
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Car_Comma uns(3);
       dcl-s CodeRetour ind;
     ?**---Définition des constantes locales----------------------------------**
       dcl-c Cst_Comma const(',');

       SrcRrn = Rrn;
       SrcMax = NbrEnregs;
       Tab_Set('SrcCpy':Niveau:DSSource);
?      //---Détermination du fichier source et du membre----------------------//
B01    If Car_Libl = 0;
B02      If Car_Slash > 0;
           Car_comma = %Scan(Cst_Comma:Srcdta:Car_Slash);
           SrcFil=%Trim(%Subst(SrcDta:Car_Slash+ 1: Car_Comma - Car_Slash- 1));
           SrcMbr  = %Trim(%Subst(SrcDta:Car_Comma + 1:10));
           SrcLib=%Trim(%Subst(SrcDta:Car_Copy + 5: Car_Slash - Car_Copy - 5));
X02      Else;
           Car_Comma = %Scan(Cst_Comma:Srcdta:Car_Copy + 1);
           SrcFil=%Trim(%Subst(SrcDta:Car_Copy + 5: Car_Comma - Car_Copy - 5));
           SrcMbr = %Trim(%Subst(SrcDta:Car_Comma + 1:10));
E02      EndIf;
X01    Else;
         Car_Comma = %Scan(Cst_Comma:Srcdta:Car_Libl + 1);
         SrcFil = %Trim(%Subst(SrcDta:Car_Libl + 6: Car_Comma - Car_Libl - 6));
         SrcMbr  = %Trim(%Subst(SrcDta:Car_Comma + 1:10));
E01    EndIf;
?      //---Affichage Statut--------------------------------------------------//
B01    If Trt = '*INTERACTIVE';
         Stat001 = 'Recherche /copy';
         Stat002 = 'Fichier Source : ' + SrcFil;
         Stat003 = 'Membre Source : '  + SrcMbr;
         Stat004 = *Blanks;
         write F13;
E01    EndIf;

?      //---Détermination de la bibliothèque----------------------------------//
B01    If Car_Slash = *Zero;
         SrcLib = Get_SrcLib(SrcFil:SrcMbr);
E01    EndIf;

B01    If SrcLib <> *Blanks;
?      //---Sauvegarde de la position dans le source--------------------------//
         SrcRrn = 1;
         CodeRetour = Ovr_SrcFile(DSSource);
B02      If CodeRetour;
           Niveau += 1;
           SrcRrn = 1;
           SrcMax = NbrEnregs;
           Tab_Set('SrcCpy':Niveau:DSSource);
X02      Else;
           DSSource = Tab_Get('SrcCpy':Niveau);
           CodeRetour = Ovr_SrcFile(DSSource);
           Read file RcdSrc;
E02      EndIf;
X01    Else;
         DSSource = Tab_Get('SrcCpy':Niveau);
E01    EndIf;

       end-proc; // Override des copy so

     ?**----------------------------------------------------------------------**
     ?**---Procédure Ovr_SrcFile : Override des sources-----------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Ovr_SrcFile; // Override des sources
     ?**---Prototype d'interface----------------------------------------------**
       dcl-pi Ovr_SrcFile ind; // Override des sources
        Source likeds(dssource);
       end-pi;
B01    If %open(file);
         Close File;
E01    EndIf;
B01    If %Trim(SrcLib) <> *Blanks;
         SrclibW = %Trim(SrcLib) + '/';
X01    Else;
         SrclibW = *Blanks;
E01    EndIf;
?      //---Sélection du source-----------------------------------------------//
       OvrCmd = 'OVRDBF FILE(FILE) TOFILE('+%trim(SrclibW) +%Trim(SrcFil) +
                ') MBR(' + %trim(SrcMbr) + ') POSITION(*RRN ' + %Char(SrcRrn) +
                ')';
       OvrCmdLen = %len(OvrCmd);
       QcmdExc(OvrCmd:OvrCmdLen);
?      //---Lecture du source-------------------------------------------------//
       Open(e) File;
B01    If %Error;
         Return *Off;
X01    Else;
         Return *On;
E01    EndIf;

       end-proc; // Override des sources

     ?**----------------------------------------------------------------------**
     ?**---Procédure Get_SrcLib : Recherche de la bibliothèque----------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Get_SrcLib; // Recherche Bibliothèq
     ?**---Prototype d'interface----------------------------------------------**
       dcl-pi Get_SrcLib char(10); // Biblitohèque Source
        SrcFil char(10); // Fichier Source
        SrcMbr char(10); // Membre Source
       end-pi;
       dcl-s StartPosit bindec(9); // Position dans le Use
       dcl-s StartLen bindec(9); // Longueur dans le Use
       dcl-s i packed(5) inz(1); // Compteur
       dcl-s j packed(5) inz; // Compteur
       dcl-s k packed(5) inz; // Compteur
       dcl-s NbrMbr packed(5);
       dcl-s FormatName char(8) inz('OBJL0100'); // Format Liste d'objet
       dcl-s SpaceAttr char(10) inz; // Attribut du User Spa
       dcl-s ObjectType char(10) inz('*ALL'); // Type d'objet
       dcl-s SpaceAuth char(10) inz('*USE'); // Autorisation User Sp
       dcl-s OverRide char(1);
       dcl-s SpaceReplc char(10) inz('*YES'); // Remplacement du User
       dcl-s SpaceText char(50) inz('User Space Temporaire'); // Libellé User Space
       dcl-s SpaceLen bindec(9) inz(maxtab); // Longueur du User Spa
     ?**---User Space Générique-----------------------------------------------**
       dcl-ds UserSpace;
        SpaceName char(10) inz('USERSPACE');
        SpaceLib char(10) inz('QTEMP');
       end-ds;
     ?**---Liste des Objets---------------------------------------------------**
       dcl-ds DsList; // Liste d'objet
        DsListFile char(10); // Objet
        DsListLib char(10); // Bibliothèque
        *n char(10); // Type d'objet  DsList
       end-ds;
     ?**---Description d'un scan----------------------------------------------**
       dcl-ds ScanDsRes;
        SourcePgm char(10) pos(1);
        *n char(10) pos(11); // SourceTyp
        *n char(49) pos(47); // SourceTxt
       end-ds;

       SrcLib = *Blanks;

?      //---Create User Space-List Fichier------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       SpaceLen = MaxTab;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

       j = 0;
?      //---------------------------------------------------------------------//
B01    For i = 1 To Tab_Inf('SCLIB');

         FormatName = 'OBJL0100';
         Obj = '*ALL';
         Lib = Tab_Get('SCLIB':i);
         ObjectType = '*FILE';
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUslObj(UserSpace:FormatName:Composant:ObjectType);

?      //---Retrieve user space General information---------------------------//
         StartPosit = 1;
         StartLen = 1024;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         Qusptrus(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
         StartPosit = ListOffset + 1;
         StartLen = EntrySize;
         NbrMbr = NumberList;

B02      For k = 1 to NbrMbr;
           SpaceName = 'USERSPACE';
           SpaceLib = 'QTEMP';
           QUsPtrUs(UserSpace:pUserSpace);
           QUsRtvUs(UserSpace:StartPosit:StartLen:DsList);
           StartPosit = StartPosit + StartLen;
?      //---Alimentation du tableau-------------------------------------------//
           j += 1;
           Tab_Set('MBRFIL':j:DsListFile);
           Tab_Set('MBRLIB':j:DsListLib);
E02      EndFor;

E01    EndFor;

       k = 1;
B01    For i = 1 to Tab_Inf('MBRFIL');

?      //---Ne faire la recherche que sur des PF------------------------------//
         Obj = Tab_Get('MBRFIL':i);
         Lib = Tab_Get('MBRLIB':i);
        QusrObjd(ObjD0400:%Size(ObjD0400):CObjD0400:Composant:'*FILE':ApiError);
?      //---Ne prendre que les fichiers source--------------------------------//
B02      If OdObjExtAtt = 'PF' and RtvFd(Composant);
?      //---Liste des membres d'un fichier source-----------------------------//
           FormatName = 'MBRL0200';
           ObjectType = '*ALL';
           OverRide = '1';
           SpaceName = 'USERSPACE';
           SpaceLib = 'QTEMP';
           QUslMbr(UserSpace:FormatName:Composant:ObjectType:OverRide);

?      //---Retrieve user space General information---------------------------//
           StartPosit = 1;
           StartLen = 1024;
           SpaceName = 'USERSPACE';
           SpaceLib = 'QTEMP';
           Qusptrus(UserSpace:pUserSpace);
           QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
           StartPosit = ListOffset + 1;
           StartLen = EntrySize;
           NbrMbr = NumberList;

?      //---Lecture de tous les Membres d'un fichier source-------------------//
B03        For j = 1 To NbrMbr;
             SpaceName = 'USERSPACE';
             SpaceLib = 'QTEMP';
             Qusptrus(UserSpace:pUserSpace);
             QUsRtvUs(UserSpace:StartPosit:StartLen:ScanDsRes);
             StartPosit = StartPosit + StartLen;
?      //---Source dans la bonne bibliothèque ?-------------------------------//
B04          If SrcFil = Obj and SrcMbr = SourcePgm;
               SrcLib = Lib;
               Return SrcLib ;
E04          EndIf;

E03        EndFor;

E02      EndIf;

E01    EndFor;

?      //---Suppression du User Space-----------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QusDltUs(UserSpace:ApiError);

       Return SrcLib;

       end-proc; // Recherche Bibliothèq

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Création et initialisation du tableau------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Init;
     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Init;
        Tab_Name char(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cpt1 int(10);
?      //---Initialisation du Heap Id (Valeur donnée par l'API)---------------//
       HeapId = 0;
?      //---Nombre d'éléments par défaut--------------------------------------//
       HeapElems = InitAlloc;
?      //---Détermination de la taille initiale-------------------------------//
       HeapSize = HeapElems * %Size(DynArr);
?      //---Création du Heap--------------------------------------------------//
       CeeCrHp(HeapId:HeapSize:0:0:*Omit);
?      //---Allocation du Heap------------------------------------------------//
       CeeGtSt(HeapId:HeapSize:DynArrà:*Omit);
?      //---Initialisation du tableau-----------------------------------------//
B01    For Cpt1 = 1 to HeapElems;
         Clear DynArr(Cpt1);
E01    EndFor;
?      //---Sauvegarde Adresse du tableau-------------------------------------//
       DynArrDsà(HeapId) = DynArrà;
?      //---Sauvegarde Informations sur le tableau----------------------------//
       HeapTab(HeapId) = HeapDef;
?      //---Sauvegarde Heap Id le plus élevé----------------------------------//
       HeapMax = HeapId;
?      //---Sauvegarde du nom du tableau suivant le Heap Id-------------------//
       NameTab(HeapId)= Tab_Name;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Suppression du tableau---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Term;
     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Term;
        Tab_Name char(10) const options(*omit);
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cpt1 int(10);
?      //---Suppression d'un tableau------------------------------------------//
B01    If Tab_Name <> *Blanks;
?      //---Recherche du Heap Id du tableau-----------------------------------//
         Cpt1 = %LookUp(Tab_Name:NameTab);
?      //---S'il existe-------------------------------------------------------//
B02      If Cpt1 > 0;
?      //---Suppression en mémoire--------------------------------------------//
           CeeDsHp(Cpt1:*Omit);
?      //---Clear des tableaux des informations de tableau--------------------//
           Clear DynArrDsà(Cpt1);
           Clear HeapTab(Cpt1);
           Clear NameTab(Cpt1);
?      //---Le Heap Id maximum est modifié s'il s'agit de sa suppression------//
B03        If Cpt1 = HeapMax;
             HeapMax -= 1;
E03        EndIf;
E02      EndIf;
X01    Else;
?      //---Suppression de tous les tableaux----------------------------------//
B02      For Cpt1 = 1 To HeapMax;
?      //---Suppression en mémoire--------------------------------------------//
           CeeDsHp(Cpt1:*Omit);
?      //---Clear des tableaux des informations de tableau--------------------//
           Clear DynArrDsà(Cpt1);
           Clear HeapTab(Cpt1);
           Clear NameTab(Cpt1);
E02      EndFor;
E01    EndIf;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Alimentation du tableau--------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Set;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Set;
        Tab_Name char(10) const;
        Index int(10) value;
        Element value like(£dyna);
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s OldElems int(10);
       dcl-s Cpt1 int(20);
       HeapId = %LookUp(Tab_Name:NameTab);
?      //---Contrôle existence du tableau-------------------------------------//
B01    If HeapId > *Zero;
?      //---Récupération des informations du tableau--------------------------//
         HeapDef = HeapTab(HeapId);
?      //---Récupération de l'adresse mémoire du tableau----------------------//
         DynArrà = DynArrDsà(HeapId);
E01    EndIf;
?      //---Sinon création en mémoire du tableau------------------------------//
B01    If DynArrà = *Null or HeapID = *Zero;
         Tab_Init(Tab_Name);
         HeapDef = HeapTab(HeapId);
         DynArrà = DynArrDsà(HeapId);
E01    EndIf;
?      //---Faut-il agrandir le tableau ?-------------------------------------//
B01    If Index > HeapElems;
         OldElems = HeapElems;
?      //---Calcul de la nouvelle taille du tableau---------------------------//
B02      If Index > HeapElems + SubsAlloc;
           HeapElems = Index;
X02      Else;
           HeapElems += SubsAlloc;
E02      EndIf;
?      //---Reallocation de la taille-----------------------------------------//
         HeapSize = HeapElems * %Size(DynArr);
         DynArrà = %realloc(DynArrà:HeapSize);
?      //---Initialisation des nouveaux éléments------------------------------//
B02      For Cpt1 = OldElems + 1 to HeapElems;
           Clear DynArr(Cpt1);
E02      EndFor;
?      //---Sauvegarde des informations du tableau----------------------------//
         DynArrDsà(HeapId) = DynArrà;
         HeapTab(HeapId)   = HeapDef;
E01    EndIf;
?      //---Alimentation du tableau-------------------------------------------//
       DynArr(Index) = Element;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Incrément d'un tableau---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Incr;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Incr;
        Tab_Name char(10) const;
        Index int(10) const;
       end-pi;
       HeapId = %LookUp(Tab_Name:NameTab);
?      //---Contrôle existence du tableau-------------------------------------//
B01    If HeapId <> 0 and Index <> 0;
?      //---Récupération des informations du tableau--------------------------//
         HeapDef = HeapTab(HeapId);
?      //---Récupération de l'adresse mémoire du tableau----------------------//
         DynArrà = DynArrDsà(HeapId);
?      //---Alimentation du tableau-------------------------------------------//
         DynArr(Index) = %Char(%Dec(DynArr(Index):30:0) + 1);
?      //---Sauvegarde des informations du tableau----------------------------//
         DynArrDsà(HeapId) = DynArrà;
         HeapTab(HeapId)   = HeapDef;
E01    EndIf;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Récupération d'un élément------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Get;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Get like(£dyna);
        Tab_Name char(10) const;
        Index int(10) value;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Element like(£dyna) inz;
       HeapId = %LookUp(Tab_Name:NameTab);
?      //---Contrôle existence du tableau-------------------------------------//
B01    If HeapId <> 0;
?      //---Récupération des informations du tableau--------------------------//
         HeapDef = HeapTab(HeapId);
?      //---Récupération de l'adresse mémoire du tableau----------------------//
         DynArrà = DynArrDsà(HeapId);
?      //---Récupération de l'élément s'il existe-----------------------------//
B02      If Index <= HeapElems And Index > *Zeros;
           Element = DynArr(Index);
X02      Else;
?      //---Retourne blanc s'il n'existe pas----------------------------------//
           Element = *Blanks;
E02      EndIf;
?      //---Sauvegarde des informations du tableau----------------------------//
         DynArrDsà(HeapId) = DynArrà;
         HeapTab(HeapId)   = HeapDef;
E01    EndIf;

       Return Element;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Recherche d'un élément---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Srch;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Srch like(index);
        Tab_Name char(10) const;
        Element value like(£dyna);
        Index int(10) value;
       end-pi;
     ?**---Définition des varaibles locales-----------------------------------**
       dcl-s Ind int(10);
       dcl-s IndRtn int(10);
       dcl-s InfTab int(10);

       HeapId   = %LookUp(Tab_Name:NameTab);
?      //---Contrôle existence du tableau et de la valeur de l'index----------//
B01    If HeapId <> 0  and Index <> 0;
?      //---Récupération des informations du tableau--------------------------//
         HeapDef = HeapTab(HeapId);
?      //---Récupération de l'adresse du tableau en mémoire-------------------//
         DynArrà  = DynArrDsà(HeapId);
?      //---Récupération de l'élément s'il existe-----------------------------//
B02      If Element <> *Blanks;
?      //---Taille du tableau-------------------------------------------------//
           InfTab = Tab_Inf(Tab_Name);
?      //---Recherche dans le tableau-----------------------------------------//
B03        For Ind = Index To InfTab;
?      //---Si trouvé---------------------------------------------------------//
B04          If Element = Tab_Get(Tab_Name:Ind);
               IndRtn = Ind;
               Ind    = Tab_Inf(Tab_Name);
X04          Else;
?      //---Si pas trouvé-----------------------------------------------------//
               IndRtn = 0;
E04          EndIf;
E03        EndFor;
E02      EndIf;
?      //---Sauvegarde des données--------------------------------------------//
         DynArrDsà(HeapId) = DynArrà ;
         HeapTab(HeapId)   = HeapDef;
E01    EndIf;

       Return IndRtn;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Information sur le tableau-----------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Inf;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Inf int(10);
        Tab_Name char(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Taille int(10);
       dcl-s Cpt1 int(10);
       HeapId   = %LookUp(Tab_Name:NameTab);
?      //---Contrôle existence du tableau-------------------------------------//
B01    If HeapId <> 0;
?      //---Récupération des informations du tableau--------------------------//
         HeapDef = HeapTab(HeapId);
?      //---Récupération de l'adresse en mémoire------------------------------//
         DynArrà  = DynArrDsà(HeapId);
?      //---Recherche du dernier poste alimenté-------------------------------//
B02      For Cpt1 = 1 to  HeapElems;
B03        If DynArr(Cpt1) <> *Blanks;
             Taille = Cpt1;
E03        EndIf;
E02      EndFor;
E01    EndIf;

       Return Taille;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Longueur Maxi d'un élément-----------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Len;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Len int(10);
        Tab_Name char(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Taille int(10) inz(0);
       dcl-s Cpt1 int(10);
       dcl-s InfTab int(10);
       HeapId   = %LookUp(Tab_Name:NameTab);
?      //---Contrôle existence du tableau-------------------------------------//
B01    If HeapId <> 0;
         HeapDef = HeapTab(HeapId);
         DynArrà  = DynArrDsà(HeapId);
         InfTab   = Tab_Inf(NameTab(HeapId));
?      //---Pour chaque poste-------------------------------------------------//
B02      For Cpt1 = 1 to  InfTab;
?      //---Recherche de la taille--------------------------------------------//
B03        If %Len(%Trim(DynArr(Cpt1))) > Taille;
             Taille = %Len(%trim(DynArr(Cpt1)));
E03        EndIf;
E02      EndFor;
E01    EndIf;

       Return Taille;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Transfert d'un tableau---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Trf;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Trf;
        Tab_Name char(10) const;
        Tab_Save char(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cpt1 int(10) inz(0);
       dcl-s InfyTab int(10) inz(0);
?      //---Recherche du Heap du tableau--------------------------------------//
       HeapId   = %LookUp(Tab_Name:NameTab) ;
?      //---Contrôle Existence du tableau-------------------------------------//
B01    If HeapId <> 0;
         HeapDef = HeapTab(HeapId);
         DynArrà  = DynArrDsà(HeapId);
?      //---Suppression du tableau de sauvegarde s'il existe------------------//
B02      If %LookUp(Tab_Save:NameTab) > 0;
           Tab_Term(Tab_Save);
E02      EndIf;
?      //---Transfert des postes 1 à 1----------------------------------------//
         InfyTab = Tab_Inf(Tab_Name);
B02      For Cpt1 = 1 to InfyTab;
           Tab_Set(Tab_Save:Cpt1:Tab_Get(Tab_Name:Cpt1));
E02      EndFor;
E01    EndIf;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Alimentation de la matrice-----------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Mat_Set;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Mat_Set;
        Matrice int(10) const;
        X int(10) value;
        Y int(10) value;
        Element value like(£dyna);
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Tab_Name char(10);
?      //---Contrôle indice de la matrice-------------------------------------//
B01    If Matrice <> 0;
?      //---Récupération des informations de la matrice-----------------------//
         MatriceDs = Mat_Matrice(Matrice);
?      //---Si Informations existent, récupération du Heap du sous tableau----//
B02      If Mat_Y(Y) <> x'4040';
           HeapID = Mat_Y(Y);
?      //---Sinon le sous tableau est créé------------------------------------//
X02      Else;
           Tab_Name = 'MAT' + %Char(y);
           Tab_Init(Tab_Name);
           Mat_Y(Y) = HeapID;
           Mat_Matrice(Matrice) = MatriceDs;
E02      EndIf;
?      //---Alimentation du sous tableau--------------------------------------//
         Tab_Set(NameTab(HeapId):X:Element);
E01    EndIf;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Récupération de la matrice-----------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Mat_Get;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Mat_Get like(£dyna);
        Matrice int(10) const;
        X int(10) value;
        Y int(10) value;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Element like(£dyna);
?      //---Contrôle indice de la matrice-------------------------------------//
B01    If Matrice <> 0;
?      //---Recherche information de la matrice-------------------------------//
         MatriceDs = Mat_Matrice(Matrice);
?      //---Récupération du Heap Id du sous tableau---------------------------//
         HeapID = Mat_Y(Y);
?      //---Récupération de lélément du sous tableau--------------------------//
         Element = Tab_Get(NameTab(HeapId):X);
E01    EndIf;

       Return Element;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Taille maximale en Y-----------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Mat_Infy;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Mat_Infy int(10);
        Matrice int(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cpt1 int(10) inz(0);
?      //---Contrôle indice de la matrice-------------------------------------//
B01    If Matrice <> 0;
         MatriceDs = Mat_Matrice(Matrice);
?      //---Recherche de l'indice de sous tableau le plus élevé---------------//
B02      Dou Mat_Y(Cpt1) = x'4040';
           Cpt1 += 1;
E02      EndDo;
E01    EndIf;

       Return Cpt1 - 1;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Taille maximale en X-----------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Mat_Infx;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Mat_Infx int(10);
        Matrice int(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cpt1 int(10) inz(0);
       dcl-s Max int(10) inz(0);
       dcl-s InfyMat int(10) inz(0);

?      //---Contrôle indice de la matrice-------------------------------------//
B01    If Matrice <> 0;
         MatriceDs = Mat_Matrice(Matrice);
         InfyMat   = Mat_Infy(Matrice);
?      //---Pour chaque sous tableau------------------------------------------//
B02      For Cpt1 = 1 To InfyMat;
           HeapID = Mat_Y(Cpt1);
?      //---Recherche de la longueur du poste---------------------------------//
B03        If Tab_Inf(NameTab (HeapId)) > Max;
             Max = Tab_Inf(NameTab(HeapId));
E03        EndIf;
E02      EndFor;
E01    EndIf;

       Return Max;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Longueur d'un élément d'une matrice--------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Mat_Len;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Mat_Len int(10);
        Matrice int(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Taille int(10) inz(0);
       dcl-s Cpt1 int(10) inz(0);
       dcl-s InfyMat int(10) inz(0);
?      //---Contrôle indice de la matrice-------------------------------------//
B01    If Matrice <> 0;
?      //---Récupération des informations-------------------------------------//
         MatriceDs = Mat_Matrice(Matrice);
         InfyMat = Mat_Infy(Matrice);
?      //---Pour chaque sous tableau------------------------------------------//
B02      For Cpt1 = 1 To InfyMat;
           HeapID = Mat_Y(Cpt1);
?      //---Recherche de la taille--------------------------------------------//
B03        If Tab_Len(NameTab(HeapId)) > Taille;
             Taille = Tab_Len(NameTab(HeapId));
E03        EndIf;
E02      EndFor;
E01    EndIf;

       Return Taille;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Longueur d'un élément d'une matrice--------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Mat_LenCol;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Mat_LenCol int(10);
        Matrice int(10) const;
        X int(10) value;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Taille int(10) inz(0);
       dcl-s InfTab int(10);
       dcl-s InfyMat int(10) inz(0);
       dcl-s Tab_Name char(10);
?      //---Contrôle indice de la matrice-------------------------------------//
B01    If Matrice <> 0;
         MatriceDs = Mat_Matrice(Matrice);
         InfyMat   = Mat_Infy(Matrice);
?      //---Pour chaque sous tableau------------------------------------------//
B02      For Cpt1 = 1 To InfyMat;
           HeapID = Mat_Y(Cpt1);
?      //---Recherche de la longueur du poste---------------------------------//
           Tab_Name = NameTab(HeapId);
           HeapId   = %LookUp(Tab_Name:NameTab);
?      //---Contrôle existence du tableau-------------------------------------//
B03        If HeapId <> 0;
             HeapDef = HeapTab(HeapId);
             DynArrà  = DynArrDsà(HeapId);
             InfTab   = Tab_Inf(NameTab(HeapId));
?      //---Recherche de la taille--------------------------------------------//
B04          If %Len(%Trim(DynArr(x))) > Taille;
               Taille = %Len(%trim(DynArr(x)));
E04          EndIf;
E03        EndIf;
E02      EndFor;
E01    EndIf;

       Return Taille;
       end-proc;
     ?**----------------------------------------------------------------------**
     ?**---Procédure : Supression de la Matrice-------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Mat_Term;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Mat_Term;
        Matrice int(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cpt1 int(10) inz(1);
       dcl-s Tab_Name char(10);
?      //---Contrôle indice matrice-------------------------------------------//
B01    If Matrice <> *Zeros;
         MatriceDs = Mat_Matrice(Matrice);
?      //---Suprresion de tous les sous-tableaux------------------------------//
B02      Dou Mat_Y(Cpt1) = x'4040';
           Tab_Name = 'MAT' + %Char(Cpt1);
           Tab_Term(Tab_Name);
           Cpt1 += 1;
E02      EndDo;
?      //---Suppression des informations sur la matrice-----------------------//
         Clear Mat_Matrice(Matrice);
E01    EndIf;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Supression de la Matrice-------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Tri2;

       dcl-pi Tab_Tri2;
        Nom_Tab char(10) value;
        Pos1 packed(5) value;
        Pos2 packed(5) value;
       end-pi;
?     **---Définition des variables locales-----------------------------------**
       dcl-s NbrTab packed(5);
       dcl-s swap like(£dyna);
       dcl-s i int(10);
       dcl-s j int(10);
       dcl-s k int(10) inz;
       dcl-s ok ind;


       j = 1;
       k = 0;
       NbrTab = Tab_Inf2(Nom_Tab);

       Dow Not Ok;

         k += 1;
         Ok = *On;
         For i = k to NbrTab - j;
           If %Xlate(up:lo:%Subst(Tab_Get2(Nom_Tab:i):Pos1:Pos2)) >
              %Xlate(up:lo:%Subst(Tab_Get2(Nom_Tab:i+1):Pos1:Pos2));
             Swap = Tab_Get2(Nom_Tab:i);
             Tab_Set2(Nom_Tab:i:Tab_Get2(Nom_Tab:i+1));
             Tab_Set2(Nom_Tab:i+1:Swap);
             Ok = *Off;
           EndIf;
         EndFor;

         j += 1;
         Ok = *On;
         For i = NbrTab - j  DownTo k;
           If %Xlate(up:lo:%Subst(Tab_Get2(Nom_Tab:i):Pos1:Pos2)) >
              %Xlate(up:lo:%Subst(Tab_Get2(Nom_Tab:i+1):Pos1:Pos2));
             Swap = Tab_Get2(Nom_Tab:i);
             Tab_Set2(Nom_Tab:i:Tab_Get2(Nom_Tab:i+1));
             Tab_Set2(Nom_Tab:i+1:Swap);
             Ok = *Off;
           EndIf;
         EndFor;

       EndDo;

       end-proc;
     ?**----------------------------------------------------------------------**
     ?**---Filtre des zones textes--------------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Filtre;

       dcl-pi Filtre char(10000);
        Texte_In char(10000) value;
        Exclus char(10000) options(*omit);
        Rempla char(10000) options(*omit);
       end-pi;
?     **---Définition des variables locales-----------------------------------**
       dcl-s i packed(5);
       dcl-s j packed(5);
       dcl-s Pos packed(5);
       dcl-s Len packed(5);
       dcl-s Texte char(10000);
B01    If %Addr(Exclus) = *Null or Exclus = *Blanks;
         Texte = Texte_In;
         Texte = %Xlate(x'00':x'40':Texte);
         Texte = %Trim(Texte);

B02      For j = 1 To 10000;
           i = %Scan('  ':Texte:j);
B03        If i > 0 ;
             Texte = %Subst(Texte:1:i) + %Subst(Texte:i+2:10000-(i+2));
             j= i-1;
E03        EndIf;
B03        If %Subst(Texte:j+1:10000-j-1) = *Blanks;
             j = 10000;
E03        EndIf;
E02      EndFor;

         Texte_In = *Blanks;
X01    Else;
B02      If %Addr(Rempla) = *Null or Rempla = *Blanks;
           Texte = Texte_In;
           Pos = %Scan(%Trim(Exclus):Texte);
B03        If Pos >0 ;
             Len = %Len(%Trim(Exclus));
B04          For  j = 1 to Len;
               %Subst(Texte:Pos + j-1 : 1) = ' ';
E04          EndFor;
E03        EndIf;
X02      Else;
           Texte = Texte_In;
           Pos = %Scan(%Trim(Exclus):Texte);
B03        If Pos >0 ;
             Len = %Len(%Trim(Exclus));
B04          For  j = 1 to Len;
B05            If j > %Len(%Trim(Rempla));
                 %Subst(Texte:Pos + j-1 : 1) = ' ';
X05            Else;
                 %Subst(Texte:Pos + j-1 : 1) = %Subst(Rempla : j : 1 );
E05            EndIf;
E04          EndFor;
E03        EndIf;
E02      EndIf;
         Texte = Filtre(Texte:*Omit:*Omit);
E01    EndIf;

       Texte_In = *Blanks;
B01    If %Addr(Exclus) <> *Null;
         Exclus   = *Blanks;
E01    EndIf;
B01    If %Addr(Rempla) <> *Null;
         Rempla   = *Blanks;
E01    EndIf;
       return texte;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Contrôle de la résolution de l'écran-------------------------------**
     ?**----------------------------------------------------------------------**

       dcl-proc Ctl_Dsp;
     ?**---Définition du prototype d'interface--------------------------------**
       dcl-pi Ctl_Dsp ind end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s Rtcd ind;

       Rtcd = *Off;

?      //---Ouverture du fichier écran----------------------------------------//
B01    If Not %Open(ZZ01D);
         Open(e) zz01d;
B02      If %Error;
?      //---Si impossible d'ouvrir l'écran------------------------------------//
           OvrCmdLen = 100;
           OvrCmd = 'CRTDSPF FILE(££zz01d)';
           QCmdExc(OvrCmd:OvrCmdLen);
           Open ££zz01d;
           hd02 = x'22'+'X-Ref'+x'20'+'fonctionne en 27 * 132 uniquement';
           Except head2;
?      //---Affichage du message pour la résolution---------------------------//
           hd03 = 'Modifier votre résolution écran sinon allez sur ' +
                  'https://github.com/ibmiiste/XREF';
           Except head3;
?      //---Fermeture des fichiers et sortie du programme---------------------//
           Close ££zz01d;
           OvrCmd = 'DLTF FILE(££zz01d)';
           QCmdExc(OvrCmd:OvrCmdLen);
           Rtcd = *On;
E02     EndIf;
E01    EndIf;

       Return Rtcd;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---[F23] : Gestion des analyses---------------------------------------**
     ?**----------------------------------------------------------------------**

       dcl-proc Gst_Analyse;
     ?**---Définition du prototype d'interface--------------------------------**
       dcl-pi Gst_Analyse end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s Zzflds char(250);
       dcl-s ZzComp char(10);
       dcl-s ZzBib char(10);
       dcl-s ZzType char(10);

B01    Dow Retour = *Off;
?      //---Requete sur fichier ZZ01OUT---------------------------------------//
         Requete4 = 'select Distinct ZzTmst, ZzComp, ZzType, ZzBib, ZzFonc, ' +
                    'ZzMode from zz01out order by ZzTmst Desc';

?      //---Clear du sous-fichier---------------------------------------------//
         F04Rrn = 0;
         SflInd = *On;
         Write F04Ctl;
         SflInd = *Off;

?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s4 FROM :requete4
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c4 CURSOR FOR s4
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c4
     C/END-EXEC

     C/EXEC SQL
     C+  FETCH NEXT FROM c4
     C+    INTO :tmst04, :obj04, :type04, :lib04, :fonc04, :mode04
     C/END-EXEC

         Cpt1 = 0;
?      //---Alimentation du sous-fichier résumé-------------------------------//
B02      Dow Sqlcod <> EndOfFile;
           Cpt1 += 1;
B03        If Entry_OutPut = '*DISPLAY' or Entry_OutPut = '*PRINTER';
             F04Rrn +=1;
             Write F04Sfl;
X03        Else;
             Fld = F04_Ds;
     C/EXEC SQL
     C+  INSERT INTO zz01out(zztmst,
     C+                      zzcomp,
     C+                      zztype,
     C+                      zzbib,
     C+                      zzfonc,
     C+                      zzmode,
     C+                      zzfld)
     C+    VALUES (:zztmst, :zzcomp, :zztype, :zzbib, :zzfonc, :trt, :fld)
     C/END-EXEC
E03        EndIf;
     C/EXEC SQL
     C+  FETCH NEXT FROM c4
     C+    INTO :tmst04, :obj04, :type04, :lib04, :fonc04, :mode04
     C/END-EXEC
E02      EndDo;
     C/EXEC SQL
     C+  CLOSE c4
     C/END-EXEC

B02      If Entry_OutPut = '*DISPLAY';
?      //---Affichage du sous-fichier-----------------------------------------//
B03        If F04Rrn > 0;

             ExFmt F04Ctl;

?      //---Lecture de chaque Enregistrement du sous-fichier------------------//
B04          If Retour <> *On;

B05            For i = 1 to Cpt1;

                 Chain i F04Sfl;
?      //---Si Affichage------------------------------------------------------//
B06              If Opt04 = '5';
                   Retour = *On;
                   i = Cpt1 + 1;
?      //---Requete sur fichier ZZ01OUT---------------------------------------//
                   Requete5 = 'select ZzFld, ZzFonc, ZzComp, ZzType, ZzBib ' +
                   'from zz01out where zztmst = '''+Tmst04 + '''';
?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s6 FROM :requete5
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c6 CURSOR FOR s6
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c6
     C/END-EXEC

     C/EXEC SQL
     C+  FETCH NEXT FROM c6 INTO :zzflds, :zzfonc, :zzcomp, :zztype, :zzbib
     C/END-EXEC
?      //---Alimentation des informations composants--------------------------//
                   Titre = Tab_Get('Fonction':Tab_Srch('Fonc':ZzFonc:1));
                   FzzDesc = Rtv_entete(ZzFonc);
                   F01Obj = ZzComp;
                   F01Bib = ZzBib;
                   F01Typ = ZzType;
                   If ZzType <> '*ALL' and ZzType <> *Blanks;
                     QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
                       F01Obj + F01Bib:F01Typ:ApiError);
                     F01Des = OdObjTxtDes;
                   Else;
                     F01Des = *Blanks;
                   EndIf;
                   SavComp = *Blanks;
                   SavComp = F01Obj + F01Bib + F01Typ;
                   Cpt_I = 0;
?      //---Alimentation du sous-fichier principal----------------------------//
B07                Dow Sqlcod <> EndOfFile;
                     FzzZone = ZzFldS;

?      //---Alimentation du tableau principal---------------------------------//
                     Cpt_I += 1;
                     Tab_Set2('££WRK':Cpt_I:FzzZone);

     C/EXEC SQL
     C+  FETCH NEXT FROM c6 INTO :zzflds, :zzfonc, :zzcomp, :zztype, :zzbib
     C/END-EXEC
E07                EndDo;

     C/EXEC SQL
     C+  CLOSE c6
     C/END-EXEC

E06              EndIf;

B06              If Opt04 = '4';
     C/EXEC SQL
     C+  DELETE FROM zz01out WHERE zztmst = :tmst04
     C/END-EXEC
E06              EndIf;
E05            EndFor;
E04          EndIf;
             Opt04 = *Blanks;
X03        Else;
             Retour = *On;
E03        EndIf;
X02      Else;
           Retour = *On;
E02      EndIf;
E01    EndDo;

       Exit = *Off;
       Retour = *Off;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Gestion de l'entête de sous-fichier--------------------------------**
     ?**----------------------------------------------------------------------**

       dcl-proc Rtv_Entete;
     ?**---Définition du prototype d'interface--------------------------------**
       dcl-pi Rtv_Entete like(fzzdesc);
        Fonction like(zzfonc) value;
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s Entete like(fzzdesc);
       dcl-s i packed(5);
       i = Tab_Srch('Fonc':fonction:1);
       If i > 0;
         Entete = Desc_Entete(i) + Desc_Entete(i+24);
       Else;
         Entete = *Blanks;
       EndIf;
       return Entete;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Création et initialisation du tableau------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Init2;
     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Init2 like(£heap) end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cpt1 like(£index);

       HeapId = *Zero;
?      //---Nombre d'éléments par défaut--------------------------------------//
       HeapElems = InitAlloc;
?      //---Détermination de la taille initiale-------------------------------//
       HeapSize = HeapElems * %Size(DynArr);
?      //---Création du Heap--------------------------------------------------//
       CeeCrHp(HeapId:HeapSize:0:0:*Omit);
?      //---Allocation du Heap------------------------------------------------//
       CeeGtSt(HeapId:HeapSize:DynArrà:*Omit);
?      //---Initialisation du tableau-----------------------------------------//
       For Cpt1 = 1 to HeapElems;
         Clear DynArr(Cpt1);
       EndFor;
?      //---Tableau de pointeur-----------------------------------------------//
       DynArrDsà(HeapId) = DynArrà;
?      //---Tableau des Heap--------------------------------------------------//
       Heap_Tab(HeapId) = HeapDef;

       Return HeapId;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Création et initialisation du tableau------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Make2;
     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Make2 like(£heap);
        Tab_Name const like(£tab);
        Index const like(£index);
        StTab_Name const like(£sttab);
       end-pi;
       dcl-s CptMake2 packed(5);

?      //---Tableau des sous-tableau------------------------------------------//
       If %LookUp(StTab_Name:Name_Tab) = 0;
?      //---Recherche du Numéro de Heap---------------------------------------//
         HeapId = Tab_Init2();
?      //---Sauvegarde du numéro des Heap Max---------------------------------//
         If HeapId > HeapMax;
           HeapMax = HeapID;
         EndIf;
?      //---Tableau des Heap--------------------------------------------------//
         Name_Tab(HeapId) = StTab_Name;
       EndIf;
?      //---Tableau des tableaux----------------------------------------------//
       If %LookUp(Tab_Name:Master_Tab) = *Zero;
         For CptMake2 = 1 to %elem(Master_Tab);
           If Master_Tab(CptMake2) <> ' ';
             Identifiant = CptMake2 + 1;
           EndIf;
         EndFor;
         If Identifiant >= %Elem(Master_Tab);
           Identifiant = %Elem(Master_Tab);
         EndIf;
         If Identifiant = 0;
           Identifiant = 1;
         EndIf;

         Master_Tab(Identifiant)  = Tab_Name;
         Master_Size(Identifiant) = Index;
       EndIf;

       Return HeapId;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Alimentation du tableau--------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Set2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Set2;
        Tab_Name const like(£tab);
        Index value like(£index);
        Element value like(£dyna);
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s IndexReduit like(£index);
       dcl-s OldElems like(£index);
       dcl-s NumSousTabl like(£stindex);
       dcl-s StTab_Name like(£sttab);


?      //---Tableau des sous-tableau------------------------------------------//
       StTab_Name = Tab_Format2(Tab_Name:Index:IndexReduit:NumSousTabl);
       HeapId     = %LookUp(StTab_Name:Name_Tab);
?      //---Sous-tableau non défini-------------------------------------------//
       If HeapId = 0;
         HeapId = Tab_Make2(Tab_Name:Index:StTab_Name);
       EndIf;
?      //---Récupération des informations sur le heap-------------------------//
       HeapDef = Heap_Tab(HeapId);
       DynArrà = DynArrDsà(HeapId);

?      //---Faut-il agrandir le tableau ?-------------------------------------//
       If IndexReduit > HeapElems;

         OldElems = HeapElems;
?      //---Calcul de la nouvelle taille du tableau---------------------------//
         If IndexReduit > HeapElems + SubsAlloc;
           HeapElems = IndexReduit;
         Else;
           HeapElems += SubsAlloc;
         EndIf;

?      //---Reallocation de la taille-----------------------------------------//
         HeapSize = HeapElems * %Size(DynArr);
         DynArrà  = %realloc(DynArrà:HeapSize);

         DynArrDsà(HeapId) = DynArrà;
         Heap_Tab(HeapId)  = HeapDef;

       EndIf;

?      //---Alimentation du tableau-------------------------------------------//
       DynArr(IndexReduit) = Element;
?      //---Mise à jour du Master Tableau-------------------------------------//
       Identifiant = %LookUp(Tab_Name:Master_Tab);
       If Index > Master_Size(Identifiant);
         Master_Size(Identifiant) = Index;
         Master_Tab(Identifiant) = Tab_Name;
       EndIf;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Récupération d'un élément------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Get2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Get2 like(£dyna);
        Tab_Name const like(£tab);
        Index value like(£index);
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s NumSousTabl like(£stindex);
       dcl-s StTab_Name like(£sttab);
       dcl-s Element like(£dyna) inz;
       dcl-s IndexReduit like(£index);

?      //---Contrôle existence du Master Tableau------------------------------//
       StTab_Name = Tab_Format2(Tab_Name:Index:IndexReduit:NumSousTabl);
       HeapId   = %LookUp(StTab_Name:Name_Tab);
       If HeapId > 0;
         HeapDef = Heap_Tab(HeapId);
         DynArrà = DynArrDsà(HeapId);
?      //---Récupération de l'élément s'il existe-----------------------------//
         If IndexReduit <= HeapElems;
           Element = DynArr(IndexReduit);
         EndIf;
         DynArrDsà(HeapId) = DynArrà;
         Heap_Tab(HeapId)  = HeapDef;
       Else;
         Element = *Blanks;
       EndIf;

       Return Element;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Définition des propriétés du tableau-------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Format2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Format2 like(£sttab);
        Tab_Name const like(£tab);
        Index value like(£index);
        IndexReduit like(£index); // Index réduit
        NumSousTabl like(£stindex); // Numéro de sous-tabl
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s StTab_Name like(£sttab);


       Tab_IdxRed2(Index:IndexReduit:NumSousTabl);
       StTab_Name = Tab_StName2(Tab_Name:NumSousTabl);

       Return StTab_Name;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Calcul de l'index réduit et numéro de sous tableau-----**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_IdxRed2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_IdxRed2;
        Index const like(£index); // Index
        IndexReduit like(£index); // Index réduit
        NumSousTabl like(£stindex); // Numéro de sous-tabl
       end-pi;


?      //---Numéro de Sous-tableau est un multiple de MaxTab------------------//
       If %Rem(Index:MaxTab) <> 0;
         NumSousTabl = %Div(Index:MaxTab) + 1;
       Else;
         NumSousTabl = %Div(Index:MaxTab);
       EndIf;

?      //---Calcul de l'index Réduit------------------------------------------//
       IndexReduit = Index - ((NumSousTabl - 1) * MaxTab);

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Incrément d'un tableau---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Incr2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Incr2;
        Tab_Name const like(£tab);
        Index const like(£index);
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s IndexReduit like(£index);
       dcl-s NumSousTabl like(£stindex);
       dcl-s StTab_Name like(£sttab);

?      //---Tableau des sous-tableau------------------------------------------//
       StTab_Name = Tab_Format2(Tab_Name:Index:IndexReduit:NumSousTabl);
       HeapId     = %LookUp(StTab_Name:Name_Tab);
       HeapDef    = Heap_Tab(HeapId);
       DynArrà    = DynArrDsà(HeapId);

?      //---Alimentation du tableau-------------------------------------------//
       DynArr(Index)      = %Char(%Dec(DynArr(Index):30:0) + 1);

       DynArrDsà(HeapId)  = DynArrà;
       Heap_Tab(HeapId)   = HeapDef;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Information sur le tableau-----------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Inf2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Inf2 like (£index);
        Tab_Name const like(£tab);
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s Index_Master like(£index);
       dcl-s Taille like(£mastertaille);

       Index_Master = %LookUp(Tab_Name:Master_Tab);
       If Index_Master > *Zero;
         Taille = Master_Size(Index_Master);
       Else;
         Taille = *Zero;
       EndIf;

       Return Taille;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Nom du Sous-Tableau------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_StName2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_StName2 like (£sttab);
        Tab_Name const like(£tab);
        NumSousTabl const like(£stindex);
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s StTab_Name like(£sttab);

?      //---Tableau des sous-tableau------------------------------------------//
       %Subst(StTab_Name:1:10) = *All'à';
       %Subst(StTab_Name:1:%Len(%Trim(Tab_Name))) = %Trim(Tab_Name);
       %Subst(StTab_Name:11:10) = %Trim(%Char(NumSousTabl));

       Return StTab_Name;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Longueur de poste d'un tableau-------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Len2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Len2 like (£index);
        Tab_Name const like(£tab);
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s StTab_Name like(£sttab);
       dcl-s Long_Name like(£index);
       dcl-s Num_StMax like(£stindex);
       dcl-s InfTab like(£index);
       dcl-s Index_Reduit like(£index);
       dcl-s Taille like(£index);
       dcl-s I like(£index);
       dcl-s J like(£index);

?      //---Si le tableau existe----------------------------------------------//
       If %LookUp(Tab_Name:Master_Tab) > *Zero;
?      //---Nombre de poste dans le tableau-----------------------------------//
         Taille = Tab_Inf2(Tab_Name);
?      //---S'il y a  au moins un poste---------------------------------------//
         If Taille > *Zero;
?      //---récupération du n° de sous tableau Max----------------------------//
           Tab_IdxRed2(Taille:Index_Reduit:Num_StMax);
?      //---recherche de la longueur max d'une zone---------------------------//
           For I = 1 To Num_StMax;
?      //---Détermination du sous-tableau-------------------------------------//
             StTab_Name = Tab_StName2(Tab_Name:I);
?      //---S'il existe-------------------------------------------------------//
             HeapId   = %LookUp(StTab_Name:Name_Tab) ;
             If HeapId > *Zero;
?      //---Récupération du tableau-------------------------------------------//
               HeapDef  = Heap_Tab(HeapId);
               DynArrà  = DynArrDsà(HeapId);
?      //---Taille du sous-tableau--------------------------------------------//
               InfTab = Tab_StInf2(Name_Tab(HeapId));
?      //---Contrôle de chaque champ------------------------------------------//
               For J = 1 to  InfTab;
                 If %Len(%Trim(DynArr(J))) > Long_Name;
                   Long_Name = %Len(%trim(DynArr(J)));
                 EndIf;
               EndFor;
             EndIf;
           EndFor;
         EndIf;
       EndIf;

       Return Long_Name;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Information sur le sous-tableau------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_StInf2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_StInf2 like(£index);
        StTab_Name const like(£sttab);
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s Taille like(£index);
       dcl-s I like(£index);

       HeapId   = %LookUp(StTab_Name:Name_Tab);
       HeapDef  = Heap_Tab(HeapId);
       DynArrà  = DynArrDsà(HeapId);

?      //---Taille du sous-tableau--------------------------------------------//
       For I = 1 to  HeapElems;
         If DynArr(I) <> *Blanks;
           Taille = I;
         EndIf;
       EndFor;

       Return Taille;

       end-proc;
     ?**----------------------------------------------------------------------**
     ?**---Procédure : Recherche d'un élément---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Srch2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Srch2 like(£index);
        Tab_Name const like(£tab);
        Element value like(£dyna);
        Index value like(£index);
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s StTab_Name like(£sttab);
       dcl-s Num_StMax like(£stindex);
       dcl-s Num_StDeb like(£stindex);
       dcl-s InfTab like(£index);
       dcl-s Index_Reduit like(£index);
       dcl-s Taille like(£index);
       dcl-s I like(£index);
       dcl-s J like(£index);
       dcl-s IndRtn like(£index);


?      //---Si variable à rechercher est différente de *blanks----------------//
       If Element <> *Blanks;
?      //---Si le tableau existe----------------------------------------------//
         If %LookUp(Tab_Name:Master_Tab) > *Zero;
?      //---Nombre de poste dans le tableau-----------------------------------//
           Taille = Tab_Inf2(Tab_Name);
?      //---S'il y a  au moins un poste---------------------------------------//
           If Taille > *Zero;
?      //---récupération du n° de sous tableau Max----------------------------//
             Tab_IdxRed2(Taille:Index_Reduit:Num_StMax);
?      //---récupération du n° de sous tableau de début-----------------------//
             Tab_IdxRed2(Index:Index_Reduit:Num_StDeb);
?      //---recherche de la longueur max d'une zone---------------------------//
             For I = Num_StDeb To Num_StMax;
?      //---Détermination du sous-tableau-------------------------------------//
               StTab_Name = Tab_StName2(Tab_Name:I);
?      //---S'il existe-------------------------------------------------------//
               HeapId   = %LookUp(StTab_Name:Name_Tab) ;
               If HeapId > *Zero;
?      //---Récupération du tableau-------------------------------------------//
                 HeapDef  = Heap_Tab(HeapId);
                 DynArrà  = DynArrDsà(HeapId);
?      //---Taille du sous-tableau--------------------------------------------//
                 InfTab = Tab_StInf2(Name_Tab(HeapId));

?      //---Contrôle de chaque champ------------------------------------------//
                 For J = Index_Reduit to  InfTab;
                   If Element = Tab_Get2(Name_Tab(HeapId):J);
                     IndRtn = J;
                     J = InfTab;
                     I = Num_StMax;
                   EndIf;
                 EndFor;
               EndIf;
             EndFor;
           EndIf;
         EndIf;
       EndIf;

       Return IndRtn;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Suppression du tableau---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Term2;
     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Term2;
        Tab_Name like(£tab) value;
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s HeapId like(£heap);
       dcl-s StTab_Name like(£sttab);
       dcl-s Num_StMax like(£stindex);
       dcl-s Index_Reduit like(£index);
       dcl-s Taille like(£index);
       dcl-s I like(£index);
       dcl-s Pt pointer;


?      //---Adresse du nom de tableau-----------------------------------------//
       Pt = %Addr(Tab_Name);
?      //---Si le nom de tableau est renseigné--------------------------------//
B01    If Pt <> *Null;
?      //---Suppression du tableau--------------------------------------------//
B02      If %LookUp(Tab_Name:Master_Tab) > *Zero;
?      //---Nombre de poste dans le tableau-----------------------------------//
           Taille = Tab_Inf2(Tab_Name);
?      //---S'il y a au moins un poste----------------------------------------//
B03        If Taille > *Zero;
?      //---Récupération du n° de sous tableau Max----------------------------//
             Tab_IdxRed2(Taille:Index_Reduit:Num_StMax);
?      //---Recherche de la longueur max d'une zone---------------------------//
B04          For I = 1 To Num_StMax;
?      //---Détermination du sous-tableau-------------------------------------//
               StTab_Name = Tab_StName2(Tab_Name:I);
?      //---S'il existe-------------------------------------------------------//
               HeapId = %LookUp(StTab_Name:Name_Tab);
B05            If HeapId > *Zero;
                 Name_Tab(HeapId) = *Blanks;
?      //---Suppression du Heap-----------------------------------------------//
                 CeeDsHp(HeapId:*Omit);
                 Clear DynArrDsà(HeapId);
                 Clear Heap_Tab(HeapId);
                 Clear Name_Tab(HeapId);
?      //---Mise à jour du Heap Id Max.---------------------------------------//
B06              If HeapId = HeapMax;
                   HeapMax -= 1;
E06              EndIf;
E05            EndIf;
E04          EndFor;
E03        EndIf;
           Master_Tab(%LookUp(Tab_Name:Master_Tab)) = *Blanks;
E02      EndIf;
X01    Else;
?      //---Suppression de tous les tableaux----------------------------------//
B02      For HeapId = 1 To HeapMax;
           CeeDsHp(HeapId:*Omit);
           Clear DynArrDsà(HeapId);
           Clear Heap_Tab(HeapId);
           Clear Name_Tab(HeapId);
E02      EndFor;

E01    EndIf;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Transfert d'un tableau---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Tab_Trf2;

     ?**---Définition d'interface de procédure--------------------------------**
       dcl-pi Tab_Trf2;
        Tab_Name const like (£tab);
        Tab_Save const like (£tab);
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cpt1 like(£index) inz(0);
       dcl-s InfyTab like(£index) inz(0);

?      //---Suppression du tableau de sauvegarde s'il existe------------------//
       If %LookUp(Tab_Save:Master_Tab) > 0;
         Tab_Term2(Tab_Save);
       EndIf;
?      //---Transfert des postes du tableau-----------------------------------//
       InfyTab = Tab_Inf2(Tab_Name);
       For Cpt1 = 1 to InfyTab;
         Tab_Set2(Tab_Save:Cpt1:Tab_Get2(Tab_Name:Cpt1));
       EndFor;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Récupération du pointeur de procédure------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc GetProcPtr;
     ?**---Définition du prototype d'interface--------------------------------**
       dcl-pi GetProcPtr pointer(*proc);
        Procedure varchar(100) const;
        Srvpgm char(10) const;
        Library char(10) const;
       end-pi;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s LibPtr like(£sysptr);
       dcl-s SrvpgmPtr like(£sysptr);
       dcl-s ActMark int(10);
       dcl-s ProcPtr pointer(*proc);
       dcl-s ExportType int(10);
     ?**---Définition des constantes locales----------------------------------**
       dcl-c EX_NOT_FOUND 0;
       dcl-c EX_PROC 1;
       dcl-c EX_DATA 2;
       dcl-c EX_NO_ACCESS 3;

?      //---First, get the pointer to the service program---------------------//
       If Library = '*LIBL';
?      //---They specified *LIBL----------------------------------------------//
         TypeSubtyp = x'0203';
         ObjectPtr = Srvpgm;
         RslvSp2(SrvpgmPtr : RslvTemplt);
       Else;
?      //---They specified the library ...------------------------------------//
?      //---Get the pointer to the library------------------------------------//
         TypeSubtyp = x'0401';
         ObjectPtr = Library;
         RslvSp2(LibPtr : RslvTemplt);
?      //---Get the pointer to the service program----------------------------//
         TypeSubtyp = x'0203';
         ObjectPtr = Srvpgm;
         RslvSp4(SrvpgmPtr : RslvTemplt : LibPtr);
       EndIf;
?      //---Now, activate the service program---------------------------------//
       ActBndPgm(SrvpgmPtr : ActMark :ABP_Info : %size(ABP_Info) : ErrCode);
?      //---------------------------------------------------------------------//
?      //---Finally, get the procedure pointer--------------------------------//
?      //---We're using nameLen+name rather than export-number----------------//
?      //---so we pass 0 as the export number.--------------------------------//
?      //---------------------------------------------------------------------//
       GetExport(ActMark:0:%len(Procedure):Procedure:ProcPtr:
                 ExportType:ErrCode);
?      //---Return the procedure pointer--------------------------------------//
       If ExportType = EX_PROC;
         Return ProcPtr;
       Else;
         Return *Null;
       EndIf;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Récupération des infos Querys--------------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc RtvQryf;
       dcl-pi RtvQryf;
        QryName char(10);
        QryLib char(10);
        QryIn char(1280);
        QryOut char(30);
        ErrCode char(1);
       end-pi;

     ?**---Définition des constantes locales----------------------------------**
       dcl-c QryOutTypeOff const(261);
       dcl-c QryOutOffOff const(381);
       dcl-c QryInCountOff const(559);
       dcl-c QryInOff const(563);

     ?**---Définition des variables locales-----------------------------------**
       dcl-ds QryOut1;
        QryOutFile char(10);
        QryOutFileLib char(10);
        QryOutFileMbr char(10);
       end-ds;
       dcl-s Idx int(10);
       dcl-s QUsQName char(20) inz('QRYDMP    QTEMP     ');
       dcl-s QUsExtAtr char(10) inz('QryDump');
       dcl-s QUsInzSiz bindec(9) inz(x'1000');
       dcl-s QUsInzVal char(1) inz(x'00');
       dcl-s QUsAut char(10) inz('*ALL');
       dcl-s QUsTxt char(50) inz('User Space for RtvQryF');
       dcl-s QUsLib char(10);
       dcl-s QUsErrCode pointer inz(*null);
       dcl-s QMhErrCode pointer inz(*null);
       dcl-s QryOutType char(1);
       dcl-s QryOutTmp char(34);
       dcl-s QryInTmp char(80);
       dcl-s QryAut ind inz( *off );
       dcl-ds QryOutOffDS;
        QryOutOff uns(10);
       end-ds;
       dcl-ds QryInCountDS;
        QryInCount uns(5);
       end-ds;
       dcl-ds QUsAttr;
        *n int(10) inz(1); // QUsNumRec
        *n int(10) inz(3); // QUsKey
        *n int(10) inz(1); // QUsRecLen
        *n char(1) inz('1'); // QUsRecData
       end-ds;
       dcl-pr QUsRtvUs extpgm('QUSRTVUS');
        *n char(20) const; // QualifiedName
        *n int(10) const; // StartingPos
        *n int(10) const; // DataRcvLength
        *n char(9999) options(*varsize); // DataRcv
       end-pr;
       dcl-pr QMhRmvPm extpgm('QMHRMVPM');
        *n char(16) const; // CSE
        *n int(10) const; // CSECtr
        *n char(4) const; // MessageKey
        *n char(10) const; // MsgToRmv
        *n pointer; // ErrCode
       end-pr;
       ErrCode = '0';
?      //---Création du User Space--------------------------------------------//
       QusCrtUs(QUsQName:QUsExtAtr:QUsInzSiz:QUsInzVal:QUsAut:QUsTxt
       :SpaceReplc:ApiError);
?      //---Augmentation de la taille en automatique--------------------------//
       QusCusAt(QUsLib:QUsQName:QUsAttr:QUsErrCode);
?      //---Dump du Query dans le User Spaceomatique--------------------------//
       DmpQry(QryName:QryLib:QUsQName:QryAut);

?      //---Si Autorisé à l'objet---------------------------------------------//
       If QryAut;

?      //---Récupération des données------------------------------------------//
         QUsRtvUs(QUsQName:QryOutTypeOff:%Size(QryOutType):QryOutType);
?      //---Contrôle Existence d'un fichier en sortie-------------------------//
         If QryOutType <> '3';
           QryOutFile = '*NONE';
         Else;
           QUsRtvUs(QUsQName:QryOutOffOff:%Size(QryOutOffDS):QryOutOffDS);
?      //---Contrôle Existence d'un fichier en sortie par défaut--------------//
           If QryOutOff = 0;
             QryOutFile = '*DFT';
           Else;
?      //---Récupération des infos du fichier en sortie-----------------------//
             QUsRtvUs(QUsQName:QryOutOff + 5:%Size(QryOutTmp):QryOutTmp);
             QryOutFile    = %Subst(QryOutTmp :  1 : 10);
             QryOutFileLib = %Subst(QryOutTmp : 13 : 10);
             QryOutFileMbr = %Subst(QryOutTmp : 25 : 10);
           EndIf;
         EndIf;

?      //---Récupération dui nombre de fichier en entrée----------------------//
         QUsRtvUs(QUsQName:QryInCountOff:%Size(QryInCountDS):QryInCountDS);
?      //---Lecture pour chaque fichier en entrée-----------------------------//
         For Idx = 0 To QryInCount - 1;
           QUsRtvUs(QUsQName:QryInOff+(Idx*80):%Size(QryInTmp):QryInTmp);
           %Subst(QryIn:1+(Idx*40):40)=%Subst(QryInTmp:1:10) +
           %Subst(QryInTmp:13:10)+%Subst(QryInTmp:25:10)+%Subst(QryInTmp:37:10);
         EndFor;

?      //---Suppression des messages------------------------------------------//
         QMhRmvPm('*ALLINACT':0:'    ':'*ALL':QMhErrCode);

       EndIf;
       If Not QryAut;
         If ErrCode = '0';
           ErrCode = '2';
         EndIf;
       EndIf;
       QryOut = QryOut1;
       ExSr Cleanup;
       *InLr = *On;
       Return;

?      //---------------------------------------------------------------------//
?      //---CleanUp : Nettoyage-----------------------------------------------//
?      //---------------------------------------------------------------------//

       BegSr CleanUp;
       QusDltUs(QusQName:ApiError);
       EndSr;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : DmpQry Dump d'un Query---------------------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc DmpQry;
       dcl-pi DmpQry;
        QueryName char(10) const;
        QueryLib char(10) const;
        QUSName char(20) const;
        QryAut ind;
       end-pi;

     ?**---Définition des variables locales-----------------------------------**
       dcl-s Cmd char(100);
       dcl-s VerRelMod int(10);
       dcl-s RcdNbr int(10);
       dcl-s QUsStrPos int(10) inz(1);
       dcl-s QUsDataForce char(1) inz('1');
     ?**---Définition des constantes locales----------------------------------**
       dcl-c QMHRSNEM 'QMHRSNEM';

       dcl-pr QUsChgUs extpgm('QUSCHGUS');
        *n char(20) const; // QualifiedName
        *n int(10) const; // StartingPos
        *n int(10) const; // DataLength
        *n char(9999) options(*varsize); // Data
        *n char(1); // ForceChanges
       end-pr;

       dcl-pr SysCmd extpgm('QCMDEXC');
        *n char(300) options(*varsize) const; // CmdString
        *n packed(15: 5) const; // CmdStringSize
        *n char(3) options(*nopass) const; // CmdOptions
       end-pr;


?      //---Sauvegarde du Query dans un savf----------------------------------//
       Cmd = 'CRTSAVF FILE(QTEMP/DMPFIL)';
       SysCmd(Cmd:%Size(Cmd));
       Cmd = 'SAVOBJ OBJ('+%Trim(QueryName)+') LIB( '+%Trim(QueryLib)+') '  +
             'DEV(*SAVF) OBJTYPE(*QRYDFN) SAVF(QTEMP/DMPFIL)';
       CallP(e)  SysCmd(Cmd:%Size(Cmd));
       If Not %Error;
         QryAut = *On;
?      //---Version de l'OS---------------------------------------------------//
         VerRelMod = %Dec(%subst(Version_os:2:1)+%subst(Version_os:4:1)+
         %subst(Version_os:6:1):3:0);
?      //---Calcul du nombre d'enregistrements à éviter-----------------------//
         If VerRelMod < 530;
           RcdNbr = 33;
         Else;
           RcdNbr = 48;
         Endif;

?      //---Override du savf--------------------------------------------------//
         Cmd = 'OVRSAVF FILE(DMPFIL) EXTEND(*NO) POSITION(*RRN ' +
            %char(RcdNbr)+') WAITFILE(*IMMED) SHARE(*NO) OPNSCOPE(*ACTGRPDFN)';
         SysCmd(Cmd:%Size(Cmd));

         Open DmpFil;
         Read DmpFil DmpFilDs;
?      //---Si l'OS est < 5.3, on saute les premiers 256 bytes----------------//
         If VerRelMod < 530;
           QUsChgUs(QUsName:QUsStrPos:%Size(NoOMH):NoOMH:QUsDataForce);
           QUsStrPos = QUsStrPos + %Size(NoOMH);
         Endif;
?      //---Lecture du restant du fichier et écriture dans le User Space------//
         Dou %Eof(DmpFil);
           Read DmpFil DmpFilDs;
           QUsChgUs(QUsName:QUsStrPos:%Size(SavfDta):SavfDta:QUsDataForce);
           QUsStrPos = QUsStrPos + %Size(SavfDta);
         EndDo;
       Else;
?      //---En Cas d'erreur---------------------------------------------------//
         QryAut = *Off;
       EndIf;
?      //---Nettoyage et Sortir-----------------------------------------------//
       ExSr Cleanup;
       Return;

?      //---------------------------------------------------------------------//
?      //---Cleanup working file----------------------------------------------//
?      //---------------------------------------------------------------------//
       BegSr CleanUp;

       Close DmpFil;
       Cmd = 'DLTF FILE(QTEMP/DMPFIL)';
       CallP(e)  SysCmd(Cmd:%Size(Cmd));

       EndSr;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure Lib_Size : Taille d'une bibliothèque---------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Taille_Bib;

       dcl-pi Taille_Bib;
        ParamPlug char(1024);
       end-pi;
     ?**---Liste des objets---------------------------------------------------**
       dcl-pr QUsLObj extpgm('QUSLOBJ');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n char(10); // parm
       end-pr;
     ?**---Création d'un User Space-------------------------------------------**
       dcl-pr QusCrtUs extpgm('QUSCRTUS');
        *n char(20); // parm
        *n char(10); // parm
        *n bindec(9); // parm
        *n char(1); // parm
        *n char(10); // parm
        *n char(50); // parm
        *n char(10); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---Description d'une bibliothèque-------------------------------------**
       dcl-pr QLirLibd extpgm('QLIRLIBD');
        *n char(32767) options(*varsize); // parm  RcvVar
        *n int(10) const; // parm  RcvVarLen
        *n char(10) const; // parm  Library
        *n char(32767) const; // parm  AtrToRtv
        *n likeds(apierror); // parm  Parm
       end-pr;
     ?**---Recherche de l'adresse d'un User Space-----------------------------**
       dcl-pr Qusptrus extpgm('QUSPTRUS');
        *n char(20); // parm
        *n pointer; // parm
       end-pr;
     ?**---Réception d'un User Space------------------------------------------**
       dcl-pr Qusrtvus extpgm('QUSRTVUS');
        *n char(20); // parm
        *n bindec(9); // parm
        *n bindec(9); // parm
        *n char(2000) options(*varsize); // parm
       end-pr;
     ?**---Définition des Constantes------------------------------------------**
       dcl-c MaxTab const(32767); // Taille Max tableau
     ?**---Entête d'un User Space---------------------------------------------**
       dcl-ds GenHeadDs based(puserspace);
        *n int(10) pos(113); // Taille de l'entête
        *n int(10) pos(117); // Offset de l'entête
        *n int(10) pos(121); // Taille de l'entête
        ListOffset int(10) pos(125); // Offset des données
        *n int(10) pos(129); // Taille de la liste
        NumberList int(10) pos(133); // Nombre de données
        EntrySize int(10) pos(137); // Taille des données
       end-ds;
     ?**---User Space Générique-----------------------------------------------**
       dcl-ds UserSpace;
        SpaceName char(10);
        SpaceLib char(10);
       end-ds;
     ?**---Code Erreur standard API : ERRC0100--------------------------------**
       dcl-ds ApiError;
        *n int(10) inz(%size(apierror));
        *n int(10) inz; // Bytes Available
        *n char(7); // Exception Id
        *n char(1); // Reserved
        *n char(128); // Exception Data
       end-ds;
     ?**---Liste des Objets---------------------------------------------------**
       dcl-ds DsList; // Liste d'objet
        DsListFile char(10); // Objet
        *n char(10); // Bibliothèque
        *n char(10); // Type d'objet
       end-ds;
     ?**---Description d'un composant-----------------------------------------**
       dcl-ds Composant; // Composant
        Obj char(10); // Objet
        Lib char(10); // Bibliothèque
       end-ds;

       dcl-ds AtrToRtvDS;
        *n int(10) inz(1);
        Elm int(10) dim(1);
       end-ds;
      *
       dcl-ds QLirr len(32767);
        *n int(10);
        *n int(10);
        *n int(10);
        *n int(10);
       end-ds;
      *
       dcl-ds LibSizeDS;
        LibSize int(10);
        LibSizeMult int(10);
        *n ind;
        *n char(3);
       end-ds;
       dcl-ds VarLenDS based(varlenà);
        VLRtnDtaLen int(10);
        VLKeyID int(10);
        VLFldSize int(10);
        VLFldValue char(1000);
       end-ds;
     ?**---Définition des variables-------------------------------------------**
       dcl-s k packed(5) inz; // Compteur
       dcl-s NbrMbr packed(5);
       dcl-s Taille packed(15);
       dcl-s FormatName char(8);
       dcl-s SpaceValue char(1) inz(x'00'); // Valeur du User Space
       dcl-s ObjectType char(10) inz('*ALL'); // Type d'objet
       dcl-s SpaceAuth char(10) inz('*USE'); // Autorisation User Sp
       dcl-s SpaceReplc char(10) inz('*YES'); // Remplacement du User
       dcl-s SpaceAttr char(10) inz; // Attribut du User Spa
       dcl-s SpaceText char(50) inz('User Space Temporaire'); // Libellé User Space
       dcl-s SpaceLen bindec(9) inz(maxtab); // Longueur du User Spa
       dcl-s StartPosit bindec(9); // Position dans le Use
       dcl-s StartLen bindec(9); // Longueur dans le Use
       dcl-s LibName char(10) inz; // Bibliothèque
       dcl-s LibTotsize int(20);
       dcl-s VarLenà pointer;


?      //---Récupération paramètres-------------------------------------------//
       DataPlugin = ParamPlug;
       LibName = X_Objet;

?      //---Create User Space-List Fichier------------------------------------//
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       SpaceLen = MaxTab;
       QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                SpaceAuth:SpaceText:SpaceReplc:ApiError);

       FormatName = 'OBJL0100';
       Obj = LibName;
       Lib = 'QSYS';
       ObjectType = '*LIB';
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       QUslObj(UserSpace:FormatName:Composant:ObjectType);

?      //---Retrieve user space General information---------------------------//
       StartPosit = 1;
       StartLen = 1024;
       SpaceName = 'USERSPACE';
       SpaceLib = 'QTEMP';
       Qusptrus(UserSpace:pUserSpace);
       QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

?      //---Retrieve user space Detail information----------------------------//
       StartPosit = ListOffset + 1;
       StartLen = EntrySize;
       NbrMbr = NumberList;

       For k = 1 to NbrMbr;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUsPtrUs(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:DsList);
         StartPosit = StartPosit + StartLen;
         libname = DSLISTFILE;
         elm(1) = 6;
         Clear QLirr;
         Clear ApiError;
         qlirlibd( QLirr:%size(QLirr):LibName:AtrToRtvDS: Apierror);
         VarLenà = %addr( QLirr ) + 16;
         LibSizeDS = VLFldValue;
         If LibSizeMult > 1;
           LibTotSize = LibSize * LibSizeMult ;
         Else;
            LibtotSize = LibSize;
         Endif;

       EndFor;

?      //---Formatage des paramètres en sortie--------------------------------//
       Taille = LibTotsize /1000;
       x_Texte = x'20' + 'Taille = '+ x'22' + %Char(Taille)
        + x'20' +' Ko';
       Taille = LibTotsize /1000000;
       x_Texte = %Trim(x_Texte) + ' / ' + x'22' + %Char(Taille) + x'20' + 'Mo';

?      //---Retour paramètres-------------------------------------------------//
       ParamPlug = DataPlugin;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure Suppression des enregistrement de PGMREF-----------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Net_Pgmref;

     ?**---Lancement de Commande----------------------------------------------**
       dcl-pr QCmdExc extpgm('QCMDEXC');
        *n char(100); // parm  Commande
        *n packed(15: 5); // parm  Longueur de la
       end-pr;
     ?**---Définition des variables locales-----------------------------------**
       dcl-s OvrCmd char(100); // Commande AS400
       dcl-s OvrCmdLen packed(15: 5); // Longueur de la comma
       dcl-s Nbr_Enr packed(9);

       dcl-pi Net_Pgmref;
        ParamPlug char(1024);
       end-pi;
     C/EXEC SQL
     C+  DELETE FROM zz01pf
     C+    WHERE zzvaleur IN
     C+      (SELECT whlib
     C+         FROM pgmref
     C+         GROUP BY whlib
     C+         HAVING COUNT(*) = 0)
     C/END-EXEC
     C/EXEC SQL
     C+  DELETE FROM pgmref
     C+    WHERE whlib NOT IN
     C+      (SELECT zzvaleur
     C+         FROM zz01pf
     C+         WHERE zztype = 'OBLIB')
     C/END-EXEC
     C/EXEC SQL
     C+  SELECT COUNT(*)
     C+    INTO :nbr_enr
     C+    FROM pgmref
     C/END-EXEC
       If Nbr_Enr > 0;
         OvrCmd = 'RGZPFM PGMREF';
         OvrCmdLen = 15;
         QCmdExc(OvrCmd:OvrcmdLen);
       EndIf;
       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Liste des zones dans un programme----------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Zone_Prog;
       dcl-pi Zone_Prog;
        ParamPlug char(1024);
       end-pi;
     ?**---Définition des variables-------------------------------------------**
       dcl-s Requete char(1000);
     d*SrcSeq12        s              8a
     d*SrcDta12        s             83a
       dcl-s OvrCmd char(200); // Commande AS400
       dcl-s OvrCmdLen packed(15: 5); // Longueur de la comma
     ?**---Lancement de Commande----------------------------------------------**
       dcl-pr QCmdExc extpgm('QCMDEXC');
        *n char(100); // parm  Commande
        *n packed(15: 5); // parm  Longueur de la
       end-pr;

?      //---Récupération paramètres-------------------------------------------//
       DataPlugin = ParamPlug;
?      //---Si Programme------------------------------------------------------//
       If x_Type = '*PGM';
         If F01Msrc <> *Blanks;
           F01LSrc = x_Bibsrc;
           F01FSrc = x_FicSrc;
           F01MSrc = x_MbrSrc;
         Else;
           F01LSrc = x_Bib;
           F01FSrc = *Blanks;
           F01MSrc = x_Objet;
         EndIf;
       EndIf;
?      //---Si Fichier--------------------------------------------------------//
       If x_Type = '*FILE';
         F01File = x_Objet;
         F01Libl = x_Bib;
         F01LSrc = *Blanks;
         F01FSrc = *Blanks;
         F01MSrc = *Blanks;
       EndIf;
?      //---Boucle principale-------------------------------------------------//
       Exit = *Off;
       Dow Not Retour AND Not Exit;
?      //---Affichage de l'écran de sélection---------------------------------//
         Write Foot;
         Exfmt F1201;
?      //---Miseà blanc des zones---------------------------------------------//
         SrcSeq12 = *Blanks;
         SrcDta12 = *Blanks;
         Column = *Blanks;
         Tablen = *Blanks;
         Pst = *Blanks;
         If AffSrc;
           OvrCmd = 'STRSEU SRCFILE(' + %Trim(F01LSRC) + '/' + %Trim(F01FSRC) +
                    ') SRCMBR(' + %Trim(F01MSRC) + ') OPTION(5)';
           OvrCmdLen = 200;
           QcmdExc(OvrCmd:OvrCmdLen);
         EndIf;
         If Not Exit
            and F01LSrc <> *Blanks and F01FSrc <> *Blanks and F01MSrc <> *Blanks
            and F01File <> *Blanks and F01Libl <> *Blanks;
?      //---Suppression de l'alias--------------------------------------------//
     C/EXEC SQL
     C+  DROP ALIAS qtemp / recherche
     C/END-EXEC
?      //---Creation de l'alias-----------------------------------------------//
           Requete = 'Create Alias Qtemp/Recherche For ' + F01LSrc + '/'
                     + F01FSrc + '(' + F01MSrc + ')';
     C/EXEC SQL
     C+  EXECUTE IMMEDIATE :requete
     C/END-EXEC
?      //---Définition de la requête principale-------------------------------//
           Requete = 'Select SRCSEQ, SRCDTA, COLUMN_NAME, TABLE_NAME,          -
           POSITION(TRIM(COLUMN_NAME) IN UPPER(SRCDTA)) AS PST FROM            -
           QTEMP/RECHERCHE, QSYS2/SYSCOLUMNS WHERE TABLE_SCHEMA =' +
           '''' + F01LIBL + '''' + ' AND TABLE_NAME = ' + '''' + F01FILE + ''''+
           'AND (POSITION(COLUMN_NAME IN UPPER(SRCDTA)) <> 0                   -
            OR POSITION(TRIM(COLUMN_NAME) IN UPPER(SRCDTA)) <> 0)';
?      //---Préparation, déclaration, ouverture, ....-------------------------//
     C/EXEC SQL
     C+  PREPARE s FROM :requete
     C/END-EXEC
     C/EXEC SQL
     C+  DECLARE c CURSOR FOR s
     C/END-EXEC
     C/EXEC SQL
     C+  OPEN c
     C/END-EXEC
?      //---Clear du sous-fichier---------------------------------------------//
            SflClr = *On;
            Write F12Ctl;
            SflClr = *Off;
            f12rrn = 0;
?      //---Lecture du premier enregistrement---------------------------------//
     C/EXEC SQL
     C+  FETCH NEXT FROM c INTO :srcseq12, :srcdta12, :column, :tablen, :pst
     C/END-EXEC
?      //---Boucle sur la requête---------------------------------------------//
            Dow sqlcod <> 100;
              f12rrn += 1;
              Write F12Sfl;
     C/EXEC SQL
     C+  FETCH NEXT FROM c INTO :srcseq12, :srcdta12, :column, :tablen, :pst
     C/END-EXEC
            EndDo;
?      //---Fermeture du curseur----------------------------------------------//
     C/EXEC SQL
     C+  CLOSE c
     C/END-EXEC
?      //---Si rien trouvé----------------------------------------------------//
            If f12rrn = 0;
              f12rrn +=1;
              SrcDta12 = 'Aucun Enregistrement trouvé';
              Write F12Sfl;
            EndIf;

?      //---Affichage du sous fichier-----------------------------------------//
            F12Rcd = 1;
            SflDsp=*on;
            SflDspCtl=*on;
            Write F12ctl;
            SflDsp=*off;
            SflDspCtl=*off;
          EndIf;
       EndDo;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure : Archivage d'un fichier par trigger---------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Arc_Trigg;
       dcl-pi Arc_Trigg;
        ParamPlug char(1024);
       end-pi;
     ?**---Définition des variables-------------------------------------------**
       dcl-s Action char(1);
       dcl-s Bib char(10);
       dcl-s Fic char(10);
       dcl-s Fic_Log char(10);
       dcl-s Requete2 char(32766);
       dcl-s Lst_Zone char(32766);
       dcl-s OvrCmd char(2800); // Commande AS400
       dcl-s OvrCmdLen packed(15: 5); // Longueur de la comma
     ?**---User Space Générique-----------------------------------------------**
       dcl-ds UserSpace;
        SpaceName char(10);
        SpaceLib char(10);
       end-ds;
     ?**---Création d'un User Space-------------------------------------------**
       dcl-pr QusCrtUs extpgm('QUSCRTUS');
        *n char(20); // parm
        *n char(10); // parm
        *n bindec(9); // parm
        *n char(1); // parm
        *n char(10); // parm
        *n char(50); // parm
        *n char(10); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---Suppression d'un User Space----------------------------------------**
       dcl-pr QusdltUs extpgm('QUSDLTUS');
        *n char(20); // parm
        *n like(apierror); // parm
       end-pr;
     ?**---Liste des formats--------------------------------------------------**
       dcl-pr QUsLRcd extpgm('QUSLRCD');
        *n char(20); // parm
        *n char(8); // parm
        *n char(20); // parm
        *n char(1); // parm
       end-pr;
     ?**---Affichage des zones d'un fichier-----------------------------------**
       dcl-pr Quslfld extpgm('QUSLFLD');
        *n char(20); // parm
        *n char(10); // parm
        *n char(20); // parm
        *n char(10); // parm
        *n char(1); // parm
       end-pr;
     ?**---Code Erreur standard API : ERRC0100--------------------------------**
       dcl-ds ApiError;
        AeBytPro int(10) inz(%size(apierror));
        AeBytAvl int(10) inz; // Bytes Available
        AeMsgId char(7); // Exception Id
        *n char(1); // Reserved
        AeMsgDta char(128); // Exception Data
       end-ds;
     ?**---Description d'un composant-----------------------------------------**
       dcl-ds Composant; // Composant
        Obj char(10); // Objet
        Lib char(10); // Bibliothèque
       end-ds;
     ?**---Entête d'un User Space---------------------------------------------**
       dcl-ds GenHeadDs based(puserspace);
        InputSize int(10) pos(113); // Taille de l'entête
        HeaderOffset int(10) pos(117); // Offset de l'entête
        HeaderSize int(10) pos(121); // Taille de l'entête
        ListOffset int(10) pos(125); // Offset des données
        ListSize int(10) pos(129); // Taille de la liste
        NumberList int(10) pos(133); // Nombre de données
        EntrySize int(10) pos(137); // Taille des données
       end-ds;
     ?**---Description d'un fichier-------------------------------------------**
       dcl-ds *n based(pentry);
        FieldName char(10) pos(1);
        DataType char(1) pos(11);
        Use char(1) pos(12);
        OutBufPos int(10) pos(13);
        InBufPos int(10) pos(17);
        ByteLeng int(10) pos(21);
        Digits int(10) pos(25);
        DecPos int(10) pos(29);
        FieldText char(50) pos(33);
        EditCode char(2) pos(83);
        EditWordLen int(10) pos(85);
        EditWord char(64) pos(89);
        ColHead1 char(20) pos(153);
        ColHead2 char(20) pos(173);
        ColHead3 char(20) pos(193);
        IntName char(10) pos(213);
        AltName char(30) pos(223);
        LenAltFld int(10) pos(253);
        NumDBCS int(10) pos(257);
        AlwNull ind pos(261);
        HostVarInd ind pos(262);
        DatTimFmt char(4) pos(263);
        DatTimSep char(1) pos(267);
        VaryingInd ind pos(268);
       end-ds;
       dcl-s fmt char(10);
       dcl-s Format char(10);
       dcl-s FormatName char(8);
       dcl-s i packed(5) inz(1); // Compteur
       dcl-c MaxTab const(32767); // Taille Max tableau
       dcl-s OverRide char(1);
       dcl-s SpaceAttr char(10) inz; // Attribut du User Spa
       dcl-s SpaceAuth char(10) inz('*USE'); // Autorisation User Sp
       dcl-s SpaceReplc char(10) inz('*YES'); // Remplacement du User
       dcl-s SpaceLen bindec(9) inz(maxtab); // Longueur du User Spa
       dcl-s SpaceValue char(1) inz(x'00'); // Valeur du User Space
       dcl-s SpaceText char(50) inz('User Space Temporaire'); // Libellé User Space
       dcl-s StartLen bindec(9); // Longueur dans le Use
       dcl-s StartPosit bindec(9); // Position dans le Use
     ?**---Recherche de l'adresse d'un User Space-----------------------------**
       dcl-pr Qusptrus extpgm('QUSPTRUS');
        *n char(20); // parm
        *n pointer; // parm
       end-pr;
     ?**---Réception d'un User Space------------------------------------------**
       dcl-pr Qusrtvus extpgm('QUSRTVUS');
        *n char(20); // parm
        *n bindec(9); // parm
        *n bindec(9); // parm
        *n char(2000) options(*varsize); // parm
       end-pr;
     ?**---Lancement de Commande----------------------------------------------**
       dcl-pr QCmdExc extpgm('QCMDEXC');
        *n char(100); // parm  Commande
        *n packed(15: 5); // parm  Longueur de la
       end-pr;

?      //---Création du fichier ZZ03PF----------------------------------------//
       Requete2 = 'Create table zz03pf (FIC03 CHAR(10), BIB03 CHAR(10), ' +
        'USR03 CHAR(10), TMSP03 TIMESTAMP, FICH03 CHAR(10))';
       EXEC SQL
         EXECUTE IMMEDIATE :requete2;
       Requete2 = 'LABEL ON TABLE zz03pf IS ' +
       '''X-Ref - Liste des Fichiers Historiques''';
       EXEC SQL
         EXECUTE IMMEDIATE :requete2;

?      //---Récupération paramètres-------------------------------------------//
       DataPlugin = ParamPlug;
       If x_Type = '*FILE';
         Fic = x_Objet;
         Bib = x_Bib;
         Action = *Blanks;
       EndIf;

?      //---Suppression des Tiggers sur le Fichier----------------------------//
       OvrCmd = 'RMVPFTRG FILE(' +  %trim(Bib) + '/' + %Trim(Fic) + ')';
       OvrCmdLen = 100;
       Callp(e) QcmdExc(OvrCmd:OvrCmdLen);
?      //---Suppression Enregistrement dans ZZ03PF----------------------------//
       Requete2= 'Delete from zz03pf where fic03 =''' + Fic + ''' and bib03' +
       ' =''' + bib + '''';
       EXEC SQL
         EXECUTE IMMEDIATE :requete2;

       If Action = *Blanks;
?      //---Nom du fichier historique-----------------------------------------//
         Fic_Log = %trim(Fic) + 'H';

?      //---Creation du fichier Historique------------------------------------//
         Requete2= 'Create table ' + %Trim(Bib)+ '/' + Fic_Log + ' like ' + Fic;
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;
?      //---Ajout des zones Historique----------------------------------------//
         Requete2= 'Alter Table ' + Fic_Log + ' add column TMSP TIMESTAMP not  -
                    null with default';
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;
         Requete2= 'Alter table ' + Fic_Log +' add column usr char(10) not null-
                    with default';
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;
         Requete2= 'Alter table ' + Fic_Log + ' add column Typ char(1) not null-
                    with default';
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;

?      //---Recherche des zones présentes dans le fichier---------------------//
         Obj = Fic;
         Lib = Bib;
?      //---Create User Space-List Fichier------------------------------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         SpaceLen = MaxTab;
         QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                  SpaceAuth:SpaceText:SpaceReplc:ApiError);
?      //---Liste des formats d'un fichier------------------------------------//
         FormatName = 'RCDL0100';
         OverRide = '1';
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUslRcd(UserSpace:FormatName:Composant:OverRide);
?      //---Retrieve user space General information---------------------------//
         StartPosit = 1;
         StartLen = 1024;
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         Qusptrus(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);
?      //---Retrieve user space Detail information----------------------------//
         StartPosit = ListOffset + 1;
         StartLen = EntrySize;
?      //---Lecture de tous les Membres d'un fichier--------------------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         Qusptrus(UserSpace:pUserSpace);
         QUsRtvUs(UserSpace:StartPosit:StartLen:fmt);
         StartPosit = StartPosit + StartLen;
?      //---Create User Space-------------------------------------------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
                  SpaceAuth:SpaceText:SpaceReplc:ApiError);
?      //---Get the list of all the fields------------------------------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         OverRide = '1';
         Format  = 'FLDL0100';
         Quslfld(UserSpace:Format:Composant:Fmt:OverRide);
?      //---Get a pointer to the user space containing the list---------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         Qusptrus(UserSpace:pUserSpace);
?      //---Récupération de la liste des zones--------------------------------//
         i = 1;
         pEntry = pUserSpace + listOffset + ((i-1)*entrySize);
         If AltName = *Blanks;
           Lst_Zone = 'o.' + FieldName;
         Else;
           Lst_Zone = 'o.' + AltName;
         EndIf;
         For i = 2 to  NumberList;
           pEntry = pUserSpace + listOffset + ((i-1)*entrySize);
           If AltName = *Blanks;
             Lst_Zone = %Trim(Lst_Zone)+ ',' + 'o.' + FieldName;
           Else;
             Lst_Zone = %Trim(Lst_Zone)+ ',' + 'o.' + AltName;
           EndIf;
         EndFor;
?      //---Suppression du User Space-----------------------------------------//
         SpaceName = 'USERSPACE';
         SpaceLib = 'QTEMP';
         QusDltUs(UserSpace:ApiError);

?      //---Trigger de mise à jour--------------------------------------------//
         Requete2= 'Create Trigger Upd_'+ %Trim(Fic) + '_' + %Trim(Fic_Log) +
         ' after update on ' + %Trim(Bib) + '/' + %Trim(Fic) +
         ' REFERENCING NEW AS o FOR EACH ROW MODE DB2ROW' +
         ' insert into ' + Fic_Log + 'values(' + %trim(Lst_Zone) +
         ', current_timestamp, user, ''U'')';
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;

?      //---Trigger d'insertion-----------------------------------------------//
         Requete2= 'Create Trigger Ins_'+ %Trim(Fic) + '_' + %Trim(Fic_Log) +
         ' after insert on ' + %Trim(Bib) + '/' + %Trim(Fic) +
         ' REFERENCING NEW AS o FOR EACH ROW MODE DB2ROW' +
         ' insert into ' + Fic_Log + 'values(' + %trim(Lst_Zone) +
         ', current_timestamp, user, ''A'')';
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;

?      //---Trigger de suppression--------------------------------------------//
         Requete2= 'Create Trigger Dlt_'+ %Trim(Fic) + '_' + %Trim(Fic_Log) +
         ' after Delete on ' + %Trim(Bib) + '/' + %Trim(Fic) +
         ' REFERENCING Old AS o FOR EACH ROW MODE DB2ROW' +
         ' insert into ' + Fic_Log + 'values(' + %trim(Lst_Zone) +
         ', current_timestamp, user, ''D'')';
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;

?      //---Initialisation du fichier Log-------------------------------------//
         Requete2='INSERT INTO ' + Fic_Log + ' SELECT a.*, current_timestamp,' +
          'user   ,''X'' FROM ' + Fic + ' a';
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;

?      //---Inscription dans le fichier zz03pf--------------------------------//
         Requete2= 'INSERT INTO ZZ03PF (FIC03, BIB03, USR03, TMSP03, FICH03) ' +
         'VALUES(''' + Fic + ''',''' + bib + ''',''' + user +
         ''', Current_Timestamp ,'''
         + fic_Log + ''')';
         EXEC SQL
           EXECUTE IMMEDIATE :requete2;
       EndIf;

       end-proc;

     ?**----------------------------------------------------------------------**
     ?**---Procédure Rec_Avc : Ajout de critère de recherche------------------**
     ?**----------------------------------------------------------------------**
       dcl-proc Rec_Avc;

       dcl-pi Rec_Avc;
        ParamPlug char(1024);
       end-pi;
       dcl-s zz like(£dyna);

       ExFmt F14;

       If F14_Des <> ' ';
         For i = 1 to Tab_Inf2('££WRK');
           zz=Tab_Get2('££WRK':i);
           If %scan(%Trim(F14_Des):zz) = 0;
             Tab_Set2('££WRK':i:' ');
           EndIf;
         EndFor;
       EndIf;

       If F14_Out <> 0;
         For i = 1 to Tab_Inf2('££WRK');
           zz=Tab_Get2('££WRK':i);
           If %subst(zz:63:1) <> x'22';
             Tab_Set2('££WRK':i:' ');
           EndIf;
         EndFor;
       EndIf;

       If F14_Lib1 <> ' ';
         For i = 1 to Tab_Inf2('££WRK');
           zz=Tab_Get2('££WRK':i);
           If F14_Dif = 2;
             If %subst(zz:101:10) = F14_Lib1;
               Tab_Set2('££WRK':i:' ');
             EndIf;
             If %subst(zz:101:10) = F14_Lib2;
               Tab_Set2('££WRK':i:' ');
             EndIf;
             If %subst(zz:101:10) = F14_Lib3;
               Tab_Set2('££WRK':i:' ');
             EndIf;
           Else;
             If %subst(zz:101:10) <> F14_Lib1 and F14_Lib1 <> ' ';
               Tab_Set2('££WRK':i:' ');
             EndIf;
             If %subst(zz:101:10) <> F14_Lib2 and F14_Lib2 <> ' ';
               Tab_Set2('££WRK':i:' ');
             EndIf;
             If %subst(zz:101:10) <> F14_Lib3 and F14_Lib3 <> ' ';
               Tab_Set2('££WRK':i:' ');
             EndIf;
           EndIf;
         EndFor;
       EndIf;
       Tab_Tri2('££WRK':12:62);

         Ind_Rappel += 1;
         IndRapWrk = Ind_Rappel;
         Tab_Set('Rappel1':Ind_Rappel:F01Obj);
         Tab_Set('Rappel2':Ind_Rappel:F01Des);
         Tab_Set('Rappel3':Ind_Rappel:F01Bib);
         Tab_Set('Rappel4':Ind_Rappel:F01Typ);
         Tab_Set('Rappel5':Ind_Rappel:ZzFonc);
         Tab_Trf2('££WRK':%Char(Ind_Rappel));

       end-proc;

** ctdata
Recherche avancée
Taille d'une bibliotheque
Nettoyage de PGMREF
Liste des zones d'un fichier dans un programme
Archivage d'un fichier par trigger              ?[Test]
** ctdata
Avec la version v1.9.0, X-Ref devient plus convivial(?!?) se rapproche de la v2 |
encore un peu plus :                                                            |
 - Le système Menu a disparu, très gadget et peu pratique en fin de compte.     |
 - Au niveau ergonomique, le gros changement vient des touches F09 et F10.      |
   A partir de maintenant, chaque analyse est sauvegardée et il est possible de |
   la rappeler à tout moment par la touche F09. La touche F10 permet de faire   |
   défiler les analyses dans l'autre sens. Un compteur a été ajouté afin de     |
   savoir quelle analyse est en cours d'affichage.                              |
 - La touche Home (la flèche qui pointe en haut, à gauche à côté du pavé        |
   numérique) permet de réafficher la fenêtre de sélection du composant si elle |
   avait été affichée au préalable.                                             |
 - Certaines touches de fonction ont été modifiées, voir la liste ci-dessous.   |
 - Lors du choix du composant, l'objet sera recherché dans tout le système.     |
   Si la bibliothèque de l'objet n'existe pas dans la liste, elle sera affichée |
   en violet. Le curseur se positionnera par défaut sur l'objet dont la         |
   bibliothèque existe dans la liste.                                           |
 - XREF peut être appeler sous la forme XREF SHIRLOCK/ZZ01 ou XREF *ALL/ZZ01.   |
                                                                                |
            ?Cf. Ci-dessous pour le détail des modifications.                   |
** ctdata                                                                       |
                               ?Aout     2009                                   |
v1.9.2  : - [F05]  : Ajout Tri par colonne                                      | 07/08/2009
          - [F22]  : La fonction marche à nouveau suite à plusieurs bug         | 13/08/2009
          - [Opt]  : BUG dans la gestion avancée des tableaux                   | 13/08/2009
          - [F04]  : Formattage entête de colonnes                              | 13/08/2009
          - [F08]  : Formattage entête de colonnes                              | 13/08/2009
================================================================================|
                               ?Janvier  2009                                   |
v1.9.1  : - [Opt]  : Correction sortie fichier de la liste de bibliothèques     | 25/11/2008
          - [F08]  : Correction sur le sens du tri                              | 10/12/2008
          - [F24]  : Sortie OUTPUT                                              | 18/12/2008
          - [CMD]  : Appel de X-Ref de la forme XREF *LIBL/ZZ01* *PGM           | 14/01/2009
          - [F05]  : Programme de service supprimé : gestion trop lourde        | 22/06/2009
          - [F05]  : Plugin incorporé dans X-Ref (Utilisation inchangée)        | 22/06/2009
          - [Opt]  : Suppression du lancement de plugin auto au démarrage       | 23/06/2009
          - [F09]  : Bug corrigé lorsque le curseur se trouvait dans le SFL     | 09/07/2009
          - [F14]  : Nom du LF mis à la place du nom du format                  | 15/07/2009
          - [F05]  : Sél. Sup. Fichier en mise à jour et bib. particulière      | 20/07/2009
          - [F05]  : Bug dans la gestion des tableaux dynamiques                | 21/07/2009
          - [F05]  : Ajout Sél. Sup. zone libre                                 | 21/07/2009
          - Optim  : Affichage composant dans bib. connue en premier            | 21/07/2009
          - Bug    : Dsppgmref en automatique ne marchait pas                   | 22/07/2009
          - Optim  : Groupe d'activation nommé à la compil supprimé             | 22/07/2009
          - Optim  : Si composant dans nvelle bib., réf. tech. possible         | 23/07/2009
================================================================================|
                               ?Décembre 2008                                   |
v1.9.0  : - [F16]  : Recherche de sous-routine incorrecte en colonné            | 27/06/2008
          - [F16]  : Sources renseignés par défaut à blanc si pas de composant  | 27/06/2008
          - [F16]  : Suppression de l'affichage persistant après analyse        | 27/06/2008
          - Optim  : Recherche de composant ne se base plus sur Liste de Bib.   | 30/06/2008
          - Optim  : Si Bib. n'existe pas, inverse video et Violet              | 30/06/2008
          - Optim  : Touche Home pour ré-afficher la liste des composants       | 30/06/2008
          - Instl  : Création de ZZ01 sous de programme directement             | 03/07/2008
          - [F02]  : Affichage, Impression et sortie fichier via un tableau     | 04/07/2008
          - [F14]  : Affichage, Impression et sortie fichier via un tableau     | 04/07/2008
          - Bug.   : Tab_Term2 - Nom des tableaux utilisés remis à blanc        | 07/07/2008
          - Optim  : Rech. Composant - Position curseur sur Bib. existante      | 07/07/2008
          - [F07]  : Affichage, Impression et sortie fichier via un tableau     | 07/07/2008
          - [F08]  : Affichage, Impression et sortie fichier via un tableau     | 07/07/2008
          - [F04]  : Affichage, Impression et sortie fichier via un tableau     | 07/07/2008
          - Bug.   : Sortie Fichier de la liste de bibliothèque                 | 07/07/2008
          - Bug.   : Recherche des références sur bibliothèques qui existent    | 07/07/2008
          - [F24]  : Amélioration des données en sortie fichier                 | 07/07/2008
          - [F15]  : Affichage, Impression et sortie fichier via un tableau     | 07/07/2008
          - [F16]  : Affichage, Impression et sortie fichier via un tableau     | 07/07/2008
          - [F24]  : Touche F03 et F12 mieux gérées en cas de problème sur liste| 08/07/2008
          - Optim  : Recherche Description d'un objet améliorée                 | 17/07/2008
          - [F18]  : Affichage, Impression et sortie fichier via un tableau     | 25/07/2008
          - [F19]  : Affichage, Impression et sortie fichier via un tableau     | 25/07/2008
          - [F20]  : Affichage, Impression et sortie fichier via un tableau     | 25/07/2008
          - [F22]  : Affichage, Impression et sortie fichier via un tableau     | 25/07/2008
          - [F23]  : Affichage, Impression et sortie fichier via un tableau     | 25/07/2008
          - [F09]  : Résultat de l'analyse ajouté                               | 28/07/2008
          - [F09]  : Numérotation des analyses en cours                         | 28/07/2008
          - [F10]  : Rappel en avant Mis en place                               | 28/07/2008
          - [F13]  : Suppression de la touche F13                               | 28/07/2008
          - Optim  : Modifications des touches F13, F18, F10 et F11(Cf. Aide)   | 28/07/2008
          - Optim  : Mise à jour Info touches de fonction (Lig. Sup ajoutée)    | 28/07/2008
          - [CMD]  : Appel de XREF par XREF Library/Object à présent            | 28/07/2008
          - Bug    : Affichage du sous-fichier après un F15                     | 28/07/2008
          - Optim  : Suppression des menus-Agrandissement de l'affichage        | 30/07/2008
          - Bug    : *RECDESC et *RECPROC corrigé via la commande               | 31/07/2008
          - Bug    : Recherche Composant si Bib. inconnue                       | 31/07/2008
          - [F07]  : Ajout d'un ~ si zone  de type varchar                      | 01/08/2008
================================================================================|
                               ?Mai 2008                                        |
v1.8.0  : - Batch  : Plantage lors du mode batch dans la routine des erreurs    | 26/11/2007
          - [F22]  : OVRDBF impossible sur certains fichier source              | 28/11/2007
          - [F17]  : Ajout du nom de la zone dans le sous fichier               | 07/12/2007
          - Optim  : Ré-écriture partielle du source                            | 17/01/2007
          - [F24]  : Ajout couleur par type de bibliothèque                     | 05/04/2008
          - Plugin : Ajout du plugin archivage par Trigger                      | 17/04/2008
          - [F02]  : Prise en compte des objets Query                           | 23/04/2008
          - [F14]  : Prise en compte des objets Query                           | 23/04/2008
          - Optim  : Référence croisé des Query                                 | 24/04/2008
          - Optim  : Correction dans recherche composant                        | 17/06/2008
================================================================================|
                             ?Octobre 2007                                      |
v1.7.1  : - Plugin : Nettoyage de PGMREF                                        | 02/08/2007
          - [F08]  : Ajout du nom du fichier physique dont dépend le LF         | 09/08/2007
          - Plugin : Lancement en auto de plugin                                | 09/08/2007
          - Plugin : Nettoyage de PGMREF en auto                                | 10/08/2007
          - [F05]  : Pas de lancement si F12 ou F03                             | 21/09/2007
          - Plugin : En auto ne sont lancer qu'une fois par jour                | 21/09/2007
          - [F22]  : Correction plantage si aucune chaine trouvée               | 26/09/2007
          - Batch  : Travail envoyé dans la jobq QS36EVOKE                      | 27/09/2007
          - Plugin : Analyse zones d'un fichier dans un source                  | 27/09/2007
          - Plugin : Alimentation des informations sources                      | 28/09/2007
          - [F24]  : Affichage des bibliothèques par ordre alphabétique         | 28/09/2007
          - [F17]  : Touche Entrée ne fonctionnait pas                          | 28/09/2007
          - [F20]  : Augmentation de la taille mémoire pour éviter les plantages| 01/10/2007
          - [F08]  : Correction Bug sur Vue SQL                                 | 12/11/2007
================================================================================|
                             ?Juin  2007                                        |
v1.7.0  : - Modification de l'emplacement pour la récupération de QSS1MRI       | 04/05/2007
          - Ajout du nom Interne et du nom Alternatif des zones d'un fichier    | 09/05/2007
          - Correction bug sur F23 lorsque type de composant ='*ALL'            | 25/05/2007
          - Ajout de la touche entrée sur le sous-fichier                       | 28/05/2007
          - Ajout de la fonction F09 rappel d'analyse. Modification de la touche| 28/05/2007
            F09 en F22 pour la recherche de caractère.                          |
          - X-Ref devient mono-module                                           | 29/05/2007
          - Présentation de la description objet modifiée                       | 30/05/2007
          - Amélioration de l'ergonomie de X-Ref avec les touches F09 et Entrée | 31/05/2007
          - Ajout de *PRINTER dans la commande et dans l'écran princpal         | 31/05/2007
          - Sup. de la touche F05 devenue inutile avec la nouvelle ergonomie    | 01/06/2007
          - Mode batch : ajout des paramètres de la v1.6.0 (source et texte)    | 06/06/2007
          - Ajout blocage si bib. de référence non créée                        | 07/06/2007
          - Modification de la gestion de la liste de bibliothèque              | 08/06/2007
          - Lancement des jobs en mode batch de façon HOLD(*YES). Ajout de para-| 12/06/2007
            métrage ultérieur au niveau application. (voir plugin)              |
          - Modification du format de l'impression                              | 13/06/2007
          - Correction pbm affichage sur la fonction where-used                 | 14/06/2007
          - Ajout du système de plugin. Appel dynamique mis en place            | 18/06/2007
================================================================================|
                             ?Avril 2007                                        |
v1.6.0  : - Agrandissement de la largeur du sous-fichier                        | 04/01/2007
          - Ajout de la description du programme dans l'algo programme          | 04/01/2007
          - Bug Cartographie source                                             | 24/01/2007
          - Bug Impression sous fichier                                         | 24/01/2007
          - Ajout OS AS400 dans l'entête                                        | 09/03/2007
          - Amélioration affichage des vues sur un fichier par l'option F08     | 15/03/2007
          - Améliorations routage des modes de traitement                       | 15/03/2007
          - Ajout de la notion fichier source dans la commande                  | 16/03/2007
          - Correction Recherche procédures dans module                         | 21/03/2007
          - Ajout du texte dans la commande pour la recherche F04 et F18        | 21/03/2007
          - Correction bug blocage X-Ref si fonction de la commande est rensei- | 21/03/2007
            gnée                                                                |
          - Correction Bug sur la fonction AlgoPgm si pas d'appel de pgm pour le| 26/03/2007
            composant à analyser                                                |
          - Ajout Libellé sur les fichier ZZ01PF et ZZ01OUT                     | 30/03/2007
          - Ajout de la bibliothèque d'installation dans l'appel de ZZ01T       | 02/04/2007
          - Bibliothèque *CURLIB plus obligatoire pour l'installation           | 03/04/2007
          - Fichier de sortie créé dans le programme à présent via SQL : simpli-| 03/04/2007
            fication de la procédure d'installation                             |
          - Ajout de l'aide en ligne sur la commande XREF                       | 05/04/2007
          - Timestamp du fichier de sortie est correcte à présent.              | 10/04/2007
          - Ajout du gestion d'erreur : affichage d'un message et création d'un | 11/04/2007
            enregistrement dans ZZ01OUT pour analyse par W-Ref.                 |
          - Correction affichage entête de sous-fichier pour la fonction F19    | 11/04/2007
          - Ajout du titre dans l'édition du spoole                             | 20/04/2007
================================================================================|
                             ?Novembre 2006                                     |
v1.5.0  : - Version v1.3.5 annulée                                              |
          - Ajout de la possibilité de créer le fichier PGMREF s'il n'existe pas|
            dans la bibliothèque de Type "R". Création des Index PGMREFx aussi. |
          - Contrôle existence des logiques pour création si nécessaire         |
          - Correction d'un bug sur la cartographie de source                   |
          - Affichage optimisé de la cartographie pour prendre le moins de place|
            possible (Largeur d'une colonne en fonction des données de cette    |
            colonne et non plus en fonction des données de l'ensemble des       |
            données.                                                            |
          - Ajout de la Cartographie ILE d'un objet (module, programme ou pro-  |
            gramme de service.                                                  |
          - Ajout du groupe d'activation XREF dans la compilation de ZZ01 pour  |
            éviter les problèmes d'overflow lors de l'utilisation intensive de  |
            X-Ref. Un RCLACTGRP XREF est alors possible pour "nettoyer" la      |
            mémoire.                                                            |
          - Touche F07 impossible pour les DTAARA. (Merci Véronique).           |
          - Obligation de créer une bibliothèque de chaque type dans la gestion |
            de la liste de bibliothèque lors de l'installation.                 |
          - Contrôle de l'existence d'une bibliothèque de chaque type en modifi-|
            cation de la liste de bibliothèque.                                 |
          - Ajout de la touche F24 pour accèder à la gestion des bibliothèques. |
          - Mise en place de la nouvelle commande Xref :                        |
             - Ajout d'une sortie fichier de l'analyse.                         |
             - Ajout de l'appel de Xref par fonction au niveau de la commande   |
             - Ajout Option "Mode" et "Sortie" : implémentation progressive des |
               différentes fonctionnalités.                                     |
             - Ajout de la fenêtre de gestion des analyses en mode fichier      |
             - Appel de la fenêtre d'analyse par la touche F23                  |
             - Type et bibliothèque de l'objet issus de la commande pris en     |
               compte                                                           |
          - Correction pbm affichage sur description de fichier                 |
          - Ajout de la description de fichier multi-format (PRTF, DSPF, etc...)|
            Merci à Delphine.                                                   |
          - Correction d'un bug sur la recherche de procédure                   |
================================================================================|
                             ?Septembre 2006                                    |
v1.3.4  : - Création index supplémentaire create index <curlib>/pgmref3 on      |
            <curlib>/pgmref (whobjt asc, whpnam asc)                            |
          - Ajout de la touche F05 pour resélectionner un composant à partir de |
            la dernière entrée au clavier.                                      |
          - Ajout du contrôle de la résolution d'écran pour eviter le plantage  |
            habituel.                                                           |
          - Modification de la gestion des bibliothèques et leur mise à jour.   |
            Correction pour la mise à jour des références techniques            |
          - Correction dans l'affichage des clés d'accès d'un LF multiple et a- |
            jout des informations SQL sur les lf sans DDS. Ajout Description.   |
          - Ajout de la touche F19 pour afficher les informations sur le compo- |
            sant. Fonctionnalitée à améliorer.                                  |
          - Fenêtres Aide, A propos et dernières modifications réunies en une   |
            seule fenêtre.                                                      |
          - Stabilisation générale de la gestion des tableaux. Les contrôles    |
            sont plus nombreux et il devrait y avoir moins de plantage.         |
          - Gestion des User Space plus propre (QRPLOBJ moins pollué)           |
          - Effacement du sous-fichier si pas de résultat.                      |
================================================================================|
                             ?Juin 2006                                         |
v1.3.3  : - Modifications de la structure ILE de X-Ref. Les anciens modules sont|
            inclus dans zz01. ZZ01X est le seul module ajouté : il contient la  |
            gestion avancée des modules.                                        |
          - ZZ01X : gestion de tableaux à 9.000.000.000 de postes.Utilisé lors  |
            de la recherche de caractère dans tous les sources (le nombre de    |
            source dépasse facilement les 38.000 sur certains systèmes :D ).    |
          - Optimisation de X-Ref si pgmref est volumineux :                    |
            CREATE INDEX  <curlib>/pgmref1 ON <curlib>/pgmref                   |
            (WHFNAM asc , WHOTYP asc )                                          |
            CREATE INDEX <curlib>/pgmref2 ON <curlib>/pgmref                    |
            (WHSPKG asc ,WHPNAM asc ,WHLIB asc )                                |
          - Ajout de la touche F12=Retour                                       |
                  ?Modifications antérieures supprimées...                      |
** ctdata
[F01]    Aide                                              *HELP
[F02]    XRef : DspPgmRef d'un programme                   *XREF
[F03]    Sortir
[F04]    Recherche par description                         *RECDESC
[F05]    Appel Plugin
[F06]    Lancement d'une requête                           *RUNQRY
[F07]    Description d'un fichier                          *DESCFILE
[F08]    Liste des logiques                                *LSTLF
[F09]    Rappel d'analyse
[F10]    Rappel d'analyse en avant
[F11]    Recherche module utilisant une procedure          *RECPROC
[F12]    Retour
[F13]    Impression du sous-fichier
[F14]    Where Used                                        *WHEREUSED
[F15]    Cartographie d'un programme                       *CARTOPGM
[F16]    Cartographie d'un source                          *CARTOSRC
[F17]    Rechercher une zone dans un fichier               *RECZONE
[F18]    Gestion des Spooles                               *WRKSPLF
[F19]    Description de l'objet                            *DESCOBJ
[F20]    Cartographie I.L.E.                               *CARTOILE
[F21]    Ligne de commande                                 *CMD
[F22]    Recherche de caractères                           *RECCAR
[F23]    Gestion des Analyses                              *ANALYSE
[F24]    Gestion des Bibliothèques                         *LIBRARY
** ctdata
123456789|123456789|123456789|123456789|123456789|123456789|
Objet     Description

Objet     Description


Zone      Description
Fichier    Biblio.  Zone      Format    Description





Objet     Description







Objet     Description


123456789|123456789|123456789|123456789|123456789|123456789|
   Accès          Format    Type        Biblio.    Niveau

Bibliothèque


 Type  Long. D   Deb    Fin  Nom Int.    Nom Alt.
                                Pf-Dta    Biblio.





   Accès          Format    Type        Biblio.    Niveau







  Biblio.     Pf-Src


