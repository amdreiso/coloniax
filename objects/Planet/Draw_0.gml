
if (surface_exists(surface)) {
	drawPlanet();
	
} else {
	generateSurface();
	
}

var outlineSpeed = 0.5;
if (hovering) {
	outlineSize = lerp(outlineSize, 1, outlineSpeed);
} else {
	outlineSize = lerp(outlineSize, 0, outlineSpeed);
}

if (outlineSize > 0.05) {
	draw_sprite_ext(sIcon_Border, 0, left, top, outlineSize, outlineSize, 0, c_white, 1);
	draw_sprite_ext(sIcon_Border, 0, right, top, outlineSize, outlineSize, -90, c_white, 1);
	draw_sprite_ext(sIcon_Border, 0, right, bottom, outlineSize, outlineSize, -180, c_white, 1);
	draw_sprite_ext(sIcon_Border, 0, left, bottom, outlineSize, outlineSize, -270, c_white, 1);
}

if (Debug.showDebugUI) {
	draw_circle_colour(x, y, 4, c_blue, c_blue, false);
	draw_ellipse(left, top, right, bottom, true);
}
