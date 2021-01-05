**FREE
/copy qcpysrc,cpyctlstm
Ctl-opt Bnddir('I_BUILDER');

// external functions prototypes
// prototype fonctions externes
/copy qcpysrc,Prtbuilder

// inherited variables
// héritage des types
/copy Qcpysrc,inhbuilder
// --------------------------------------------------
// Prototype for procedure: Builder_Rdi
// --------------------------------------------------
Dcl-Pr Builder_Rdi EXTPGM('BUILDRDI');
  p_biblio_lot LIKE(r_Nom_obj_IBMi);
End-Pr ;

Dcl-Pi Builder_Rdi;
  p_biblio_lot LIKE(r_Nom_obj_IBMi);
End-Pi;

Dcl-s l_Numero_lot Like(r_Num_lot);
Dcl-S l_optimize char(20) Inz('*NONE');

If p_biblio_lot = '*CURLIB';
  EXEC SQL
    SELECT Schema_Name
      INTO :P_Biblio_Lot
      FROM Qsys2.Library_List_Info
      WHERE Type = 'CURRENT';
ENDIF;

l_Numero_lot = %Dec(%subst(p_biblio_lot:2:9):9:0);

builder( l_Numero_lot
        :p_biblio_lot
        :''
        :l_optimize
        :'0'
        :''
        :''
        :'');

*Inlr = *On;

Return;

