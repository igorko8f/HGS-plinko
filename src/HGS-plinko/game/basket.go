components {
  id: "basket"
  component: "/scripts/game/basket.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"cup\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/textures/plinko.atlas\"\n"
  "}\n"
  ""
}
embedded_components {
  id: "score_text"
  type: "label"
  data: "size {\n"
  "  x: 25.0\n"
  "  y: 32.0\n"
  "}\n"
  "text: \"+50\"\n"
  "font: \"/builtins/fonts/default.font\"\n"
  "material: \"/builtins/fonts/label-df.material\"\n"
  ""
  position {
    y: -2.0
  }
  scale {
    x: 1.5
    y: 1.5
  }
}
