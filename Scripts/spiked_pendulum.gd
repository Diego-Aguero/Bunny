extends StaticBody2D

# Estas variables serán visibles y editables desde el inspector en la escena padre.
@export var impulse_x: int = 300
@export var impulse_y: int = 0
@export var direction: int = 1  # 1 = derecha, -1 = izquierda
@export var threshold: float = 0.1

# Referencia al nodo RigidBody2D que contiene el código del spiked pendulum.
@onready var spiked_rigid: RigidBody2D = $SpikedPendulumRigid

func _ready():
	# Asignamos los valores exportados del padre al hijo.
	spiked_rigid.set_impulse_parameters(impulse_x, impulse_y, direction, threshold)
	
# lower -0.785 y Upper 0.785 para ±45° en el pinjoint para que se mueva como un pendulo invertido.
