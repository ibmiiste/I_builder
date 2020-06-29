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
//     >>PARM<<  DBGVIEW(*SOURCE);                               */
//     >>PARM<<  COMPILEOPT(&U0);                                */
//   >>END-IMPORTANT<<                                           */
// >>EXECUTE<<                                                   */
// >>END-PRE-COMPILER<<                                          */

/copy qcpysrc,cpyctlstm
Ctl-opt Bnddir('I_BUILDER');

//*********************************************************************
// OD 17/11/2017
// Liste des objets à construire
//*********************************************************************
// déclaration des fichiers
dcl-f listbuilde workstn sfile(sfl01 :wran01) infds(dssfl1) indds(IndDS);


// main function prototype
// prototype fonction principale
// --------------------------------------------------
// Prototype for procedure: liste_objet_construction
// --------------------------------------------------
DCL-PR liste_objet_construction EXTPGM('LISTBUILD');
  p_Num_lot Like(r_Num_lot) Const;
END-PR ;

Dcl-pr X_ref Extpgm('XREF');
  ParmEntry char(150);
End-pr;


// Gestion des messages
dcl-pr gst_message_CL extpgm('GSTMSG01');
  a_typ like(r_typmsg);
  a_fim like(r_Nom_obj_IBMi);
  a_mid like(r_numero_msg);
  a_mdt like(r_msgdta);
  p_nom_PGM like(r_Nom_obj_IBMi) Options(*OMIT);
end-pr;

// external functions prototypes
// prototype fonctions externes
/copy qcpysrc,Prtbuilder

// Mise en ligne de la bibliothèque du lot
Dcl-pr Testlot Extpgm('STRTSTLOT');
  p_Num_lot Packed(9:0);
End-pr;

// Suppression de la bibliothèque du lot de la liste de bibliothèques système
Dcl-pr Rmvlot Extpgm('ENDTSTLOT');
  p_Num_lot Packed(9:0);
End-pr;

// local functions prototypes
// prototypes fonctions locales
Dcl-pr reincrement_liste_objet;
  p_num_Lot like(r_Num_lot) const;
End-Pr;

// global variables
// variables globales
dcl-s l_sobjet like(r_Nom_obj_IBMi);
dcl-s g_wsobp like(r_Nom_obj_IBMi);

dcl-s g_nblis1 like(r_nblign);
dcl-s g_lstlig like(r_nblign);
dcl-s g_nbrlig like(r_nblign);
dcl-s g_i packed(3:0);
dcl-s g_xobjet like(r_Nom_obj_IBMi);
dcl-s a_typ like(r_typmsg);
dcl-s a_fim like(r_Nom_obj_IBMi);
dcl-s a_mid like(r_numero_msg);
dcl-s a_mdt like(r_msgdta);


Dcl-s g_Num_lot Like(r_Num_lot);

dcl-s a_chx char(2);
//dcl-s a_nrec like(r_uuid_db2);
//dcl-s a_uuid like(r_uuid_db2);
Dcl-S g_verif packed(1:0);

// Indicateurs
dcl-s g_sortie ind;
dcl-s g_trt_opt ind;
dcl-s g_selection ind;
dcl-s g_alimsfl ind;
dcl-s g_filtre ind;


// Redéfinission des touches de fonction
Dcl-S Construction ind Based(P_INKI);
Dcl-S Livraison_recette ind Based(P_INKJ);
Dcl-S Livraison_production ind Based(P_INKK);


// Appel à CONSTRUCT
Dcl-S g_Failed packed(10:0);
Dcl-S g_FileAttach char(10000);
Dcl-S g_optimize char(20);
Dcl-S g_BibSrc_pre LIKE(r_Nom_obj_IBMi);
Dcl-S g_FicSrc_pre LIKE(r_Nom_obj_IBMi);
Dcl-S g_MbrSrc_pre LIKE(r_Nom_obj_IBMi);
Dcl-s g_list_biblio LIKE(r_Nom_obj_IBMi);
Dcl-s g_lib_lot Like(r_Nom_obj_IBMi);

// API QUSRMBRD (Retreive Member Description)
// --------------------------------------------------
dcl-s bOvr char(1) inz('0');
dcl-s Fmt char(8) inz('MBRD0100');


// Touches de fonction
/copy qcpysrc,fonction

// data-structures
// structures de données
// Informations objets IBM i
Dcl-ds l_Base_infos_obj_light likeDS(OBJD0200_t);

// program status data structure
// structure information programme
/copy qcpysrc,psds


// Indicateurs renommés avec Indara et INDDS
Dcl-ds IndDS;
  ROLLUP ind pos(2);
  SFLDSP ind pos(4);
  SFLDSPCTL ind pos(5);
  SFLCLR ind pos(6);
  SFLEND ind pos(7);
  SFLNXTCHG ind pos(8);
  SFLENDMSG ind pos(9);
  SFLINZ ind pos(10);
  PROTECT ind pos(20);
  g_lot_inactif ind pos(21);
  Erreur_objet ind Pos(25);
  Erreur_Source Ind Pos(26);
end-ds;

// la ds du sous=fichier
dcl-ds dssfl1;
  wposc bindec(2:0) pos(370);
  wrrng bindec(2:0) pos(376);
  wrngp bindec(2:0) pos(378);
  wnbrsf bindec(2:0) pos(380);
end-ds;

// la ds du fichier
dcl-ds fic;
  wnrc01 bindec(4:0) pos(397);
end-ds;

dcl-ds wdsfic;
  wcdfil char(8);
  wopenf char(1);
  wstsfi packed(5:0);
  wopcod char(5);
  wrpgsq char(8);
  wrpgnr char(8);
  werrfi char(7);
  wnfich char(10);
  wnlibr char(10);
  wspnam char(10);
  wsplib char(10);
  wspnum bindec(2:0);
  wlimbr char(10);
  wnbput bindec(4:0);
  wnbget bindec(4:0);
  wnbpg bindec(4:0);
  wnbio bindec(4:0);
  wrcdft char(10);
  wnbrcd bindec(4:0);
  wnrcfi bindec(4:0);
end-ds;

// paramètres d'entrée de XREF
dcl-ds ParmEntry1;
  Entry_Obj char(10);
  Entry_Lib char(10);
  Entry_typ char(7);
  Entry_Fct char(10) Inz('*NONE     ');
  Entry_Output char(8) Inz('*DISPLAY');
  Entry_Trt char(12) Inz('*INTERACTIVE');
  Code bindec(4) Inz(3);
  Entry_FicSrc char(10) Inz('*NONE     ');
  Entry_BibSrc char(10) Inz('*LIBOBJ   ');
  Entry_MbrSrc char(10) Inz('*OBJ      ');
  Entry_Text char(50) pos(90)
             Inz('                                                  ');
end-ds;

// La DS de la table LIST_OBJET_BUILD
Dcl-ds Ds_LIST_OBJET_BUILD Extname('LSTOBJBLD') Qualified End-ds;

// La DS de la table LOTS
Dcl-ds Ds_Lots Extname('LOTS') Qualified End-ds;

// Paramètre d'appel de XREF
Dcl-s ParmEntry char(150);


// inherited variables
// héritage des types
/copy Qcpysrc,inhbuilder

// constants
// constantes

DCL-PI liste_objet_construction;
  p_Num_lot Like(r_Num_lot) Const;
END-PI ;

// main function
// fonction principale
monitor;

  // Initialisation de variables
  g_Num_lot=p_Num_lot;

  // le nombre de lignes affichables, déclaration Ã  la volée
  g_nblis1=18;
  // initialisation des variables générales
  zpgm=PROCEDURE;
  zdate=%dec(%date():*eur);
  zheur=%dec(%time():*eur);
  zuser=USER;
  zjob=JOB_NAME;
  // initialisation du sous fichier des messages
  wpgmq='*  ';
  wmgkey='CC01';
  sflendmsg = *on;
  sflinz = *on;
  // indicateur fin
  g_sortie = *off;
  // début du traitement,
  exsr initsf;
  // boucle d'attente de sortie
  dow not g_sortie;
    exsr trtsfl;
  enddo;

on-error;
  dump(a);
  gest_erreur();
endmon;

// indicateur de fin de programme
*inlr = *on;
// les procédures
// traitement de l'écran
begsr trtsfl;
  // effacement du sous=fichier de messages
  a_typ='3';
  a_fim=*blank;
  a_mid=*blank;
  gst_message_CL(  a_typ
              : a_fim
              : a_mid
              : a_mdt
              :*OMIT);
  write wsfctl;
  // ecriture de l'écran
  sfldsp = *on;
  sfldspctl = *on;
  write fore1;

  write forb1;
  // attente lecture
  read fore1;

  // une touche a été actionnée
  // chargement de l'heure
  zheur=%dec(%time());
  // indicateur pour ne pas tester d'autres actions
  g_trt_opt = *on;
  if rollup;
    // page suivante
    exsr chgpag;
    g_trt_opt = *off;
  endif;
  //
  if g_wsobp <> ZSOBJET
  and g_trt_opt;
    // test si selection/ si changé on initialise
    exsr initsf;
    g_trt_opt = *off;
  endif;
  // touches f3 et f12
  if sortie or
        cancel;
    // on met l'indicateur à off = fin du programme
    g_sortie = *on;
    g_trt_opt = *off;
  endif;
  //
  if refresh;
    // f5 rafraichissement de l'écran
    exsr initsf;
    g_trt_opt = *off;
  endif;
  //
  //if creer;
  // f6 création d'un nouveau matricule
  //  a_chx='CR';
  //  a_nrec=*blank;
  //  detail_personnel(a_chx:a_nrec);
  //  exsr initsf;
  //  g_trt_opt = *off;
  //endif;
  //if imprimer;
  // f8 impression du fichier
  //  a_uuid=*blank;
  // on appelle le cl de routage sans soumission, sinon pgmf20cl
  //  impression(a_uuid);
  //  g_trt_opt = *off;
  //endif;
  // on ne fait ceci que s'il n'y a eu rien d'autre
  if Construction;
    g_optimize='*NONE';
    Testlot(g_Num_lot);
    builder( g_Num_lot
            :g_lib_lot
            :''
            :g_optimize
            :'0'
            :''
            :''
            :'');
    RMVlot(g_Num_lot);
    EXEC SQL
      UPDATE Lots SET Statlot = 'D' WHERE Lot_Number = :G_Num_Lot;
  EndIf;

  if Livraison_recette;
    g_optimize='*NONE';
    Testlot(g_Num_lot);
    builder( g_Num_lot
            :g_lib_lot
            :''
            :g_optimize
            :'1'
            :'CICA95'
            :'DRUBIGNY'
            :'DANIEL1E01');
    RMVlot(g_Num_lot);
    EXEC SQL
      UPDATE Lots SET Statlot = 'R' WHERE Lot_Number = :G_Num_Lot;
  EndIf;

  if Livraison_production;
    g_optimize='*FULL';
    Copie_sources(g_Num_lot);
    builder( g_Num_lot
            :''
            :''
            :g_optimize
            :'1'
            :'CICA98'
            :'DRUBIGNY'
            :'DANIEL1E01');
    EXEC SQL 
      UPDATE Lots SET Statlot = 'P' WHERE Lot_Number = :G_Num_Lot;
  EndIf;

  if g_trt_opt;
    exsr trtopt;
  endif;
// on recommence la boucle d'attente
endsr;
// initialisation du sous-fichier
begsr initsf;
  //    l'indicateur 20 conditionne la zone opt (protection)
  PROTECT = *on;
  // initialisation de la variable de sélection
  g_wsobp=ZSOBJET;
  l_sobjet=*blank;

  //Récupération de la list de bibliothèque
  EXEC SQL
    SELECT Lpad( Libelle_Lots, 0.5*CHARACTER_LENGTH( Libelle_Lots) + 64, ' '),
           Liste_Biblio_Projet,
           Biblot,
           Statut_Enreg
      INTO :Zprojet,
           :G_List_Biblio,
           :G_Lib_Lot,
           :Ds_Lots.Statenreg
      FROM Lots
      WHERE Lot_Number = :G_Num_Lot;

  // Alimentation de la bibliothèque lot dans l'entête
  Zbiblot =G_Lib_Lot;

  IF Ds_Lots.Statenreg=0;
    g_lot_inactif=*on;
  Else;
    g_lot_inactif=*off;
  ENDIF;
  ZOBJDST=*blank;
  g_selection = *off;
  g_filtre = *off;
  if ZSOBJET <> *blank;
    // si différent de blank il y a sélection
    g_selection = *on;
    g_i=0;
    g_i=%scan('*':ZSOBJET);

    if g_i > 0;
      g_filtre=*on;
      g_i=g_i-1;
      l_sobjet=%subst(ZSOBJET:1:g_i);
      // on est dans le cas d'une sélection générique
      // on se positionnera juste au bon endroit dans le fichier
      ZOBJDST=l_sobjet;
    endif;
  endif;
  // la dernière ligne écrite

  g_lstlig=0;
  // le compteur de ligne par page
  g_nbrlig=0;
  // le fameux wran01
  wran01=0;
  // effacement du sous=fichier
  sflclr = *on;
  sflend = *on;
  sfldsp = *off;
  sfldspctl = *off;
  write fore1;
  sflclr = *off;
  sfldsp = *on;
  sfldspctl = *on;
  EXEC SQL
    CLOSE List_Obj;
  // positionnement en début de fichier
  EXEC SQL
    DECLARE List_Obj CURSOR FOR
      SELECT Obj_Number,
             Lot_Number,
             Ordre,
             Bibliotheque_Source,
             Fichier_Source,
             Membre_Source,
             Bibliotheque_Destination,
             Objet_Destination,
             Type_Objet
        FROM List_Objet_Build
        WHERE Lot_Number = :G_Num_Lot
        ORDER BY Ordre DESC;

  EXEC SQL
    OPEN List_Obj;
  // chargement de la première page
  // lecture de l'enregistrement suivant
  EXEC SQL
    FETCH List_Obj
      INTO :Hnumobjbld, :Hlot_Numbe, :Zordre, :Zbibsrc, :Zficsrc, :Zmbrsrc, :Zbibdst, :Zobjdst,
        :Ztypobj;
  exsr chgpag;
endsr;
// traitement des options, on ne lit que les enregistrements modifiés
begsr trtopt;
  // lecture des enregistrements modifiés
  wran01=1;
  // top pour rafrachir l'écran, si besoin
  g_alimsfl = *off;
  // Gestion de la création d'enregistrement
  if (zoptc = '1') or (zoptc = ' 1');
    // Récupération des informations objets si elles existent
    if not infos_objet( zobjdstc + zbibdstc
                       :ztypobjc
                       :l_Base_infos_obj_light);

      infos_objet( zobjdstc + g_Lib_lot
                  :ztypobjc
                  :l_Base_infos_obj_light);
    Endif;

    EXEC SQL
      SELECT 1
        INTO :G_Verif
        FROM List_Objet_Build
        WHERE Lot_Number = :G_Num_Lot
              AND Ordre = :Zordrec;
    if sqlcode = 0;
      // envoyer un message pour dire que l'emplacement est déjà pris
      a_typ='1';
      a_fim='BUILDMSGF';
      a_mid='MSG0002';
      a_mdt = %Char(Zordrec);
      gst_message_CL( a_typ
                     :a_fim
                     :a_mid
                     :a_mdt
                     :*OMIT);
    Else;
      Monitor;
        API_RtvMbrDesc( MbrD0100
                       :%Size(MbrD0100)
                       :Fmt
                       :Zficsrcc + Zbibsrcc
                       :Zmbrsrcc
                       :bOvr);
      On-error;
      Endmon;

      // Ajoute tous les lots où se trouve l'objet dans la file de message
      verif_presence_autre_lot( Zbibdstc
                               :Zobjdstc
                               :Ztypobjc
                               :g_Num_lot);

      EXEC SQL
        INSERT INTO List_Objet_Build(Numobjbld,
                                     Lot_Number,
                                     Ordre,
                                     Bibliotheque_Source,
                                     Fichier_Source,
                                     Membre_Source,
                                     Bibliotheque_Destination,
                                     Objet_Destination,
                                     Type_Objet,
                                     Attribut_Objet,
                                     Type_Source,
                                     User_Creation)
          VALUES (DEFAULT,
                  :G_Num_Lot,
                  :Zordrec,
                  :Zbibsrcc,
                  :Zficsrcc,
                  :Zmbrsrcc,
                  :Zbibdstc,
                  :Zobjdstc,
                  :Ztypobjc,
                  :L_Base_Infos_Obj_Light.Atr,
                  :Mbrd0100.Srctype,
                  USER) ;

    Endif;


    zoptc=*blank;
    zordrec=*zero;
    zbibsrcc=*blank;
    zficsrcc=*blank;
    zmbrsrcc=*blank;
    zbibdstc=*blank;
    zobjdstc=*blank;
    ztypobjc=*blank;
    g_alimsfl=*on;
  EndIf;

  readc sfl01;
  dow not %eof;
    //a_nrec=hnrec;
    g_filtre = *on;
    // Si le lot est inactif, certaine option en sont pas possible
    IF g_lot_inactif;
      If %Trim(zopt)='2'
      Or %Trim(zopt)='3'
      Or %Trim(zopt)='4'
      Or %Trim(zopt)='9'
      Or %Trim(zopt)='10'
      Or %Trim(zopt)='11';
        Zopt='5';
      Endif;
    ENDIF;
    // selection en fonction du choix saisi
    select;
    WHEN
     (zopt = ' 2') or (zopt = '2');
      a_chx='MO';
      // Ajoute tous les lots où se trouve l'objet dans la file de message
      verif_presence_autre_lot( Zbibdst
                               :Zobjdst
                               :Ztypobj
                               :g_Num_lot);

      // Récupération des informations objets si elles existent
      if not infos_objet( zobjdst + zbibdst
                         :ztypobj
                         :l_Base_infos_obj_light);

        infos_objet( zobjdst + g_Lib_lot
                    :ztypobj
                    :l_Base_infos_obj_light);
      Endif;

      EXEC SQL
        UPDATE List_Objet_Build
          SET Lot_Number = :G_Num_Lot,
              Ordre = :Zordre,
              Bibliotheque_Source = :Zbibsrc,
              Fichier_Source = :Zficsrc,
              Membre_Source = :Zmbrsrc,
              Bibliotheque_Destination = :Zbibdst,
              Objet_Destination = :Zobjdst,
              Type_Objet = :Ztypobj,
              Attribut_Objet = :L_Base_Infos_Obj_Light.Atr,
              User_Modification = USER
          WHERE Obj_Number = :Hnumobjbld;

    when (zopt = '3') or (zopt = ' 3');
      a_chx='CO';
    when (zopt = '4') or (zopt = ' 4');

      EXEC SQL
        DELETE List_Objet_Build WHERE Obj_Number = :Hnumobjbld;
    when (zopt = '5') or (zopt = ' 5');
      a_chx='AF';
    when (zopt = '6') or (zopt = ' 6');
      g_filtre = *off;

    when %Trim(zopt) = '7';
      Entry_Obj=ZOBJDST;
      Entry_Lib=ZBIBDST;
      Entry_typ=ZTYPOBJ;
      ParmEntry=ParmEntry1;
      X_ref(ParmEntry);

    when (zopt = '9') or (zopt = ' 9');
      g_BIBSRC_pre=ZBIBSRC;
      g_FicSrc_pre=ZFICSRC;
      g_MbrSrc_pre=ZMBRSRC;
      g_optimize='*NONE';
      Testlot(g_Num_lot);
      Construct( g_Lib_lot
                :g_FicSrc_pre
                :g_MbrSrc_pre
                :g_Lib_lot
                :ZOBJDST
                :ZTYPOBJ
                :g_Lib_lot
                :ZFICSRC
                :ZMBRSRC
                :g_optimize
                :g_Failed
                :g_FileAttach
                :g_list_biblio
                :'');
      Rmvlot(g_Num_lot);
      if  g_Failed<>0;
        EnvRapMel();
      EndIf;
    when zopt = '10';
      g_BIBSRC_pre=ZBIBSRC;
      g_FicSrc_pre=ZFICSRC;
      g_MbrSrc_pre=ZMBRSRC;
      g_optimize='*NONE';
      Testlot(g_Num_lot);
      Construct( g_Lib_lot
                :g_FicSrc_pre
                :g_MbrSrc_pre
                :g_Lib_lot
                :ZOBJDST
                :ZTYPOBJ
                :g_Lib_lot
                :ZFICSRC
                :ZMBRSRC
                :g_optimize
                :g_Failed
                :g_FileAttach
                :g_list_biblio
                :'');
      if  g_Failed<>0;
        EnvRapMel();
      EndIf;
      RMVlot(g_Num_lot);
      Copie_liste_objet_a_livres( g_num_lot
                                 :Hnumobjbld);
      Livraison( g_num_lot
                :'CICA95'
                :'DRUBIGNY'
                :'DANIEL1E01');
    when zopt = '11';
      g_BIBSRC_pre=ZBIBSRC;
      g_FicSrc_pre=ZFICSRC;
      g_MbrSrc_pre=ZMBRSRC;
      g_optimize='*FULL';
      Testlot(g_Num_lot);
      Construct( g_Lib_lot
                :g_FicSrc_pre
                :g_MbrSrc_pre
                :g_Lib_lot
                :ZOBJDST
                :ZTYPOBJ
                :g_Lib_lot
                :ZFICSRC
                :ZMBRSRC
                :g_optimize
                :g_Failed
                :g_FileAttach
                :g_list_biblio
                :'');
      if  g_Failed<>0;
        EnvRapMel();
      EndIf;
      RMVlot(g_Num_lot);
      Copie_liste_objet_a_livres( g_num_lot
                                 :Hnumobjbld);
      Livraison( g_num_lot
                :'CICA98'
                :'DRUBIGNY'
                :'DANIEL1E01');
      Copie_sources( g_Num_lot
                    :Hnumobjbld);
      g_optimize='*NONE';
      Construct( g_BibSrc_pre
                :g_FicSrc_pre
                :g_MbrSrc_pre
                :Zbibdst
                :ZOBJDST
                :ZTYPOBJ
                :ZBIBSRC
                :ZFICSRC
                :ZMBRSRC
                :g_optimize
                :g_Failed
                :g_FileAttach
                :g_list_biblio
                :'');
    //when (zopt = '99');
    //  a_chx='PE';
    other;
      // la saisie ne correspond  rien
      g_filtre = *off;
      // envoyer un message pour dire que l'option n'existe pas
      a_typ='1';
      a_fim='BUILDMSGF ';
      a_mid='ERR0006';
      gst_message_CL( a_typ
                     :a_fim
                     :a_mid
                     :a_mdt
                     :*OMIT);
    endsl;
    // nettoyage
    zopt=*blanks;
    update(e) sfl01;
    // on aurait pu aussi faire if..., en tout cas le choix est bon
    //detail_personnel(  a_chx
    //                 : a_nrec);
    g_alimsfl=*on;
    // on continue de boucler si autre option
    readc(e) sfl01;
  enddo;
  // potentiellement il y a eu mise  jour, on pourrait affiner
  if g_alimsfl;
    reincrement_liste_objet(g_Num_lot);
    exsr initsf;
  ENDIF;
endsr;
// chargement d'une page
begsr chgpag;
  // il faut positionner correctement les indicateurs et les variables
  sflnxtchg = *off;
  //                  seton                                        04
  wran01=g_lstlig;
  // remise à zéro du compteur de ligne, mais on pourrait faire autrement
  g_nbrlig=0;

  dow sqlcode<>100
  and g_nbrlig < 18;
    // remplissage des zones écran
    g_alimsfl = *on;
    // test s'il y a sélection
    if g_selection or g_filtre;
      if g_selection and not g_filtre;
        // on recherche la stricte égalité de nom
        if ZOBJDST <> ZSOBJET;
          g_alimsfl = *off;
        endif;
      else;
        // on recherche si le nom commence par la valeur avant le '*'
        g_xobjet=%subst( ZOBJDST:1:g_i);
        if g_xobjet <> l_sobjet;
          g_alimsfl = *off;
        endif;
      endif;
    endif;
    // l'indicateur est  '1' si sélection ok ou pas de sélection
    // les compteurs, attention au wran01
    if g_alimsfl;
      g_nbrlig+=1;
      g_lstlig+=1;
      wran01+=1;
      IF infos_objet( zobjdst + zbibdst
                     :ztypobj
                     :l_Base_infos_obj_light);
        zDescobjet=l_Base_infos_obj_light.Txt;
      Endif;

      If zDescobjet=*Blank;
        infos_objet( zobjdst + g_Lib_lot
                    :ztypobj
                    :l_Base_infos_obj_light);
        zDescobjet=l_Base_infos_obj_light.Txt;
      Endif;

      If l_Base_infos_obj_light.RtnSize=0;
        // envoyer un message pour dire que l'objet n'est pas présent dans le lot
        Erreur_objet=*On;
        A_Typ = '5';
        A_Fim = 'BUILDMSGF';
        A_Mid = 'ERR0009';
        A_Mdt = zobjdst + g_Lib_lot;
        Gst_Message_Cl(A_Typ :A_Fim :A_Mid :A_Mdt:Procedure);
      ENDIF;

      // Vérification que le source est présent dans le lot
      Monitor;
        API_RtvMbrDesc( MbrD0100
                       :%Size(MbrD0100)
                       :Fmt
                       :ZFICSRC + g_Lib_lot
                       :ZMBRSRC
                       :bOvr);
      On-error;
        // envoyer un message pour dire que l'objet n'est pas présent dans le lot
        Erreur_Source=*On;
        A_Typ = '5';
        A_Fim = 'BUILDMSGF';
        A_Mid = 'ERR0008';
        A_Mdt = g_Lib_lot  + ZFICSRC + ZMBRSRC;
        Gst_Message_Cl(A_Typ :A_Fim :A_Mid :A_Mdt:Procedure);
      Endmon;

      if PROTECT=*on;
        PROTECT=*off;
      EndIf;
      // ecriture de la ligne
      write sfl01;
    endif;
    // lecture du suivant
    EXEC SQL
      FETCH List_Obj
        INTO :Hnumobjbld, :Hlot_Numbe, :Zordre, :Zbibsrc, :Zficsrc, :Zmbrsrc, :Zbibdst, :Zobjdst,
          :Ztypobj;
  enddo;
  // on quitte la boucle soit en fin de page
  //                     soit en fin de fichier
  if sqlcode=100;
    // le caractère de suite, on est en fin de fichier
    sflend = *on;
  else;
    sflend = *off;
  endif;
  // si le fichier est vide
  if wran01 = 0;
    g_nbrlig=1;
    g_lstlig=1;
    // un petit message
    wran01=1;
    // pas de saisie d'option
    PROTECT = *on;
    if ZSOBJET <> *blank;
      ZDESCOBJET = 'sélection vide';
    else;
      ZDESCOBJET = 'Fichier vide';
    endif;
    // ne pas oublier de remettre à blanc
    ZOBJDST=*blank;
    ZBIBDST=*blank;
    ZBIBSRC=*blank;
    ZFICSRC=*blank;
    ZMBRSRC=*blank;
    ZORDRE=0;
    hnrec=*blank;
    // ecriture du message sur la première ligne
    write sfl01;
  endif;
endsr;


Dcl-Proc reincrement_liste_objet;
  Dcl-pi reincrement_liste_objet;
    p_num_lot like(r_Num_lot) const;
  End-Pi;

  Dcl-S l_num_Lot like(r_num_Lot);
  Dcl-S l_Ordre packed(6:0);
  Dcl-s l_Bibliotheque_source Like(r_Nom_obj_IBMi);
  Dcl-s l_Fichier_source Like(r_Nom_obj_IBMi);
  Dcl-s l_Membre_source Like(r_Nom_obj_IBMi);


  EXEC SQL
    DROP SEQUENCE Order_Seq;

  EXEC SQL
    CREATE SEQUENCE Order_Seq START WITH 10 INCREMENT BY 10 MAXVALUE 9990 CYCLE CACHE 24;


  EXEC SQL
    CLOSE List_Obj_Projet;
  // positionnement en début de fichier
  EXEC SQL
    DECLARE List_Obj_Projet CURSOR FOR
      SELECT Lot_Number,
             Ordre, Bibliotheque_Source,Fichier_Source, Membre_Source
        FROM List_Objet_Build
        WHERE Lot_Number = :P_Num_Lot
        ORDER BY Ordre,
                 RRN(List_Objet_Build) ;

  EXEC SQL
    OPEN List_Obj_Projet;

  EXEC SQL
    FETCH List_Obj_Projet
      INTO :L_Num_Lot, :L_Ordre, :L_Bibliotheque_Source, :L_Fichier_Source,:L_Membre_Source;

  Dow sqlcode=0;
    Monitor;
      API_RtvMbrDesc( MbrD0100
                     :%Size(MbrD0100)
                     :Fmt
                     :L_Fichier_Source + L_Bibliotheque_Source
                     :L_Membre_Source
                     :bOvr);

    // Si l'objet est nouveau, son source n'est pas présent dans la bib appli
    // Il faut rechercher dans la bib lot dans ce cas.
    On-error;
      API_RtvMbrDesc( MbrD0100
                    :%Size(MbrD0100)
                    :Fmt
                    :L_Fichier_Source + g_Lib_lot
                    :L_Membre_Source
                    :bOvr);
    Endmon;

    EXEC SQL
      UPDATE List_Objet_Build
        SET Ordre = NEXT VALUE FOR Order_Seq,
            Type_Source = :Mbrd0100.Srctype
        WHERE CURRENT OF List_Obj_Projet;


    EXEC SQL
      FETCH List_Obj_Projet
        INTO :L_Num_Lot, :L_Ordre, :L_Bibliotheque_Source,:L_Fichier_Source,:L_Membre_Source;

  EndDo;

End-proc;



// --------------------------------------------------
// Procedure name: verif_presence_autre_lot
// Purpose:        Lister la présence de l'objet dans d'autre lots actif
// Returns:
// --------------------------------------------------
DCL-PROC verif_presence_autre_lot ;
  Dcl-pi verif_presence_autre_lot;
    p_biblio_objet Like(r_Nom_obj_IBMi);
    p_Nom_objet Like(r_Nom_obj_IBMi);
    p_Type_objet Like(r_TypObj);
    p_Num_Lot Like(r_Num_lot);
  END-PI;

  // DS d'envoi des variables du message MSG0001
  Dcl-ds DS_MSG0001;
    // transmission d'un nom d"objet qualifié
    l_objet_msg Char(21);
    l_type_objet Like(R_TypObj);
    l_Num_Lot_Doublon Like(r_Num_lot);
    l_User_Doublon Like(r_profil);
  END-DS;


  EXEC SQL
    CLOSE Curs_Objet_Lot;

  EXEC SQL
    DECLARE Curs_Objet_Lot CURSOR FOR
      SELECT A.Lot_Number,
             A.User_Creation
        FROM List_Objet_Build A
        WHERE A.Bibliotheque_Destination = :P_Biblio_Objet
              AND A.Objet_Destination = :P_Nom_Objet
              AND A.Type_Objet = :P_Type_Objet
              AND Exists (SELECT 1
                            FROM Lots B
                            WHERE A.Lot_Number = B.Lot_Number
                                  AND B.Lot_Number <> :P_Num_Lot
                                  AND B.Statenreg = 1);
  EXEC SQL
    OPEN Curs_Objet_Lot;

  EXEC SQL
    FETCH Curs_Objet_Lot INTO :L_Num_Lot_Doublon, :L_User_Doublon;

  Dow Sqlcode = 0;
    // envoyer un message pour dire que l'objet est déjà dans un autre lot
    A_Typ = '5';
    A_Fim = 'BUILDMSGF';
    A_Mid = 'MSG0001';

    l_Objet_Msg = %trim(P_Biblio_Objet) + '/' + %trim(P_Nom_Objet);
    l_Type_Objet = P_Type_Objet;
    A_Mdt = Ds_Msg0001;
    Gst_Message_Cl(A_Typ :A_Fim :A_Mid :A_Mdt:Procedure);
    EXEC SQL
      FETCH Curs_Objet_Lot INTO :L_Num_Lot_Doublon, :L_User_Doublon;

  Enddo;
  RETURN ;
END-Proc ;

