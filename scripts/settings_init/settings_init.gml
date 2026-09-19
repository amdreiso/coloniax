
function settings_init() {
	G Settings;
	Settings = settings_get();
	
}

function settings_get(){
	var stt = {};
	
	stt.camera = {
		shakeIntensity: 1,
	}
	
	stt.graphics = {
		lighting: true,
	}
	
	return stt;
}

