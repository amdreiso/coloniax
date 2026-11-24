
if (Paused) return;

orbit_set();

var list = ds_list_create();
var num = collision_circle_list(x, y, range, targets, false, false, list, false);
if (num) {
	target = list[| 0];
}

if (place_meeting(x, y, Projectile)) {
	var proj = instance_nearest(x, y, Projectile);
	hp -= 10;
	instance_destroy(proj);
}

if (hp <= 0) {
	instance_destroy();
}

enemy_apply_ai(self);

moving = (hsp != 0 || vsp != 0);

x += hsp;
y += vsp;

if (moving) {
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
}

