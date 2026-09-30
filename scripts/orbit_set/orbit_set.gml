function orbit_set(planet=false) {
	var body = sun;

	var r = point_distance(body.x, body.y, x, y);
	if (r < 1) return;

	var a = point_direction(body.x, body.y, x, y);
	var w = radtodeg(sqrt(GRAVITATIONAL_CONSTANT * body.mass / power(r, 3)));
	a -= w;

	var ox = x;
	var oy = y;

	x = body.x + lengthdir_x(r, a);
	y = body.y + lengthdir_y(r, a);

	if (!planet) return;

	var mx = x - ox;
	var my = y - oy;
	
	for (var i = array_length(riders) - 1; i >= 0; i--) {
		var rider = riders[i];
		if (!instance_exists(rider)) {
			array_delete(riders, i, 1);
			continue;
		}
		rider.x += mx;
		rider.y += my;
	}
	
}