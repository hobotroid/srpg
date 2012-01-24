package
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
    
    import util.Base64;
    
	public class Map
	{
		public var width:int;
		public var height:int;
		public var pixelWidth:int;
		public var pixelHeight:int;
		public var tileWidth:int;
		public var tileHeight:int;
		public var playerStart:Object;
		public var playerLayers:Object = {};
		private var parentClip:Test;
		
		public var tiles:Array = new Array();
        public var tileSets:Object = { };
		public var collisionMap:Array = new Array();
		public var collisionMapIndexes:Object = {};
		public var collisionMapColliding:Array = new Array(); //for debugging
		public var layerCount:int = 0;
		public var visibleLayers:Object = {0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1, 7: 1, 8: 1, 9: 1, 10: 1};
		public var npcs:Array = new Array();
		
		private var mapLoader:URLLoader;
		private var tilesLoader:Loader;
		private var backgroundLoader:Loader;
		private var tilesetFilename:String;
		private var mapFilename:String;
		private var tilesFilename:String;
		private var completeFunction:Function;
		
		private var mapData:XML;
		
		public function Map(clip:Test, mapFilename:String, completeFunction:Function)
		{
			this.mapFilename = mapFilename;
			this.tilesFilename = tilesFilename;
			this.completeFunction = completeFunction;
			this.parentClip = clip;
			XML.ignoreWhitespace = true;
			XML.prettyIndent = 0;
            
            mapLoader = new URLLoader();
            mapLoader.addEventListener(Event.COMPLETE, mapLoaded);
            mapLoader.load(new URLRequest(mapFilename));
        }

		private function mapLoaded(e:Event):void
		{
			mapData = new XML(mapLoader.data);
			
            //tilesets
            for each (var tileset:XML in mapData.tileset) {
                var w:int = Number(tileset.@tilewidth);
                tileSets[w] = {
                    width: w,
                    height: Number(tileset.@tileheight),
                    index: Number(tileset.@firstgid),
                    tilesPerRow: Number(w == 24 ? 34 : 17)
                };
            }
            
			//load and background image
			if (mapData.properties.property.(@name == "background").@value)
			{
				trace(mapData.properties.property.(@name == "background").@value);
				backgroundLoader = new Loader();
				backgroundLoader.contentLoaderInfo.addEventListener(Event.INIT, function(e:Event):void
					{
						Global.currentBackground = Bitmap(backgroundLoader.content).bitmapData;
					});
				backgroundLoader.load(new URLRequest("../" + mapData.properties.property.(@name == "background").@value));
			}
			
			//get dimensions of map & tile dimensions
			width = mapData.layer.(@name == "Floor").@width;
			height = mapData.layer.(@name == "Floor").@height;
			tileWidth = 24;//mapData.tileset.@tilewidth;
			tileHeight = 24;//mapData.tileset.@tileheight;
			pixelWidth = width * tileWidth;
			pixelHeight = width * tileHeight;
			
			//get layer count and player layer 
			for each (var node:XML in mapData.*)
			{
				for each (var innerNode:XML in node)
				{
					if (innerNode.name() == "layer" || innerNode.name() == "objectgroup")
					{
						if (String(innerNode.@name).toLowerCase() == "player layer")
						{
							playerLayers[layerCount] = 1;
						}
						layerCount++;
					}
				}
			}
			
			trace("map has " + layerCount + " layers");
			
			//populate array with tiles and objects
			var layerIndex:int = 0;
			tiles = [];
			for each (node in mapData.*)
			{
				for each (innerNode in node)
				{
					switch (String(innerNode.name()))
					{
						case 'layer': //regular map layer - tiles
							var tileNodes:XMLList = innerNode.data.tile;
                            
                            
                            
                            
                            
                            
                            
                            //var compressed:ByteArray = Base64.decode(innerNode.data);
                            //compressed.inflate();
                            
                            
                            
							for (var x:int = 0; x < width; x++)
							{
								for (var y:int = 0; y < height; y++)
								{
									var id:int = tileNodes[y * width + x].@gid;
									if (!tiles[layerIndex])
									{
										tiles[layerIndex] = [];
									}
									if (!tiles[layerIndex][x])
									{
										tiles[layerIndex][x] = [];
									}
									if (id > 0)
									{
										var isCollidable:int = (String(innerNode.properties.property.(@name == "collidable").@value) == '1' ? 1 : 0);
										var tile:Tile = new Tile(this, id, isCollidable);
										tile.x = x * tileWidth;
										tile.y = y * tileHeight;
										tile.setSize(tileWidth, tileHeight);
										tile.layerIndex = layerIndex;
										tiles[layerIndex][x][y] = tile;
										if (id == 124)
										{
											trace('got one: ' + x + 'x' + y);
										}
										
										if (isCollidable)
										{
											collisionMap.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
										}
									}
								}
							}
							layerIndex++;
							break;
						case 'objectgroup': //object layer
							for each (var object:XML in innerNode.object)
							{
								var objectx:int = object.@x / tileWidth;
								var objecty:int = object.@y / tileHeight;
								var mapObject:MapObject;
								var collisionXML:XMLList;
								
								if (!tiles[layerIndex])
								{
									tiles[layerIndex] = [];
								}
								if (!tiles[layerIndex][objectx])
								{
									tiles[layerIndex][objectx] = [];
								}
								
								/********************* PORTAL TO OTHER MAP ************************/
								if (object.@type == "portal")
								{
									mapObject = new MapObject(this, Global.TILE_TYPE_PORTAL, {"destination": object.properties.property.@value});
									mapObject.x = object.@x;
									mapObject.y = object.@y;
									mapObject.layerIndex = layerIndex;
									mapObject.setSize(object.@width, object.@height);
									addCollisionRect(new Rectangle(object.@x, object.@y, object.@width, object.@height), mapObject)
									tiles[layerIndex][objectx][objecty] = mapObject;
									
									/********************* GRAVE            ************************/
								}
								else if (object.@type == "grave")
								{
									mapObject = new MapObject(this, Global.TILE_TYPE_GRAVE);
									mapObject.x = object.@x;
									mapObject.y = object.@y;
									mapObject.setSize(object.@width, object.@height);
									mapObject.layerIndex = addToPlayerLayer(mapObject, objectx, objecty);
									
									addCollisionRect(new Rectangle(mapObject.x + 7, mapObject.y + 28, parseInt(object.@width) - 14, 20), mapObject);
									//collisionMap.push(new Rectangle(mapObject.x + 6, mapObject.y + 14, 36, 26));
									mapObject.collideIndex = collisionMap.length - 1;
									
									/********************* NPC            ************************/
								}
								else if (object.@type == "npc")
								{
									//process npc party
									var partyValue:String = object.properties.property.(@name == "party").@value;
									var enemies:Array = partyValue.indexOf(',') != -1 ? partyValue.split(',') : [partyValue];
									var party:Party = new Party(object.@name);
									var leader:Character;
									
									for each (var enemyType:String in enemies)
									{
										var enemyXML:XMLList = (Global.charactersXML.character.(@id == enemyType));
										var char:Character = new Character(this, enemyXML, object.@x, object.@y);
										if (object.@name == "joshua")
										{
											char.addShopItems(object.properties.property.(@name == "items").@value);
										}
										if (object.properties.property.(@name == "movement").length())
										{
											char.setMovementType(object.properties.property.(@name == "movement").@value);
										}
										party.addCharacter(char);
									}
									
									leader = party.getFirstMember();
									mapObject = new MapObject(this, Global.TILE_TYPE_NPC, {'character': party});
									mapObject.x = object.@x;
									mapObject.y = object.@y;
									//mapObject.layerIndex = addToPlayerLayer(mapObject, objectx, objecty);
									tiles[layerIndex][objectx][objecty] = mapObject;
									mapObject.setSize(object.@width, object.@height);
									var collisionRect:Rectangle = new Rectangle(enemyXML.collision.x, enemyXML.collision.y, enemyXML.collision.width, enemyXML.collision.height);
									party.leader.collisionRectIndex = addCollisionRect(new Rectangle(mapObject.x + collisionRect.x, mapObject.y + collisionRect.y, collisionRect.width, collisionRect.height), mapObject);
									mapObject.collideIndex = collisionMap.length - 1;
									trace('adding ' + object.@name + ' npc to ' + object.@x + ' ' + object.@y);
									
									//process rest of the properties for this npc
									for each (var property:XML in object.properties.*)
									{
										switch (String(property.@name))
										{
											case "chase_range": 
												party.leader.addChaseRange(property.@value);
												break;
											default: 
												break;
										}
									}
									
									//add npc to map
									npcs.push(party);
									
									/********************* WALK PATH            ************************/
								}
								else if (object.@type == "path")
								{
									/*mapObject = new MapObject(this, "npc");
									   var pathTarget:Party = getPartyByName(object.properties.property.(@name=="target").@value);
									   var pathIndex:int = object.properties.property.(@name=="index").@value;
									   var pathDelay:int = object.properties.property.(@name=="delay").@value;
									   var pathSpeed:int = object.properties.property.(@name == "speed").@value;
									 pathTarget.leader.addPathNode(object.@x, object.@y, pathIndex, pathDelay, pathSpeed);*/
									
									/********************* PLAYER START        ************************/
								}
								else if (object.@name == "start")
								{
									trace('player start is: ' + object.@x + 'x' + object.@y);
									playerStart = {"x": object.@x, "y": object.@y}
									
									/********************* AIRSHIP            ************************/
								}
								else if (object.@type == "airship")
								{
									mapObject = new MapObject(this, Global.TILE_TYPE_AIRSHIP);
									mapObject.x = object.@x;
									mapObject.y = object.@y;
									mapObject.layerIndex = layerIndex;
									mapObject.setSize(object.@width, object.@height);
									tiles[layerIndex][objectx][objecty] = mapObject;
									addCollisionRect(new Rectangle(mapObject.x, mapObject.y, object.@width, object.@height), mapObject);
									mapObject.collideIndex = collisionMap.length - 1;
									
									/********************* BOX MAN (TREASURE) ************************/
								}
								else if (object.@type == "box")
								{
									var charXML:XML = Global.charactersXML.character.(@id == "boxman") as XML;
									collisionXML = Global.charactersXML.character.(@id == "boxman").collision;
									mapObject = new MapObject(this, Global.TILE_TYPE_BOX, {contents: object.properties.property.(@name == "contents").@value, quantity: object.properties.property.(@name == "quantity").@value});
									mapObject.x = object.@x;
									mapObject.y = object.@y;
									mapObject.setSize(object.@width, object.@height);
									//mapObject.layerIndex = addToPlayerLayer(mapObject, objectx, objecty);
                                    tiles[layerIndex][objectx][objecty] = mapObject;
									
									addCollisionRect(new Rectangle(mapObject.x + parseInt(collisionXML.x), mapObject.y + parseInt(collisionXML.y), collisionXML.width, collisionXML.height), mapObject);
									mapObject.collideIndex = collisionMap.length - 1;
								}
                                /********************* PLANE TROLLY ************************/
								else if (object.@type == "plane_trolly")
								{
                                    var trollyXML:XMLList = Global.charactersXML.character.(@id == "plane_trolly") as XMLList;
									mapObject = new MapObject(this, Global.TILE_TYPE_TROLLY, {spriteNum: object.@gid});
									mapObject.x = object.@x;
									mapObject.y = object.@y;
									mapObject.setSize(object.@width, object.@height);
									//mapObject.layerIndex = addToPlayerLayer(mapObject, objectx, objecty);
                                    tiles[layerIndex][objectx][objecty] = mapObject;
									addCollisionRect(new Rectangle(mapObject.x + int(trollyXML.collision.x), mapObject.y + int(trollyXML.collision.y), int(trollyXML.collision.width), int(trollyXML.collision.height)), mapObject);
									//collisionMap.push(new Rectangle(mapObject.x + 6, mapObject.y + 14, 36, 26));
									mapObject.collideIndex = collisionMap.length - 1;
                                }
                                /********************* ANY OTHER OBJECT IN CHARACTER.XML ************************/
								else if (Global.charactersXML.character.(@id == object.@type).collision.length())
								{
									collisionXML = Global.charactersXML.character.(@id == object.@type).collision;
									mapObject = new MapObject(this, Global.TILE_TYPE_MISC, {spriteNum: object.@gid});
									mapObject.x = object.@x;
									mapObject.y = object.@y;
									//addToPlayerLayer(mapObject, objectx, objecty);
									tiles[layerIndex][objectx][objecty] = mapObject;
									addCollisionRect(new Rectangle(mapObject.x + parseInt(collisionXML.x), mapObject.y + parseInt(collisionXML.y), collisionXML.width, collisionXML.height));
									
									
								}
                                /********************* INVISIBLE WALL     ************************/
								else if (object.@type == "wall")
								{
									addCollisionRect(new Rectangle(object.@x, object.@y, object.@width, object.@height));
								}
                                /********************* ANY OTHER GENERIC OBJECT NOT IN CHARACTER.XML ************************/
								else if(String(object.@width).length && String(object.@height).length)
								{
									mapObject = new MapObject(this, Global.TILE_TYPE_MISC, {spriteNum: object.@gid});
									mapObject.x = object.@x;
									mapObject.y = object.@y;
                                    trace(object.@width);
									//addToPlayerLayer(mapObject, objectx, objecty);
									tiles[layerIndex][objectx][objecty] = mapObject;
                                    
                                    if(String(object.properties.property.(@name == "collidable").@value) == "1") {
                                        addCollisionRect(new Rectangle(mapObject.x, mapObject.y + int(object.@height) - 1, parseInt(object.@width), 1));
                                    }
									
									
								}
							}
							layerIndex++;
							break;
						default: 
							break;
					}
				}
			}
			
			/***************** optimize collision map - combine all combinable boxes ******************/
			//keep processing until no changes are made
			var changesMade:Boolean = true;
			while (changesMade)
			{
				changesMade = false;
				
				//first pass - combine all equal-width adjacent boxes into one tall box
				for (var i:int = 0; i < collisionMap.length; i++)
				{
					var rect:Rectangle = collisionMap[i];
					if (rect)
					{
						for (var j:int = 0; j < collisionMap.length; j++)
						{
							var rect2:Rectangle = collisionMap[j];
							if (rect2 && rect.width == rect2.width && rect.left == rect2.left && rect.top == rect2.bottom)
							{
								collisionMap[j] = new Rectangle(rect2.x, rect2.y, rect2.width, rect2.height + rect.height);
								collisionMap[i] = null;
								changesMade = true;
							}
						}
					}
				}
				//second pass - combine all equal-height adjacent boxes into one widge box
				for (i = 0; i < collisionMap.length; i++)
				{
					rect = collisionMap[i];
					if (rect)
					{
						for (j = 0; j < collisionMap.length; j++)
						{
							rect2 = collisionMap[j];
							if (rect2 && rect.height == rect2.height && rect.top == rect2.top && rect.left == rect2.right)
							{
								collisionMap[j] = new Rectangle(rect2.x, rect2.y, rect2.width + rect.width, rect2.height);
								collisionMap[i] = null;
								changesMade = true;
							}
						}
					}
				}
				//third pass - combine boxed of >= height. kind of.
				for (i = 0; i < collisionMap.length; i++)
				{
					rect = collisionMap[i];
					if (rect)
					{
						for (j = 0; j < collisionMap.length; j++)
						{
							rect2 = collisionMap[j];
							if (rect2 && rect2.left == rect.right && rect2.top == rect.top && rect2.height > rect.height)
							{
								collisionMap[i] = new Rectangle(rect.x, rect.y, rect.width + rect2.width, rect.height);
								collisionMap[j] = new Rectangle(rect2.x, rect.bottom, rect2.width, rect2.height - rect.height);
								changesMade = true;
							}
						}
					}
				}
			}
			
			//map is all done loading - call complete function
			completeFunction(this);
		}
		
		public function updateNPCs():void
		{
			for each (var npc:Party in npcs)
			{
				npc.leader.updatePosition();
			}
		}
		
		private function addToPlayerLayer(object:Object, x:int, y:int):int
		{
			var l:int;
			
			for (var layer:String in playerLayers)
			{
				l = parseInt(layer);
				if (!tiles[l][x] || !tiles[l][x][y])
				{
					if (!tiles[l][x])
					{
						tiles[l][x] = [];
					}
					tiles[l][x][y] = object;
					return (l);
				}
			}
			
			tiles[tiles.length] = [];
			tiles[tiles.length - 1][x] = [];
			tiles[tiles.length - 1][x][y] = object;
			playerLayers[tiles.length - 1] = 1;
			return (tiles.length - 1);
		}
		
		private function addCollisionRect(rect:Rectangle, tile:Object = null):int
		{
			collisionMap.push(rect);
			if (tile)
			{
				collisionMapIndexes[collisionMap.length - 1] = tile;
			}
			return (collisionMap.length - 1);
		}
		
		public function getPartyByName(partyName:String):Party
		{
			trace('HERE:' + partyName);
			for each (var npc:Party in npcs)
			{
				trace(npc.name);
				if (npc.name == partyName)
				{
					return (npc);
				}
			}
			return (null);
		}
		
		public function getTileAt(l:int, x:int, y:int):Object
		{
			if (tiles[l][x])
			{
				return (tiles[l][x][y]);
			}
			
			return (null);
		}
        
        public function getCharactersAt(l:int, x:int, y:int):Array
        {
            var chars:Array = [];

            for each (var party:Party in npcs) {
                if(party.leader.mapX == x && party.leader.mapY == y) {
                    chars.push(party.leader);
                }
            }

            return(chars);
        }
		
		public function getTilesAt(x:int, y:int):Array
		{
			var tilesArray:Array = [];
			for each (var layer:Array in tiles)
			{
				if (layer[x / tileWidth])
				{
					tilesArray.push(layer[x / tileWidth][y / tileHeight]);
				}
			}
			return (tilesArray);
		}
		
		public function getTilesAbove(tile:Object):Array
		{
			var tilesArray:Array = [];
			var tempTile:Object;
			for (var l:int = tile.layerIndex + 1; l < layerCount; l++)
			{
				tempTile = getTileAt(l, tile.x / tileWidth, tile.y / tileHeight);
				if (tempTile)
				{
					tilesArray.push(tempTile);
				}
			}
			return (tilesArray);
		}
		
		public function addTileAt(x:int, y:int, tile:Object):void
		{
			tile.x = x;
			tile.y = y;
			if (!tiles[tile.layerIndex][int(x / tileWidth)])
			{
				tiles[tile.layerIndex][int(x / tileWidth)] = [];
			}
			tiles[tile.layerIndex][int(x / tileWidth)][int(y / tileHeight)] = tile;
			trace('added tile: ' + tiles[tile.layerIndex][int(x / tileWidth)][int(y / tileHeight)]);
		}
		
		public function removeTileAt(x:int, y:int, tile:Object):void
		{
			trace('request tile removal of ' + tile + '(' + tile.layerIndex + 'x' + int(x / tileWidth) + 'x' + int(y / tileHeight) + ')');
			trace('removing tile ' + tiles[tile.layerIndex][int(x / tileWidth)][int(y / tileHeight)]);
			tiles[tile.layerIndex][int(x / tileWidth)][int(y / tileHeight)] = null;
		}
		
		public function isCollidableAt(x:int, y:int):Boolean
		{
			Global.game.debugAddHighlightedTile(x, y);
			var tiles:Array = getTilesAt(x, y);
			for each (var tile:Object in tiles)
			{
				if (tile && tile.collisionType)
				{
					return (true);
				}
			}
			return (false);
		}
		
		public function removeNpc(party:Party):void
		{
			for (var i:int = 0; i < npcs.length; i++)
			{
				if (npcs[i] == party)
				{
					npcs.splice(i, 1);
					return;
				}
					//if(npcs[i] == party) { npcs = new Array(); }
			}
		}
	}
}