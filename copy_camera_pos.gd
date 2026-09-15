extends Node3D

@export var snap_scale: float;
@export var copy_source: Camera3D;

func _process(_delta: float) -> void:
	var snapped_pos: Vector3 = self.copy_source.global_position;
	snapped_pos /= self.snap_scale;
	snapped_pos = round(snapped_pos);
	snapped_pos *= self.snap_scale;
	snapped_pos *= Vector3(1,0,1);
	self.global_position = snapped_pos;
