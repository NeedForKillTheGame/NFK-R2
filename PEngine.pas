unit PEngine;
// blood engine
interface

type TParticle = class
                  protected
                   Visual: Integer;
                  public
                   Xpos, Ypos, Xvel, Yvel: Double;

                   Cycle: Integer;
                   alpha:cardinal;
                   Next: TParticle;
                   angl:byte;
                   maxlife,spotpattern:byte;
                   spoted:boolean;
                   constructor Create();

                   function Move(): Boolean;

                   procedure Draw();
                 end;
     TParticleEngine = class
                        private
                         ListHead: TParticle;

                         function GetCount(): Integer;
                        public
                         property Count: Integer read GetCount;

                         constructor Create();

                         procedure AddParticle(Xpos, Ypos, Xvel, Yvel: Double;long:boolean);

                         procedure Process();

                         procedure Render();
                       end;
implementation
Uses UNit1, PowerD3D, AGFUnit, DirectXGraphics,SysUtils;

constructor TParticle.Create();
begin
 inherited;

 Cycle:= 0;
 Visual:= Random(4);

 Next:= nil;
end;

function TParticle.Move(): Boolean;
var temp:byte;
    tt:integer;
begin
 Xpos:= Xpos + Xvel;
 Ypos:= Ypos + Yvel;

 Yvel:= Yvel + 0.035;
 Xvel:= Xvel * 0.99;

 if cycle > maxlife div 2 then ALPHA := trunc($FF-($FF/(maxlife/2))*(cycle - maxlife / 2)) else ALPHA := $F0;

 if SYS_BLOODRAIN=false then
 if AllBricks[trunc(xpos) div 32,trunc(ypos+3) div 16].block=true then begin
        ypos := round(ypos / 16)*16;
        xvel := 0;
        if random(2)=1 then cycle := cycle-1;
        Yvel := 0;
        end;

 Inc(cycle);
 Result:= cycle < maxlife;

end;

procedure TParticle.Draw();
var pattern:byte;
begin

        IF NOT inscreen(trunc(xpos),trunc(ypos),24) then exit;

//        MainForm.PowerGraph.Antialias := true;
        pattern := 0;

        if YPOS>4 then
        if (AllBricks[trunc(xpos) div 32,trunc(ypos) div 16].block =true)
        and (AllBricks[trunc(xpos) div 32,trunc(ypos-4) div 16].block =false) then pattern:=1;

//      MainForm.PowerGraph.RotateEffect(mainform.Images[36], Round(Xpos)+GX, GY+Round(Ypos), angl+cycle*3,alpha*2,$FFFFFFFF,pattern, effectSrcAlpha OR EffectDiffuseAlpha);

        if pattern=1 then                                                                                                                                                     
        MainForm.PowerGraph.RotateEffect(mainform.Images[36], Round(Xpos)+GX, GY+Round(Ypos)+4,64,256,(alpha shl 24)+$FFFFFF,pattern+spotpattern, effectSrcAlpha or EffectDiffuseAlpha) else
        MainForm.PowerGraph.RotateEffect(mainform.Images[36], Round(Xpos)+GX, GY+Round(Ypos), angl+cycle*(2 + spotpattern),256,(alpha shl 24)+$FFFFFF,pattern, effectSrcAlpha OR EffectDiffuseAlpha);
//      MainForm.PowerGraph.Antialias := false;
end;

constructor TParticleEngine.Create();
begin
 inherited;

 ListHead:= nil;
end;

procedure TParticleEngine.AddParticle(Xpos, Ypos, Xvel, Yvel: Double;long:boolean);
Var Particle: TParticle;
begin
 Particle:= TParticle.Create();
 Particle.Xpos:= Xpos;
 Particle.Ypos:= Ypos;
 Particle.Xvel:= Xvel;
 Particle.Yvel:= Yvel;
 Particle.Next:= ListHead;
 Particle.alpha:=$FF;
 Particle.angl := random($FF);
 Particle.spotpattern := random(2);
 if long=true then
 Particle.maxlife := 30+random(25) else
 Particle.maxlife := 30+random(10);
 Particle.spoted := false;
 ListHead:= Particle;
end;

procedure TParticleEngine.Process();
Var Aux, Temp: TParticle;
begin
 // adding one useless particle for reference purposes
 Aux:= TParticle.Create();
 Aux.Next:= ListHead;
 ListHead:= Aux;

 // moving all the particles
 while (Aux <> nil)and(Aux.Next <> nil) do
  begin
   if (not Aux.Next.Move()) then
    begin
     Temp:= Aux.Next;
     Aux.Next:= Aux.Next.Next;
     Temp.Free();
    end;
   Aux:= Aux.Next;
  end;

 // removing first reference object
 Temp:= ListHead;
 ListHead:= ListHead.Next;
 Temp.Free();
end;

procedure TParticleEngine.Render();
Var Aux: TParticle;
begin
 Aux:= ListHead;

 while (Aux <> nil) do
  begin
   Aux.Draw();

   Aux:= Aux.Next;
  end;
end;

function TParticleEngine.GetCount(): Integer;
Var Aux: TParticle;
begin
 Result:= 0;
 Aux:= ListHead;

 while (Aux <> nil) do
  begin
   Inc(Result);
   Aux:= Aux.Next;
  end;
end;

end.
