      *
      *  Program SAVUSROBJ:  Save User Objects. Saves the objects that
      *                      have been entered into the SAVINFO file.
      *                      The objects are grouped by library and
      *                      saved together. That is, objects in the same
      *                      library are all saved together using a single
      *                      save operation and a single tape label (up to
      *                      the maximum of 1600 objects in a single save
      *                      operation). If file SAVINFO contains more
      *                      than 1600 objects for a single library,
      *                      objects are saved 1600 at a time until all
      *                      objects have been saved.
      *
      *                      User space SAVUSROBJ must already exist in
      *                      QTEMP. Note, it would be more efficient to
      *                      base data structure UsrSpc on a pointer set
      *                      to point to the actual user space object with
      *                      the QUSPTRUS API. This would also allow the
      *                      ObjArr array to be expanded to 32,767 elements.
      *                      The following method simplifies the code,
      *                      especially the initialization code (ie, the
      *                      INZ keyword cannot be used in a based-on
      *                      data structure).
      *

     FSAVINFO   IF   E           K DISK


     D cUsrSpcNam      C                   Const('SAVUSROBJ QTEMP     ')


      *  Data structure for user space (note, 4-byte binary fields must
      *  be defined as 9.0 in RPG). Lx = record length, Kx = Key,
      *  LPx = Length of key-specific Parameter data.

     D UsrSpc          DS

      *     #Keys = the number of records that follow.
     D   #Keys                        9b 0 Inz(4)

      *     Library info record.
     D   L1                           9b 0 Inz(26)
     D   K1                           9b 0 Inz(2)
     D   LP1                          9b 0 Inz(14)
     D   #Libs                        9b 0 Inz(1)
     D   LibName                     10

      *     Tape device record.
     D   L2                           9b 0 Inz(26)
     D   K2                           9b 0 Inz(3)
     D   LP2                          9b 0 Inz(14)
     D   #Devs                        9b 0 Inz(1)
     D   DevName                     10    Inz('TAP01')

      *     End-of-tape option record.
     D   L3                           9b 0 Inz(13)
     D   K3                           9b 0 Inz(10)
     D   LP3                          9b 0 Inz(1)
     D   EndTapeOpt                   1    Inz('1')

      *     Object info record (length not known).
     D   L4                           9b 0
     D   K4                           9b 0 Inz(1)
     D   LP4                          9b 0
     D   #Objs                        9b 0
     D   ObjArr                      20    dim(1600)

      * ----------  End of UsrSpc data structure  ------------


     D Max#Objs        S              9b 0 Inz(%Elem(ObjArr))

      *  The following data structure is used to overlay the
      *  object array in UsrSpc (ObjArr) with the object name
      *  and object type in the proper format.
     D ObjDS           DS
     D   SIOBJ
     D   SITYP

     D LenUsrSpc       S              9b 0
     D StartPos        S              9b 0 Inz(1)


     c                   read      SAVINFO                                lr
     c     *inlr         DoWEq     '0'

     c                   MoveL     *Zeros        #Objs
     c                   MoveL     SILIB         LibName

      *  Fill up ObjArr array.
     c     SILIB         DoWEq     LibName
     c     #Objs         AndLT     Max#Objs
     c     *inlr         AndEq     '0'
     c                   Add       1             #Objs
     c                   MoveL     ObjDS         ObjArr(#Objs)
     c                   read      SAVINFO                                lr
     c                   EndDo

      *  Rewind tape if last save ('0' = rewind).
     c     *inlr         IfEq      '1'
     c                   MoveL     '0'           EndTapeOpt
     c                   EndIf

      *  Set the len of the var-len record (L4) and the len of
      *  parm data (LP4) for the Object Information record.
     c                   Eval      LP4 = (#Objs * 20) + 4
     c                   Eval      L4 = LP4 + 12

      *  Set the len of data in data structure.
     c                   Eval      LenUsrSpc = L1 + L2 + L3 + L4 + 4

      *  Write it to the user space.
     c                   call      'QUSCHGUS'
     c                   parm      cUsrSpcNam    UsrSpcName       20
     c                   parm                    StartPos
     c                   parm                    LenUsrSpc
     c                   parm                    UsrSpc
     c                   parm      '0'           Force2Aux         1

      *  Call the QSRSAVO API to perform save.
     c                   call      'QSRSAVO'
     c                   parm      cUsrSpcNam    UsrSpcName       20
     c                   parm      x'00000000'   ResigError        4

      *  Do next library.
     c                   EndDo


     c                   Return
