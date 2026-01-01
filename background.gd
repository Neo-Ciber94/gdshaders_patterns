@tool
extends ColorRect

@export var speed: Vector2 = Vector2(0.0, 10.0);
@export var enabled: bool = true;

func _process(delta: float) -> void:
	if not enabled:
		return;
		
	var shader_material = material as ShaderMaterial;
	var noise_texture = shader_material.get_shader_parameter("intensity_texture") as NoiseTexture2D;
	var noise = noise_texture.noise as FastNoiseLite;
	noise.offset.x += delta * speed.x;
	noise.offset.y += delta * speed.y;
