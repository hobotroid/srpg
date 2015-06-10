package com.lasko {
	import flash.text.Font;
	import flash.text.TextFormat;
	
	public class Fonts {
		[Embed(
			source = "../../../pixChicago.ttf",
			fontName = "pixChicago",
			fontWeight = "normal",
			advancedAntiAliasing = "false",
			mimeType = "application/x-font",
			fontStyle = "normal",
			embedAsCFF = 'false'
		)]
		private static var pixChicagoClass:Class;
		public static var textFormatMain:TextFormat;
	
		public static function init():void {
			addFont(pixChicagoClass);
		}
		
		public static function addFont(fontClass:Class):void {
			Font.registerFont(fontClass);
			
			textFormatMain = new TextFormat();
			textFormatMain.font = "pixChicago";
			textFormatMain.color = 0xffffff;
			textFormatMain.size = 10;
			//textFormatMain.letterSpacing = 0.8;

		}
	}
}