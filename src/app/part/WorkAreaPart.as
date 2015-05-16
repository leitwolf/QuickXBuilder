package app.part
{
	import app.Config;
	import app.data.ControlData;
	import app.data.FileData;
	import app.message.MessageCenter;
	import app.message.Messager;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	import spark.components.Panel;
	import spark.components.SkinnableContainer;

	public class WorkAreaPart extends Messager
	{
		private var _group:Group;
		private var _container:SkinnableContainer;
		
		// 要监听的元素的消息类型列表
		private var _elementTypeList:Array=[
			MessageCenter.CONTROL_IMAGE,
			MessageCenter.CONTROL_POSITION,
			MessageCenter.CONTROL_ANCHOR,
			MessageCenter.CONTROL_COLOR,
			MessageCenter.CONTROL_VISIBLE
		];
		
		//当前元件
		private var _curElement:WorkElement;
		
		public function WorkAreaPart()
		{
			_group=FlexGlobals.topLevelApplication.groupContainer;
			_container=FlexGlobals.topLevelApplication.workContainer;
			
			_group.addEventListener(ResizeEvent.RESIZE,resizeHandler);
			
			_container.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			
			this.createStage();
		}
		/**
		 * 接收消息 
		 * @param sender
		 * @param type
		 * 
		 */		
		override public function receiveMessage(sender:Object, type:String):void
		{
			if(type==MessageCenter.RESOLUTION)
			{
				// 分辨率改变
				this.createStage();
				
				//更新位置
				var i:int=0;
				for(i=0;i<_container.numElements;i++)
				{
					var element:WorkElement=_container.getElementAt(i) as WorkElement;
					if(element!=null)
					{
						element.updatePosAll();
					}
				}
				
				// 更新图层
				this.receiveMessage(null,MessageCenter.CONTROL_COLOR);
			}
			else if(type==MessageCenter.ZOOM)
			{
				// 缩放
				var s:Number=Config.sceneZoom/100;
				_container.scaleX=s;
				_container.scaleY=s;
			}
			else if(type==MessageCenter.DRAG_SCENE)
			{
				// 拖动场景
				_container.mouseChildren=!Config.enableDragScene;
				_container.mouseEnabled=Config.enableDragScene;
			}
			else if(type==MessageCenter.CURRENT_FILE)
			{
				// 当前文件
				this.createStage();
				this.newFileData();
			}
			else if(type==MessageCenter.NEW_CONTROL)
			{
				// 新控件
				var parent:ControlData=Config.newControl.parent as ControlData;
				var container:SkinnableContainer=_container;
				if(parent!=null)
				{
					container=this.findElement(parent,_container);
				}
				this.addNode(Config.newControl,container);
			}
			else if(type==MessageCenter.CURRENT_CONTROL)
			{
				// 控件名改变，刷新树列表
				if(_curElement!=null)
				{
					_curElement.setSelected(false);
				}
				if(Config.curControl==null)
				{
					_curElement=null;
				}
				else
				{
					var e:WorkElement=this.findElement(Config.curControl,_container);
					if(e!=null)
					{
						e.setSelected(true);
					}
					else
					{
						trace("no cur");
					}
					_curElement=e;
				}
			}
			else if(_elementTypeList.indexOf(type)!=-1)
			{
				if(_curElement!=null)
				{
					_curElement.update(type);
				}
			}
		}
		/**
		 * 建立舞台
		 * 
		 */
		private function createStage():void
		{
			var w:Number=Config.resolution.width;
			var h:Number=Config.resolution.height;
			if(Config.curFileData)
			{
				w=Config.curFileData.width;
				h=Config.curFileData.height;
			}
			_container.graphics.clear();
			_container.graphics.beginFill(0x0000ff);
			_container.graphics.drawRect(0,0,w,h);
			_container.graphics.endFill();
		}
		/**
		 * 从容器中查找控件
		 * @param data
		 * @param container
		 * @return 
		 * 
		 */		
		private function findElement(data:ControlData,container:SkinnableContainer):WorkElement
		{
			var i:int=0;
			for(i=0;i<container.numElements;i++)
			{
				var element:WorkElement=container.getElementAt(i) as WorkElement;
				if(element!=null)
				{
					if(element.data==data)
					{
						return element;
					}
					else
					{
						var w:WorkElement=this.findElement(data,element);
						if(w!=null)
						{
							return w;
						}
					}
				}
			}
			return null;
		}
		
		protected function resizeHandler(event:ResizeEvent):void
		{
//			this.resizeView(false);
		}
		/**
		 * 开始拖动场景 
		 * @param event
		 * 
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			_container.startDrag(false,null);
			var stage:Stage=FlexGlobals.topLevelApplication.stage;
			stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
		}
		/**
		 * 结束拖动 
		 * @param event
		 * 
		 */
		protected function mouseUpHandler(event:MouseEvent):void
		{
			var stage:Stage=FlexGlobals.topLevelApplication.stage;
			stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			_container.stopDrag();
		}
		/**
		 * 新文件树，将删除所有的element然后再重新添加
		 * @param fileData
		 * 
		 */
		private function newFileData():void
		{
			var len:int=_container.numElements;
			if(len>0)
			{
				var i:int=0;
				for(i=len-1;i>=0;i--)
				{
					(_container.getElementAt(i) as WorkElement).remove();
				}				
			}
			if(Config.curFileData==null)
			{
				return;
			}
			//解析
			for each(var node:ControlData in Config.curFileData.children)
			{
				this.addNode(node,_container);
			}
		}
		/**
		 * 生成控件并加入父控件
		 * @param node 
		 * @param container
		 * 
		 */		
		private function addNode(node:ControlData,container:SkinnableContainer):void
		{
			var element:WorkElement=new WorkElement(node);
			container.addElement(element);
			// 监听
			element.addEventListener(Event.SELECT,selectHandler);
			element.addEventListener(Event.CHANGE,positionChangeHandler);
			if(node.children)
			{
				for each(var n:ControlData in node.children)
				{
					this.addNode(n,element);
				}
			}
		}
		/**
		 * 选择了当前控件
		 * @param event
		 * 
		 */
		protected function selectHandler(event:Event):void
		{
			var element:WorkElement=event.currentTarget as WorkElement;
			if(element==_curElement)
			{
				return;
			}
			if(_curElement!=null)
			{
				_curElement.setSelected(false);
			}
			_curElement=element;
			element.setSelected(true);
			Config.curControl=element.data;
			//通知控件树
			this.sendMessage(MessageCenter.CURRENT_CONTROL);
		}
		/**
		 * 拖动了，坐标改变
		 * @param event
		 * 
		 */
		protected function positionChangeHandler(event:Event):void
		{
			this.sendMessage(MessageCenter.CONTROL_POSITION);
			this.sendMessage(MessageCenter.FILE_DIRTY);
		}
		
	}
}