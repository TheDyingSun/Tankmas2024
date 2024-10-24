#if ldtk
package levels;

import LdtkProject.LdtkProject_Level;
import flixel.tile.FlxTilemap;

class LDTKLevel extends FlxTilemap
{
	public var tile_size:Int = 32;

	var lvl_width:Int = 0;
	var lvl_height:Int = 0;
	var array_len:Int = 0;

	public function new(level_name:String, graphic:String)
	{
		super();
		generate(level_name, graphic);
	}

	function generate(level_name:String, graphic:String)
	{
		var data:LdtkProject_Level = get_level_by_name(level_name);

		lvl_width = Math.floor(data.pxWid / tile_size);
		lvl_height = Math.floor(data.pxHei / tile_size);
		array_len = lvl_width * lvl_height;

		var layer_name:String = "Tiles";

		var layer = data.resolveLayer(layer_name);

		var int_grid:Array<Int> = [];

		lvl_width = layer.cWid;
		lvl_height = layer.cHei;

		for (x in 0...lvl_width)
			for (y in 0...lvl_height)
			{
				var tile = switch (layer_name)
				{
					case "Tiles":
						data.l_Tiles.getTileStackAt(x, y);
					default:
						null;
				}

				var index:Int = Math.floor(x + y * lvl_width);
				int_grid[index] = tile.length > 0 ? tile[0].tileId : 0;
			}

		array_len = int_grid.length;
		loadMapFromArray(int_grid, lvl_width, lvl_height, graphic, tile_size, tile_size);
	}

	function get_level_by_name(level_name:String):LdtkProject_Level
	{
		for (data in Main.project.all_worlds.main.levels)
			if (data.identifier == level_name)
				return data;
		throw "level does not exist by the name of '" + level_name + "'";
	}
}
#end
