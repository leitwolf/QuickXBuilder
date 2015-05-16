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
			this.enableKeyPress(false,true);
			
			this.init();
		}
		//
		override protected function keyUpHandler(keyCode:uint):void
		{
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