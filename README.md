# Shoot 'em up
This is a little shoot 'em up game I made for fun + to build-up my skills.

It's based on a short GDQuest tutorial, which I then added to - "Your First 2D GAME From Zero in Godot 4" ([link](https://youtu.be/GwCiGixlqiU)).

It goes on indefinitely, and the only directive is to survive!
Don't wander too far whilst mobs are spawning, as they might get stuck on trees 😝

Released versions of the game are available on the [itch.io page](https://dylanbeard.itch.io/shoot-em-up).

## Extensions
- ~~Make gun actually point at closest mob, not first in array~~
- ~~Flip gun visuals left / right depending on aim direciton~~
- ~~Add state understanding to player animation controller & gun flipping~~
- ~~Randomly spawn trees as player moves around~~
- ~~Add support for holding multiple guns (each points at a different enemy)~~
  - Not pleased with how I implemented the gun handling - the gun class is alright tho
- ~~Random chance to spawn heal item at enemy when killed~~
- ~~Add waves which increase in difficulty (infinite or finite)~~
- ~~Make UI to show wave progress~~
- ~~Make main menu~~
- ~~Animate scenes transitions & game over UI~~
- ~~Implement muzzle flash from provided assets & make gun show over bullet~~
- Allow slimes to pass between smaller gaps by squeezing through
- Add power-ups (e.g. rapid fire, higher damage, penetration)
- Add more types of guns
- Kick enemies when too close for gun
- Spawn heal pickup at last alive enemy of each wave once complete
- Flip player visuals left / right depending on movement direction
  - This is hard to do to look good because flipping the whole "HappyBoo" means the walking animation looks weird (instantly switches which side the up / down leg is on)
  - Maybe an overlapping animation to change direction of legs would work better, instead of switching which leg is which
