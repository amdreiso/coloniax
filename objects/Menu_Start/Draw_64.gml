
starLightspeed = (keyboard_check(ord("W")));

if (starLightspeed) {
	starSpeed = lerp(starSpeed, 100, 0.01);
} else {
	starSpeed = lerp(starSpeed, 5, 0.02);
}

var w = WIDTH;
var h = HEIGHT;
var cx = w/2;
var cy = h/2;

for (var i = 0; i < array_length(stars); i++) {
	var s = stars[i];
	var alpha = 1;
	
	if (irandom(100) < 1) {
		alpha = random(0.50);
	}
	
	var spd = starSpeed * s.spd;
	
	s.old = new Vec2(s.x, s.y);
	s.x += (s.x - cx) / w * spd;
	s.y += (s.y - cy) / w * spd;
	
	if (s.x < 0 || s.x > w || s.y < 0 || s.y > h) {
		array_delete(stars, i, 1);
		createStar();
		continue;
	}
	
	if (!starLightspeed) {
		//if (s.dot)	draw_point_color(s.x, s.y, s.color);
		//else		draw_circle_color(s.x, s.y, 1, s.color, s.color, false);
		var width = (s.dot) ? 2 : 1;
		draw_line_width_color(s.old.x, s.old.y, s.x, s.y, width, s.color, s.color);

	} else {
		var width = (s.dot) ? 2 : 1;
		draw_line_width_color(s.old.x, s.old.y, s.x, s.y, width, s.color, s.color);

	}
}

var sw = sprite_get_width(sIcon_Logo_1);
var sh = sprite_get_height(sIcon_Logo_1);
var size = window_get_width() / sw;
var logoscale = min(1, size);
var yy = max(window_get_height()/4, sh/2);

var lx = WIDTH/2;
var ly = yy;

draw_sprite_ext(sIcon_Logo_1, 0, WIDTH/2, yy, logoscale, logoscale, 0, c_white, 1);

// Planet
var pox = 79 * logoscale;
var poy = 63 * logoscale;

isPlanetSpinning = max(0, isPlanetSpinning-1);
var pangle = (sin(current_time * 0.01) * 5) * (isPlanetSpinning / isPlanetSpinningTime);

draw_sprite_ext(sIcon_Logo_Planet, (current_time / 50), lx + pox, ly - poy, logoscale, logoscale, pangle, c_white, 1);

var mx = window_mouse_get_x();
var my = window_mouse_get_y();
var r = 64;
var xx = lx + pox, yy = ly + poy;
if (mx > xx-r && mx < xx+r && my > yy-r && my < yy+r) {
	draw_text(mx, my, "collising");
	if (mouse_check_button_pressed(mb_left)) {
		var t = 120;
		isPlanetSpinning = t;
		isPlanetSpinningTime = t;
	}
}

index.Draw();

