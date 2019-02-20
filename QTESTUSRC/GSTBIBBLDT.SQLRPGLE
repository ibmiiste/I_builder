      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  RUCRTTST SRCFILE(&SL/&SF) SRCMBR(&SM);          */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  TSTPGM(&LI/&OB);                                */
      *     >>PARM<<  DBGVIEW(*ALL);                                  */
      *     >>PARM<<  POPTION(*EVENTF);                               */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */
       ctl-opt NoMain bnddir('I_BUILDER':'SERVICE');

      /copy RPGUNIT1,TESTCASE


      /Copy Qcpysrc,prtbuilder

      /include Qcpysrc,Multiappr

       Dcl-s l_Num_lot_carac Like(r_Num_lot_carac);
       Dcl-s l_nom_bib_lot like(r_Nom_obj_IBMi);
       DCL-S retField IND Inz(*On);
       Dcl-s l_Lettre_prefix Char(1) Inz('L');
       // Informations objets IBM i
       Dcl-ds l_Base_infos_obj_light likeDS(OBJD0200_t);

       Dcl-Pr Test_creat_bib end-pr;


       Dcl-proc Test_creat_bib export;
       Dcl-pi Test_creat_bib End-Pi;

       Dcl-s l_libel_lot Char(50);
       Dcl-s g_Exists Ind;

         l_Num_lot_carac='131541120';
         l_libel_lot='Test de création de lot';
         l_Nom_bib_lot='';
         l_Lettre_prefix='R';

         Crtbibbld(l_Num_lot_carac:l_libel_lot:l_Nom_bib_lot:l_Lettre_prefix);

         g_Exists=Infos_objet( l_Nom_bib_lot + 'QSYS      '
                             :'*LIB'
                            :l_Base_infos_obj_light);
         nEqual( *on:g_Exists);
         aEqual('L131541120':l_Nom_bib_lot);
         aEqual(l_libel_lot:l_Base_infos_obj_light.Txt);

       End-proc Test_creat_bib;
