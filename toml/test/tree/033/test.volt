module test;

import toml = watt.toml;

enum TomlFile = `
template = "temporary-onetime-stat-buff"
rarity = 0
# Hello world
[[args.changes]]
stat = "user.heatEnergy"
change = 800
[args]
glyph = "item-attack-potion"
icon = "swoleIcon"
stat = "user.attack"
change = 3
duration = 15
sound = "swole"
playerChangeGlyph = "player-swole"
playerHitChangeGlyph = "player-swole-hit"
buffid = 4774774
`;

fn main() i32
{
	val := toml.parse(TomlFile);
	str := val.toString();
	val2:= toml.parse(str);
	return val2["args"]["changes"].array()[0]["change"].integer() == 800 ? 0 : 1;
}
