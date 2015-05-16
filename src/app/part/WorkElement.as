package app.part
{
	import app.Config;
	import app.data.ControlData;
	import app.data.FileData;
	import app.message.MessageCenter;
	import app.part.property.NodeProperty;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.media.Video;
	
	import mx.events.FlexEvent;
	
	import spark.components.Image;
	import spark.components.SkinnableContainer;
	
	/**
	 * 工作区里的单元，所有控件都是在这个里面封装
	 * 可拖动，当前的控件会有选择标志
	 * @author lonewolf
	 * 
	 */	
	public class WorkElement extends SkinnableContainer
	{
		private var _image:Image=null;
		private var _layer:SkinnableContainer;
		// 选中
		private var _selected:Boolean=false;		
		// data
		private var _data:ControlData;
		
		//拖动相关参数
		private var _startDragPos:Point=new Point();
		private var _startStagePos:Point=new Point();
		
		public function WorkElement(data:ControlData)
		{
			_data=data;
			this.init();
			//拖动
			this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
		}
		/**
		 * 初始化
		 * 
		 */
		private function init():void
		{
			if(_data.type==Config.CONTROL_TYPE_SPRITE)
			{
				this.setImage();
			}
			else if(_data.type==Config.CONTROL_TYPE_BUTTON)
			{
				this.setImage();
			}
			else if(_data.type==Config.CONTROL_TYPE_LAYER)
			{
				this.setLayer();
			}
			this.setPosition();
			this.setAnchor();
		}
		/**
		 * 设置图像,也可以是重设
		 * 
		 */
		private function setImage():void
		{
			var path:String="";
			var plist:String="";
			if(_data.type==Config.CONTROL_TYPE_SPRITE)
			{
				path=_data.spriteData.image;
				plist=_data.spriteData.imagePlist;
			}
			else if(_data.type==Config.CONTROL_TYPE_BUTTON)
			{
				path=_data.buttonData.normal;
				plist=_data.buttonData.normalPlist;
			}
			if(_image==null)
			{
				_image=new Image();
				// 图像加载完成
				_image.addEventListener(FlexEvent.READY,imageReadyHandler);
				this.addElement(_image);
			}
			var source:Object=Config.missingImage;
			if(path!="")
			{
				var image:DisplayObject=Config.resourceManager.findImage(path,plist);
				if(image!=null)
				{
					source=image;
				}
			}
			_image.source=source;
		}
		/**
		 * 图像加载完成，设置锚点
		 * @param event
		 * 
		 */		
		protected function imageReadyHandler(event:FlexEvent):void
		{
			this.setAnchor();
			if(_selected)
			{
				this.drawFlag();
			}
		}
		/**
		 * 设置图层 
		 * 
		 */
		private function setLayer():void
		{
			if(_layer==null)
			{
				_layer=new SkinnableContainer();
				this.addElement(_layer);
			}
			_layer.graphics.clear();
			_layer.graphics.beginFill(_data.layerData.color,_data.layerData.alpha);
			_layer.graphics.drawRect(0,0,Config.curFileData.width,-Config.curFileData.height);
			_layer.graphics.endFill();
		}
		/**
		 * 设置坐标
		 * 
		 */
		private function setPosition():void
		{
			var w:Number=Config.curFileData.width;
			var h:Number=Config.curFileData.height;
			var x:Number=_data.nodeData.x;
			var xAlign:String=_data.nodeData.xAlign;
			if(xAlign==Config.LOCATION_CENTER)
			{
				x=w/2-x;
			}
			else if(xAlign==Config.LOCATION_RIGHT)
			{
				x=w-x;
			}
			var y:Number=_data.nodeData.y;
			var yAlign:String=_data.nodeData.yAlign;
			if(yAlign==Config.LOCATION_CENTER)
			{
				y=h/2-y;
			}
			else if(yAlign==Config.LOCATION_TOP)
			{
				y=h-y;
			}
			// 转成flash坐标
			if(_data.parent is ControlData)
			{
				y=-y;
			}
			else
			{
				y=h-y;
			}
			this.x=x;
			this.y=y;
		}
		/**
		 * 设置锚点 
		 * 
		 */
		private function setAnchor():void
		{
			if(_image==null||_image.sourceWidth==0)
			{
				return;
			}
//			trace("anchor"+_image.sourceWidth+" "+_image.sourceHeight);
			var anchorX:Number=_data.nodeData.anchorX;
			var anchorY:Number=_data.nodeData.anchorY;
			_image.x=-_image.sourceWidth*anchorX;
			_image.y=_image.sourceHeight*anchorY-_image.sourceHeight;
			if(_selected)
			{
				this.drawFlag();
			}
		}
		/**
		 * 更新控件属性，由WorkAreaPart调用 
		 * @param type
		 * 
		 */
		public function update(type:String):void
		{
			if(type==MessageCenter.CONTROL_IMAGE)
			{
				this.setImage();
			}
			else if(type==MessageCenter.CONTROL_POSITION)
			{
				this.setPosition();
			}
			else if(type==MessageCenter.CONTROL_ANCHOR)
			{
				this.setAnchor();
			}
			else if(type==MessageCenter.CONTROL_COLOR)
			{
				this.setLayer();
			}
			else if(type==MessageCenter.CONTROL_VISIBLE)
			{
				this.visible=_data.nodeData.visible;
			}
		}
		/**
		 * 全部更新位置，由WorkAreaPart调用 
		 * 
		 */		
		public function updatePosAll():void
		{
			this.setPosition();
			var i:int=0;
			for(i=0;i<this.numElements;i++)
			{
				var element:WorkElement=this.getElementAt(i) as WorkElement;
				if(element!=null)
				{
					element.updatePosAll();
				}
			}
		}
		/**
		 * 开始拖动 
		 * @param event
		 * 
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			this.dispatchEvent(new Event(Event.SELECT));
			// 颜色层不可以拖动
			if(_data.type==Config.CONTROL_TYPE_LAYER)
			{
				return;
			}
			_startDragPos.x=this.x;
			_startDragPos.y=this.y;
			_startStagePos.x=event.stageX;
			_startStagePos.y=event.stageY;
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			event.stopImmediatePropagation();
		}
		/**
		 * 拖动中 
		 * @param event
		 * 
		 */
		protected function moveHandler(event:MouseEvent):void
		{
			var s:Number=Config.sceneZoom/100;
			this.x=_startDragPos.x+(event.stageX-_startStagePos.x)/s;
			this.y=_startDragPos.y+(event.stageY-_startStagePos.y)/s;
			this.coorFlashToGame();
			// 坐标改变
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		/**
		 * 停止拖动 
		 * @param event
		 * 
		 */
		protected function mouseUpHandler(event:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
		}
		/**
		 * 把当前坐标转换成游戏坐标
		 * 
		 */
		private function coorFlashToGame():void
		{
			var w:Number=Config.curFileData.width;
			var h:Number=Config.curFileData.height;
			
			// 转换后的坐标
			var x:Number=this.x;
			var y:Number=this.y;
			if(_data.parent is ControlData)
			{
				y=-y;
			}
			else
			{
				y=h-y;
			}
			
			//再转成相对的坐标
			var xAlign:String=_data.nodeData.xAlign;
			if(xAlign==Config.LOCATION_CENTER)
			{
				x-=w/2;
			}
			else if(xAlign==Config.LOCATION_RIGHT)
			{
				x=w-x;
			}
			var yAlign:String=_data.nodeData.yAlign;
			if(yAlign==Config.LOCATION_CENTER)
			{
				y=h/2-y;
			}
			else if(yAlign==Config.LOCATION_TOP)
			{
				y=h-y;
			}
			_data.nodeData.x=x;
			_data.nodeData.y=y;
		}
		/**
		 * 选中标志 
		 * @param value
		 * 
		 */
		public function setSelected(value:Boolean):void
		{
			if(value==_selected)
			{
				return;
			}
			_selected=value;
			this.graphics.clear();
			if(!value)
			{
				return;
			}
			this.drawFlag();
		}
		/**
		 * 显示标志 
		 * 
		 */		
		private function drawFlag():void
		{
			this.graphics.clear();
			if(_image)
			{
				this.graphics.lineStyle(1,0xff0000);
				this.graphics.beginFill(0xff0000,0.3);
				this.graphics.drawRect(_image.x,_image.y,_image.sourceWidth,_image.sourceHeight);
				this.graphics.endFill();
			}
			//node，画一个小的圆圈
			if(_data.type==Config.CONTROL_TYPE_NODE)
			{
				this.graphics.lineStyle(1,0xff0000);
				this.graphics.beginFill(0xff0000,0.5);
				this.graphics.drawCircle(0,0,10);
				this.graphics.endFill();
			}			
		}
		/**
		 * 不再使用，从界面中删除 
		 * 
		 */
		public function remove():void
		{
			if(_image)
			{
				_image.source=null;
			}
			if(this.owner)
			{
				(this.owner as SkinnableContainer).removeElement(this);
			}
		}

		public function get data():ControlData
		{
			return _data;
		}


	}
}