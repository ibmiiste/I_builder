      // Indicateurs de touches fonctions *INKA, ...
      // à utiliser par /COPY

      /if defined(FONCTION_H)
       /eof
      /endif

       /define FONCTION_H

       dcl-s P_INKA pointer inz(%addr(*inka));
       dcl-s F1 ind based(p_inka);
       dcl-s Aide ind based(p_inka);
       dcl-s P_INKB pointer inz(%addr(*inkb));
       dcl-s F2 ind based(p_inkb);
       dcl-s P_INKC pointer inz(%addr(*inkc));
       dcl-s F3 ind based(p_inkc);
       dcl-s Sortie ind based(p_inkc);
       dcl-s Exit ind based(p_inkc);
       dcl-s P_INKD pointer inz(%addr(*inkd));
       dcl-s F4 ind based(p_inkd);
       dcl-s Guide ind based(p_inkd);
       dcl-s P_INKE pointer inz(%addr(*inke));
       dcl-s F5 ind based(p_inke);
       dcl-s Refresh ind based(p_inke);
       dcl-s Rafraichir ind based(p_inke);
       dcl-s P_INKF pointer inz(%addr(*inkf));
       dcl-s F6 ind based(p_inkf);
       dcl-s Creer ind based(p_inkf);
       dcl-s P_INKG pointer inz(%addr(*inkg));
       dcl-s F7 ind based(p_inkg);
       dcl-s P_INKH pointer inz(%addr(*inkh));
       dcl-s F8 ind based(p_inkh);
       dcl-s Imprimer ind based(p_inkh);
       dcl-s P_INKI pointer inz(%addr(*inki));
       dcl-s F9 ind based(p_inki);
       dcl-s P_INKJ pointer inz(%addr(*inkj));
       dcl-s F10 ind based(p_inkj);
       dcl-s P_INKK pointer inz(%addr(*inkk));
       dcl-s F11 ind based(p_inkk);
       dcl-s P_INKL pointer inz(%addr(*inkl));
       dcl-s F12 ind based(p_inkl);
       dcl-s Cancel ind based(p_inkl);
       dcl-s Annuler ind based(p_inkl);
       dcl-s P_INKM pointer inz(%addr(*inkm));
       dcl-s F13 ind based(p_inkm);
       dcl-s P_INKN pointer inz(%addr(*inkn));
       dcl-s F14 ind based(p_inkn);
       dcl-s P_INKP pointer inz(%addr(*inkp));
       dcl-s F15 ind based(p_inkp);
       dcl-s P_INKQ pointer inz(%addr(*inkq));
       dcl-s F16 ind based(p_inkq);
       dcl-s P_INKR pointer inz(%addr(*inkr));
       dcl-s F17 ind based(p_inkr);
       dcl-s P_INKS pointer inz(%addr(*inks));
       dcl-s F18 ind based(p_inks);
       dcl-s P_INKT pointer inz(%addr(*inkt));
       dcl-s F19 ind based(p_inkt);
       dcl-s P_INKU pointer inz(%addr(*inku));
       dcl-s F20 ind based(p_inku);
       dcl-s P_INKV pointer inz(%addr(*inkv));
       dcl-s F21 ind based(p_inkv);
       dcl-s P_INKW pointer inz(%addr(*inkw));
       dcl-s F22 ind based(p_inkw);
       dcl-s P_INKX pointer inz(%addr(*inkx));
       dcl-s F23 ind based(p_inkx);
       dcl-s P_INKY pointer inz(%addr(*inky));
      * ------------------------------------------------------
       dcl-s F24 ind based(p_inky);
