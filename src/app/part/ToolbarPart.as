package app.part
{
	import AirLib.G;
	
	import app.Config;
	import app.data.ProjectData;
	import app.message.MessageCenter;
	import app.message.Messager;
	import app.win.CreateFileWin;
	import app.win.CreateProjectWin;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.LinkButton;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.DropDownList;
	import spark.components.ToggleButton;
	import spark.events.IndexChangeEvent;

	/**
	 * 上方的控件 
	 * @author lonewolf
	 * 
	 */	
	public class ToolbarPart extends Messager
	{
		// 新建文件
		private var _newFile:LinkButton;
		// 修改文件名
		private var _modifyFile:LinkButton;
		// 保存场景
		private var _saveScene:LinkButton;
		// 修改项目
		private var _modifyProject:LinkButton;
		// 发布
		private var _publish:LinkButton;
		// 最近文件列表
		private var _recentProjectList:DropDownList;
		// 分辨率列表
		private var _resolution:DropDownList;
		// 屏幕方向
		private var _dir:DropDownList;
		// 场景缩放程度
		private var _zoom:DropDownList;
		// 是否可拖动画面
		private var _dragScene:ToggleButton;
		
		public function ToolbarPart()
		{
			_newFile=FlexGlobals.topLevelApplication.newFile;
			_modifyFile=FlexGlobals.topLevelApplication.modifyFile;
			_saveScene=FlexGlobals.topLevelApplication.saveScene;
			_modifyProject=FlexGlobals.topLevelApplication.modifyProject;
			_recentProjectList=FlexGlobals.topLevelApplication.recentProjectList;
			_resolution=FlexGlobals.topLevelApplication.resolution;
			_dir=FlexGlobals.topLevelApplication.dir;
			_zoom=FlexGlobals.topLevelApplication.zoom;
			_dragScene=FlexGlobals.topLevelApplication.dragScene;
			_publish=FlexGlobals.topLevelApplication.publish;
			
			_newFile.enabled=false;
			_modifyProject.enabled=false;
			_saveScene.enabled=false;
			_dragScene.selected=false;
			_publish.selected=false;
			_dragScene.label="锁住场景";
			
			_recentProjectList.dataProvider=Config.getRecentProjectList();
			_resolution.dataProvider=Config.getResolutionList();
			_resolution.selectedIndex=0;
			
			var data:ArrayCollection=new ArrayCollection();
			data.addItem({label:"竖屏",data:1});
			data.addItem({label:"横屏",data:2});
			_dir.dataProvider=data;
			_dir.selectedIndex=0;
			
			data=new ArrayCollection();
			for each(var z:int in Config.zoomList)
			{
				data.addItem({label:z+"%",data:z});
			}
			_zoom.dataProvider=data;
			_zoom.selectedIndex=4;
			
			_recentProjectList.focusEnabled=false;
			_resolution.focusEnabled=false;
			_dir.focusEnabled=false;
			_zoom.focusEnabled=false;
			
			
			_newFile.addEventListener(MouseEvent.CLICK,newSceneHandler);
			_modifyFile.addEventListener(MouseEvent.CLICK,modifyFileHandler);
			FlexGlobals.topLevelApplication.saveScene.addEventListener(MouseEvent.CLICK,saveSceneHandler);
			FlexGlobals.topLevelApplication.newProject.addEventListener(MouseEvent.CLICK,createProjectHandler);
			FlexGlobals.topLevelApplication.modifyProject.addEventListener(MouseEvent.CLICK,modifyProjectHandler);
			FlexGlobals.topLevelApplication.customResolution.addEventListener(MouseEvent.CLICK,customResolutionHandler);
			FlexGlobals.topLevelApplication.publish.addEventListener(MouseEvent.CLICK,publishHandler);
			_recentProjectList.addEventListener(IndexChangeEvent.CHANGE,recentProjectListChangeHandler);
			_resolution.addEventListener(IndexChangeEvent.CHANGE,resolutionChangeHandler);
			_dir.addEventListener(IndexChangeEvent.CHANGE,resolutionChangeHandler);
			_zoom.addEventListener(IndexChangeEvent.CHANGE,zoomChangeHandler);
			_dragScene.addEventListener(Event.CHANGE,dragSceneChangeHandler);
			
			this.setResolution();
		}
		/**
		 * 接收消息 
		 * @param sender
		 * @param type
		 * 
		 */		
		override public function receiveMessage(sender:Object, type:String):void
		{
			if(type==MessageCenter.NEW_PROJECT)
			{
				// 打开新项目，重新加载最近文件
				_recentProjectList.dataProvider=Config.getRecentProjectList();
				_newFile.enabled=true;
				_modifyProject.enabled=true;
				_publish.enabled=true;
			}
			else if(type==MessageCenter.CUSTOM_RESOLUTION)
			{
				// 自定义分辨率
				_resolution.dataProvider=Config.getResolutionList();
				this.checkResolution();
				_resolution.invalidateDisplayList();
			}
			else if(type==MessageCenter.LOCK_SCENE_STATE_CHANGED)
			{
				// 场景拖动状态改变
				this.lockSceneStateChanged();
			}
			else if(type==MessageCenter.SCENE_ZOOM)
			{
				// 场景缩放
				this.zoomChanged();
			}
			else if(type==MessageCenter.FILE_DIRTY)
			{
				// 当前文件内容改变，需要保存
				_saveScene.enabled=true;
			}
			else if(type==MessageCenter.FILE_SAVED)
			{
				// 当前文件内容已保存
				_saveScene.enabled=false;
			}
			else if(type==MessageCenter.CURRENT_FILE)
			{
				// 当前文件，分辨率改变
				this.checkResolution();
			}
		}
		/**
		 * 检测与当前分辨率相符 
		 * 
		 */		
		private function checkResolution():void
		{
			var w:Number=0;
			var h:Number=0;
			if(Config.curFileData)
			{
				w=Config.curFileData.width;
				h=Config.curFileData.height;
			}
			else if(Config.projectData)
			{
				w=Config.projectData.width;
				h=Config.projectData.height;
			}
			Config.resolution.width=w;
			Config.resolution.height=h;
			if(w>h)
			{
				// 横屏
				var a:Number=w;
				w=h;
				h=a;
				_dir.selectedIndex=1;
			}
			else
			{
				_dir.selectedIndex=0;
			}
			// 查找对应的项
			for each(var obj:Object in _resolution.dataProvider)
			{
				if(obj.width==w&&obj.height==h)
				{
					_resolution.selectedItem=obj;
					break;
				}
			}
		}
		/**
		 * 获取当前设置的分辨率 
		 * @return {w,h}
		 * 
		 */
		private function setResolution():void
		{
			var obj:Object=_resolution.selectedItem;
			var w:Number=obj.width;
			var h:Number=obj.height;
			// 横屏
			if(_dir.selectedIndex==1)
			{
				w=obj.height;
				h=obj.width;
			}
			Config.resolution.width=w;
			Config.resolution.height=h;
		}
		/**
		 * 场景拖放状态改变 
		 * 
		 */		
		private function lockSceneStateChanged():void
		{
			var enable:Boolean=Config.enableDragScene;
			if(enable)
			{
				_dragScene.label="可拖动场景";
			}
			else
			{
				_dragScene.label="不可拖动";
			}
			_dragScene.selected=enable;
		}
		/**
		 * 场景缩放改变 
		 * 
		 */		
		private function zoomChanged():void
		{
			var arr:ArrayCollection=_zoom.dataProvider as ArrayCollection;
			for each(var obj:Object in arr)
			{
				if(obj.data==Config.sceneZoom)
				{
					_zoom.selectedItem=obj;
					break;
				}
			}
		}
		/**
		 * 场景缩放 
		 * @param event
		 * 
		 */		
		protected function zoomChangeHandler(event:IndexChangeEvent):void
		{
			var obj:Object=_zoom.selectedItem;
			Config.sceneZoom=obj.data;
			this.sendMessage(MessageCenter.SCENE_ZOOM);
		}
		/**
		 * 改变了分辨率 
		 * @param event
		 * 
		 */		
		protected function resolutionChangeHandler(event:IndexChangeEvent):void
		{
			this.setResolution();
			if(Config.curFileData!=null)
			{
				Config.curFileData.width=Config.resolution.width;
				Config.curFileData.height=Config.resolution.height;
				_saveScene.enabled=true;
			}
			this.sendMessage(MessageCenter.RESOLUTION);	
		}
		/**
		 * 打开最近项目文件 
		 * @param event
		 * 
		 */		
		protected function recentProjectListChangeHandler(event:IndexChangeEvent):void
		{
			var obj:Object=_recentProjectList.selectedItem;
			if(obj==null)
			{
				return;
			}
			if(obj.data==null)
			{
				//删除最近列表
				Config.configData.deleteRecentProject();
				_recentProjectList.dataProvider=null;
			}
			else
			{
				//打开项目
				var project:ProjectData=new ProjectData();
				project.load(obj.data);
				if(project.isValid)
				{
					Config.projectData=project;
					_newFile.enabled=true;
					_modifyProject.enabled=true;
					this.sendMessage(MessageCenter.NEW_PROJECT);
				}
			}
		}
		/**
		 * 新建场景，打开新建对话框
		 * @param event
		 * 
		 */
		protected function newSceneHandler(event:MouseEvent):void
		{
			G.curScene.onEnd();
			CreateFileWin.type=1;
			PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,CreateFile,true);
		}
		/**
		 * 修改文件名
		 * @param event
		 * 
		 */
		protected function modifyFileHandler(event:MouseEvent):void
		{
			if(!Config.curFileData)
			{
				return;
			}
			G.curScene.onEnd();
			CreateFileWin.type=2;
			PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,CreateFile,true);
		}
		/**
		 * 保存场景 
		 * @param event
		 * 
		 */
		protected function saveSceneHandler(event:MouseEvent):void
		{
			if(Config.curFileData)
			{
				Config.curFileData.save();
			}
			_saveScene.enabled=false;
		}
		/**
		 * 是否可拖动场景 
		 * @param event
		 * 
		 */		
		protected function dragSceneChangeHandler(event:Event):void
		{
			Config.enableDragScene=_dragScene.selected;
			this.lockSceneStateChanged();
			this.sendMessage(MessageCenter.LOCK_SCENE_STATE_CHANGED);
		}
		/**
		 * 导入项目 
		 * @param event
		 * 
		 */		
		protected function createProjectHandler(event:MouseEvent):void
		{
//			G.curScene.onEnd();
//			PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,CreateProject,true);
		}
		/**
		 * 修改项目 
		 * @param event
		 * 
		 */		
		protected function modifyProjectHandler(event:MouseEvent):void
		{
			CreateProjectWin.isNewProject=false;
			G.curScene.onEnd();
			PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,CreateProject,true);
		}
		/**
		 * 自定义分辨率管理 
		 * @param event
		 * 
		 */		
		protected function customResolutionHandler(event:MouseEvent):void
		{
			G.curScene.onEnd();
			PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,CustomResolution,true);
		}
		/**
		 * 发布项目，生成代码 
		 * @param event
		 * 
		 */
		protected function publishHandler(event:MouseEvent):void
		{
			Config.generateLua();
			Alert.show("发布完成");
		}
	
	}
}