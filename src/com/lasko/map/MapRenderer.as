package com.lasko.map 
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	import net.flashpunk.graphics.Tilemap;
	
	import com.lasko.util.Utils;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MapRenderer 
	{
		private var map:Map;
		private var canvas:BitmapData;
		private var clearedCanvas:BitmapData;
		private var camera:Rectangle;
		
		[Embed(source = "../../../../maps/tileset24.png")]
		private const tileset24:Class;
		
		public function MapRenderer(map:Map, canvas:BitmapData) 
		{
			this.map = map;
			this.canvas = canvas;
			this.clearedCanvas = new BitmapData(canvas.width, canvas.height, false);
			this.camera = new Rectangle(0, 0, canvas.width, canvas.height);
		}
		
		public function render():void
		{
			//canvas.fillRect(canvas.rect, 0xffffff);
			//canvas.copyPixels(clearedCanvas, new Rectangle(0, 0, clearedCanvas.width, clearedCanvas.height), new Point(0, 0));
			//for each(var layer:Tilemap in map.get) {
			//	layer.render(this.canvas, new Point(0, 0), camera.topLeft);
			//}
			//map.
		}		
		
		public function scrollUp():void {
			camera.y -= 5;
			if (camera.y < 0)
			{
				camera.y = 0;
			}
		}
		
		public function scrollDown():void {
			camera.y += 5;
		}
		
		public function scrollLeft():void {
			camera.x -= 5;
			if (camera.x < 0)
			{
				camera.x = 0;
			}
		}
		
		public function scrollRight():void {
			camera.x += 5;
		}
		
		/*public function render(vx:int, vy:int, vw:int, vh:int):void
		{
			var spriteNum:int;
			var tile:Object;
            var chars:Array;
			var charsDrawn:Object = { };
			var tileSet:Object;

			//needs to be optimized to not draw every time. maybe?
			if (Global.currentBackground) {
                canvas.copyPixels(Global.currentBackground, Global.currentBackground.rect, new Point(0, 0));
			}
			
            
			for (var l:int = 0; l < maps[activeMap].tiles.length ; l++) {
                //skip this layer if it's debug-invisible at the moment
				if (!maps[activeMap].visibleLayers[l])	{
					continue;
				}

                for (var y:int = mapScrollY / maps[activeMap].tileHeight; y < mapScrollY / maps[activeMap].tileHeight + stage.stageHeight / maps[activeMap].tileHeight; y++) {
                    for (var x:int = mapScrollX / maps[activeMap].tileWidth; x < mapScrollX / maps[activeMap].tileWidth + stage.stageWidth / maps[activeMap].tileWidth; x++) {
                       
                        
                        
                                                
                        //is there a tile/object to draw at this location?
						if ((tile = maps[activeMap].getTileAt(l, x, y))) {
							tileSet = maps[activeMap].findTileSet(tile.spriteNum);
							if(tileSet) {
								spriteNum = tile.spriteNum - tileSet.index - 1;
								canvas.copyPixels(
									GameGraphics['tileset' + tileSet.width], 
									new Rectangle((spriteNum % tileSet.tilesPerRow) * tileSet.width, (int(spriteNum / tileSet.tilesPerRow)) * tileSet.height, tileSet.width, tileSet.height), 
									new Point(tile.x - mapScrollX, tile.y - mapScrollY)
								);
							}
                        }
                        
                        //are there any characters to draw at this location?
                        if(maps[activeMap].playerLayers[l]) {
                            chars = maps[activeMap].getCharactersAt(l, x, y);
                            for each(var char:Character in chars) {
								if (charsDrawn[char.id]) { continue; }
                                char.tick();
                                spriteNum = char.anim.getCurrentFrame();
                                canvas.copyPixels(GameGraphics.tileset48, new Rectangle((spriteNum % 17) * 48, (int(spriteNum / 17)) * 48, 48, 48), new Point(char.x - mapScrollX, char.y - mapScrollY)); 
								charsDrawn[char.id] = true;
                            }
                        }
					}
				}
			}
			
			debugDrawCollisionBoxes();
            drawPlayerBox(party.leader.mapX * maps[activeMap].tileWidth - mapScrollX, party.leader.mapY * maps[activeMap].tileHeight - mapScrollY, maps[activeMap].tileWidth, maps[activeMap].tileHeight);      
        }*/
		
        private function drawPlayerBox(x:int, y:int, w:int, h:int):void
        {
            var rectangle:Shape = new Shape;
            rectangle.graphics.beginFill(0xFF0000, 0.5);
            rectangle.graphics.lineStyle(1, 0x0000FF);
            rectangle.graphics.drawRect(0, 0, w, h);
            rectangle.graphics.endFill();
            canvas.draw(rectangle, new Matrix(1, 0, 0, 1, x, y));
        }
	}

}