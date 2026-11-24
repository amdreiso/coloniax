
sun = instance_nearest(x, y, Sun);
orbitRadius = point_distance(sun.x, sun.y, x, y);
orbitAngle = point_direction(sun.x, sun.y, x, y);

target = noone;
targets = [];
targetDirection = 0;
targetDeviationStrength = 30;
targetDeviation = irandom_range(-targetDeviationStrength, targetDeviationStrength);
targetDeviationTime = irandom(5 * 60);

range = 50;
ai = eEnemyAI.NO_AI;

hsp = 0;
vsp = 0;

acceleration = 0.015;
deceleration = 0.005;
maxTurnSpeed = 1.05;
turnSpeed = 0;
turnForce = 0.085;
spd = 0;
desiredSpeed = 0;
maxSpeed = 4;
dir = irandom(360);

// health
hp = 30;

checkProjectileCollision = function() {
	if (place_meeting(x, y, Projectile)) {
		var proj = instance_nearest(x, y, Projectile);
		hp -= 10;
		instance_destroy(proj);
	}
}

die = function() {
	instance_destroy();
}

checkDeath = function() {
	if (hp <= 0) {
		die();
	}
}

lookForTargets = function() {
	var list = ds_list_create();
	var num = collision_circle_list(x, y, range, targets, false, false, list, false);
	if (num) {
		target = list[| 0];
	}
}

applyDeviation = function() {
	var ds = targetDeviationStrength;
	if (ds == 0) return;

	targetDeviationTime = max(0, targetDeviationTime - 1);

	if (targetDeviationTime == 0) {
		targetDeviation = irandom_range(-ds, ds);
		targetDeviationTime = irandom(100);
	}
}

steerTowardsTarget = function(error = 10) {
	var d = targetDeviation;
	targetDirection = point_direction(x, y, target.x, target.y) + d;

	var diff = angle_difference(targetDirection, dir);
	var step = sign(diff);

	if (abs(diff) <= error) {
	    turnSpeed = max(0, turnSpeed - deceleration);
	} else {
	    turnSpeed = min(maxTurnSpeed, turnSpeed + turnForce);
	}

	dir += turnSpeed * step;
}

onMove = new Callback();

