package {
	import flash.text.Font;
	import flash.text.TextFormat;
	
	/**
	 *  This class sets up the fonts for the application.
	 */
	public class Fonts {
		// Embed a TTF files
		[Embed(
			source = "../pixChicago.ttf",
			fontName = "pixChicago",
			fontWeight = "normal",
			advancedAntiAliasing = "false",
			mimeType = "application/x-font",
			fontStyle = "normal",
			embedAsCFF = 'false'
		)]
		private static var pixChicago:Class;
		[Embed(
			source = "../chicago_normal.ttf",
			fontName = "Chicago",
			fontWeight = "bold",
			advancedAntiAliasing = "false",
			mimeType = "application/x-font",
			fontStyle = "normal",
			embedAsCFF = 'false'
		)]
		private static var chicago:Class;
		public static var textFormatMain:TextFormat;
	
		public static function init():void {
			// Register the font with the global Font manager class
			Font.registerFont(pixChicago);
			Font.registerFont(chicago);
			
			textFormatMain = new TextFormat();
			textFormatMain.font = "Chicago";
			textFormatMain.color = 0xffffff;
			textFormatMain.size = 16;
			//textFormatMain.letterSpacing = 0.8;

		}
	}
}