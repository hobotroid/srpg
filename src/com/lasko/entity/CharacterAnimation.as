package com.lasko.entity 
{
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import net.flashpunk.graphics.Spritemap;
	
	import com.lasko.entity.Character;
	import com.lasko.util.Utils;
	import com.lasko.Global;
	import com.lasko.GameGraphics;

	public class CharacterAnimation 
	{
		private var character:Character;
		private var spritemap:Spritemap;
		
		public function CharacterAnimation(character:Character, dataXML:XMLList)
		{
			this.character = character;
			spritemap = new Spritemap(GameGraphics.carlFrames, character.width, character.height);
			
			//frames
			var framesInfo:Array = new Array();
			var framesByLabel:Object = { };

			for each (var frameXML:XML in dataXML.frames.children()) {
				var label:String = String(frameXML.@label.toXMLString());
				var frameInfo:Object = { "num": frameXML.@index.toXMLString(), "label": Number(label), "default": frameXML.@default.toXMLString(), "speed": frameXML.@speed.toXMLString() };
				if (!framesByLabel[label]) { framesByLabel[label] = []; }
				framesByLabel[label].push(int(frameInfo.num));
				framesInfo.push(frameInfo);
			}
			
			//create the flashpunk frames
			for (label in framesByLabel) {
				spritemap.add(label, framesByLabel[label], .2);
			}
			
			spritemap.play("downstill");
			character.graphic = spritemap;
		}
		
		public function setAnimState(stateName:String):void
		{
			spritemap.play(stateName);
		}
		
		public function walkStop():void
		{
			if (this.spritemap.currentAnim == "downwalk") {
				this.spritemap.play("downstill");
			} else if (this.spritemap.currentAnim == "upwalk") {
				this.spritemap.play("upstill");
			} else if (this.spritemap.currentAnim == "leftwalk") {
				this.spritemap.play("leftstill");
			} else if (this.spritemap.currentAnim == "rightwalk") {
				this.spritemap.play("rightstill");
			}
		}
		
		public function getAnimState():String
		{
			return this.spritemap.currentAnim;
		}
	}
}