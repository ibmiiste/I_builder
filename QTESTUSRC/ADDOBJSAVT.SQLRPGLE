**FREE
      //=====================================================================//
      //  Empty Unit Test Case. Prints a protocol of the execution flow.     //
      //=====================================================================//
      //  Command to create the service program:                             //
      //=====================================================================//
      //  Tools/400 STRPREPRC instructions:                                  //
      //   >>PRE-COMPILER<<                                                  //
      //     >>CRTCMD<<  RUCRTTST    TSTPGM(&LI/&OB) +                       //
      //                             SRCFILE(&SL/&SF);                       //
      //     >>COMPILE<<                                                     //
      //       >>PARM<< COPTION(*SRCSTMT);                                   //
      //       >>PARM<< DBGVIEW(*LIST);                                      //
      //     >>END-COMPILE<<                                                 //
      //     >>EXECUTE<<                                                     //
      //   >>END-PRE-COMPILER<<                                              //
      //=====================================================================//
      ctl-opt nomain option(*srcstmt) bnddir('I_BUILDER');
      dcl-f QSYSPRT printer(80) usropn oflind(*in70);

      /copy RPGUNIT1,TESTCASE

      Dcl-s g_Num_lot Packed(9:0) Inz(58);

      // ============================================================
      //  Sauvegarde des ovbjets dans une SAVF
      // ============================================================
      Dcl-pr Sauv_obj_lot;
        p_Num_lot Packed(9:0) value;
      END-Pr;


      // ============================================================
      //  Opens the printer.
      // ============================================================
      dcl-proc openPrinter export;
        dcl-pi *n end-pi;

        open QSYSPRT;

      end-proc;

      // ============================================================
      //  Prints a message.
      // ============================================================
      dcl-proc print export;
        dcl-pi *n;
          text varchar(128) value  options(*nopass);
        end-pi;

        dcl-ds lineOutput len(80) inz end-ds;

        if (%parms() >= 1);
          lineOutput = text;
        else;
          lineOutput = '';
        endif;
        write QSYSPRT lineOutput;

      end-proc;

      // ============================================================
      //  Closes the printer.
      // ============================================================
      dcl-proc closePrinter export;
        dcl-pi *n end-pi;

        if (%open(QSYSPRT));
          close QSYSPRT;
        endif;

      end-proc;

      // ============================================================
      //  Set up test suite. Executed once per RUCALLTST.
      // ============================================================
      dcl-proc setUpSuite export;
        dcl-pi *n end-pi;

        dcl-s rc char(1);
        Dcl-s CMD Char(1000);
        Monitor;
          Cmd='CRTSAVF FILE(L' + %Editc(g_Num_lot:'X') + '/S' +
                      %Editc(g_Num_lot:'X') +
                   ') TEXT(''Sauvegarde du lot 3'')';
          runCmd(Cmd);
        On-error;
        Endmon;

        monitor;
          openPrinter();
          print('Executing:   setUpSuite()');
        on-error;
        // ignore errors ...
        endmon;

        // ... but try to remove the override.
        monitor;
          runCmd('DLTOVR FILE(QSYSPRT) LVL(*JOB)');
        on-error;
          dsply '*** Failed to delete QSYSPRT override! ***' rc;
        endmon;

      end-proc;

      // ============================================================
      //  Tear down test suite.
      // ============================================================
      dcl-proc tearDownSuite export;
        dcl-pi *n end-pi;

        Dcl-s CMD Char(1000);

        Monitor;
          Cmd='DLTOBJ L' + %Editc(g_Num_lot:'X') + '/S' +
                      %Editc(g_Num_lot:'X') + ' OBJTYPE(*FILE)';
          runCmd(Cmd);
        On-error;
        Endmon;

        print('Executing:   tearDownSuite()');
        closePrinter();

      end-proc;

      // ============================================================
      //  Set up test case.
      // ============================================================
      dcl-proc setUp export;
        dcl-pi *n end-pi;

        print('Executing:   - setUp()');

      end-proc;

      // ============================================================
      //  Tear down test case.
      // ============================================================
      dcl-proc tearDown export;
        dcl-pi *n end-pi;

        print('Executing:   - tearDown()');

      end-proc;

      // ============================================================
      //  RPGUnit test case.
      // ============================================================
      dcl-proc Test_sauv_lot export;
        dcl-pi *n end-pi;

        Dcl-s L_Objdst Char(10);
        Dcl-s L_Typobj char(10);

        //Constantes
        Dcl-c c_Trouve 0;


        Sauv_obj_lot(g_Num_lot);

        EXEC SQL
          CLOSE Csr_Obj_Sav;

        EXEC SQL
          DECLARE Csr_Obj_Sav CURSOR FOR
            SELECT Objet_Destination,
                   Type_Objet
              FROM List_Objet_Build
              WHERE Lot_Number = :G_Num_Lot
              ORDER BY Ordre;

        EXEC SQL
          OPEN Csr_Obj_Sav;

        // Lecture des objets du lot à livrer
        EXEC SQL
          FETCH Csr_Obj_Sav INTO :L_Objdst, :L_Typobj;

        Dow Sqlcode=c_Trouve;
          Aequal( L_Objdst:Verif_SAVF( 'L' + %Editc(g_Num_lot:'X')
                                      :'S' + %Editc(g_Num_lot:'X')
                                      :L_Objdst));

          EXEC SQL
          FETCH Csr_Obj_Sav INTO :L_Objdst, :L_Typobj;
        Enddo;

        print('Executing:       * Test_sauv_lot()');

      // Place your assertions here.

      end-proc;

      // --------------------------------------------------
      // Procedure name: Verif_SAVF
      // Purpose:        Récupérer la liste des objets d'une SAVF
      // Returns:
      // Parameter:      p_Bib_SAVF => Bibliothèque de la SAVF
      // Parameter:      p_Nom_SAVF => Nom de la SAVF
      // --------------------------------------------------
      DCL-PROC Verif_SAVF ;
        DCL-PI *N Char(10);
          p_Bib_SAVF CHAR(10) VALUE;
          p_Nom_SAVF CHAR(10) VALUE;
          p_Nom_obj Char(10) Value;
        END-PI ;
        //-----------------------------------------------------
        // API error code data structure
        //-----------------------------------------------------
        dcl-ds MyErrCode;
          BytesProv int(10) inz(%size(myerrcode));
          BytesAvail int(10) inz(0);
          MsgID char(7);
          Reserved char(1);
          MessageData char(1000);
        end-ds;

        //-----------------------------------------------------
        // Userspace variable
        //-----------------------------------------------------
        // ---User Space Générique-----------------------------
        dcl-ds UserSpace;
          SpaceName char(10);
          SpaceLib char(10);
        end-ds;

        // Paramètres conception User Space
        // Attribut du User Space
        dcl-s SpaceAttr char(10) inz;
        // Longueur du User Spa
        dcl-s SpaceLen bindec(9) inz(262144);
        // Valeur du User Space
        dcl-s SpaceValue char(1) inz(x'00');
        // Autorisation User Space
        dcl-s SpaceAuth char(10) inz('*USE');
        // Libellé User Space
        dcl-s SpaceText char(50);
        // Remplacement du User Space
        dcl-s SpaceReplc char(10) inz('*YES');

        // Paramètres API liste objets
        dcl-s FormatName char(8);

        //--Description d'un composant-------------------------
        dcl-ds Composant; // Composant
          Obj char(10); // Objet
          Lib char(10); // Bibliothèque
        end-ds;

        // Type d'objet
        dcl-s ObjectType char(10) inz('*ALL');

        //-----------------------------------------------------
        // Format de l'en-tête générique
        //
        // Il existe de nombreuses infos dans l'en-tête
        // générique mais tout ce qui m'intéresse sont les
        // offsets dont j'ai besoin pour accéder à liste
        // proprement dite.
        //-----------------------------------------------------
        dcl-s p_ListHeader pointer;
        dcl-ds ListHeader based(p_listheader);
          DataOffset int(10) pos(125);
          NumEntries int(10) pos(133);
          EntrySize int(10) pos(137);
        end-ds;

        //-----------------------------------------------------
        // API error code data structure
        //-----------------------------------------------------
        dcl-pr QUsLObj extpgm('QSRLSAVF');
          UserSpace char(20); // Qualified user space object
          Format_name char(8); // Format
          Qualified_save_file_name char(20); // Object and library name
          Object_name_filter Char(10);
          Object_type_filter char(10); // Object type filter
          Continuation_handle Char(36);
          // optional group 1:
          ErrorCode Char(8000) options(*varsize: *nopass);
        end-pr;

        // Cette DS correspond au format
        // SAVF0200  de l'API QSRLSAVF.
        dcl-s p_ListEntry pointer;
        dcl-ds SAVF0200 based(p_listentry);
          Object_name Char(10);
          Library_saved Char(10);
          Object_type Char(10);
          Extended_object_attribute Char(10);
          Save_date_and_time Char(8);
          Object_size Int(10);
          Object_size_multiplier Int(10);
          Auxiliary_storage_pool Int(10);
          Data_saved Char(1);
          Object_owner Char(10);
          Document_library_object_DLO_name Char(20);
          Folder Char(63);
          Text_description Char(50);
          Auxiliary_storage_pool_device_name Char(10);
        End-ds;

        //-----------------------------------------------------
        // Create User Space (QUSCRTUS) API
        //-----------------------------------------------------
        dcl-pr QUSCRTUS extpgm('QUSCRTUS');
          UserSpace char(20) const; // UserSpace
          Attrib char(10) const; // Attrib
          InitSize int(10) const; // InitSize
          InitVal char(1) const; // InitVal
          PubAuth char(10) const; // PubAuth
          Text char(50) const; // Text
          // optional group 1:
          Replace char(10) const options(*nopass); // Replace
          ErrorCode char(8000) options(*varsize: *nopass); // ErrorCode
          // optional group 2:
          Domain char(10) const options(*nopass); // Domain
          // optional group 3:
          XferSizeReq int(10) const options(*nopass); // XferSizeReq
          OptAlign char(1) const options(*nopass); // OptAlign
        end-pr;

        //-----------------------------------------------------
        // Retrieve Pointer to User Space (QUSPTRUS) API
        //-----------------------------------------------------
        dcl-pr QUSPTRUS extpgm('QUSPTRUS');
          UserSpace char(20) const; // UserSpace
          Pointer pointer; // Pointer
          ErrorCode char(8000) options(*varsize: *nopass); // ErrorCode
        end-pr;

        // Variable locale
        Dcl-s Msg Char(52);
        Dcl-s EntryNo int(10);

        // Nom qualifié de la SAVF
        Dcl-ds l_Qual_savf_name;
          l_Nom_SAVF CHAR(10);
          l_Bib_SAVF CHAR(10);
        End-ds;

        Dcl-s l_Object_name_filter Char(10);
        Dcl-s l_Object_type_filter char(10);
        Dcl-s l_Continuation_handle Char(36);

        //  Création d'un espace utilisateur pour que l'API
        //  QUSLJOB puisse y déposer ses infos
        //  La taille initiale de l'espace sera de 256Ko (256*1024 octets)
        //  L'API QUSLJOB étendra automatiquement cette limite
        //  si elle a besoin de plus de mémoire.
        //
        SpaceName='LSTOBJSAVF';
        SpaceLib='QTEMP';
        SpaceAttr='LIST_OBJ';
        SpaceText='Liste objets sauvegardés';
        QUSCRTUS( UserSpace
                 : SpaceAttr
                 : SpaceLen
                 : SpaceValue
                 : SpaceAuth
                 : SpaceText
                 : SpaceReplc
                 : MyErrCode);
        if BytesAvail <> 0;
          Msg = 'QUSCRTUS API a échoué avec un ' +
                'MSGID ' + MsgID;
          dsply Msg;
          *inlr = *on;
          return *Blanks;
        endif;

        // Liste tous les objets du système.
        // Le résultat ira dans l'espace utilisateur que nous
        // venons de créer
        l_Bib_SAVF = p_Bib_SAVF;
        l_Nom_SAVF = p_Nom_SAVF;
        FormatName = 'SAVF0200';
        l_Object_name_filter = p_Nom_obj;
        l_Object_type_filter= '*ALL'; // Object type filter
        l_Continuation_handle = *Blanks;
        QUslObj( UserSpace
                :FormatName
                :l_Qual_savf_name
                :l_Object_name_filter
                :l_Object_type_filter
                :l_Continuation_handle
                :MyErrCode);
        if BytesAvail <> 0;
          Msg = 'QUSLOBJ API a échoué avec un ' +
              'MSGID ' + MsgID;
          dsply '' ' ' Msg;
          *inlr = *on;
          return *Blanks;
        endif;

        //  Positionne un pointeur sur le début de
        //  l'espace utilisateur.
        //  Dans cet exemple, la zone "Bytes Provided" est
        //  mise à zéro et le programme se plantera avec une
        //  erreur "CPFxxxx" si quelque chose ne va pas:
        BytesProv = 0;
        QUSPTRUS( UserSpace
                 :p_ListHeader);

        p_ListEntry = p_ListHeader + DataOffset;

        Return Object_name;
      END-PROC ;

