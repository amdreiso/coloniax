
var w = WIDTH;
var h = HEIGHT;
var cx = w/2;
var cy = h/2;
var spd = starSpeed;

for (var i = 0; i < array_length(stars); i++) {
	var s = stars[i];
	var alpha = 1;
	
	if (irandom(100) < 1) {
		alpha = random(0.50);
	}
	
	s.x += (s.x - cx) / w * spd;
	s.y += (s.y - cy) / w * spd;
	
	if (s.x < 0 || s.x > w || s.y < 0 || s.y > h) {
		array_delete(stars, i, 1);
		createStar();
		continue;
	}
	
	draw_set_alpha(s.alpha * alpha);
	if (s.dot) {
		draw_point_color(s.x, s.y, s.color);
	} else {
		draw_circle_color(s.x, s.y, 1, s.color, s.color, false);
	}
	draw_set_alpha(1);
}


var sw = sprite_get_width(sIcon_Logo_1);
var sh = sprite_get_height(sIcon_Logo_1);
var size = window_get_width() / sw;

var logoscale = min(1, size);

var yy = max(window_get_height()/4, sh/2);

draw_sprite_ext(sIcon_Logo_1, 0, WIDTH/2, yy, logoscale, logoscale, 0, c_white, 1);

index.Draw();

ALIGN_BOTTOM_LEFT;
draw_text(0, HEIGHT, currentBuild);

