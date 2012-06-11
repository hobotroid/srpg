package com.lasko.entity 
{
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import com.lasko.entity.Character;
	import com.lasko.util.Utils;
	import com.lasko.Global;

	public class CharacterAnimation 
	{
		private var character:Character;
		
		private var frames:Array = new Array();
		private var currentFrame:int = 0;
        private var frameDelayCount:int = 0;
		public var animState:int;
		
		//for blinking and other alternate frames
		private var replaceTimer:int = 0;
		
		public function CharacterAnimation(character:Character, dataXML:XMLList)
		{
			this.character = character;
			
			//frames
			var framesInfo:Array = new Array();
			var enumMap:Object = { 
				'leftwalk': Global.STATE_LEFTWALK, 'rightwalk': Global.STATE_RIGHTWALK, 'upwalk': Global.STATE_UPWALK, 
				'downwalk': Global.STATE_DOWNWALK, 'leftstill': Global.STATE_LEFTSTILL, 'rightstill': Global.STATE_RIGHTSTILL, 
				'upstill': Global.STATE_UPSTILL, 'downstill': Global.STATE_DOWNSTILL , 'combat' : Global.STATE_COMBAT, 
				'dead': Global.STATE_DEAD, 'standard': Global.STATE_STANDARD, 'leftblink': Global.STATE_LEFTBLINK, 
				'rightblink': Global.STATE_RIGHTBLINK, 'downblink': Global.STATE_DOWNBLINK, 'invulnerable': Global.STATE_INVULNERABLE };
			for each (var frameXML:XML in dataXML.frames.children())
			{
				var label:String = String(frameXML.@label.toXMLString());
				if (enumMap[label]) { label = enumMap[label]; }
				framesInfo.push({"num": frameXML.@index.toXMLString(), "label": Number(label), "default": frameXML.@default.toXMLString(), "speed": frameXML.@speed.toXMLString()});
				
				if (frameXML.@replace.length())
				{
					for (var i:int = 0; i < framesInfo.length; i++)
					{
						if (framesInfo[i].label == frameXML.@replace.toXMLString())
						{
							framesInfo[i].alternate = Number(label);
						}
					}
				}
			}
			
			//create the frame array
			for each (var frameInfo:Object in framesInfo)
			{
				if (!frames[frameInfo.label])
				{
					frames[frameInfo.label] = [];
				}
				frames[frameInfo.label].push({"num": frameInfo.num, "default": frameInfo.default, "speed": frameInfo.speed, "alternate": frameInfo.alternate});
			}
			
			//set initial frame
			animState = frames[Global.STATE_DOWNSTILL] ? Global.STATE_DOWNSTILL : Global.STATE_STANDARD;
			
		}
		
		public function getCurrentFrame():int
		{
			if (frames[animState][currentFrame].alternate)
			{
				if (this.replaceTimer++)
				{
					if (this.replaceTimer < frames[frames[animState][currentFrame].alternate][0].speed)
					{
						return (frames[frames[animState][currentFrame].alternate][0].num);
					}
					else
					{
						this.replaceTimer = 0;
					}
				}
				else if (Utils.randRange(1, 30) == 30)
				{
					trace('returning ' + frames[frames[animState][currentFrame].alternate][0].num);
					return (frames[frames[animState][currentFrame].alternate][0].num);
				}
			}
			
			return (frames[animState][currentFrame].num);
		}
		
		public function setAnimState(animState:int):void
		{
			if (!frames[animState])
			{
				animState = frames[Global.STATE_DOWNSTILL] ? Global.STATE_DOWNSTILL : Global.STATE_STANDARD;
			}
			if (this.animState != animState)
			{
				this.animState = animState;
				currentFrame = 0;
				/*if (frames[animState].length > 1)
				{
					frameTimer.start();
				}
				else
                
				{
					frameTimer.stop();
				}*/
				
				switch (animState)
				{
					case "downstill":
						
						break;
					case "downwalk1":
						
						break;
					case "downwalk2":
						
						break;
					default: 
						break;
				}
			}
		}
		
		public function setDefaultAnimState():void
		{
			animState = frames[animState][currentFrame].default;
			if (frames[animState].length > 1)
			{
				//frameTimer.start();
			}
			else
			{
				//frameTimer.stop();
			}
		}
		
		public function changeFrameEvent(e:TimerEvent=null):void
		{
			if (currentFrame < frames[animState].length - 1)
			{
				currentFrame++;
			}
			else
			{
				currentFrame = 0;
			}
		}
		
	}

}