
/// @desc - NET: Update current game state

// Update state of all thingies
alarm_set(0, 2);

var b = buffer_create(256, buffer_grow, 1);
buffer_write(b, buffer_u8, NET.STATE);

// Sync all players according to host
buffer_write(b, buffer_u8, ds_map_size(players));
var k = ds_map_find_first(players);
while (!is_undefined(k)) {
    var p = players[? k];
    buffer_write(b, buffer_u8, k);
    buffer_write(b, buffer_f32, p.x);
    buffer_write(b, buffer_f32, p.y);
    buffer_write(b, buffer_s16, p.dir);
    k = ds_map_find_next(players, k);
}

network_broadcast(b, -1);

buffer_delete(b);

