package AirLib.dragable
{
	import AirLib.events.DragMoveEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;

	/**
	 * 在舞台上拖动的物体 
	 * @author lonewolf
	 * 
	 */	
	public class DragMoveObject extends EventDispatcher
	{
		private var _ui:UIComponent;
		
		public function DragMoveObject(ui:UIComponent)
		{
			_ui=ui;
			
			_ui.addEventListener(MouseEvent.MOUSE_DOWN,startDragHandler);
			_ui.addEventListener(MouseEvent.MOUSE_UP,stopDragHandler);
		}
		//开始拖动
		protected function startDragHandler(event:MouseEvent):void
		{
			_ui.startDrag();
			FlexGlobals.topLevelApplication.stage.addEventListener(MouseEvent.MOUSE_MOVE,dragingHandler);
			var event2:DragMoveEvent=new DragMoveEvent(DragMoveEvent.START);
			event2.source=_ui;
			this.dispatchEvent(event2);
		}		
		//拖动中
		protected function dragingHandler(event:MouseEvent):void
		{
			var event2:DragMoveEvent=new DragMoveEvent(DragMoveEvent.DRAGING);
			event2.source=_ui;
			this.dispatchEvent(event2);	
		}
		//停止拖动
		protected function stopDragHandler(event:MouseEvent):void
		{
			FlexGlobals.topLevelApplication.stage.removeEventListener(MouseEvent.MOUSE_MOVE,dragingHandler);
			_ui.stopDrag();
			var event2:DragMoveEvent=new DragMoveEvent(DragMoveEvent.STOP);
			event2.source=_ui;
			this.dispatchEvent(event2);
		}
	}
}