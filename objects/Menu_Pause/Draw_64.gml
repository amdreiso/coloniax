
if (!show) return;

depth = 99999999;

applyBackgroundBlur();

draw_set_alpha(backgroundOpacity);
draw_rectangle_colour(0, 0, WIDTH, HEIGHT, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

index.Draw();


