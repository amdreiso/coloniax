
draw_set_font(fnt_main);

GUI.Call();
CHAT.Draw();
draw_debug_ui();
CONSOLE.Draw();

showSavingIcon = max(0, showSavingIcon - 1);
if (showSavingIcon) {
	var margin = 50;
	draw_sprite_ext(sIcon_Saving, current_time / 150, WIDTH - margin, margin, 1, 1, 0, c_white, 1);
}

//shader_set(shd_blur);
//shader_set_uniform_f(shader_get_uniform(shd_blur, "resolution"), WIDTH, HEIGHT);
//shader_set_uniform_f(shader_get_uniform(shd_blur, "direction"), 1, 0);

//shader_set(shd_blur);
//shader_set_uniform_f(shader_get_uniform(shd_blur, "resolution"), WIDTH, HEIGHT);
//shader_set_uniform_f(shader_get_uniform(shd_blur, "direction"), 0, 1);

//application_surface_draw_enable(false);

//draw_surface_stretched(application_surface, 0, 0, window_get_width(), window_get_height());

//shader_reset();
//shader_reset();

ALIGN_BOTTOM_LEFT;
draw_text(0, HEIGHT, currentBuild);
ALIGN_MIDDLE_CENTER;
