function network_client_exists(){
	return (instance_exists(Client) && Client.socket != -1);
}