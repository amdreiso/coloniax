function handle_escape(){
	if (keyboard_check_pressed(vk_escape)) {
		if (CHAT.open) {
			CHAT.Close();
			return;
		}
		// pause menu opens here
	}
}