
var size = 1;
var pos = getChunkPosition(Spaceship.x, Spaceship.y);

for (var i = -1; i <= size; i++) {
	for (var j = -1; j <= size; j++) {
		var xx, yy;
		xx = pos.x + i;
		yy = pos.y + j;
		
		var keypos = chunkGetKey(xx, yy);
		
		if (chunks[$ keypos] == undefined) {
			array_push(job, {x: xx, y: yy});
			continue;
		}
		
		chunks[$ keypos].Draw();
	}
}

var keys = variable_struct_get_names(chunks);

for (var i = 0; i < array_length(keys); i++) {
    var key = keys[i];
    var chunk = chunks[$ key];

    if (abs(chunk.x - pos.x) > size ||
        abs(chunk.y - pos.y) > size) {
        
        chunk.Unload();
        variable_struct_remove(chunks, key);
    }
}
