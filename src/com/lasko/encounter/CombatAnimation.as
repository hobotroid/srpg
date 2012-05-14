package com.lasko.encounter 
{
	public class CombatAnimation 
	{
		private var frames:Array;
		
		public function CombatAnimation(frames:Array) 
		{
			this.frames = frames;
		}
		
		public function getFrames():Array {
			return this.frames;
		}
		
		public function getFrameAt(index:int):Object {
			return this.frames[index];
		}
		
		public function getFrameCount():int {
			return this.frames.length;
		}
	}

}