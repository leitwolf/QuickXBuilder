package AirLib.events
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	public class DragMoveEvent extends Event
	{
		public static const START:String="start";
		public static const DRAGING:String="draging";
		public static const STOP:String="stop";
		
		public var source:UIComponent;
		
		public function DragMoveEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}