
/**
 * Broadcasts a packet to every connected client
 * @param {Buffer} buffer 
 * @param {Real} exclude
 */
function network_broadcast(buffer, exclude = -1) {
	if (!instance_exists(Host)) {
		return;
	}
	
	var size = buffer_tell(buffer);
	var client = ds_map_find_first(Host.clients);
	
	while (!is_undefined(client)) {
		if (client != exclude) {
			network_send_packet(client, buffer, size);
		}
		client = ds_map_find_next(Host.clients, client);
	}
}
