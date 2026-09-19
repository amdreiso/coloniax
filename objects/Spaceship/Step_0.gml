
event_inherited();

// Controls
if (controlling) {
	Player.x = x;
	Player.y = y;
}

canMove = (!player.ejected && !Debug.console && !CHAT.open);
pilot();

angle = dir;

// Apply movement
hsp = lengthdir_x(spd, dir);
vsp = lengthdir_y(spd, dir);

orbit_set();

x += hsp;
y += vsp;

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
	if (mouse_check_button(mb_left)) {
		x = mouse_x;
		y = mouse_y;
	}
}
