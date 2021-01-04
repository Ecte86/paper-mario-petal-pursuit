extends MarginContainer

func _physics_process(delta):
	$HBoxContainer/VBoxContainer/FPS.text = "FPS:" + str(Performance.get_monitor(Performance.TIME_FPS))
	$HBoxContainer/VBoxContainer/MemoryUsage.text = "Memory Usage:" + str(round(Performance.get_monitor(Performance.MEMORY_DYNAMIC)/1024/1024)) + " MB"
