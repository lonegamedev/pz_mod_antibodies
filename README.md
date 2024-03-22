# Antibodies (Project Zomboid Mod)

The Antibodies mod enhances the vanilla zombification mechanic by introducing an antibodies curve inspired by real-life immune system responses. If the antibodies successfully counteract the infection, the character will experience a gradual recovery over time.

Steam Workshop: `https://steamcommunity.com/sharedfiles/filedetails/?id=2392676812`

## Building

Run either `build.sh` or `build_dev.sh`

## Translations

Antibodies requires some translations, because of UI elements.

I have provided ENG and PL, but would gladly accept contributions.
Worst case scenario, I can do machine translations - but these can be worse than default ENG.

All you need to do is put translations under `source/media/lua/shared` (check existing ones for refrence),

In case language requires different encoding than UTF-8, you also have to add it to `encoding_map` in `build.py`.
See https://pzwiki.net/wiki/Translations `Languages` section for a reference.

Basically any path matching a key in that map will be re-coded upon build.
This allows us to store only UTF-8 translations, and avoid most of the git encoding issues.

## Manual Installation

Place mod directory under `/Zomboid/mods`.
