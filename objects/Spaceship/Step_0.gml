

if (isPuppet) {
	// Interpolate position
	var lerpAmount = 0.1;
	
	x = lerp(x, newx, lerpAmount);
	y = lerp(y, newy, lerpAmount);
}


if (Paused || isPuppet) return;

event_inherited();

// Controls
if (controlling) {
	if (instance_exists(Player)) {
		Player.x = x;
		Player.y = y;
	}
	
	SOUND.ListenerPosition(x, y);
	
	var ty = y+4;
	var mx = mouse_x, my = mouse_y;
	mouseAngle = point_direction(x, ty, mx, my);
}

turretSpriteShootingCooldown = max(0, turretSpriteShootingCooldown - 1);

canMove = (!player.ejected && !Debug.console && !CHAT.open && !KeyboardBusy);
pilot();
shoot();

angle = dir;

// Apply movement
hsp = lengthdir_x(spd, dir);
vsp = lengthdir_y(spd, dir);

if (!stationed) {
	orbit_set();
}

x += hsp + knockback.x;
y += vsp + knockback.y;

knockback.x = lerp(knockback.x, 0, 0.03);
knockback.y = lerp(knockback.y, 0, 0.03);

// Player
checkPlanetCollision();

if (keyboard_check_pressed(vk_space)) {
	if (!player.ejected && canMove) {
		ejectPlayer();
	} else if (player.ejected) {
		boardPlayer();
	}
}

if (keyboard_check(vk_control)) {
	if (mouse_check_button(mb_left)) {
		x += (x - mouse_x) * 0.1 * -1;
		y += (y - mouse_y) * 0.1 * -1;
	}
}

