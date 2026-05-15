class_name CutsceneContext

# Just in case we need this class? Not sure we do yet, but it's nice to have jic
var ContextDict = {}
var CurrentDialogWindow : DialogueWindow
var WindowAnchor : Node2D


func CleanUp():
	if CurrentDialogWindow != null:
		CurrentDialogWindow.queue_free()
