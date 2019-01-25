       Dcl-s r_ccsid char(10) Template;
       Dcl-s r_chemin char(256) Template;
       Dcl-s r_commande_CLLE char(1024) Template;
       Dcl-s r_data_message char(20) Template;
       Dcl-s r_Lib_lot char( 50) Template;
       Dcl-s r_longueur_CMD_CLLE packed(15:5) Template;
       Dcl-s r_msgdta char(99) Template;
       Dcl-s r_Nom_obj_IBMi Char(10) Template;
       Dcl-s r_Nom_travail Char(10) Template;
       Dcl-s r_nblign packed(4:0) Template;
       Dcl-s r_Num_lot Packed(9:0) Template;
       Dcl-s r_Num_lot_carac Char(9) Template;
       Dcl-s r_Numero_msg char(7) Template;
       Dcl-s r_Prefix Char(1) Template;
       Dcl-s r_profil char(10) Template;
       Dcl-s r_qualified_name Char(20) Template;
       Dcl-s r_typmsg char(1) Template;
       Dcl-s R_TypObj Char(10) Template;

             // OBJD0100 Format
       Dcl-ds OBJD0100_t qualified template;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         Name char(10);                 // Object name
         Lib char(10);                  // Object library name
         Type char(10);                 // Object type
         RtnLib char(10);               // Return library
         ASPNbr int(10);                // Object ASP number
         Owner char(10);                // Object owner
         Dommain char(2);               // Object domain
         CrtDte char(13);               // Creation date and t
         ChgDte char(13);               // Object change date
       end-ds;

       Dcl-ds OBJD0200_t qualified template;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         Name char(10);                 // Object name
         Lib char(10);                  // Object library name
         Type char(10);                 // Object type
         RtnLib char(10);               // Return library
         ASPNbr int(10);                // Object ASP number
         Owner char(10);                // Object owner
         Dommain char(2);               // Object domain
         CrtDte char(13);               // Creation date and t
         ChgDte char(13);               // Object change date
         Atr char(10);                  // Extended object att
         Txt char(50);                  // Text description
         SrcF char(10);                 // Source file name
         SRCL char(10);                 // Source file library
         SRCM char(10);                 // Source file member
       end-ds;

       Dcl-ds OBJD0300_t qualified template;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         Name char(10);                 // Object name
         Lib char(10);                  // Object library name
         Type char(10);                 // Object type
         RtnLib char(10);               // Return library
         ASPNbr int(10);                // Object ASP number
         Owner char(10);                // Object owner
         Dommain char(2);               // Object domain
         CrtDte char(13);               // Creation date and t
         ChgDte char(13);               // Object change date
         Atr char(10);                  // Extended object att
         Txt char(50);                  // Text description
         SrcF char(10);                 // Source file name
         SRCL char(10);                 // Source file library
         SRCM char(10);                 // Source file member
         SrcUpd char(13);               // Source file updated
         SveDte char(13);               // Object saved date a
         RstDte char(13);               // Object restored dat
         CrtUsr char(10);               // Creator's user prof
         filler char(8);                // System where object
         RzDte char(7);                 // Reset date
         SavSz int(10);                 // Save size
         SavSeq int(10);                // Save sequence numbe
         SavSto char(10);               // Storage
         SavCmd char(10);               // Save command
         SavVid char(71);               // Save volume ID
         SavDev char(10);               // Save device
         SavFnm char(10);               // Save file name
         SavFLb char(10);               // Save file library n
         SavLbl char(17);               // Save label
         SysLvl char(9);                // System level
         Compiler char(16);             // Compiler
         ObjLvl char(8);                // Object level
         UsrChgd char(1);               // User changed
         LicPgm char(16);               // Licensed program
         Ptf char(10);                  // Program temporary f
         AApar char(10);                // Authorized program
       end-ds;

        //          OBJD0400 -----------
       Dcl-ds OBJD0400_t qualified template;
         RtnSize int(10);               // Bytes returned
         AvlSize int(10);               // Bytes available
         Name char(10);                 // Object name
         Lib char(10);                  // Object library name
         Type char(10);                 // Object type
         RtnLib char(10);               // Return library
         ASPNbr int(10);                // Object ASP number
         Owner char(10);                // Object owner
         Dommain char(2);               // Object domain
         CrtDte char(13);               // Creation date and t
         ChgDte char(13);               // Object change date
         Atr char(10);                  // Extended object att
         Txt char(50);                  // Text description
         SrcF char(10);                 // Source file name
         SRCL char(10);                 // Source file library
         SRCM char(10);                 // Source file member
         SrcUpd char(13);               // Source file updated
         SveDte char(13);               // Object saved date a
         RstDte char(13);               // Object restored dat
         CrtUsr  char(10);              // Creator's user prof
         filler char(8);                // System where object
         RzDte char(7);                 // Reset date
         SavSz int(10);                 // Save size
         SavSeq int(10);                // Save sequence numbe
         SavSto char(10);               // Storage
         SavCmd char(10);               // Save command
         SavVid char(71);               // Save volume ID
         SavDev char(10);               // Save device
         SavFnm char(10);               // Save file name
         SavFLb char(10);               // Save file library n
         SavLbl char(17);               // Save label
         SysLvl char(9);                // System level
         Compiler char(16);             // Compiler
         ObjLvl char(8);                // Object level
         UsrChgd char(1);               // User changed
         LicPgm char(16);               // Licensed program
         Ptf char(10);                  // Program temporary f
         AApar char(10);                // Authorized program
         UseDte char(7);                // Last-used date
         UseInfUpd char(1);             // Usage information u
         DayCnt int(10);                // Days-used count
         ObjSz int(10);                 // Object size
         OBjMul int(10);                // Object size multipl
         Compress char(1);              // Object compression
         PgmChgAlw char(1);             // Allow change by pro
         ChdPgm char(1);                // Changed by program
         UsrAtt char(10);               // User-defined attrib
         OflAsp char(1);                // Object overflowed A
         ActSavDte char(13);            // Save active date an
         AudVlu char(10);               // Object auditing val
         PriGrp char(10);               // Primary group
         JrnSts char(1);                //  Journal status
         JrnNm char(10);                // Journal name
         JrnLib char(10);               // Journal library nam
         JrnImg char(1);                // Journal images
         JrnOmit char(1);               // Journal entries to
         JrnStrDte char(13);            // Journal start date
         DgtSig char(1);                // Digitally signed
         SavUntSiz int(10);             // Saved size in units
         SavUntMul int(10);             // Saved size multipli
         AspLibNbr int(10);             // Library ASP number
         AspDevNm  char(10);            // Object ASP device n
         AspLibNm char(10);             // Library ASP device
         DgtTrust char(1);              // Digitally signed by
         dgtMost char(1);               //
       end-ds;

      // Prototype retour erreur API
       Dcl-ds ApiError qualified Template;
         BytesProv int(10) inz(%len(ApiError));  // Bytes provided
         BytesAvail int(10);                     // Bytes available
         MsgID char(7);                          // Exception ID
         Reserved char(1);                       // Reserved  data
         MessageData char(32767);                //  Exception data
       end-ds;
