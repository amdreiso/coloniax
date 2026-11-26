
drawPlanet();

var outlineSpeed = 0.5;
if (hovering) {
	outlineSize = lerp(outlineSize, 1, outlineSpeed);
	
	var p = self;
	
	if (mouse_check_button_released(mb_left) && !instance_exists(Menu_Planet)) {
		Camera.setTarget(self);
		Camera.returnToPreviousTarget(function(){
			return (point_distance(Camera.target.x, Camera.target.y, Camera.previousTarget.x, Camera.previousTarget.y) > interactionRange);
		});

		spawn(window_mouse_get_x(), window_mouse_get_y(), 0, Menu_Planet, {
			planet: p,
		});
	}
	
} else {
	outlineSize = lerp(outlineSize, 0, outlineSpeed);
}

if (outlineSize > 0.05) {
	draw_boundaries(outlineSize);
}

if (Debug.showHitboxes) {
	draw_circle_colour(x, y, 4, c_blue, c_blue, false);
	draw_ellipse(left, top, right, bottom, true);
}

