{*******************************************************************************

    NFK [R2]
    Ingame Menu

*******************************************************************************}

if INGAMEMENU then begin
    PowerGraph.RenderEffect(Images[94], 320-192, 50, 256+128, 0, effectSrcAlpha);

    // draws in any gametype
    if GAMEMENUORDER = 0 then
        nfkFont1.drawString('RESUME GAME',200,280,$FF0000FF,1)
    else
        nfkFont1.drawString('RESUME GAME',200,280,$FF0000CC,1);

    // Team Game
    if CanSelectTeam then begin
        if GAMEMENUORDER = 3 then nfkFont1.drawString('ADD BOTS',225,160,$FF0000FF,1)
        else nfkFont1.drawString('ADD BOTS',225,160,$FF0000CC,1);

        if GAMEMENUORDER = 4 then nfkFont1.drawString('REMOVE BOTS',200,190,$FF0000FF,1)
        else nfkFont1.drawString('REMOVE BOTS',200,190,$FF0000CC,1);

        if GAMEMENUORDER = 5 then nfkFont1.drawString('CHANGE TEAM',197,220,$FF0000FF,1)
        else nfkFont1.drawString('CHANGE TEAM',197,220,$FF0000CC,1);

        if GAMEMENUORDER = 6 then nfkFont1.drawString('RESTART ARENA',185,250,$FF0000FF,1)
        else nfkFont1.drawString('RESTART ARENA',185,250,$FF0000CC,1);

        if GAMEMENUORDER = 1 then nfkFont1.drawString('LEAVE ARENA',205,310,$FF0000FF,1)
        else nfkFont1.drawString('LEAVE ARENA',205,310,$FF0000CC,1);

        if GAMEMENUORDER = 2 then nfkFont1.drawString('EXIT GAME',225,340,$FF0000FF,1)
        else nfkFont1.drawString('EXIT GAME',225,340,$FF0000CC,1);

    end else begin
    // Not a Team Game

        if GAMEMENUORDER = 3 then nfkFont1.drawString('ADD BOTS',225,160,$FF0000FF,1)
        else nfkFont1.drawString('ADD BOTS',225,160,$FF0000CC,1);

        if GAMEMENUORDER = 4 then nfkFont1.drawString('REMOVE BOTS',200,190,$FF0000FF,1)
        else nfkFont1.drawString('REMOVE BOTS',200,190,$FF0000CC,1);

        if GAMEMENUORDER = 5 then nfkFont1.drawString('CHANGE TEAM',197,220,$FF666666,1)
        else nfkFont1.drawString('CHANGE TEAM',197,220,$FF666666,1);

        if GAMEMENUORDER = 1 then nfkFont1.drawString('LEAVE ARENA',205,310,$FF0000FF,1)
        else nfkFont1.drawString('LEAVE ARENA',205,310,$FF0000CC,1);

        if GAMEMENUORDER = 2 then nfkFont1.drawString('EXIT GAME',225,340,$FF0000FF,1)
        else nfkFont1.drawString('EXIT GAME',225,340,$FF0000CC,1);

        if MATCH_DEMOPLAYING then begin
            // IF DEMO
            if GAMEMENUORDER = 6 then
                nfkFont1.drawString('RESTART DEMO',200,250,$FF0000FF,1)
            else
                nfkFont1.drawString('RESTART DEMO',200,250,$FF0000CC,1);
        end else
            // Not a Demo
            if GAMEMENUORDER = 6 then
                nfkFont1.drawString('RESTART ARENA',185,250,$FF0000FF,1)
            else
                nfkFont1.drawString('RESTART ARENA',185,250,$FF0000CC,1);

        //if GAMEMENUORDER = 3 then GAMEMENUORDER := 2;  // ?
    end;

end else if SYS_TEAMSELECT>0 then begin
    PowerGraph.RenderEffect(Images[94], 320-128, 80, 256, 0, effectSrcAlpha);
    
    //PowerGraph.FillRect(208,175,224,100,COLORARRAY[OPT_GAMEMENUCOLOR],effectMul);
    //ParseCenterColorText('^3Select team' ,180,4);
    nfkFont1.drawString('SELECT TEAM', 205, 180,$FF00FFFF,1);

    if GAMEMENUORDER = 0 then
        nfkFont1.drawString('AUTO',265,220,$FF0000FF,1)
    else
        nfkFont1.drawString('AUTO',265,220,$FF0000CC,1);

    if GAMEMENUORDER = 1 then
        nfkFont1.drawString('RED',275,250,$FF0000FF,1)
    else
        nfkFont1.drawString('RED',275,250,$FF0000CC,1);

    if GAMEMENUORDER = 2 then
        nfkFont1.drawString('BLUE',270,280,$FF0000FF,1)
    else
        nfkFont1.drawString('BLUE',270,280,$FF0000CC,1);

end;