defmodule EdgeBuilder.GameView do
  use EdgeBuilder.Web, :view

  def display_attributes do
    [
      ["Species", "species"],
      ["Career", "career"],
      ["Specializations", "specializations"],
      ["Brawn", "characteristic_brawn"],
      ["Agility", "characteristic_agility"],
      ["Intellect", "characteristic_intellect"],
      ["Cunning", "characteristic_cunning"],
      ["Willpower", "characteristic_willpower"],
      ["Presence", "characteristic_presence"],
      ["Soak", "soak"],
      ["Wounds", "wounds_threshold"],
      ["Strain", "strain_threshold"],
      ["Ranged Defense", "defense_ranged"],
      ["Melee Defense", "defense_melee"],
    ]
  end
end
