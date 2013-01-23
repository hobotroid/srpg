package com.lasko 
{	
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	
	import mx.core.BitmapAsset;
	
	import com.lasko.Global;
	import com.lasko.ui.UIBar;
	import com.lasko.map.Map;
		
	public class GameGraphics 
	{
		[Embed(source="../../../maps/tileset.png")]
		[Bindable]
		private static var tileset48Class:Class;
		[Embed(source="../../../maps/tileset24.png")]
		[Bindable]
		private static var tileset24Class:Class;
		[Embed(source="../../../assets/characters/carl.png")]
		[Bindable]
		private static var carlFramesClass:Class;
		
		public static var tileset24:BitmapData;
		public static var tileset48:BitmapData;
		public static var carlFrames:BitmapData;
		public static var spritemap48:Spritemap;
		
		public static var uiBarCap:Bitmap;
		
		public function GameGraphics() { }
		
		public static function init():void {
			setTilesetImage(24, new tileset24Class() as BitmapAsset);
			setTilesetImage(48, new tileset48Class() as BitmapAsset);
			carlFrames = (new carlFramesClass() as BitmapAsset).bitmapData;
			spritemap48 = new Spritemap(tileset48, 48, 48);
			
			uiBarCap = new Bitmap(new BitmapData(24, 24, true, 0x00000000));
			uiBarCap.bitmapData.copyPixels(GameGraphics.tileset24, new Rectangle((7 % 34) * 24, (int(7 / 34)) * 24, 24, 24), new Point(0, 0));
		}
		
		private static function setTilesetImage(size:int, bma:BitmapAsset):void {
			if (size == 24) {
				tileset24 = bma.bitmapData;
			} else {
				tileset48 = bma.bitmapData;
			}
		}
      
		public static function makeSprite(index:int):Bitmap
		{
			var bitmap:Bitmap = new Bitmap(new BitmapData(48, 48));
			bitmap.bitmapData.copyPixels(
				GameGraphics.tileset48, 
				new Rectangle((index % 17) * 48, (int(index/17)) * 48, 48, 48*2),
				new Point(0, 0)
			);

			return(bitmap);
		}
		
		public static function makeImage(index:int):Image
		{
			var row:int = Math.floor(index / 17);
			var column:int = index % 17;
			var bmd:BitmapData = new BitmapData(48, 48, true, 0x00000000);
			
			spritemap48.setFrame(column, row);
			spritemap48.render(bmd, new Point(0, 0), new Point(0, 0));

			var image:Image = new Image(bmd);
			
			return image;
		}
	}

}