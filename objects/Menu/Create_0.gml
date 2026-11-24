
blurBackground = false;

applyBackgroundBlur = function() {
	if (!blurBackground) return;
	layer_set_visible(layer_get_id("FX_Blur"), true);
}

