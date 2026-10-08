
GUI.Call();
CHAT.Draw();
draw_debug_ui();
CONSOLE.Draw();

showSavingIcon = max(0, showSavingIcon - 1);
if (showSavingIcon) {
	var margin = 50;
	draw_sprite_ext(sIcon_Saving, current_time / 150, WIDTH - margin, margin, 1, 1, 0, c_white, 1);
}
