
var time = current_time + timeOffset;
image_xscale = sin(time * 0.003) * 1;
image_angle = sin(time * 0.0075) * 2;

draw();
