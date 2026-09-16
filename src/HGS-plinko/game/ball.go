components {
  id: "ball"
  component: "/scripts/game/ball.script"
  properties {
    id: "jump_landing_offset"
    value: "20.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "time_scale"
    value: "1.0"
    type: PROPERTY_TYPE_NUMBER
  }
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"ball_1\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/textures/plinko.atlas\"\n"
  "}\n"
  ""
}
