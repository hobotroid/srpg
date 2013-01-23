package com.lasko.map
{
	import com.lasko.entity.map.GenericMapObject;
	import com.lasko.entity.map.MapObjectFactory;
	import flash.display.Bitmap;
	import flash.geom.*;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getDefinitionByName;
	import flash.errors.IllegalOperationError;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.World;
    
    import com.lasko.util.Base64;
	import com.lasko.util.Camera;
    import com.lasko.entity.Character;
	import com.lasko.entity.Party;
	import com.lasko.Global;
	import com.lasko.Game;
	import com.lasko.GameGraphics;
	
	public class Map extends World
	{
		private var playerStart:Point;
		private var playerLayerIndex:int = 0;
		
		public var tiles:Array = new Array();
        private var tileSets:Object = { };
		private var tileWidth:int;
		private var tileHeight:int;

		private var mapData:XML;
		private var mapName:String;
		
		public var pixelWidth:int;
		public var pixelHeight:int;
		
		public var cam:Camera;
		
		//debug
		private var collisionLayer:Tilemap;
		private var collisionEntity:Entity;
		private var showCollisionLayer:Boolean = false;
		
		public function Map(mapName:String)
		{	
			super();
			
            this.mapName = mapName;
			this.mapData = Global.getMapXML(mapName);
			this.makeMap();
			
			cam = new Camera(200, Global.SCROLL_SPEED);
		}
		
		private function makeMap():void
		{
			var widthInTiles:int = mapData.@width;
			var heightInTiles:int = mapData.@height;
			var tileWidth:int = mapData.@tilewidth;
			var tileHeight:int = mapData.@tileheight;
			var width:int = widthInTiles * tileWidth;
			var height:int = heightInTiles * tileHeight;
			var x:int, y:int;
			var layerIndex:int = 999;
			var mapObjectFactory:MapObjectFactory = new MapObjectFactory();
			trace("map is " + width + "x" + height + " pixels, " + tileWidth + "x" + tileHeight + " tile dimensions, " + widthInTiles + "x" + heightInTiles + " tiles.");

			for each(var nodeXML:XML in mapData.*) {
				for each (var layerXML:XML in nodeXML) {
					if(layerXML.name() == "layer") {				//regular layer
						var tileIds:Array = String(layerXML.data).replace(/\n/g, "").split(",");
						var index:int;
						
						if (String(layerXML.@name).toLowerCase() == "collision") {	//collision tile layer
							var gridLayer:Grid = new Grid(width, height, tileWidth, tileHeight);
							collisionLayer = new Tilemap(GameGraphics.tileset24, width, height, tileWidth, tileHeight);
							collisionEntity = new Entity(0, 0, collisionLayer);
							for (index = 0; index < tileIds.length; index++) {
								y = Math.floor(index / widthInTiles);
								x = index % widthInTiles;
								gridLayer.setTile(x, y, tileIds[index] > 0);
								collisionLayer.setTile(x, y, tileIds[index] - 1);
							}
							this.addMask(gridLayer, Global.COLLISION_LEVEL);
						} else {													//regular tile layer
							var layer:Tilemap = new Tilemap(GameGraphics.tileset24, width, height, tileWidth, tileHeight);
							for (index = 0; index < tileIds.length; index++) {
								if (tileIds[index] > 0) {
									y = Math.floor(index / widthInTiles);
									x = index % widthInTiles;
									layer.setTile(x, y, tileIds[index] - 1);
								}
							}
							var layerEntity:Entity = new Entity(0, 0, layer);
							layerEntity.layer = layerIndex;
							trace(String(layerXML.@name).toLowerCase() + " is on layer " + layerEntity.layer);
							this.add(layerEntity);
						}
					} else if (layerXML.name() == "objectgroup") {	//object layer
						if (String(layerXML.@name).toLowerCase() == "player layer") {
							playerLayerIndex = layerIndex;
							for each(var objectXML:XML in layerXML.object) {
								var objectX:int = objectXML.@x;
								var objectY:int = objectXML.@y - 48; //hack to fix tiled bug
								
								if (String(objectXML.@name).toLowerCase() == "player start") {
									this.playerStart = new Point(objectX, objectY);
								} else {
									var gid:int = int(objectXML.@gid)
									if (gid >= 2740) {
										gid -= 2740;
									}
									
									
									var mapObject:GenericMapObject = mapObjectFactory.makeMapObject(objectXML.@name, gid);
									mapObject.moveTo(objectX, objectY);
									mapObject.layer = layerIndex - 1;
									this.add(mapObject);
								}
							}
						}
					}
				}
				
				layerIndex--;
			}
			this.pixelWidth = width;
			this.pixelHeight = height;
			trace('map initted - player start: '+playerStart+", player layer: " + playerLayerIndex);
		}
		
		public function getTileWidth():int 
		{
			return tileWidth;
		}
		
		public function getTileHeight():int 
		{
			return tileHeight;
		}
		
		public function addCharacter(character:Character):void
		{
			add(character);
			character.layer = this.playerLayerIndex;
		}
		
		public function addParty(party:Party):void
		{
			addCharacter(party.getLeader());
			
		}
		
		public function getPlayerStart():Point
		{
			return playerStart;
		}
		
		override public function update():void
		{
			if (Global.showCollisionBoxes != this.showCollisionLayer) {
				this.showCollisionLayer = Global.showCollisionBoxes;
				if (this.showCollisionLayer) {
					this.add(collisionEntity);
				} else {
					this.remove(collisionEntity);
				}
			}
			super.update();
		}
	}
}