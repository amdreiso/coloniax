
event_inherited();

sprite_index = sEnemy_Destroyer_2;

range = 1000;
ai = eEnemyAI.FOLLOWER;

targetDeviationTime = 2;
targetDeviationStrength = 5;

//array_push(targets, Spaceship);

hp = 100;

onMove.Register(function(){
	var xx, yy;
	var r = 4;
	var val = 2;
	xx = x - lengthdir_x(10, dir);
	yy = y - lengthdir_y(10, dir);
	
	var n = ceil(val * (spd / maxSpeed));
	
	var emitter = part_emitter_create(World.ps);
	part_emitter_region(World.ps, emitter, xx - r, xx + r, yy - r, yy + r, ps_shape_rectangle, ps_distr_gaussian);
	part_emitter_burst(World.ps, emitter, World.particleFire, n);
	part_emitter_destroy(World.ps, emitter);
});

