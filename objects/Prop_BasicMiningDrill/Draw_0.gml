
if (sprite_index == -1) return;

image_alpha = alpha;
image_angle = sin(current_time * 0.001) * tilt;
tilt = lerp(tilt, 0, 0.1);

draw_self();

if (working) {
	var turbulance = 0.016;
	image_xscale = 1 + random_range(-turbulance, turbulance);
	image_yscale = 1 + random_range(-turbulance, turbulance);
}
