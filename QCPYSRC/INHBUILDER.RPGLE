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
       Dcl-s r_Auto_Number Packed(9:0) Template;
       Dcl-s r_Num_lot Packed(9:0) Template;
       Dcl-s r_Num_lot_carac Char(9) Template;
       Dcl-s r_Numero_msg char(7) Template;
       Dcl-s r_Prefix Char(1) Template;
       Dcl-s r_profil char(10) Template;
       Dcl-s r_qualified_name Char(20) Template;
       Dcl-s r_Target_release Char(10) Template;
       Dcl-s r_typmsg char(1) Template;
       Dcl-s R_TypObj Char(10) Template;
       Dcl-s R_TypSrc Char(10) Template;

       // Classe Environnement
       Dcl-ds environnement Extname('ENVIRONMNT') Qualified Template End-ds;
