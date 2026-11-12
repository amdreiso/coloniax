
sprite_index = sEnemy_Mercenary;

sun = instance_nearest(x, y, Sun);

orbitRadius = point_distance(sun.x, sun.y, x, y);
orbitAngle = point_direction(sun.x, sun.y, x, y);

target = noone;
targets = [Spaceship];
targetDir = 0;

range = 300;
ai = eEnemyAI.SUICIDE_BOMBER;

hsp = 0;
vsp = 0;

acceleration = 0.015;
deceleration = 0.005;
maxTurnSpeed = 1.05;
turnSpeed = 0;
turnForce = 0.085;
spd = 0;
maxSpeed = 4;
dir = irandom(360);

// health
hp = 30;


