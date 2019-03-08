      /if defined(*CRTBNDRPG)
       ctl-opt dftactgrp(*no) ACTGRP(*NEW);
      /else
       ctl-opt nomain;
      /endif
       ctl-opt Bnddir('I_BUILDER');
       ctl-opt datedit(*ymd) decedit('0,');
       ctl-opt option(*nodebugio:*srcstmt:*nounref) CCSIDCVT(*LIST);
