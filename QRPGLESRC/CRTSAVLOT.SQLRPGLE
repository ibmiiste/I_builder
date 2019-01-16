**Free
/copy qcpysrc,cpyctlstm
//
//  Program SAVUSROBJ:  Save User Objects. Saves the objects that
//                      have been entered into the SAVINFO file.
//                      The objects are grouped by library and
//                      saved together. That is, objects in the same
//                      library are all saved together using a single
//                      save operation and a single tape label (up to
//                      the maximum of 1600 objects in a single save
//                      operation). If file SAVINFO contains more
//                      than 1600 objects for a single library,
//                      objects are saved 1600 at a time until all
//                      objects have been saved.
//
//                      User space SAVUSROBJ must already exist in
//                      QTEMP. Note, it would be more efficient to
//                      base data structure UsrSpc on a pointer set
//                      to point to the actual user space object with
//                      the QUSPTRUS API. This would also allow the
//                      ObjArr array to be expanded to 32,767 elements.
//                      The following method simplifies the code,
//                      especially the initialization code (ie, the
//                      INZ keyword cannot be used in a based-on
//                      data structure).
//
/Copy Qcpysrc,Prtbuilder

Dcl-proc Sauv_obj_lot Export;
  Dcl-pi Sauv_obj_lot;
    p_Num_lot Packed(9:0);
  END-PI;

  // API de changement d'attribut d'un user space
  dcl-pr ChgUsrSpcA extpgm('QUSCUSAT');
    *n char(10); // RtnUsrSpcLib
    *n char(20) const; // QualUsrSpcN
    *n char(1) const options(*varsize); // UsrSpcAttrs
    *n likeds(qusec); // ErrCde
  end-pr;

  // API Create User Space (QUSCRTUS)
  dcl-pr CrtUsrSpc extpgm('QUSCRTUS');
    *n char(20) const; // QualUsrSpcN
    *n char(10) const; // XAttr
    *n int(10) const; // IntSize
    *n char(1) const; // IntValue
    *n char(10) const; // PubAut
    *n char(50) const; // TxtDesc
    *n char(10) const options(*nopass); // ReplaceOpt
    *n likeds(qusec) options(*nopass); // ErrCde
    *n char(10) const options(*nopass); // Domain
    *n int(10) const options(*nopass); // TfrSize
    *n char(1) const options(*nopass); // OptSpcAlgn
  end-pr;

  // API Change User Space (QUSCHGUS)
  Dcl-pr Creation_usr_space Extpgm('QUSCHGUS');
    UsrSpcName Char(20) Const;
    StartPos Int(10) Const;
    LenUsrSpc Int(10) Const;
    UsrSpc Char(1000000) Const Options(*VarSize);
    Force2Aux Char(1);
    Error Like(ApiError);
  END-PR;

  // Sauvegarde des objets
  Dcl-pr Sauve_objets Extpgm('QSRSAVO');
    UsrSpcName Char(20) Const;
    Error Like(ApiError);
  END-PR;

  dcl-c cUsrSpcNam const('SAVUSROBJ QTEMP     ');


  //  Data structure for user space (note, 4-byte binary fields must
  //  be defined as 9.0 in RPG). Lx = record length, Kx = Key,
  //  LPx = Length of key-specific Parameter data.


  //     $Keys = the number of records that follow.
  dcl-ds UsrSpc;

    //     Library info record.
    $Keys bindec(9) inz(4);
    L1 bindec(9) inz(26);
    K1 bindec(9) inz(2);
    LP1 bindec(9) inz(14);
    $Libs bindec(9) inz(1);

    //     Tape device record.
    LibName char(10);
    L2 bindec(9) inz(26);
    K2 bindec(9) inz(4);
    LP2 bindec(9) inz(14);
    $Devs bindec(9) inz(1);

    //     End-of-tape option record.
    DevName char(10) inz('TAP01');
    L3 bindec(9) inz(13);
    K3 bindec(9) inz(10);
    LP3 bindec(9) inz(1);

    //     Object info record (length not known).
    EndTapeOpt char(1) inz('1');
    L4 bindec(9);
    K4 bindec(9) inz(1);
    LP4 bindec(9);
    $Objs bindec(9);
    ObjArr char(20) dim(1600);
  end-ds;

  // ----------  End of UsrSpc data structure  ------------


  dcl-s Max$Objs bindec(9) inz(%elem(objarr));

  //  The following data structure is used to overlay the
  //  object array in UsrSpc (ObjArr) with the object name
  //  and object type in the proper format.
  Dcl-ds ObjDS;
    SIOBJ;
    SITYP;
  End-ds;

  Dcl-s LenUsrSpc bindec(9);
  Dcl-s StartPos bindec(9) inz(1);

  EXEC SQL
    DECLARE List_Obj CURSOR FOR
      SELECT Bibdst,
             Objdst,
             Typobj
        FROM List_Objet_Build
        WHERE Lot_Number = :P_Num_Lot
        ORDER BY Ordre;


  EXEC SQL
    OPEN List_Obj;

  $Objs=*Zeros;
  EXEC SQL
    FETCH List_Obj INTO :Libname, :Siobj,:Sityp;
  DOW Sqlcode = c_Trouve
  And $Objs < Max$Objs;
    $Objs+=1;
    ObjArr($Objs)=ObjDS;
    EXEC SQL
      FETCH List_Obj INTO :Libname, :Siobj,:Sityp;
  EndDo;

  //  Set the len of the var-len record (L4) and the len of
  //  parm data (LP4) for the Object Information record.
  LP4 = ($Objs * 20) + 4;
  L4 = LP4 + 12;

  //  Set the len of data in data structure.
  LenUsrSpc = L1 + L2 + L3 + L4 + 4;

  //  Write it to the user space.

  Creation_usr_space( cUsrSpcNam
                     :StartPos
                     :LenUsrSpc
                     :UsrSpc
                     :Force2Aux
                     :ApiError);

  //  Call the QSRSAVO API to perform save.
  Sauve_objets( cUsrSpcNam
               :Apierror);

  Return;
End-proc;
