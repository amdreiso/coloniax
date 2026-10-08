
if (sprite_index == -1) return;

image_alpha = alpha;
image_angle = sin(current_time * 0.001) * tilt;
tilt = lerp(tilt, 0, 0.1);

draw_self();
