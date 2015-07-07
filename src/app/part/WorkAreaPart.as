package app.part
{
	import app.Config;
	import app.data.ControlData;
	import app.data.FileData;
	import app.data.ResourceNodeData;
	import app.message.MessageCenter;
	import app.message.Messager;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.DragSource;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.ResizeEvent;
	import mx.managers.DragManager;
	
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
			
			// 拖动
			_container.addEventListener(DragEvent.DRAG_ENTER,dragEnterHandler);
			_container.addEventListener(DragEvent.DRAG_DROP,dragDropHandler);
			
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
			else if(type==MessageCenter.SCENE_ZOOM)
			{
				// 缩放
				// 相对于group中心点缩放
				var s:Number=Config.sceneZoom/100;
				_container.scaleX=_container.scaleY=s;
//				s=s/_container.scaleX;
//				var p:Point=new Point(_group.width/2,_group.height/2);
//				p=_group.localToGlobal(p);
//				p=_container.globalToLocal(p);
//				var m:Matrix=_container.transform.matrix;
//				m.translate(-p.x,-p.y);
//				m.scale(s,s);
//				m.translate(p.x,p.y);
//				_container.transform.matrix=m;
			}
			else if(type==MessageCenter.LOCK_SCENE_STATE_CHANGED)
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
			else if(type==MessageCenter.DELETE_CONTROL)
			{
				// 删除控件
				if(_curElement!=null)
				{
					_curElement.remove();
					_curElement=null;					
				}
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
			else if(type==MessageCenter.DRAG_CONTROL)
			{
				// 拖动控件
				this.newFileData();
				// 找出要拖动的控件
				e=this.findElement(Config.curControl,_container);
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
			else if(_elementTypeList.indexOf(type)!=-1)
			{
				if(_curElement!=null)
				{
					_curElement.update(type);
				}
			}
		}
		/**
		 * 是否可以通过滚轮来缩放
		 * @return 
		 * 
		 */
		public function checkWheel():Boolean
		{
			return _group.hitTestPoint(_group.stage.mouseX,_group.stage.mouseY);
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
					DragManager.acceptDragDrop(_container);
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
			
			var control:ControlData=new ControlData(Config.CONTROL_TYPE_SPRITE);
			control.spriteData.image=data.path;
			control.spriteData.imagePlist=data.plist;
			// 确定放置点
			var container:DisplayObjectContainer=_container;
			if(_curElement)
			{
				if(_curElement.data.type==Config.CONTROL_TYPE_NODE)
				{
					container=_curElement;
				}
				else
				{
					container=_curElement.owner;
				}
			}
			var p:Point=container.globalToLocal(new Point(event.stageX,event.stageY));
			control.nodeData.x=p.x;
			if(container==_container)
			{
				control.nodeData.y=Config.resolution.height-p.y;
			}
			else
			{
				control.nodeData.y=-p.y;
			}			
			Config.newControl=control;
			MessageCenter.sendMessage(null,MessageCenter.NEW_CONTROL);
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
			_container.stage.focus=_curElement;
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