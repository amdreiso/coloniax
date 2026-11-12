
function enemy_init(){
	enum eEnemyAI {
		NO_AI,
		SUICIDE_BOMBER,
	}
}

function enemy_ai_suicide_bomber(obj) {
	with (obj) {
	
	if (target != noone) {
		targetDir = point_direction(x, y, target.x, target.y);
		var error = 20;
		var step = (dir < targetDir) ? 1 : -1;
		
		// Stop turning if under margin of error
		if (dir > targetDir-error && dir < targetDir+error) {
			turnSpeed = max(0, turnSpeed - deceleration);
			dir += (turnSpeed) * step;
			
		}
		// if direction is too discrepant start TURNING
		else {
			turnSpeed = min(maxTurnSpeed, turnSpeed + turnForce);
			dir += (turnSpeed) * step;
			
		}
		
		spd = min(maxSpeed, spd + acceleration);
		hsp = lengthdir_x(spd, dir);
		vsp = lengthdir_y(spd, dir);
	}
	
	}
}

function enemy_apply_ai(obj) {
	var type = obj.ai;
	
	switch (type) {
		case eEnemyAI.NO_AI: break;
		case eEnemyAI.SUICIDE_BOMBER: enemy_ai_suicide_bomber(obj); break;
	}
}
