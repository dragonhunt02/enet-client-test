extends Node
var server_started = false

func _ready() -> void:
	if Engine.is_editor_hint() or server_started:
		return
	# 1. Create and start an ENet server on UDP port 4444
	var enet = ENetMultiplayerPeer.new()
	var err = enet.create_server(4444, 8, 4 )
	# max_peers = 8, channels = 4
	if err != OK:
		push_error("Failed to start ENet server: %d" % err)
		return
	server_started = true

	# 2. Hook it into Godot's MultiplayerAPI
	multiplayer.multiplayer_peer = enet

	# 3. When any client connects, send them "hello world"
	multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(peer_id: int) -> void:
	var msg = "hello world"
	var buf = msg.to_utf8_buffer()
	# send_bytes() defaults to channel 0 and reliable delivery
	multiplayer.send_bytes(buf)
	print("📤 Sent raw packet to peer %d: '%s'" % [peer_id, msg])
