unit PowerAcrModuleInfo;

interface

const
  PowerArcModuleSignature = 'AA6F3C60-37D7-11D4-B4BF-D80DBEC04C01';

type
  TPowerArcModuleInfo = packed record
    Signature:   PChar; // must be eq to PowerArcModuleSignature
    Name:        PChar; // short name
    Description: PChar; // full description
    Options:     PChar; // opt list delimited with #0
    // bit per char on calgary corpus *100
    DefaultBPC:  integer;
    MaxBPC:      integer; 
    case integer of     // unique
      0: ( ModuleID:    packed array[0..7] of Char );
      1: ( ModuleIDW:   packed array[0..1] of integer );
  end;
  PPowerArcModuleInfo = ^TPowerArcModuleInfo;
  
implementation

end.
