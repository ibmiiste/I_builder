      //Option de contr�le du programme
       /copy qcpysrc,cpyctlstm
       Ctl-opt bnddir('I_BUILDER');

       //H�ritage des classes de donn�es

       /copy Qcpysrc,Inhbuilder

       // Proc�dure externe
       /Copy Qcpysrc,Prtbuilder

       // --------------------------------------------------
       // Procedure name: Recup_erreur
       // Purpose:        Lire le fichier des �v�nement et les cumuler dans u...
       //                          ne table
       // Returns:
       // Parameter:      p_biblio_dest => Biblioth�que du fichier EVFEVENT
       // Parameter:      p_Objet_destination => Membre du fichier EVFEVENT �...
       //                           traiter
       // --------------------------------------------------
       DCL-PROC Recup_erreur ;
         DCL-PI *N;
           p_biblio_dest LIKE(r_Nom_obj_IBMi);
           p_Objet_destination LIKE(r_Nom_obj_IBMi);
         END-PI ;

         Dcl-s l_Instruction_SQL Char(1024);

         EXEC SQL
           SET OPTION COMMIT = *NONE;

         l_instruction_SQL='CREATE ALIAS QTEMP/' + Trim(p_Objet_destination) +
                           ' FOR ' + Trim(p_biblio_dest) + '/EVFEVENT (' +
                           Trim(p_Objet_destination) + ')';

         EXEC SQL
           EXECUTE IMMEDIATE :l_instruction_sql;

         IF  Not Exists( 'ERRORLIST QTEMP     '
                        :'*FILE');
           l_instruction_SQL='CREATE TABLE QTEMP.ERRORLIST AS ' +
                              'SELECT EVFEVENT ' +
                                'FROM QTEMP/' + Trim(p_Objet_destination) +
                               'WHERE %SUBST( EVFEVENT, 1 , 10) = ''FILEID''' +
                                ' WITH NO DATA';

           EXEC SQL
             EXECUTE IMMEDIATE :l_instruction_sql;
         Endif;

         l_instruction_SQL='INSERT INTO QTEMP.ERRORLIST ' +
                              'SELECT EVFEVENT ' +
                                'FROM QTEMP/' + Trim(p_Objet_destination) +
                               'WHERE %SUBST( EVFEVENT, 1 , 10) = ''FILEID''';

         EXEC SQL
           EXECUTE IMMEDIATE :l_instruction_sql;

         l_instruction_SQL='INSERT INTO QTEMP.ERRORLIST ' +
                              'SELECT EVFEVENT ' +
                                'FROM QTEMP/' + Trim(p_Objet_destination) +
                               'WHERE %SUBST( EVFEVENT, 1 , 10) = ''ERROR''';

         EXEC SQL
           EXECUTE IMMEDIATE :l_instruction_sql;

         RETURN ;
       END-PROC ;
