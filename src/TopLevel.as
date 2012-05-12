package {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;

	/*
	* TopLevel class
	* have all document classes extend this
	* class instead of Sprite or MovieClip to
	* allow global stage and root access through
	* TopLevel.stage and TopLevel.root
	*/
	public class TopLevel extends Sprite {

		public static var stage:Stage;
		public static var root:DisplayObject;
		 
		public function TopLevel() 
		{
			TopLevel.stage = this.stage;
			TopLevel.root = this;
			mouseEnabled = false;
		}
	}
}