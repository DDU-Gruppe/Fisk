extends Node

@onready var slot0_label: Label = $VBoxContainer/Slot0/Label
@onready var slot1_label: Label = $VBoxContainer/Slot1/Label2
@onready var slot2_label: Label = $VBoxContainer/Slot2/Label3
@onready var slot3_label: Label = $VBoxContainer/Slot3/Label4

func _process(_delta):
	update_fish_counts()

func update_fish_counts():
	var counts = DatabaseManager.get_fish_counts()
	slot0_label.text = str(counts.get("laks", 0))
	slot1_label.text = str(counts.get("torsk", 0))
	slot2_label.text = str(counts.get("bluefish", 0))
	slot3_label.text = str(counts.get("tun", 0))
