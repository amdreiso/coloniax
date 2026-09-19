
if (!controlling) return;

event_inherited();

canMove = (!Debug.console && !CHAT.open);

getInput();
applyCollisions();

multiplier = getMultiplier();

multiplier.spd = max(0, 1 - (0.5 * onLava));

spd = defaultSpd * multiplier.spd;

applyMovement();

orbit_set();

var yy = planet.top - y;
depth = planet.depth + floor(yy / floor(TILE_HEIGHT / 2));

if (mouse_check_button(mb_left)) {
	if (instance_exists(Prop)) {
		var inst = instance_nearest(x, y, Prop);
		if (distance_to_object(inst) < reach) {
			inst.hit();
			swing = min(1, swing + 0.1);
		}
	}
	
} else {
	swing = max(0, swing - 0.1);
}

effect.Call("update");
effect.Apply();


