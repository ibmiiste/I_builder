             CMD        PROMPT('X-REF : ANALYSE ISERIES V1.9.3')
             PARM       KWD(COMPOSANT) TYPE(L1) PASSVAL(*DFT) +
                          PROMPT('COMPOSANT À ANALYSER')
             PARM       KWD(TYPE) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          DFT(*ALL) VALUES(*ALL *PGM *FILE *SRVPGM +
                          *DTAARA *MODULE) PROMPT('TYPE D''OBJET')
             PARM       KWD(FONCTION) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*NONE) VALUES(*NONE *XREF *RECDESC +
                          *DESCFILE *LSTLF *RECCAR *WHEREUSED +
                          *CARTOPGM *CARTOSRC *CARTOSRC2 *RECZONE +
                          *RECPROC *DESCOBJ *CARTOILE *LIBRARY +
                          *RUNQRY *WRKSPLF *CMD *ANALYSE *PGMREF) +
                          PROMPT('FONCTIONNALITÉ')
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*DISPLAY) VALUES(*DISPLAY *OUTFILE +
                          *PRINTER) MIN(0) CHOICE('*DISPLAY, +
                          *OUTFILE, *PRINTER') PMTCTL(*PMTRQS) +
                          PROMPT('SORTIE')
             PARM       KWD(MODE) TYPE(*CHAR) LEN(12) RSTD(*YES) +
                          DFT(*INTERACTIVE) VALUES(*INTERACTIVE +
                          *BATCH *NOPROMPT) PMTCTL(*PMTRQS) +
                          PROMPT('MODE D''ANALYSE')
             PARM       KWD(SOURCE) TYPE(L2) PMTCTL(L0) +
                          PROMPT('SOURCE À ANALYSER')
             PARM       KWD(TEXTE) TYPE(*CHAR) LEN(50) PMTCTL(L3) +
                          PROMPT('TEXTE')
 L0:         PMTCTL     CTL(FONCTION) COND((*EQ *CARTOSRC) (*EQ +
                          *CARTOSRC2)) NBRTRUE(*GE 1)

 L1:         QUAL       TYPE(*GENERIC) LEN(10) DFT(*NONE) MIN(0) +
                          CHOICE('OBJET')
             QUAL       TYPE(*CHAR) LEN(10) DFT(*LIBL) CHOICE('NOM, +
                          *LIBL') PROMPT('BIBLIOTHÈQUE')
 L2:         ELEM       TYPE(*CHAR) LEN(10) DFT(*NONE) MIN(0) +
                          CASE(*MIXED) CHOICE('NOM, *NONE') +
                          PROMPT('FICHIER SOURCE')
             ELEM       TYPE(*CHAR) LEN(10) DFT(*LIBOBJ) MIN(0) +
                          CHOICE('NOM, *LIBOBJ') PROMPT('BIBLIOTHÈQUE')
             ELEM       TYPE(*CHAR) LEN(10) DFT(*OBJ) MIN(0) +
                          CHOICE('NOM, *OBJ') PROMPT('MEMBRE')
 L3:         PMTCTL     CTL(FONCTION) COND((*EQ *RECDESC) (*EQ +
                          *RECPROC)) NBRTRUE(*GE 1)
