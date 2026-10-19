
layer_set_visible(layer_get_id("Glow"), Settings.graphics.lighting);
layer_enable_fx(layer_get_id("Sun"), Settings.graphics.lighting);

repeat (1) {
	if (array_length(job) == 0) continue;
	var j = array_pop(job);
	var keypos = chunkGetKey(j.x, j.y);
	
	if (chunks[$ keypos] != undefined) continue;
	
	chunks[$ keypos] = new World_Chunk(j.x, j.y);
	chunks[$ keypos].Load();
}

