{*******************************************************************************

    NFK [R2]
    Sound Library

    Header

    Contains:

        procedure loadSamples;
        procedure ErrorSound;
        procedure PAINSOUNDZZ(F : TPlayer);

    See also:

        inc__r2sound.pas            // implementation

*******************************************************************************}

type r2sound = class
  public

    Stream: PFSoundStream;
    SAMPLES:array[0..5000] of PFSoundSample;

    listenerPos: array[0..2] of single;
    sampleFormat:longint;
    maxSound : word;

    Player : TMediaPlayer;

    constructor Create;

    procedure loadSamples;
    procedure play(SNDINDEX : word;x,y : real);
    procedure musicStop;
    procedure musicReset;
    procedure musicPlay;
    procedure musicStart(id : byte);
    procedure playerNotify(Sender: TObject);
    procedure AppClose(i:word);
    procedure Pain(var F : TPlayer);
    procedure ErrorSound;
    procedure loadModelSounds();
    procedure commentPlay(par: string; st: string);

end;
