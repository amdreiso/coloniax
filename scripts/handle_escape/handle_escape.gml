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

		//if (instance_exists(Menu_Script)) {
		//	instance_destroy(Menu_Script);
		//	window_set_cursor(cr_default);
		//	return;
		//}

		//if (instance_exists(Menu_Pause)) {
		//	Menu_Pause.close();
		//	window_set_cursor(cr_default);
		//	return;
		//}
		
		if (instance_exists(Menu)) {
			instance_destroy(Menu);
			KeyboardBusy = false;
			CursorBusy = false;
			return;
		}
			
		if (room != rmMenu) {
			instance_create_depth(0, 0, depth, Menu_Pause);
		}
	}
}
