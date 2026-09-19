function orbit_set(){
	var body = sun;
	
	var dx = body.x - x;
	var dy = body.y - y;

	var r = point_distance(x, y, body.x, body.y);
	var a = point_direction(x, y, body.x, body.y);
	
	var orbital_speed = sqrt(GRAVITATIONAL_CONSTANT * body.mass / r);
	
	x += lengthdir_x(orbital_speed, a + 90);
	y += lengthdir_y(orbital_speed, a + 90);
}