# Antibodies (Project Zomboid Mod)

Antibodies mod expands vanilla zombification mechanic by adding antibodies curve which is loosely based on real-life immune system response. If antibodies overtake the infection, the character will slowly recover.

## Why did you bother making it?

Although I really like the idea of a butt-clenching zombification threat, I can’t say I like the way it is implemented at the moment - a single RNG roll that decides whether you live or die.

My aim is to create a scenario in which you have to _**up your game**_ to have the chance of survival. It is meant to be hard, but fair (like the rest of the game mechanics).

## Can you tell me more about this new mechanic?

Once your character gets infected, the production of antibodies begins. By default base antibodies production is faster than infection spread, but it is affected by many factors.

* **Infection stage** (In the early and late infection stage the antibody production is severely impaired)
* **Moodles** (provide core buffs and debuffs)
* **Traits** (minor buffs and debuffs)
* **Number of infected body parts** (minor debuff)

Remember that time to zombification is randomized at the infection time (something like 48-72h). This mod won’t tell you anything beyond what vanilla game tells you, so you can just make an educated guess about the current infection stage.

If you need more, you can always look ‘under the hood’. I have commented on the main bits you might want to tweak.

## Compatibility

It is developed for **IWBUMS 41**.

## Installation

Place mod directory under `/Zomboid/mods`.
