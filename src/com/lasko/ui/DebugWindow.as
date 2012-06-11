package com.lasko.ui 
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import spark.components.TextArea;
	
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.Window;
	
	public class DebugWindow extends Window
	{
		private var tf:TextArea = new TextArea();
		
		public function DebugWindow() 
		{
			this.title = "Debug";
			addEventListener(Event.ADDED_TO_STAGE, this.init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, this.init);
			
			tf.visible = true;
			tf.percentWidth = 100;
			tf.percentHeight = 100;
			
			this.addElement(tf);

			out('Debug Window Initialized, bro.');
		}
		
		public function out(string:String):void {
			tf.appendText(string + "\n");
			tf.scroller.verticalScrollBar.value = tf.scroller.verticalScrollBar.maximum;
		}
		
	}

}