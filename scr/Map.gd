extends Node2D

var range_of_movement = Array()
var active_piece
var turn = "white"

var clickable = true
onready var player_colors = get_node('/root/PlayerColors').colors

func _ready():
	$TileMap.place_pieces ()
	$TileMap.visible = true
	
	$Camera2D.camera_following($TileMap)
	
	for button in $HUD/PromotionBox.get_children ():
		button.connect ('pressed', self, '_on_Promotion_pressed', [button.text])
	
func _unhandled_input(event):
	
	if event is InputEventMouseButton:
		if event.pressed and clickable and turn in player_colors:
			var clicked_cell = $TileMap.world_to_map(get_global_mouse_position())

			if clicked_cell in range_of_movement:
				range_of_movement = []
				
				if clicked_cell in $TileMap.npc_coord():
					for piece in $TileMap.npc_list:
						if piece.tile_position == clicked_cell and piece !=active_piece:
							$TileMap.npc_die(piece)
				
				for tile in $TileMap.jumped_over_tiles:
					if clicked_cell == tile and 'Pawn' in active_piece.name:
						$TileMap.npc_die($TileMap.jumped_over_tiles[clicked_cell])
							
				active_piece.position = $TileMap.map_to_world(clicked_cell)
				active_piece.tile_position = clicked_cell
				$TileMap.draw_map ()
				
				for tile in $TileMap.passable_tiles:
					if $TileMap.passable_tiles[tile] == active_piece:
						$TileMap.jumped_over_tiles[tile] = active_piece

				$TileMap.passable_tiles = {}
				
				if 'Pawn' in active_piece.name and clicked_cell in $TileMap.promotion_tiles:
					$HUD/PromotionBox.visible = true
					clickable = false
				
				if turn == 'white':
					turn = 'black'
				else:
					turn = 'white'
				
				$TileMap.clean_up_jumped_over (turn)
				
				if $TileMap.check_checkmate_stalemate(turn):
					clickable = false
					$HUD/GameOver.text = turn + ' is ' + $TileMap.check_checkmate_stalemate(turn)
					$HUD/GameOver.visible = true
					$HUD/TryAgain.visible = true
				
			elif clicked_cell in $TileMap.npc_coord():
				var piece = $TileMap.npc_coord()[clicked_cell]
				if piece.tile_position == clicked_cell and piece.color == turn:
					$TileMap.draw_map ()
					range_of_movement = $TileMap.check_check(piece, $TileMap.find_possible_moves(piece, clicked_cell))
					active_piece = piece
					$TileMap.set_cells (range_of_movement, 4)
						
func _on_TryAgain_pressed():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func _on_Promotion_pressed(piece):
	$TileMap.promote_pawn(active_piece, piece)
	clickable = true
	$HUD/PromotionBox.visible = false