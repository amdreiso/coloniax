
var lag = 0;
var len = array_length(slots);
var spd = 0, maxspd = 0;

var rows = ceil(len / columns);
for (var i = 0; i < len; i++) {
	var obj = slots[i];
	var col = (i % columns);
	var row = floor(i / columns);

	var even = (row % 2 == 0); 

	var xoff = (row - (rows - 1)/2) * spacing;
	var yoff = (col - (columns - 1)/2) * spacing;

	obj.target = new Vec2(
		x + lengthdir_x(xoff, dir) + lengthdir_x(yoff, dir + 90),
		y + lengthdir_y(xoff, dir) + lengthdir_y(yoff, dir + 90)
	);

	lag += point_distance(obj.x, obj.y, obj.target.x, obj.target.y);
	spd += obj.spd;
	maxspd += obj.maxSpeed;
}

var average = max(spd / len, (maxspd / len));
var averageLag = lag / len;
var slowdown = 1 - clamp(averageLag / 1000, 0, 1);

dir += 0.1;

direction = dir;
speed = average * slowdown;

