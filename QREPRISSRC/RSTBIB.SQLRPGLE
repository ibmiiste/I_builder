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

/Copy Qcpysrc,psds

Dcl-ds ds_Lots Extname('LOTS') Qualified End-ds;
Dcl-s i Packed(3:0) inz(0);
Dcl-s j Packed(3:0);
Dcl-s k Packed(3:0);
Dcl-s l_Cmd Char(1024);
Dcl-s Savf Char(10);
Dcl-s bibSavf Char(10);
Dcl-s Nombre Packed(3:0);
Dcl-s Odlbnm Char(10);
Dcl-s Odobnm Char(10);
Dcl-s Odobtp Char(10);
Dcl-s Odobat Char(10);
Dcl-s Ordre Packed(6:0);
Dcl-s Typ_Source Char(10);
dcl-s FormatName char(8);
dcl-s ObjectType char(10) inz('*ALL'); // Type d'objet
dcl-s NbrMbr packed(5);
dcl-s Nbr packed(5);
dcl-s SpaceAttr char(10) inz; // Attribut du User Spa
dcl-s SpaceAuth char(10) inz('*USE'); // Autorisation User Sp
dcl-s SpaceReplc char(10) inz('*YES'); // Remplacement du User
dcl-s SpaceText char(50) inz('User Space Temporaire'); // Libellé User Space
dcl-s SpaceValue char(1) inz(x'00'); // Valeur du User Space



Dcl-c Cobjd0200 const('OBJD0200'); // Description Objet

//---OBJD0400-----------------------------------------------------------**
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

//---Description d'un composant-----------------------------------------**
dcl-ds Composant; // Composant
  Obj char(10); // Objet
  Lib char(10); // Bibliothèque
end-ds;

//---Entête d'un User Space---------------------------------------------**
dcl-ds GenHeadDs based(puserspace);
  InputSize int(10) pos(113); // Taille de l'entête
  *n int(10) pos(117); // Offset de l'entête H
  *n int(10) pos(121); // Taille de l'entête H
  ListOffset int(10) pos(125); // Offset des données
  *n int(10) pos(129); // Taille de la liste L
  NumberList int(10) pos(133); // Nombre de données
  EntrySize int(10) pos(137); // Taille des données
end-ds;

//---Liste des Objets---------------------------------------------------**
dcl-ds DsList; // Liste d'objet
  DsListobj char(10); // Objet
  DsListLib char(10); // Bibliothèque
  DsListTyp char(10); // Type d'objet
end-ds;


dcl-s SpaceLen bindec(9) inz(1048576); // Longueur du User Spa
dcl-s StartPosit bindec(9); // Position dans le Use
dcl-s StartLen bindec(9); // Longueur dans le Use

//---User Space Générique-----------------------------------------------**
dcl-ds UserSpace;
  SpaceName char(10);
  SpaceLib char(10);
end-ds;

//---Recherche de l'adresse d'un User Space-----------------------------**
dcl-pr Qusptrus extpgm('QUSPTRUS');
  *n char(20); // parm
  *n pointer; // parm
end-pr;

//---Réception d'un User Space------------------------------------------**
dcl-pr Qusrtvus extpgm('QUSRTVUS');
  *n char(20); // parm
  *n bindec(9); // parm
  *n bindec(9); // parm
  *n char(2000) options(*varsize); // parm
end-pr;

//---Description d'un objet---------------------------------------------**
dcl-pr QusrObjd extpgm('QUSROBJD');
  *n char(32767) options(*varsize); // parm  Receiver Varia
  *n int(10) const; // parm  Length of Rece
  *n char(8) const; // parm  Format Name
  *n char(20) const; // parm  Object and Lib
  *n char(10) const; // parm  Object Type
  *n char(32767) options(*varsize); // parm  Api Error
end-pr;

//---Création d'un User Space-------------------------------------------**
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

//---Liste des objets---------------------------------------------------**
dcl-pr QUsLObj extpgm('QUSLOBJ');
  *n char(20); // parm
  *n char(8); // parm
  *n char(20); // parm
  *n char(10); // parm
end-pr;
// Positionnement en début de fichier

l_Cmd='DSPOBJD OBJ(ARCHIVELOT/*ALL) OBJTYPE(*FILE) OUTPUT(*OUTFILE) OUTFILE(QTEMP/DSPLOTS)';
cmd_exec(l_Cmd);

EXEC SQL
  CLOSE Curs_Savf;

EXEC SQL
  DECLARE Curs_Savf CURSOR FOR
    SELECT Odobtx,
           Odobnm,
           Odlbnm
      FROM Qtemp / Dsplots
      WHERE Odobnm LIKE 'S%';

EXEC SQL
  OPEN Curs_Savf;

EXEC SQL
  FETCH Curs_Savf INTO :Ds_Lots.Libellot, :Savf, :Bibsavf;

Dow Sqlcode = 0;
  // Création du lot
  Ordre=0;

  EXEC SQL
    INSERT INTO I_Builder.Lots(Libelle_Lots,
                               Liste_Biblio_Projet,
                               Description_Lots,
                               Statuts_Lot,
                               User_Creation,
                               User_Modification,
                               Statut_Enreg)
      VALUES (:Ds_Lots.Libellot, 'BASE', '', 'P', USER, USER, 1);

  EXEC SQL
    SELECT Lot_Number
      INTO :Ds_Lots.Numlot
      FROM I_Builder.Lots
      ORDER BY Lot_Number DESC
      FETCH FIRST 1 ROW ONLY;

  Ds_lots.BIBLOT= 'L' + %Editc(Ds_Lots.Numlot:'X');

  EXEC SQL
    UPDATE I_Builder.Lots SET Biblio_Lot = :Ds_Lots.Biblot WHERE Lot_Number = :Ds_Lots.Numlot;


  ds_Lots.LIBELLOT=%scanrpl('''':'''''':Ds_Lots.Libellot);
  l_Cmd='CRTLIB LIB(L' + %Editc(ds_Lots.Numlot:'X') + ') TYPE(*TEST) ' +
        'TEXT(''' + Ds_Lots.Libellot + ''')';

  cmd_exec(l_Cmd);

  Nombre=%Dec(%Subst(savf:8:3):3:0);

  If %Subst(savf:1:3) = 'SAV';
    L_cmd='RSTLIB SAVLIB(LOT_000' + %Editc(Nombre:'X') + ') ' +
           'DEV(*SAVF) ' +
           'SAVF(' + Bibsavf + '/' + savf + ') '  +
           'RSTLIB(L' + %Editc(ds_Lots.Numlot:'X') + ')';
  Else;
    l_cmd='RSTLIB SAVLIB(L000000' + %Editc(Nombre:'X') + ') ' +
           'DEV(*SAVF) ' +
           'SAVF(' + Bibsavf + '/' + savf + ') '  +
           'RSTLIB(L' + %Editc(ds_Lots.Numlot:'X') + ')';
  ENDIF;

  MONITOR;
    cmd_exec(l_Cmd);
  On-error;
  Endmon;

  l_Cmd='DSPOBJD OBJ(L' + %Editc(ds_Lots.Numlot:'X') + '/*ALL) ' +
        'OBJTYPE(*ALL) ' +
        'OUTPUT(*OUTFILE) ' +
        'OUTFILE(QTEMP/DSPOBJD)';

  MONITOR;
    cmd_exec(l_Cmd);
  On-error;
  Endmon;


  EXEC SQL
    CLOSE Curs_Objd1;

  EXEC SQL
    DECLARE Curs_Objd1 CURSOR FOR
      SELECT Odlbnm,
             Odobnm,
             Odobtp,
             Odobat
        FROM Qtemp / Dspobjd
        WHERE Odobat = 'PF';

  EXEC SQL
    OPEN Curs_Objd1;

  EXEC SQL
    FETCH Curs_Objd1 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat ;

  Dow sqlcode = 0;
    Exsr lecture;
    EXEC SQL
      FETCH Curs_Objd1 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat ;
  ENDDO;

  EXEC SQL
    CLOSE Curs_Objd1;

  EXEC SQL
    CLOSE Curs_Objd2;

  EXEC SQL
    DECLARE Curs_Objd2 CURSOR FOR
      SELECT Odlbnm,
             Odobnm,
             Odobtp,
             Odobat
        FROM Qtemp / Dspobjd
        WHERE Odobat = 'LF';

  EXEC SQL
    OPEN Curs_Objd2;

  EXEC SQL
    FETCH Curs_Objd2 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat ;

  Dow sqlcode = 0;
    Exsr lecture;
    EXEC SQL
      FETCH Curs_Objd2 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat ;
  ENDDO;

  EXEC SQL
    CLOSE Curs_Objd3;

  EXEC SQL
    DECLARE Curs_Objd3 CURSOR FOR
      SELECT Odlbnm,
             Odobnm,
             Odobtp,
             Odobat
        FROM Qtemp / Dspobjd
        WHERE Odobat = 'DSPF';

  EXEC SQL
    OPEN Curs_Objd3;

  EXEC SQL
    FETCH Curs_Objd3 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;

  Dow sqlcode = 0;
    Exsr lecture;
    EXEC SQL
      FETCH Curs_Objd3 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;
  ENDDO;

  EXEC SQL
    CLOSE Curs_Objd4;

  EXEC SQL
    DECLARE Curs_Objd4 CURSOR FOR
      SELECT Odlbnm,
             Odobnm,
             Odobtp,
             Odobat
        FROM Qtemp / Dspobjd
        WHERE Odobat = 'PRTF';

  EXEC SQL
    OPEN Curs_Objd4;

  EXEC SQL
    FETCH Curs_Obj4d INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;

  Dow sqlcode = 0;
    Exsr lecture;
    EXEC SQL
      FETCH Curs_Objd4 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;
  ENDDO;

  EXEC SQL
    CLOSE Curs_Objd5;

  EXEC SQL
    DECLARE Curs_Objd5 CURSOR FOR
      SELECT Odlbnm,
             Odobnm,
             Odobtp,
             Odobat
        FROM Qtemp / Dspobjd
        WHERE Odobtp = '*MODULE';

  EXEC SQL
    OPEN Curs_Objd5;

  EXEC SQL
    FETCH Curs_Objd5 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;

  Dow sqlcode = 0;
    Exsr lecture;
    EXEC SQL
      FETCH Curs_Objd5 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;
  ENDDO;

  EXEC SQL
    CLOSE Curs_Objd6;

  EXEC SQL
    DECLARE Curs_Objd6 CURSOR FOR
      SELECT Odlbnm,
             Odobnm,
             Odobtp,
             Odobat
        FROM Qtemp / Dspobjd
        WHERE Odobtp = '*SRVPGM';

  EXEC SQL
    OPEN Curs_Objd6;

  EXEC SQL
    FETCH Curs_Objd6 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;

  Dow sqlcode = 0;
    Exsr lecture;
    EXEC SQL
      FETCH Curs_Objd6 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;
  ENDDO;

  EXEC SQL
    CLOSE Curs_Objd7;

  EXEC SQL
    DECLARE Curs_Objd7 CURSOR FOR
      SELECT Odlbnm,
             Odobnm,
             Odobtp,
             Odobat
        FROM Qtemp / Dspobjd
        WHERE Odobtp = '*PGM';

  EXEC SQL
    OPEN Curs_Objd7;

  EXEC SQL
    FETCH Curs_Objd7 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;

  Dow sqlcode = 0;
    Exsr lecture;
    EXEC SQL
      FETCH Curs_Objd7 INTO :Odlbnm, :Odobnm, :Odobtp, :Odobat;
  ENDDO;

  EXEC SQL
    FETCH Curs_Savf INTO :Ds_Lots.Libellot, :Savf, :Bibsavf;
ENDDO;

*Inlr= *On;
Return;

Begsr lecture;
  If Odobnm<>'EVFEVENT'
  And Odobnm<>'EVFTEMPF01'
  And %Subst(Odobnm:1:1) <>'Q';
    //---Create User Space List Fichier------------------------------------//
    SpaceName = 'USERSPACE';
    SpaceLib = 'QTEMP';
    QUsCrtUs(UserSpace:SpaceAttr:SpaceLen:SpaceValue:
             SpaceAuth:SpaceText:SpaceReplc:ApiError);

    //---Liste des objets avec le nom ObjNam-------------------------------//
    Obj = Odobnm;
    Lib = '*ALL';
    ObjectType = Odobtp;
    SpaceName = 'USERSPACE';
    SpaceLib = 'QTEMP';
    FormatName = 'OBJL0100';
    QUslObj(UserSpace:FormatName:Composant:ObjectType);

    //---Retrieve user space General information---------------------------//
    StartPosit = 1;
    StartLen = 1024;
    SpaceName = 'USERSPACE';
    SpaceLib = 'QTEMP';
    QUsPtrUs(UserSpace:pUserSpace);
    QUsRtvUs(UserSpace:StartPosit:StartLen:GenHeadDs);

    //---Retrieve user space Detail information----------------------------//
    StartPosit = ListOffset + 1;
    StartLen = EntrySize;
    NbrMbr = NumberList;

    For Nbr = 1 To NbrMbr;
      SpaceName = 'USERSPACE';
      SpaceLib = 'QTEMP';
      QUsRtvUs(UserSpace:StartPosit:StartLen:DsList);
      StartPosit = StartPosit + StartLen;

      If ( Dslistlib = 'BFBASE'
      OR  Dslistlib = 'BFMIR'
      OR  Dslistlib = 'BF750'
      OR  Dslistlib = 'BFAMM'
      OR  Dslistlib = 'BPPLA'
      OR  Dslistlib = 'BP400'
      OR  Dslistlib = 'BPMIR'
      OR  Dslistlib = 'BP750'
      OR  Dslistlib = 'BPAMM'
      OR  Dslistlib = 'BPPGM'
      OR  Dslistlib = 'BERGER'
      OR  Dslistlib = 'I_BUILDER');
        QusrObjd(Objd0400:%size(Objd0400):Cobjd0200:
              Dslistobj + Dslistlib:Dslisttyp:ApiError);



        l_cmd='DSPFD FILE(' + %Trim(Odobjsrclib) + '/' + %Trim(Odobjsrcfil) + ') ' +
              'OUTPUT(*OUTFILE) ' +
              'TYPE(*MBRLIST) ' +
              'OUTFILE(QTEMP/DSPMBRSRC) ';

        MONITOR;
          cmd_exec(l_Cmd);
        On-error;
        Endmon;

        EXEC SQL
          SELECT Mlseu2
            INTO :Typ_Source
            FROM Qtemp / Dspmbrsrc
            WHERE Mllib = :Odobjsrclib
                  AND Mlfile = :Odobjsrcfil
                  AND Mlname = :Odobjsrcmbr;


        Ordre+=10;

        EXEC SQL
          INSERT INTO I_Builder.Lstobjbld(Lot_Number,
                                          Ordre,
                                          Bibliotheque_Source,
                                          Fichier_Source,
                                          Membre_Source,
                                          Type_Source,
                                          Bibliotheque_Destination,
                                          Objet_Destination,
                                          Type_Objet,
                                          Attribut_Objet,
                                          User_Creation,
                                          User_Modification)
            VALUES (:Ds_Lots.Numlot,
                    :Ordre,
                    :Odobjsrclib,
                    :Odobjsrcfil,
                    :Odobjsrcmbr,
                    :Typ_Source,
                    :Odobjlib,
                    :Odobjnam,
                    :Odobjtyprt,
                    :Odobjextatt,
                    USER,
                    USER);
      Endif;

    EndFor;

  Endif;

Endsr;

