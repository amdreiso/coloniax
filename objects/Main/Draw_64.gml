
GUI.Call();
CHAT.Draw();
draw_debug_ui();
CONSOLE.Draw();

showSavingIcon = max(0, showSavingIcon - 1);
if (showSavingIcon) {
	draw_sprite_ext(sIcon_Saving, current_time / 150, WIDTH - 100, HEIGHT - 100, 2, 2, 0, c_white, 1);
}
