package app.part.property
{
	import app.data.ResourceNodeData;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.core.DragSource;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.components.Image;
	
	/**
	 * 拖动到图片 
	 * @author lonewolf
	 * 
	 */	
	public class DropImage extends EventDispatcher
	{
		private var _image:Image;
		//图像
		private var _imagePath:String="";
		private var _plist:String="";
		
		public function DropImage(image:Image)
		{
			_image=image;
			image.addEventListener(DragEvent.DRAG_ENTER,dragEnterHandler);
			image.addEventListener(DragEvent.DRAG_DROP,dragDropHandler);
		}
		/**
		 * 拖动到上面，判定能不能放置 
		 * @param event
		 * 
		 */
		protected function dragEnterHandler(event:DragEvent):void
		{
			//数据源
			var ds:DragSource=event.dragSource;
			var data:Object=null;
			if(ds.hasFormat("treeItems"))
			{
				var arr:Array=ds.dataForFormat("treeItems") as Array;
				//不符合
				if(arr==null||arr.length==0)
				{
					return;
				}
				data=arr[0];
				if(data is ResourceNodeData)
				{
					DragManager.acceptDragDrop(_image);
				}
			}
		}
		/**
		 * 放置 
		 * @param event
		 * 
		 */		
		protected function dragDropHandler(event:DragEvent):void
		{
			var ds:DragSource=event.dragSource;
			var data:ResourceNodeData=(ds.dataForFormat("treeItems") as Array)[0] as ResourceNodeData;
			_image.source=data.image;
			_imagePath=data.path;
			_plist=data.plist;
			this.dispatchEvent(new Event(Event.CHANGE));
		}

		public function get imagePath():String
		{
			return _imagePath;
		}

		public function get plist():String
		{
			return _plist;
		}

		public function get image():Image
		{
			return _image;
		}


	}
}