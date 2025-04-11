extends CanvasLayer

@onready var status_label = $VBoxContainer/StatusLabel

func _ready():
	var label = get_node("VBoxContainer/StatusLabel")
	if label == null:
		printerr("Error: StatusLabel node not found! Check the node path.")
	else:
		print("StatusLabel node found:", label)
	updateDisplay()

func updateDisplay():
	if Questmanager.quest_active:
		status_label.text = "Quest Active"
	else:
		status_label.text = "No Quest Active"
