      // Indicateurs de touches fonctions *INKA, ...
      // à utiliser par /COPY

      /if defined(FONCTION_H)
       /eof
      /endif

       /define FONCTION_H

<<<<<<< Upstream, based on origin/master
     D P_INKA          s               *   INZ(%ADDR(*INKA))
     D  F1             s               N   Based(P_INKA)
     D  Aide           s               N   Based(P_INKA)
     D P_INKB          s               *   INZ(%ADDR(*INKB))
     D  F2             s               N   Based(P_INKB)
     D P_INKC          s               *   INZ(%ADDR(*INKC))
     D  F3             s               N   Based(P_INKC)
     D  Sortie         s               N   Based(P_INKC)
     D  Exit           s               N   Based(P_INKC)
     D P_INKD          s               *   INZ(%ADDR(*INKD))
     D  F4             s               N   Based(P_INKD)
     D  Guide          s               N   Based(P_INKD)
     D P_INKE          s               *   INZ(%ADDR(*INKE))
     D  F5             s               N   Based(P_INKE)
     D  Refresh        s               N   Based(P_INKE)
     D P_INKF          s               *   INZ(%ADDR(*INKF))
     D  F6             s               N   Based(P_INKF)
     D  Creer          s               N   Based(P_INKF)
     D P_INKG          s               *   INZ(%ADDR(*INKG))
     D  F7             s               N   Based(P_INKG)
     D P_INKH          s               *   INZ(%ADDR(*INKH))
     D  F8             s               N   Based(P_INKH)
     D  Imprimer       s               N   Based(P_INKH)
     D P_INKI          s               *   INZ(%ADDR(*INKI))
     D  F9             s               N   Based(P_INKI)
     D P_INKJ          s               *   INZ(%ADDR(*INKJ))
     D  F10            s               N   Based(P_INKJ)
     D P_INKK          s               *   INZ(%ADDR(*INKK))
     D  F11            s               N   Based(P_INKK)
     D P_INKL          s               *   INZ(%ADDR(*INKL))
     D  F12            s               N   Based(P_INKL)
     D  Cancel         s               N   Based(P_INKL)
     D  Annuler        s               N   Based(P_INKL)
     D P_INKM          s               *   INZ(%ADDR(*INKM))
     D  F13            s               N   Based(P_INKM)
     D P_INKN          s               *   INZ(%ADDR(*INKN))
     D  F14            s               N   Based(P_INKN)
     D P_INKP          s               *   INZ(%ADDR(*INKP))
     D  F15            s               N   Based(P_INKP)
     D P_INKQ          s               *   INZ(%ADDR(*INKQ))
     D  F16            s               N   Based(P_INKQ)
     D P_INKR          s               *   INZ(%ADDR(*INKR))
     D  F17            s               N   Based(P_INKR)
     D P_INKS          s               *   INZ(%ADDR(*INKS))
     D  F18            s               N   Based(P_INKS)
     D P_INKT          s               *   INZ(%ADDR(*INKT))
     D  F19            s               N   Based(P_INKT)
     D P_INKU          s               *   INZ(%ADDR(*INKU))
     D  F20            s               N   Based(P_INKU)
     D P_INKV          s               *   INZ(%ADDR(*INKV))
     D  F21            s               N   Based(P_INKV)
     D P_INKW          s               *   INZ(%ADDR(*INKW))
     D  F22            s               N   Based(P_INKW)
     D P_INKX          s               *   INZ(%ADDR(*INKX))
     D  F23            s               N   Based(P_INKX)
     D P_INKY          s               *   INZ(%ADDR(*INKY))
     D  F24            s               N   Based(P_INKY)
      * ------------------------------------------------------
=======
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
>>>>>>> ecd5080 Pass to free form on Definition specification and add French word.
