package app
{
	import AirLib.G;
	import AirLib.SceneBase;
	
	import app.data.ProjectData;
	import app.message.MessageCenter;
	import app.part.ControlPart;
	import app.part.ControlViewPart;
	import app.part.ProjectViewPart;
	import app.part.PropertyPart;
	import app.part.ResourcePart;
	import app.part.ToolbarPart;
	import app.part.WorkAreaPart;
	import app.win.CreateProjectWin;
	
	import flash.display.DisplayObject;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;

	public class MainScene extends SceneBase
	{
		private var _selectObj:Object;
		
		public function MainScene()
		{
			super("main");
			
			//允许本地拖动
			this.enableNativeDrag(true,1);
			//按键监听
			this.enableKeyPress(true,true);
			// 鼠标滚轮
			this.enableMouseWheel(true);
			
			this.init();
		}
		/**
		 * 监听按键 
		 * @param keyCode
		 * 
		 */		
		override protected function keyDownHandler(keyCode:uint):void
		{
			if(keyCode==Keyboard.DELETE)
			{
				// 删除
				if(!Config.projectViewPart.tryDeleteFile())
				{
					Config.controlViewPart.deleteControl();
				}
			}
			else if(keyCode==Keyboard.LEFT||keyCode==Keyboard.RIGHT||keyCode==Keyboard.UP||keyCode==Keyboard.DOWN)
			{
				// 移动当前控件
				var x:Number=0;
				var y:Number=0;
				if(keyCode==Keyboard.LEFT)
				{
					x=-1;
				}
				else if(keyCode==Keyboard.RIGHT)
				{
					x=1;
				}
				else if(keyCode==Keyboard.UP)
				{
					y=1;
				}
				else if(keyCode==Keyboard.DOWN)
				{
					y=-1;
				}
				if(Config.curControl)
				{
					Config.curControl.nodeData.move(x,y);
					MessageCenter.sendMessage(null,MessageCenter.CONTROL_POSITION);
				}
			}
			else if(keyCode==Keyboard.ALTERNATE)
			{
				// 可拖动地图
				Config.enableDragScene=true;
				MessageCenter.sendMessage(null,MessageCenter.LOCK_SCENE_STATE_CHANGED);
			}
		}
		/**
		 * 松开按键 
		 * @param keyCode
		 * 
		 */		
		override protected function keyUpHandler(keyCode:uint):void
		{
			if(keyCode==Keyboard.ALTERNATE)
			{
				// 不可拖动地图
				Config.enableDragScene=false;
				MessageCenter.sendMessage(null,MessageCenter.LOCK_SCENE_STATE_CHANGED);
			}
		}	
		
		/**
		 * 拖入一个项目文件夹 
		 * @param fileList
		 * 
		 */		
		override protected function nativeHandler(fileList:Array):void
		{
			var file:File=fileList[0] as File;
			var valid:Boolean=true;
			if(!file.isDirectory)
			{
				Alert.show("请导入一个文件夹");
			}
			else
			{
				var project:ProjectData=new ProjectData();
				project.load(file.url);
				if(project.isValid)
				{
					Config.projectData=project;
					MessageCenter.sendMessage(null,MessageCenter.NEW_PROJECT);
				}
				else
				{
					// 还没有建数据信息
					G.curScene.onEnd();
					CreateProjectWin.isNewProject=true;
					CreateProjectWin.projectUrl=file.url;
					PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,CreateProject,true);
				}
			}
		}
		/**
		 * 处理鼠标滚轮事件 
		 * @param delta
		 * 
		 */		
		override protected function mouseWheelHandler(delta:int):void
		{
			// 当前缩放值所在序号
			var index:int;
			var list:Array=Config.zoomList;
			var i:int=0;
			for(i=0;i<list.length;i++)
			{
				if(list[i]==Config.sceneZoom)
				{
					index=i;
					break;
				}
			}
			var prev:int=index;
			if(delta<0&&index>0)
			{
				index--;
			}
			else if(delta>0&&index<list.length-1)
			{
				index++;
			}
			if(index!=prev)
			{
				Config.sceneZoom=list[index];
				MessageCenter.sendMessage(null,MessageCenter.SCENE_ZOOM);
			}
		}		
		/**
		 * 按键保存 
		 * 
		 */		
		override protected function keyPressSave():void
		{
			if(Config.curFileData)
			{
				Config.curFileData.save();
				MessageCenter.sendMessage(null,MessageCenter.FILE_SAVED);
			}
		}		
		
		/**
		 * 初始化 
		 * 
		 */
		private function init():void
		{
			Config.init();
			MessageCenter.init();
			
			Config.mainScene=this;
			Config.resourcePart=new ResourcePart();
			Config.projectViewPart=new ProjectViewPart();
			Config.controlViewPart=new ControlViewPart();
			Config.toolbarPart=new ToolbarPart();
			Config.workAreaPart=new WorkAreaPart();
			Config.propertyPart=new PropertyPart();
			Config.controlPart=new ControlPart();			
			
			MessageCenter.registerMessager(Config.resourcePart);
			MessageCenter.registerMessager(Config.projectViewPart);
			MessageCenter.registerMessager(Config.controlViewPart);
			MessageCenter.registerMessager(Config.toolbarPart);
			MessageCenter.registerMessager(Config.workAreaPart);
			MessageCenter.registerMessager(Config.propertyPart);
		}
	}
}