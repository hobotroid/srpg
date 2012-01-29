package util {
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   	import com.wirelust.as3zlib.Deflate;
	import com.wirelust.as3zlib.JZlib;
	import com.wirelust.as3zlib.System;
	import com.wirelust.as3zlib.ZInputStream;
	import com.wirelust.as3zlib.ZOutputStream;
	import com.wirelust.as3zlib.ZStream;
	import com.wirelust.as3zlib.ZStreamException;

	public class Utils  {
		private var instance:Utils = null;

		public static function randRange(low:int, high:int):int
		{
			return(Math.round(low + Math.random()*(high-low)));
		}

		public static function clone(source:Object):*
		{
			var copier:ByteArray = new ByteArray();
			copier.writeObject(source);
			copier.position = 0;
			return(copier.readObject());
		}

		//The resizing function
		// parameters
		// required: mc = the movieClip to resize
		// required: maxW = either the size of the box to resize to, or just the maximum desired width
		// optional: maxH = if desired resize area is not a square, the maximum desired height. default is to match to maxW (so if you want to resize to 200x200, just send 200 once)
		// optional: constrainProportions = boolean to determine if you want to constrain proportions or skew image. default true.
		public static function resizeMe(obj:Object, maxW:Number, maxH:Number=0, constrainProportions:Boolean=true):void{
			maxH = maxH == 0 ? maxW : maxH;
			obj.width = maxW;
			obj.height = maxH;
			if (constrainProportions) {
				obj.scaleX < obj.scaleY ? obj.scaleY = obj.scaleX : obj.scaleX = obj.scaleY;
			}
		}

		public static function autoCrop(bmd:BitmapData):BitmapData {
			var rect:Rectangle = new Rectangle(0, 0, bmd.width, bmd.height);
			var x:int, y:int;
			var found:Boolean = false;
			var newBmd:BitmapData;
			
			//left
			for (x = 0; x < bmd.width; x++) {
				for (y = 0; y < bmd.height; y++) {
					if (!found && bmd.getPixel(x, y)) { found = true; rect.x = x-1; }
				}
			}
			//right
			found = false;
			for (x = bmd.width-1; x >= 0; x--) {
				for (y = 0; y < bmd.height; y++) {
					if (!found && bmd.getPixel(x, y)) { found = true; rect.width = x+1 - rect.x; }
				}
			}
			//top
			found = false;
			for (y = 0; y < bmd.height; y++) {
				for (x = 0; x < bmd.width; x++) {
					if (!found && bmd.getPixel(x, y)) { found = true; rect.y = y-1; }
				}
			}
			//bottom
			found = false;
			for (y = bmd.height-1; y >= 0; y--) {
				for (x = bmd.width; x > 0; x--) {
					if (!found && bmd.getPixel(x, y)) { found = true; rect.height = y+1 - rect.y; }
				}
			}

			newBmd = new BitmapData(rect.width, rect.height);
			newBmd.copyPixels(
				bmd, rect, new Point(0, 0)
			);

			return newBmd;
		}
		
		public static function crop(bmd:BitmapData, rect:Rectangle, scale:Boolean = false):BitmapData {
			var newBmd:BitmapData = new BitmapData(rect.width, rect.height);
			newBmd.copyPixels(
				bmd,
				rect,
				new Point(0, 0)
			);
			
			return newBmd;
		}
		
		public static function addBorder(myMC):void{
			var mc:MovieClip = new MovieClip();
			mc.graphics.lineStyle(2, 0x434B54);
			mc.graphics.drawRect(0, 0, myMC.width, myMC.height);
			mc.graphics.endFill();
			myMC.addChild(mc);
		}		
	}
}