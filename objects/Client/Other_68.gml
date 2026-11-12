var type = async_load[? "type"];

switch (type) {
	case network_type_data: {
		var buffer = async_load[? "buffer"];
        var socket = async_load[? "id"];
        var size = async_load[? "size"];
		
		network_receive_packet(buffer, socket, size);
		
		if (Debug.showNetworkPackets)
			CHAT.DebugNetwork($"CLIENT: Received packet of size '{size}'");
		break;
	}
	
	case network_type_non_blocking_connect:
		var ok = async_load[? "succeeded"];
		
		if (ok) {
			CHAT.DebugNetwork($"Connected successfully to network {address}:{port}");
		} else {
			CHAT.DebugNetwork($"Failed to connect to network {address}:{port}");
		}
		
		break;
		
	case network_type_up_failed:
		CHAT.DebugNetwork($"Connection to network {address}:{port} failed.");
		
		break;
		
	case network_type_disconnect:
		CHAT.DebugNetwork($"Disconnected.");
		
		break;
}
