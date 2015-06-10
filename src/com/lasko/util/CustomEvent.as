package com.lasko.util
{
	import flash.events.Event;
	
	public class CustomEvent extends Event 
	{
		public static const EVENT_DEFAULT:String = "event1";
		public static const EVENT_CUSTOM:String = "event2";

		public function CustomEvent(type:String = CustomEvent.EVENT_DEFAULT, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new CustomEvent(type, bubbles, cancelable);
		}
	}
}