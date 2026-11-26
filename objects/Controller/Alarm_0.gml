
/// @desc Network: send input packet

alarm_set(0, 2);

if (isPuppet) return;
if (!network_client_exists()) return;

var b = buffer_create(1024, buffer_grow, 1);
buffer_write(b, buffer_u8, NET.PLAYER_INPUT);
buffer_write(b, buffer_f32, x);
buffer_write(b, buffer_f32, y);
buffer_write(b, buffer_s16, dir);
network_send_packet(Client.socket, b, buffer_tell(b));
buffer_delete(b);

