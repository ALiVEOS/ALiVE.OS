_dir = random 359;
titleText ["Traveling to Base Location", "BLACK OUT", 8];
sleep 10;
player SetPos [(getPos USBASE select 0)-5*sin(_dir),(getPos USBASE select 1)-5*cos(_dir)];
sleep 2;
titleText ["", "BLACK IN", 8];
