
if (Paused) return;

event_inherited();

// Controls
if (controlling) {
	Player.x = x;
	Player.y = y;
	
	SOUND.ListenerPosition(x, y);
	
	var ty = y+4;
	var mx = mouse_x, my = mouse_y;
	mouseAngle = point_direction(x, ty, mx, my);
}

turretSpriteShootingCooldown = max(0, turretSpriteShootingCooldown - 1);

canMove = (!player.ejected && !Debug.console && !CHAT.open);
pilot();
shoot();

angle = dir;

// Apply movement
hsp = lengthdir_x(spd, dir);
vsp = lengthdir_y(spd, dir);

if (!stationed) orbit_set();

x += hsp + knockback.x;
y += vsp + knockback.y;

knockback.x = lerp(knockback.x, 0, 0.03);
knockback.y = lerp(knockback.y, 0, 0.03);

// Player
if (instance_exists(Planet)) {
	var planet = instance_nearest(x, y, Planet);
	
	var dx = x - planet.x;
	var dy = y - planet.y;
	var rx = planet.radius;
	var ry = planet.radius / 2;

	//var spaceshipCollision = (distance_to_object(Spaceship) < radius / 2);
	onPlanet = ((dx * dx) / (rx * rx) + (dy * dy) / (ry * ry) <= 1);
}

if (keyboard_check_pressed(vk_space)) {
	if (!player.ejected && canMove) {
		ejectPlayer();
	} else if (player.ejected) {
		boardPlayer();
	}
}


if (keyboard_check(vk_control)) {
	if (mouse_check_button_pressed(mb_left)) {
		x = mouse_x;
		y = mouse_y;
	}
}
