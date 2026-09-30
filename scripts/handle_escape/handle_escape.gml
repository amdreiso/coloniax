function handle_escape(){
	if (keyboard_check_pressed(vk_escape)) {
		if (Debug.console) {
			Debug.console = false;
			return;
		}
		
		if (CHAT.open) {
			CHAT.Close();
			return;
		}
		
		if (instance_exists(PauseMenu)) {
			PauseMenu.close();
			window_set_cursor(cr_default);
			return;
		}
		
		instance_create_depth(0, 0, depth, PauseMenu);
	}
}