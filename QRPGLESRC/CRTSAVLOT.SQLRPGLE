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

       Dcl-pr Creation_usr_space Extpgm('QUSCHGUS');
         UsrSpcName Char(20) Const;
         StartPos Int(10) Const;
         LenUsrSpc Int(10) Const;
         UsrSpc Char(1000000) Const Options(*VarSize);
         Force2Aux Char(1);
         Error Like(ApiError)
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
        K2 bindec(9) inz(3);
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
       dcl-ds ObjDS;
        SIOBJ;
        SITYP;
       end-ds;

       dcl-s LenUsrSpc bindec(9);
       dcl-s StartPos bindec(9) inz(1);


       Exec sql
         DECLARE List_obj CURSOR FOR
           Select ORDRE,
                  BIBDST,
                  OBJDST,
                  TYPOBJ
             From LIST_OBJET_BUILD
             Where LOT_NUMBER = :p_Num_lot;



       DOW *inlr = '0';


       $Objs=*Zeros;
       LibName=SILIB;

      //  Fill up ObjArr array.
         Dow SILIB = LibName
         AND $Objs < Max$Objs
         AND *inlr = '0';
           $Objs+=1;
           ObjArr($Objs)=ObjDS;
           read SAVINFO;
           *INlr = %EOF;
         EndDo;

         //  Rewind tape if last save ('0' = rewind).
         IF *inlr = '1';
           EndTapeOpt='0';
         EndIf;

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
                            :Force2Aux);         1

      //  Call the QSRSAVO API to perform save.
     c                   call      'QSRSAVO'
     c                   parm      cUsrSpcNam    UsrSpcName       20
     c                   parm      x'00000000'   ResigError        4

      //  Do next library.
      /FREE
       EndDo;


       Return;
      /END-FREE
