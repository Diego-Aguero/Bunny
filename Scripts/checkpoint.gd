extends Area2D

@export var checkpoint_id: int = 0
#@onready var anim_player = $AnimationPlayer 

func _ready():

   # if GameManager.current_checkpoint_id >= checkpoint_id:
        #if anim_player: anim_player.play("activated_idle") 
    
    if GameManager.last_checkpoint_position == Vector2.ZERO and checkpoint_id == 0:
        pass

func _on_body_entered(body):
    if body.is_in_group("Player"):
        if checkpoint_id > GameManager.current_checkpoint_id:
            GameManager.current_checkpoint_id = checkpoint_id
            GameManager.last_checkpoint_position = global_position
            
            print("Checkpoint ", checkpoint_id, " activado.")
           # if anim_player: anim_player.play("activate")