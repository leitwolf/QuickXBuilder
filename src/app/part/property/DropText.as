package app.part.property
{
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.components.TextInput;

	/**
	 * 接受其它控件拖动过来的文件名 
	 * @author lonewolf
	 * 
	 */	
	public class DropText
	{
		public static const IMAGE:String="png|jpg";
		public static const SOUND:String="mp3|wav";
		
		private var _textInput:TextInput;
		private var _acceptExtArr:Array=[];
		private var _property:PropertyBase;
		private var _path:String;
		//是否是plist里的
		private var _isPackage:Boolean=false;
		
		/**
		 *  
		 * @param textInput
		 * @param acceptExt "png|jpg"
		 * 
		 */		
		public function DropText(textInput:TextInput,acceptExt:String,property:PropertyBase)
		{
			_textInput=textInput;
			_acceptExtArr=acceptExt.split("|");
			_property=property;
			if(_acceptExtArr.length>0)
			{
				_textInput.editable=false;
				_textInput.addEventListener(DragEvent.DRAG_ENTER,dragEnterHandler);
				_textInput.addEventListener(DragEvent.DRAG_DROP,dragDropHandler);
			}
		}
		
		protected function dragEnterHandler(event:DragEvent):void
		{
			var ds:DragSource=event.dragSource;
			if(ds.hasFormat("treeItems"))
			{
				var data:Array=ds.dataForFormat("treeItems") as Array;
				if(data&&data.length>0)
				{
					var obj:Object=data[0];
					if(obj.label && obj.path)
					{
						var name:String=obj.label;
						var index:uint=name.lastIndexOf(".");
						if(index!=-1)
						{
							var ext:String=name.substring(index+1);
							var has:Boolean=false;
							for each(var str:String in _acceptExtArr)
							{
								if(str==ext)
								{
									has=true;
									break;
								}
							}
							if(has)
							{
								DragManager.acceptDragDrop(event.currentTarget as UIComponent);
							}
						}
					}
				}
			}
		}
		
		protected function dragDropHandler(event:DragEvent):void
		{
			var ds:DragSource=event.dragSource;
			var data:Object=ds.dataForFormat("treeItems");
			_textInput.text=data[0].path;
			_path=data[0].path;
			//保存到属性
//			_property.commitControlValue(_textInput);
		}

		public function get textInput():TextInput
		{
			return _textInput;
		}

	}
}