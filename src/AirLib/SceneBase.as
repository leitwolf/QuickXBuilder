package AirLib
{
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.NativeDragEvent;
	
	import mx.core.FlexGlobals;

	/**
	 * 所有页面的基类 
	 * @author lonewolf
	 * 
	 */	
	public class SceneBase
	{
		//当前页面的state
		protected var _state:String;
		//是否已经执行onStart过
		private var _onStartProceeded:Boolean=false;
		//是否有本地拖动
		private var _enableNativeDrag:Boolean=false;
		//允许同时拖进的个数,0为任意个
		private var _nativeDragNum:uint=0;
		//是否要监听按键
		private var _enableKeyDown:Boolean=false;
		private var _enableKeyUp:Boolean=false;
		
		public function SceneBase(state:String="")
		{
			_state=state;
		}
		/**
		 * 是否允许本地拖动
		 * @param enable
		 * @param num 允许同时拖进的数量,0为任意个
		 * 
		 */
		protected function enableNativeDrag(enable:Boolean,num:uint=0):void
		{
			if(enable==_enableNativeDrag)
			{
				return;
			}
			_enableNativeDrag=enable;
			_nativeDragNum=num;
			if((enable&&_onStartProceeded)||!enable)
			{
				//如果已经执行过onStart，说明界面已经显示，则直接调用
				this.nativeDrag(enable);
			}
		}
		//开始或停止本地拖进
		private function nativeDrag(value:Boolean):void
		{
			var stage:Stage=FlexGlobals.topLevelApplication.stage;
			if(value)
			{
				stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,nativeDragEnterHandler);
				stage.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,nativeDragDropHandler);
			}
			else
			{
				stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,nativeDragEnterHandler);
				stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP,nativeDragDropHandler);					
			}
		}
		//本地拖动进来		
		private function nativeDragEnterHandler(event:NativeDragEvent):void
		{
			// 只接受外部拖动
			var fileArr:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			if(fileArr!=null&&fileArr.length>0)
			{
				if(_nativeDragNum==0||fileArr.length==_nativeDragNum)
				{
					NativeDragManager.acceptDragDrop(FlexGlobals.topLevelApplication.stage);
				}
			}
		}
		//本地拖动放下
		private function nativeDragDropHandler(event:NativeDragEvent):void
		{
			var fileArr:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			if(fileArr==null||fileArr.length==0)
			{
				return;
			}
			this.nativeHandler(fileArr);
		}
		/**
		 * 本地拖动的处理方法，要在子类中继承
		 * @param fileList 已经拖进来的文件
		 * 
		 */		
		protected function nativeHandler(fileList:Array):void
		{			
		}
		/**
		 * 是否允许按键监听 
		 * @param enableKeyDown 监听按下
		 * @param enableKeyUp 监听按键释放
		 * 
		 */		
		protected function enableKeyPress(enableKeyDown:Boolean,enableKeyUp:Boolean):void
		{
			if(enableKeyDown!=_enableKeyDown)
			{
				_enableKeyDown=enableKeyDown;
				if((_enableKeyDown&&_onStartProceeded)||!_enableKeyDown)
				{
					this.keyPress(1,_enableKeyDown);
				}
			}
			if(enableKeyUp!=_enableKeyUp)
			{
				_enableKeyUp=enableKeyUp;
				if((_enableKeyUp&&_onStartProceeded)||!_enableKeyUp)
				{
					this.keyPress(2,_enableKeyUp);
				}
			}
		}
		//开始或停止按键监听 1按下 2释放
		private function keyPress(type:uint,value:Boolean):void
		{
			var stage:Stage=FlexGlobals.topLevelApplication.stage;
			if(type==1)
			{
				if(value)
				{
					stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler1);
				}
				else
				{
					stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler1);				
				}
			}
			else if(type==2)
			{
				if(value)
				{
					stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler1);
				}
				else
				{
					stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpHandler1);				
				}
			}
		}		
		private function keyDownHandler1(event:KeyboardEvent):void
		{
			this.keyDownHandler(event.keyCode);
		}		
		private function keyUpHandler1(event:KeyboardEvent):void
		{
			this.keyUpHandler(event.keyCode);
		}
		/**
		 * 按下按键处理，在子类中继续 
		 * @param keyCode
		 * 
		 */		
		protected function keyDownHandler(keyCode:uint):void
		{			
		}
		/**
		 * 释放按键处理，在子类中继续 
		 * @param keyCode
		 * 
		 */		
		protected function keyUpHandler(keyCode:uint):void
		{			
		}
		
		/**
		 * 场景开始后(转到前台)必须执行的方法
		 * 
		 */	
		public function onStart():void
		{
			if(_enableNativeDrag)
			{
				this.nativeDrag(true);
			}
			if(_enableKeyDown)
			{
				this.keyPress(1,true);
			}
			if(_enableKeyUp)
			{
				this.keyPress(2,true);
			}
			_onStartProceeded=true;
		}
		/**
		 * 场景结束后(转到后台)必须执行的方法
		 * 
		 */		
		public function onEnd():void
		{
			if(_enableNativeDrag)
			{
				this.nativeDrag(false);
			}
			if(_enableKeyDown)
			{
				this.keyPress(1,false);
			}
			if(_enableKeyUp)
			{
				this.keyPress(2,false);
			}
			_onStartProceeded=false;
		}

		public function get state():String
		{
			return _state;
		}

	}
}