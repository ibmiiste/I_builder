      **************************************************************************
      * MODULE    : UTIUUID                 Date Création : 16/03/2017         *
      * AUTEUR    : T.Van-Lede                  Copyright : Ista France        *
      *------------------------------------------------------------------------*
      *  APPLICATION :                                                         *
      *  Services                                                              *
      *------------------------------------------------------------------------*
      *  DESCRIPTION :                                                         *
      *  Procédures pour la gestion des UUID                                   *
      *                                                                        *
      *------------------------------------------------------------------------*
      * MAINTENANCE :                                                          *
      *  N°    AUTEUR                       OBJET                       DATE   *
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      * ...  ...........  .........................................  ../../....*
      **************************************************************************
       // Options de contrôle
       ctl-opt option(*srcstmt:*nodebugio:*nounref);
       ctl-opt nomain bnddir('QC2LE');

       // Procédure permettant de générer un UUID en hexa
       dcl-pr genUuidApi extproc('_GENUUID');
        uuid_p          pointer value;
       end-pr;

       // Procédure permettant de convertir de l'hexa en alpha
       dcl-pr cvthc extproc('cvthc');
         ptrHexResult   pointer value;
         ptrCharSrc     pointer value;
         charLength     int(10) value;
       end-pr;

       // Procédure permettant d'obtenir un UUID au format standard
       dcl-proc genUuid export;
         dcl-pi *n char(36) end-pi;

         // Constantes pour passer en minuscules
         dcl-c lowerCase 'abcdefghijklmnopqrstuvwxyz';
         dcl-c upperCase 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

         // DS pour l'appel à _GENUUID
         dcl-ds uuid_ds;
           bytesProvided  uns(10) inz(%size(uuid_ds));
           bytesAvailable uns(10) inz;
           reserved       char(8) inz(*allx'00');
           uuidH          char(16);
         end-ds;

         // Variable de retour
         dcl-s uuid char(36);

         // Génération d'un UUID
         genUuidApi(%addr(uuid_ds));

         // Mise en forme standard
         cvthc(%addr(uuid):%addr(uuidH):%len(uuidH)*2);
         uuid = %xlate(upperCase:lowerCase:uuid);
         uuid = %subst(uuid:1:8) + '-' + %subst(uuid:9:4) + '-' +
                %subst(uuid:13:4) + '-' + %subst(uuid:17:4) + '-' +
                %subst(uuid:21:12);

         return uuid;
       end-proc;

       // Procédure permettant de convertir un UUID du format hexadécimal au
       //   format standard (ajout de tiret)
       dcl-proc cvtUuid32ToStd export;
         dcl-pi *n char(36);
           Uuid32 char(32) const;
         end-pi;

         return %subst(uuid32:1:8) + '-' + %subst(uuid32:9:4) + '-' +
                %subst(uuid32:13:4) + '-' + %subst(uuid32:17:4) + '-' +
                %subst(uuid32:21:12);
       end-proc;

       // Procédure permettant de convertir un UUID du format standard au
       //   format hexadécimal (retrait de tiret)
       dcl-proc cvtUuidStdTo32 export;
         dcl-pi *n char(32);
           UuidStd char(36) const;
         end-pi;

         return %subst(uuidStd:1:8) + %subst(uuidStd:10:4) +
                %subst(uuidStd:15:4) + %subst(uuidStd:20:4) +
                %subst(uuidStd:25:12);
       end-proc;

       // Procédure permettant d'obtenir un UUID sur 32 sans tirets
       //   format utilisé pour Mirus et SAP (hors transaction id)
       // dcl-pr GenUuid32 char(32) end-pr; = déclaration dans les sources appelants
        dcl-proc GenUuid32 Export;
           dcl-pi *N char(32) end-pi;  // Ce que fournit la procédure

           // Génère un UUID au format standard
           dcl-pr genUuid char(36) end-pr;

           // cvtUuidStdTo32 : convertit un UUID du format standard au format sans tiret
           dcl-pr cvtUuidStdTo32 char(32);
              Uuid32 char(36) const;
           end-pr;

           Return cvtUuidStdTo32(GenUuid);

        End-Proc GenUuid32;
