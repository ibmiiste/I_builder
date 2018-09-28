      //
      //******************* INFOS FICHIER
      //
       dcl-ds FichierDS template;
        nomfichier char(8) pos(1);
      // 1 = oui
        f_open char(1) pos(9);
      // 1 = oui
        f_eof char(1) pos(10);
        f_status zoned(5) pos(11);
        codoperation char(6) pos(16);
        f_routine char(8) pos(22);
        no_sequence char(8) pos(30);
      // en externe, nom du format
      // en interne, indicateur d'entrée
        format char(8) pos(38);


      //
      //******************** OPEN FEEDBACK AREA
        erreur char(7) pos(46);
      // ODP  DS = DEVICE, DB = DataBase, SP = Spool
      //        type_odp char(2) pos(81);
      // (<> de nomfichier si OVRDBF)
        fichier_ouvert char(10) pos(83);
        bibliotheque char(10) pos(93);
        SplNbr int(5) pos(123);
        lg_maxi int(10) pos(125);
        Membre char(10) pos(129);
        nb_de_lignes int(5) pos(152);
        nb_de_colonne int(5) pos(154);
      // NB d'enregistrements lors de l'open
        nb_enregs int(10) pos(156);
      // KU = Keyed Unique, KF = Keyed Fifo, KL = Keyed Lifo, AR =Arrivée
      //
        type_acces char(2) pos(160);
      //   U (unique) D (dup)
        cle_dupliquee char(1) pos(162);
      //   Y = srcpf
        source char(1) pos(163);


      //
      //******************** I-O FEEDBACK AREA  (standard)
      //
        overflow int(5) pos(188);
        nb_write int(10) pos(243);
        nb_read int(10) pos(247);
        nb_exfmt int(10) pos(251);
        nb_autreio int(10) pos(255);
        dernier_format char(10) pos(261);
        classe_unite char(2) pos(271);
        nom_unite char(10) pos(273);
      //
      //******************** I-O FEEDBACK AREA  (ICF et DSPF)
      //
        lg_dernier int(10) pos(283);
      // X'31'-X'3C' = F1 à F12,
      // X'B1'-X'BC' = F13 à F24
      // X'BD'       = CLEAR            X'F1'       = Entrée
      // X'F4'/X'F5' = Rolldown/rollup  X'F3'       = Aide
      // X'F6'       = Print            x'F8'       = Home (pos 1)
      // x'70'-x'7F' = EVENT-ID donné par le mot-clé MOUBTN(*xxx E00-E15)

      // Display flags
        DSP_FLAG1 CHAR(2) POS(367);

      //
        touche char(1) pos(369);
      //       LICO   DIV   256 --> LIGNE
      //              MVR     --> COLONNE
      //
        lico int(5) pos(370);
      // Actual data len
       DATA_LEN      INT(10)    POS(372);
        rang_sfl int(5) pos(376);
      //      RANG du premier enreg de sous fichier qui était affiché
      //      lors de la lecture, si l'on place cette valeur
      //      dans SFLRCDNBR on réaffiche toujours même page !
        premier_rang int(5) pos(378);
        nbrcd_sfl int(5) pos(380);
      // position curseur mais dans la fenêtre active
        ACT_CURS      CHAR(2)    POS(382);
      // Major ret code
        DSP_MAJOR     CHAR(2)    POS(401);
      // Minor ret code
        DSP_MINOR     CHAR(2)    POS(403);

      //
      //******************** I-O FEEDBACK AREA  (PRTF)
      //
        wlico int(5) pos(382);
        ligne_en_cours int(5) pos(367);





      //
      //******************** I-O FEEDBACK AREA  (DATA BASE)
        page_en_cours int(5) pos(369);
        lg_totale int(10) pos(367);
      // chaque bit représente un fichier  0 = utilisé sans JDFTVAL
      //                                   1           avec JDFTVAL
        jdftval char(4) pos(370);
        offset_to_null int(5) pos(375);
        nbrcd_lock int(5) pos(377);
        nb_de_cles int(5) pos(387);
        lg_cle int(5) pos(393);
        no_membre int(5) pos(395);
      // valeur_cles                  xxx     overlay(fichierDS:400)
      // cles_nulles                  yyy     overlay(fichierDS:zzz)
      //
      // xxx est donné par "lg_cle"
      // yyy est donné par "offset_to_null
      // zzz est donné par "lg_totale"
      // =====================================================================
        recno int(10) pos(397);
       end-ds;
