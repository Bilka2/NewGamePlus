# NewGamePlus

Allows you to start a new game plus once you launch a rocket. Generate a new world and leave your home world, but carry over an inventory full of items and your research.

Enabled the mod option to be able to run the ngp-gui command. Then simply type /ngp-gui in chat (or the console, it's the same thing), and you will see the gui and be able to start the new game plus without launching the rocket.

The above processes can be repeated an infinite amount of times. Please know that it is not possible to go back to your old world(s)! Pressing the start button might also freeze your game for up to a few minutes. That's fine. It'll unfreeze eventually. Complain to Rseding to make it possible to delete Nauvis to fix this.

Works with mods that add ores or terrain etc. If you want to generate a new world with them, first enable them, then start the new game plus, not the other way around. Also works with RSO (has to be version 3.4.0 or higher).

Changelog:

2.1.0

* Added cliff settings to the options
* Fixed that the player didnt consider tile transitions

2.0.1

* Fixed that new players in multiplayers games would spawn in the wrong world

2.0.0

* Update to 0.16

1.1.2

* Fixed building platform option appearing although the building platform mod was not installed
* Changed how on_entity_died is raised when deleting chunks, should prevent weirdness due to chunk borders when interacting with another mod's entities

1.1.1

* Added support for the building platform mod
* Minor code cleanup

1.1.0

* Added all advanced settings that can be found in the map generation GUI to the advanced settings
* Added option to reset enemy evolution
* Added "Reset to default" button that resets all settings back to the default
* The "Set to current map settings" button now also sets the advanced settings to the currently used settings

1.0.0

* Initial release
