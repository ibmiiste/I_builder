      **************************************************************************
      * MODULE    : UTIDSP                  Date Création : 19/07/2017         *
      * AUTEUR    : D.LANDRAGIN                 Copyright : Ista France        *
      *------------------------------------------------------------------------*
      *  APPLICATION :                                                         *
      *  Services                                                              *
      *------------------------------------------------------------------------*
      *  DESCRIPTION :                                                         *
      *  Procédures pour la gestion des écrans                                 *
      *                                                                        *
      *------------------------------------------------------------------------*
      * MAINTENANCE :                                                          *
      *  N°    AUTEUR                       OBJET                       DATE   *
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      **************************************************************************
      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) +    */
      *                 SRCMBR(&SM);                                  */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  OPTION(*EVENTF);                                */
      *     >>PARM<<  DBGVIEW(*ALL);                                  */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */

       ctl-opt nomain;
       ctl-opt option(*srcstmt:*nodebugio:*nounref);

       /copy *libl/qcpysrc,utiproc

       dcl-c USRSPC_NAME 'UTIDSPUSRSQTEMP';       //nom qualifié du usrspc
       dcl-c FLDL0100 'FLDL0100';                 //format des données extraites
       dcl-c MAX_ZONES 300;                       //maximum de zones à extraire

       //API  de création d'un userspace
       dcl-pr crtUserSpace extpgm('QUSCRTUS');
         *n char(20) const;  // Name
         *n char(10) const;  // Attribute
         *n int(10) const;   // Initial size
         *n char(1) const;   // Initial value
         *n char(10) const;  // Authority
         *n char(50) const;  // Text
         *n char(10) const options(*nopass);  // Replace existing
         *n char(32767) options(*varsize:*nopass);  // Error feedback
       end-pr;

       //API de listage des zones d'un format de fichier dans un userspace
       dcl-pr listFields extpgm('QUSLFLD');
         *n char(20) const;  // User space name
         *n char(8) const;   // Format
         *n char(20) const;  // File name
         *n char(10) const;  // Record format
         *n char(1) const;   // Use override
         *n char(32767) options(*varsize:*nopass);  // Error feedback
       end-pr;

       //API de récupération du pointeur sur un userspace
       dcl-pr getPointer extpgm('QUSPTRUS');
         *n char(20) const;   // Name
         *n pointer;          // Pointer to user space
         *n char(32767) options(*varsize:*nopass);  // Error feedback
       end-pr;

       //API de suppression d'un userspace
       dcl-pr dltUserSpace extpgm('QUSDLTUS') ;
         *n char(20) const ;   // Name
         *n char(32767) options(*varsize:*nopass) ;  // Error feedback
       end-pr ;

       //Entête de la liste extraite
       dcl-ds listHeader based(userSpacePointer) qualified;
         offset int(10) pos(125); //position
         count int(10) pos(133);  //nombre de zones
         size int(10) pos(137);   //taille d'une entrée de la liste
       end-ds;

       //Description d'une zone
       dcl-ds fieldInfo based(fieldPointer) qualified;
         name      char(10) pos(1);  //nom zone
         dataType  char(1) pos(11);  //type de donnée
         input     int(10) pos(17);  //position début zone
         fldLength int(10) pos(21);  //longrue zone en octets
         digits    int(10) pos(25);  //nombre de chiffres
         dec       int(10) pos(29);  //positions decimales
         row       int(10) pos(449); //ligne à l'écran ou à l'impression
         col       int(10) pos(453); //colonne à l'écran ou à l'impression
       end-ds;

       //modèle infos stockées pour un format
       dcl-ds descFormat_t qualified template;
         name char(10);   //nom du format
         nbZones uns(10); //nombre de zones dans le format
         allocFields uns(5); //nombre de zones allouées pour le format
         ptrTFields pointer; //pointeur sur le tableau des zones du format
       end-ds;

       //modèle infos stockées pour une zone
       dcl-ds descZone_t qualified template;
         name char(10);
         row  int(10);
         col  int(10);
       end-ds;

       //tableau infos stockées pour les fichiers
       dcl-ds tFiles qualified dim(100) based(ptr_files);
         name char(20);          //nom du fichier
         nbFormats uns(10);      //nombre de formats dans le fichier
         allocFormats uns(5);    //nombre de formats alloués
         ptrTFormats pointer;    //pointeur sur le tableau des formats du ficher
       end-ds;

       dcl-ds tFormats likeds(descFormat_t) dim(100) based(ptr_formats);
       dcl-ds tFields likeds(descZone_t) dim(5000) based(ptr_fields);

       dcl-s idx uns(10); //index dernier fichier
       dcl-s allocFiles uns(5) inz(2); //nombre de fichiers prévus

       dcl-c ALLOC_FORMATS 2; //nombre de formats prévus par fichier
       dcl-c ALLOC_FIELDS 100; //nombre de zones prévues par format
       dcl-c INCR_FILES 2;  //incrément nombre de fichiers
       dcl-c INCR_FORMATS 2;  //incrément nombre de formats d'un fichier
       dcl-c INCR_FIELDS 50;  //incrément nombre de zones d'un format

       // --------------------------------------------------
       // Procedure name: dsp_rtvPosition
       // Purpose:        renvoyer la position d'une zone
       //                 (col, lig) pour positionnement
       // Returns:
       // Parameter:      p_fichier => Nom qualifié du fichier
       // Parameter:      p_format => Nom du format de fichier
       // Parameter:      p_zone => Nom de la zone
       // Parameter:      p_colonne => la colonne (entrée-sortie)
       // Parameter:      p_ligne => la ligne (entrée-sortie)
       // --------------------------------------------------
       DCL-PROC dsp_rtvPosition EXPORT;

         DCL-PI *n;
           p_fichier char(10) const;
           p_format char(10) const;
           p_zone char(10) const;
           p_colonne zoned(3);
           p_ligne zoned(3);
         END-PI;

         dcl-ds w_descZone likeds(descZone_t);

         dcl-ds fichier qualified;
           nom    char(10);
           *n char(10) inz('*LIBL');
         end-ds;

         //nom qualifié du fichier
         fichier.nom = p_fichier;

         //récupération description de la zone
         w_descZone = rtvField(fichier:p_format:p_zone);
         //si la zone n'est pas trouvée on extrait les zones du format et on en extrait la zone
         if w_descZone.name = *blanks;
           genListe(fichier:p_format);
           w_descZone = rtvField(fichier:p_format:p_zone);
         endif;

         //si la zone est trouvée on alimente sa position, sinon on n'y touche pas
         if w_descZone.name <> *blanks;
           p_colonne = w_descZone.col;
           p_ligne = w_descZone.row;
         endif;

         return;


       END-PROC;

       // --------------------------------------------------
       // Procedure name: genListe
       // Purpose:        générer liste des zones d'un format
       // Returns:
       // Parameter:      p_fichier => Nom qualifié du fichier
       // Parameter:      p_format => Nom du format de fichier
       // --------------------------------------------------
       DCL-PROC genListe;

         DCL-PI *n;
           p_fichier char(20) const;
           p_format char(10) const;
         END-PI;

         dcl-s idx_f uns(10);  //index fichier
         dcl-s idx_r uns(10);  //sous-index format
         dcl-s i uns(10);      //index zone



         //recherche du fichier
         idx_f = rtvIdxFile(p_fichier);

         //recherche du format dans le fichier
         idx_r = rtvIdxFormat(idx_f:p_format);

         //pointeur sur les formats du fichier   ???
         ptr_formats = tFiles(idx_f).ptrTFormats;

         //Création du userspace
         crtUserSpace(USRSPC_NAME:'':131072:x'00':
                 '*ALL':'List of fields in file':'*NO':errApi);

         //Remplissage avec la liste des zones du format
         listFields(USRSPC_NAME
                     :FLDL0100:p_fichier:p_format:'0':errApi);

         //Récupération du pointeur sur le userspace
         getPointer(USRSPC_NAME:userSpacePointer:errApi);

         tFormats(idx_r).allocFields = ALLOC_FIELDS;
         ptr_fields = %alloc(%size(tFields) * tFormats(idx_r).allocFields);
         tFormats(idx_r).ptrTFields = ptr_fields;

         //extraction de la description des zones en tableau
         for i = 1 to listHeader.count;
           if i > tFormats(idx_r).allocFields;
             tFormats(idx_r).allocFields += INCR_FIELDS;
             ptr_fields =
               %realloc(tFormats(idx_r).ptrTFields
                         :%size(tFields) * tFormats(idx_r).allocFields);
             tFormats(idx_r).ptrTFields = ptr_fields;
           endif;
           fieldPointer = userSpacePointer
                          + listHeader.offset
                          + (listHeader.size * (i - 1));
           tFields(i).name = fieldInfo.name; //nom zone
           tFields(i).row = fieldInfo.row;   //no ligne
           tFields(i).col = fieldInfo.col;   //no colonne
         endfor;

         //nombre de zones pour le fichier
         tFormats(idx_r).nbZones = listHeader.count;

         //suppression du userspace
         dltUserSpace(USRSPC_NAME:errApi);

       END-PROC;



       // --------------------------------------------------
       // Procedure name: rtvField
       // Purpose:        Récupèrer la description d'une zone de fichier
       //                          déjà extraite
       // Returns:        la description d'une zone
       // Parameter:      p_fichier => Nom qualifié du fichier
       // Parameter:      p_zone => Nom de la zone
       // --------------------------------------------------
       DCL-PROC rtvField;

         DCL-PI *N likeds(descZone_t);
           p_fichier char(20) const;
           p_format char(10) const;
           p_zone char(10) const;
         END-PI ;

         DCL-DS w_zone LIKEDS(descZone_t);

         dcl-s idx_f uns(10); //index fichier
         dcl-s idx_r uns(10); //sous-index format
         dcl-s idx_z uns(10); //sous-index zone


         if idx > 0;
           //recherche du fichier dans le tableau
           idx_f = %lookup(%trim(p_fichier):tFiles(*).name:1:idx);

           if idx_f > 0 and tFiles(idx_f).nbFormats > 0;
             ptr_formats = tFiles(idx_f).ptrTFormats;
             idx_r = %lookup(%trim(p_format)
                             :tFormats(*).name
                             :1
                             :tFiles(idx_f).nbFormats
                     );
             if idx_r > 0 and tFormats(idx_r).nbZones > 0;
               ptr_fields = tFormats(idx_r).ptrTFields;
               idx_z = %lookup(%trim(p_zone)
                               :tFields(*).name
                             :1
                               :tFormats(idx_r).nbZones
                     );
             endif;
           endif;
         endif;

         //récupération de la description de la zone
         if idx_z > 0;
           w_zone = tFields(idx_z);
         else;
           clear w_zone;
         endif;

         return w_zone;
       END-PROC;

       // --------------------------------------------------
       // Procedure name: dsp_remove
       // Purpose:        Libérer les ressources allouées
       //
       // Returns:        Vrai
       // --------------------------------------------------
       DCL-PROC dsp_remove EXPORT;

         dcl-pi *n ind end-pi;

         if ptr_files <> *null;
           dealloc(en) ptr_files;
         endif;
         if ptr_formats <> *null;
           dealloc(en) ptr_formats;
         endif;
         if ptr_fields <> *null;
           dealloc(en) ptr_fields;
         endif;
         idx = 0;

         return *on;
       END-PROC;



       // --------------------------------------------------
       // Procedure name: rtv_idxFile
       // Purpose:        Renvoie l'index d'un fichier (récup ou attribution)
       // Returns:        Index du fichier
       // Parameter:      p_name => Nom du fichier
       // --------------------------------------------------
       DCL-PROC rtvIdxFile;

         dcl-pi *n uns(10);
           p_name char(20) const;
         end-pi;

         dcl-s index uns(10);

         //recherche du fichier
         if idx > 0;
           index = %lookup(%trim(p_name):tFiles(*).name:1:idx);
         endif;

         //allocations tableau des fichiers si non trouvé
         if idx = 0;
           ptr_files = %alloc(%size(tFiles) * allocFiles);
         elseif index = 0 and (idx + 1) > allocFiles;
           allocFiles += INCR_FILES;
           ptr_files = %realloc(ptr_files:%size(tFiles) * allocFiles);
         endif;

         if index = 0;
           idx += 1;
           index = idx;
           clear tFiles(index);
           tFiles(index).name = p_name;
         endif;

         return index;
       END-PROC;

       // --------------------------------------------------
       // Procedure name: rtv_idxFormat
       // Purpose:        Renvoie l'index d'un format (récup ou attribution)
       // Returns:        Index du format
       // Parameter:      p_index => Index du fichier
       // Parameter:      p_name => Nom du format
       // --------------------------------------------------
       DCL-PROC rtvIdxFormat;

         dcl-pi *n uns(10);
           p_index uns(10) const;
           p_name char(10) const;
         end-pi;

         dcl-s index uns(10);
         dcl-s i uns(10);

         if idx = 0;
           return index;
         endif;

         //recherche du format
         if tFiles(p_index).nbFormats > 0;
           ptr_formats = tFiles(p_index).ptrTFormats;
           index = %lookup(%trim(p_name)
                           :tFormats(*).name
                           :1:tFiles(p_index).nbFormats);
         endif;

         //si format trouvé on renvoie son index
         if index > 0;
           return index;
         endif;

         //allocation tableau des formats si non trouvé
         if tFiles(p_index).nbFormats = 0;
           ptr_formats = %alloc(%size(tFormats) * ALLOC_FORMATS);
           tFiles(p_index).ptrTFormats = ptr_formats;
           tFiles(p_index).allocFormats = ALLOC_FORMATS;
         //agrandissement si plein et format non trouvé
         elseif (tFiles(p_index).nbFormats + 1) > tFiles(p_index).allocFormats;
           tFiles(p_index).allocFormats += INCR_FORMATS;
           ptr_formats = %realloc(tFiles(p_index).ptrTFormats
                               :%size(tFormats) * tFiles(p_index).allocFormats);
           tFiles(p_index).ptrTFormats = ptr_formats;
         endif;

         tFiles(p_index).nbFormats += 1;
         index = tFiles(p_index).nbFormats;
         clear tFormats(index);
         tFormats(index).name = p_name;

         return index;
       END-PROC;

