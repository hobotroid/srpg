package com.lasko.ui 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.containers.TabNavigator;
	import mx.containers.VBox;
	import mx.controls.Button;
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.components.VGroup;
	
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.Window;
	
	import com.lasko.input.GameInput;
	
	public class DebugWindow extends Window
	{
		private var tf:TextArea = new TextArea();
		private var tn:TabNavigator = new TabNavigator();
		
		public function DebugWindow() 
		{
			this.title = "Debug";
			
			addEventListener(Event.ADDED_TO_STAGE, this.init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, this.init);
			
			tn.percentWidth = 100;
			tn.percentHeight = 100;
			tf.percentWidth = 100;
			tf.percentHeight = 100;
			tn.addChild(createTab('Output', tf));
			tn.addChild(createTab('Input', makeInputs()));
			this.addChild(tn);

			out('Debug Window Initialized, bro.');
		}
		
		public function out(string:String):void {
			tf.appendText(string + "\n");
			if (!tf.scroller) { 
				tf.text += string;
				return;
			}
			tf.scroller.verticalScrollBar.value = tf.scroller.verticalScrollBar.maximum;
		}
		
		private function createTab(label:String, content:DisplayObject=null):Canvas {
			var tab:Canvas = new Canvas();
			var inside:Panel = new Panel();
			
			tab.label = label;
			tab.name = label;
			tab.percentWidth = 100;
			tab.percentHeight = 100;
			
			if(content) {
				tab.addChild(content);
			}
			
			return tab;
		}
		
		private function makeInputs():Box {
			var box:Box = new Box();
			box.name = "inputs";
			
			var refreshButton:Button = new Button();
			refreshButton.label = "Refresh";
			refreshButton.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				refreshInputs();
			});
			
			box.addChild(refreshButton);
			
			return box;
		}
		
		private function refreshInputs():void {
			var box:Box = (tn.getChildByName("Input") as Canvas).getChildByName("inputs") as Box;
			
			for (var i:int = 0; i < box.numChildren; i++) {
				var child:DisplayObject = box.getChildAt(i);
				if (getQualifiedClassName(child) == "Label") {
					box.removeChild(child);
				}
			}
			
			var activeInputInstance:GameInput = GameInput.getActiveInstance();
			for each(var input:GameInput in GameInput.getInstances()) {
				var label:Label = new Label();
				label.text = input.getLabel();
				if(input == activeInputInstance) { label.setStyle("color", "red"); }
				box.addChild(label);
			}
		}
		
	}

}