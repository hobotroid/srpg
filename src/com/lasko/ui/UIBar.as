package com.lasko.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import com.lasko.Global;
	import com.lasko.GameGraphics;
   
	public class UIBar extends MovieClip
	{
		public static const WIDTH:int = 88;
		public static const HEIGHT:int = 8;
		public static const CAP_WIDTH:int = 7;
		public static const LINE_WIDTH:int = 1;
		
		private var color:int = 0xFF0000;
		private var max:int;
		private var value:int;
		private var label:String;

		private var bar:Sprite;
		private var rightCap:Bitmap;
		private var text:TextField;

		public function UIBar(color:int, max:int, label:String) 
		{
			this.max = max;
			this.color = color;
			this.label = label;
			
			bar = new Sprite();
			var outline:Sprite = new Sprite();
			/*bar.graphics.beginFill(color);
			bar.graphics.lineStyle(LINE_WIDTH, color);
			bar.graphics.drawRoundRect(0, 0, WIDTH, HEIGHT, 8);
			bar.graphics.endFill();*/

            /*var parallelogram:Shape = new Shape();    
			parallelogram.graphics.beginFill(0xffffff);
            parallelogram.graphics.lineStyle(1, 0xffffff, 1, false, LineScaleMode.VERTICAL, CapsStyle.NONE, JointStyle.MITER, 5);
            parallelogram.graphics.moveTo(9, 0);
            parallelogram.graphics.lineTo(0, 9);
            parallelogram.graphics.lineTo(80, 9);
            parallelogram.graphics.lineTo(89, 0);
            parallelogram.graphics.lineTo(9, 0); 
			parallelogram.graphics.endFill();
			outline.addChild(parallelogram);
			*/
			
			/*var filling:Shape = new Shape();
			filling.graphics.beginFill(color);
            filling.graphics.lineStyle(1, 0xffffff, 1, false, LineScaleMode.VERTICAL, CapsStyle.NONE, JointStyle.MITER, 5);
            filling.graphics.moveTo(8, 0);
            filling.graphics.lineTo(0, 8);
            filling.graphics.lineTo(78, 8);
            filling.graphics.lineTo(88, 0);
            filling.graphics.lineTo(8, 0); 
			filling.graphics.endFill();*/
			
			var filling:Shape = new Shape();
			filling.graphics.beginFill(color);
			filling.graphics.drawRect(0, 0, UIBar.WIDTH, UIBar.HEIGHT);
			filling.graphics.endFill();
			
			bar.addChild(filling);
			
			//caps on left amd right of bar
			var leftCap:Bitmap = new Bitmap(new BitmapData(CAP_WIDTH, HEIGHT, true, 0x00000000));
			rightCap = new Bitmap(new BitmapData(CAP_WIDTH, HEIGHT, true, 0x00000000));
			var ct:ColorTransform = new ColorTransform();
			//ct.color = color;
			leftCap.bitmapData.copyPixels(GameGraphics.uiBarCap.bitmapData, new Rectangle(0, 0, CAP_WIDTH, HEIGHT), new Point(0, 0));
			//leftCap.bitmapData.colorTransform(new Rectangle(0, 0, CAP_WIDTH, HEIGHT), ct);
			rightCap.bitmapData.copyPixels(GameGraphics.uiBarCap.bitmapData,  new Rectangle(24 - CAP_WIDTH, 0, CAP_WIDTH, HEIGHT), new Point(0, 0));
			rightCap.x = WIDTH - CAP_WIDTH;
			//rightCap.bitmapData.colorTransform(rightCap.getRect(rightCap), ct);
			
			addChild(bar);
			addChild(rightCap);
			addChild(leftCap);

			text = Global.makeSmallText(label);
			text.setTextFormat(new TextFormat("Chicago", 8, 0x000000));
			text.x = -5;
			text.y = -6;
			addChild(text);

			setValue(max);
		}
      
		private function reset():void
		{
			graphics.clear();

			//shadow
			/*graphics.beginFill(0x000000);
			graphics.lineStyle(LINE_WIDTH, 0x000000);
			graphics.drawRoundRect( -LINE_WIDTH, LINE_WIDTH, WIDTH - LINE_WIDTH, HEIGHT + LINE_WIDTH, 8);
			graphics.endFill();

			//white background
			graphics.beginFill(0xffffff);
			graphics.lineStyle(LINE_WIDTH, 0xffffff);
			graphics.drawRoundRect(0, 0, WIDTH, HEIGHT, 8);
			graphics.endFill();*/
		}

		public function setValue(value:int):void {
			reset();

			if (this.value != value) {
				//text.text = String(value) + ' / ' + String(max);
				this.value = value;
				TweenMax.to(bar, 1, { scaleX: Math.floor(value / max * 100) / 100, ease:Cubic.easeOut } );
				TweenMax.to(rightCap, 1, { x: Math.ceil(value / max * WIDTH - CAP_WIDTH), ease:Cubic.easeOut } );
			}
		}
		
		public function getValue():int {
			return this.value;
		}
	}
}