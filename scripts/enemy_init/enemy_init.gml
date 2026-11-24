
function enemy_init(){
	enum eEnemyAI {
		NO_AI,
		SUICIDE_BOMBER,
		FOLLOWER,
	}

	enum eEnemyState {
		IDLING,
		FOLLOWING,
	}
}

function enemy_ai_suicide_bomber(obj) {
	with (obj) {

	if (target == noone && !is_struct(target)) return;

	applyDeviation();
	steerTowardsTarget(20);

	// Movement
	spd = min(maxSpeed, spd + acceleration);

	hsp = lengthdir_x(spd, dir);
	vsp = lengthdir_y(spd, dir);
	
	}
}

function enemy_ai_follower(obj) {
	with (obj) {
	
	if (target == noone && !is_struct(target)) return;

	applyDeviation();
	steerTowardsTarget(1);
	
	var distance = point_distance(x, y, target.x, target.y);
	var arrivalRadius = 200;

	desiredSpeed = maxSpeed * min(1, distance / arrivalRadius);
	spd = lerp(spd, desiredSpeed, 0.05);

	hsp = lengthdir_x(spd, dir);
	vsp = lengthdir_y(spd, dir);

	}
}

function enemy_apply_ai(obj) {
	var type = obj.ai;
	
	switch (type) {
		case eEnemyAI.NO_AI: break;
		case eEnemyAI.SUICIDE_BOMBER: enemy_ai_suicide_bomber(obj); break;
		case eEnemyAI.FOLLOWER: enemy_ai_follower(obj); break;
	}
}

