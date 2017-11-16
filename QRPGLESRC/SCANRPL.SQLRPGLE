      * >>PRE-COMPILER<<                                              */
      *   >>CRTCMD<<  CRTSQLRPGI SRCFILE(&SL/&SF) SRCMBR(&SM);        */
      *   >>IMPORTANT<<                                               */
      *     >>PARM<<  OBJ(&LI/&OB);                                   */
      *     >>PARM<<  OBJTYPE(*MODULE);                               */
      *     >>PARM<<  OPTION(*EVENTF);                                */
      *     >>PARM<<  RPGPPOPT(*LVL2);                                */
      *     >>PARM<<  CLOSQLCSR(*ENDACTGRP);                          */
      *     >>PARM<<  DATFMT(*ISO);                                   */
      *     >>PARM<<  TIMFMT(*ISO);                                   */
      *   >>END-IMPORTANT<<                                           */
      *   >>EXECUTE<<                                                 */
      * >>END-PRE-COMPILER<<                                          */
       ctl-opt nomain;
       // --------------------------------------------------
       // Procedure name: ScanRpl
       // Purpose:        Utiliser le BIF %ScanRpl par des exécutables où la ...
       //                          fonction n'existe pas exemple CLLE
       // Returns:        Chaîne résultante après remplacement de la chaîne.
       // Parameter:      p_scan_string => Chaîne de caractères à rechercher ...
       //                          et à remplacer
       // Parameter:      p_replacement => Chaîne de caractères de remplacement
       // Parameter:      p_source => Chaîne de caractères à scanner
       // Parameter:      p_scan_start => A partir de quelle position doit êt...
       //                          re recherché la chaîne de caractères à rem...
       //                          placer
       // Parameter:      p_scan_length => Longueur de chaîne à partir du sta...
       //                          rting position dans laquel est recherché l...
       //                          a chaîne à remplacer.
       // --------------------------------------------------
       DCL-PROC ScanRpl EXPORT;
         DCL-PI *N VARCHAR(1024);
           p_scan_string VARCHAR(1024) CONST;
           p_replacement VARCHAR(1024) CONST;
           p_source VARCHAR(1024) CONST;
           p_scan_start PACKED(8:0) OPTIONS(*OMIT);
           p_scan_length PACKED(8:0) OPTIONS(*OMIT);
         END-PI ;

         DCL-S p_scanrpl VARCHAR(1024);

         if %parms=5;
           p_scanrpl=%SCANRPL( p_scan_string
                              :p_replacement
                              :p_source
                              :p_scan_start
                              :p_scan_length);
         endif;

         if %parms=4;
           p_scanrpl=%SCANRPL( p_scan_string
                              :p_replacement
                              :p_source
                              :p_scan_start);
         endif;

         if %parms=3;
           p_scanrpl=%SCANRPL( p_scan_string
                              :p_replacement
                              :p_source);
         endif;

         return p_scanrpl ;
       END-PROC ;

