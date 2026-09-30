
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
	draw_boundaries(outlineSize);
}

if (Debug.showDebugUI) {
	draw_circle_colour(x, y, 4, c_blue, c_blue, false);
	draw_ellipse(left, top, right, bottom, true);
}
