# Shoot 'em Up
A vampire survivor like game made & extended from the GDQuest 
"Your First 2D GAME From Zero in Godot 4" tutorial ([link to tutorial](https://youtu.be/GwCiGixlqiU)).

## Extensions
- ~~Make gun actually point at closest mob, not first in array~~
- ~~Flip gun visuals left / right depending on aim direciton~~
- ~~Add state understanding to player animation controller & gun flipping~~
- Randomly spawn trees as player moves around
- Add support for holding multiple guns (each points at a different enemy)
- Random chance to spawn heal item as enemy when killed
- Add waves which increase in difficulty (infinite)
- Spawn heal item at last alive enemy of each wave once complete
- Add power-ups (e.g. rapid fire, higher damage, penetration)
- Add more types of guns
- Flip player visuals left / right depending on movement direction
  - This is hard to do to look good because flipping the whole "HappyBoo" means the walking animation looks weird (instantly switches which side the up / down leg is on)
  - Maybe an overlapping animation to change direction of legs would work better, instead of switching which leg is which
- Add kick for when enemy is too close
