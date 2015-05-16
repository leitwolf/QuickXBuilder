package app.part
{
	import app.Config;
	import app.data.FileData;
	import app.message.MessageCenter;
	import app.message.Messager;
	
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	/**
	 * 项目文件列表 
	 * @author lonewolf
	 * 
	 */	
	public class ProjectViewPart extends Messager
	{
		private var _list:List;
		
		public function ProjectViewPart()
		{
			_list=FlexGlobals.topLevelApplication.projectView;			
			_list.addEventListener(IndexChangeEvent.CHANGE,listChangeHandler);
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
				// 新项目，刷新列表
				this.loadFiles();
				this.sendMessageDelay(MessageCenter.CURRENT_FILE);
			}
			else if(type==MessageCenter.NEW_FILE)
			{
				// 新建文件，加到列表中
				var arr:ArrayCollection=_list.dataProvider as ArrayCollection;
				arr.addItem(Config.curFileData);
				_list.selectedItem=Config.curFileData;
				this.sendMessageDelay(MessageCenter.CURRENT_FILE);
			}
		}		
		
		/**
		 * 显示相应文件结构
		 * @param event
		 * 
		 */
		protected function listChangeHandler(event:IndexChangeEvent):void
		{
			if(_list.selectedItem!=Config.curFileData)
			{
				//切换的时候先保存之前的
				if(Config.curFileData)
				{
					Config.curFileData.save();
					this.sendMessage(MessageCenter.FILE_SAVED);
				}
				Config.curFileData=_list.selectedItem as FileData;
				
				//先加载
				Config.curFileData.load();
				Config.resolution.width=Config.curFileData.width;
				Config.resolution.height=Config.curFileData.height;
				
				// 文件改变
				this.sendMessage(MessageCenter.CURRENT_FILE);
			}
		}
		/**
		 * 加载文件
		 * 
		 */
		private function loadFiles():void
		{
			//先保存之前的
			if(Config.curFileData)
			{
				Config.curFileData.save();
				this.sendMessage(MessageCenter.FILE_SAVED);
			}
			var arr:ArrayCollection=new ArrayCollection();
			var file:File=Config.projectData.sceneFilesDirFile;
			if(file.exists&&file.isDirectory)
			{
				var list:Array=file.getDirectoryListing();
				for each(var f:File in list)
				{
					if(f.extension==Config.FILE_EXT)
					{
						var fileData:FileData=new FileData(f.url);
						arr.addItem(fileData);
					}
				}
			}
			_list.dataProvider=arr;
			Config.fileDataList=arr.toArray();
			Config.curFileData=null;
		}

	}
}