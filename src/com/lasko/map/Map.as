package com.lasko.map
{
	import flash.display.Bitmap;
	import flash.geom.*;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.errors.IllegalOperationError;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.World;
    
    import com.lasko.util.Base64;
    import com.lasko.entity.Character;
	import com.lasko.Global;
	import com.lasko.Game;
	import com.lasko.GameGraphics;
	
	public class Map extends World
	{
		public var playerStart:Object;
		public var playerLayers:Object = {};
		
		public var tiles:Array = new Array();
        private var tileSets:Object = { };
		private var tileWidth:int;
		private var tileHeight:int;

		private var mapData:XML;
		private var mapName:String;
		
		public function Map(mapName:String)
		{	
            this.mapName = mapName;
			this.mapData = Global.getMapXML(mapName);
			this.makeMap();
		}
		
		private function makeMap():void
		{
			var width:int = mapData.@width;
			var height:int = mapData.@height;
			var tileWidth:int = 24;
			var tileHeight:int = 24;
			var widthInTiles:int = width / tileWidth;
			var heightInTiles:int = height / tileHeight;
			trace("map is " + width + "x" + height + " pixels, " + tileWidth + "x" + tileHeight + " tile dimensions, " + widthInTiles + "x" + heightInTiles + " tiles.");

			for each(var layerXML:XML in mapData.*) {
				if (layerXML.@exportMode == "Bitstring") {	//grid layer
					
				} else if (layerXML.@exportMode == "CSV") {	//tile layer
					var tileIds:Array = String(layerXML).replace(/\n/g, ",").split(",");
					var layer:Tilemap = new Tilemap(GameGraphics.tileset24, width, height, tileWidth, tileHeight);
					trace('ADDING A LAYER TO MAP:'+ String(layerXML));
					for (var index:int = 0; index < tileIds.length; index++) {
						var y:int = Math.floor(index / widthInTiles);
						var x:int = index % widthInTiles;
						layer.setTile(x, y, tileIds[index]);
					}
					this.add(new Entity(0, 0, layer));
				}
			}
			trace('map initted');
		}
		
		public function getTileWidth():int 
		{
			return tileWidth;
		}
		
		public function getTileHeight():int 
		{
			return tileHeight;
		}
	}
}