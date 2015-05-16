package AirLib.dragable
{
	import AirLib.events.DragDropEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.components.Group;

	/**
	 * 拖动图片到Group 
	 * @author lonewolf
	 * 
	 */	
	public class DragImageDropGroup extends EventDispatcher
	{
		private var _dropGroup:Group;
		private var _imageClass:Class;
		
		/**
		 * 构造函数 
		 * @param group 判断拖动到的Group，并不一定将图片拖动到此Group，也可以放在它的子Group中
		 * @param dropGroup 真正放入的Group,可以和group是同一个
		 * @param imageClass DropImage或其子类
		 * 
		 */		
		public function DragImageDropGroup(group:Group,dropGroup:Group,imageClass:Class)
		{
			_dropGroup=dropGroup;
			_imageClass=imageClass;
			group.addEventListener(DragEvent.DRAG_ENTER,dragEnterHandler);
			group.addEventListener(DragEvent.DRAG_DROP,dragDropHandler);
		}
		/**
		 * 拖动进入范围 
		 * @param event
		 * 
		 */		
		protected function dragEnterHandler(event:DragEvent):void
		{
			if(event.dragSource.hasFormat("itemsByIndex"))
			{
				DragManager.acceptDragDrop(UIComponent(event.currentTarget));
			}			
		}
		/**
		 * 拖动释放 
		 * @param event
		 * 
		 */		
		protected function dragDropHandler(event:DragEvent):void
		{
			var source:Vector.<Object>=event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			var item:IDragObject=source[0] as IDragObject;
			var image:DropImage=new _imageClass() as DropImage;
			image.source=item.getSource();
			image.setUserData(item.userData());
			var p:Point=_dropGroup.globalToContent(new Point(event.stageX,event.stageY));
			image.x=p.x;
			image.y=p.y;
			_dropGroup.addElement(image);
			//拖动完成，触发事件
			var event2:DragDropEvent=new DragDropEvent(DragDropEvent.COMPLETE);
			event2.dropObject=image;
			this.dispatchEvent(event2);
		}
	}
}