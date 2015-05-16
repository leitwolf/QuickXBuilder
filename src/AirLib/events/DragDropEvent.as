package AirLib.events
{
	import AirLib.dragable.IDropObject;
	
	import flash.events.Event;
	
	public class DragDropEvent extends Event
	{
		/**
		 * 拖动完成 
		 */
		public static const COMPLETE:String="complete";
		
		public var dropObject:IDropObject;
		
		public function DragDropEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}