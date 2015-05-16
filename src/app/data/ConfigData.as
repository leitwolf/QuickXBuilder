package app.data
{
	import AirLib.Helper;
	
	import app.Config;
	
	import flash.filesystem.File;

	/**
	 * 系统配置数据 
	 * @author lonewolf
	 * 
	 */	
	public class ConfigData
	{
		// 最近文件列表
		private var _recentProjectList:Array=[];
		// 自定义分辨率列表 [{width,height}]
		private var _customResolutionList:Array=[];
		
		public function ConfigData()
		{
//			this.load();
		}
		/**
		 * 加载 
		 * 
		 */
		public function load():void
		{
			var file:File=File.applicationStorageDirectory.resolvePath(Config.SYSTEM_CONFIG_FILENAME);
			if(file.exists)
			{
				// {recentProject:[], customResolution:[]}
				var data:String=Helper.readData(file.url);
				var obj:Object=JSON.parse(data);
				
				// 最近文件列表
				// [url,url,...]
				for each(var p:String in obj.recentProject)
				{
					_recentProjectList.push(p);
				}
				
				// 自定义分辨率列表
				// [{width,height},{width,height},...]
				for each(var r:Object in obj.customResolution)
				{
					_customResolutionList.push(r);
				}
			}			
		}
		/**
		 * 保存配置 
		 * 
		 */		
		public function save():void
		{
			var file:File=File.applicationStorageDirectory.resolvePath(Config.SYSTEM_CONFIG_FILENAME);
			var data:Object={recentProject:_recentProjectList, customResolution:_customResolutionList};
			var str:String=JSON.stringify(data);
			Helper.saveData(str,file.url);
		}
		/**
		 * 添加最近项目 
		 * @param url
		 * 
		 */		
		public function addRecentProject(url:String):void
		{
			for each(var item:String in _recentProjectList)
			{
				if(item==url)
				{
					// 已经有相同的了
					return;
				}
			}
			// 添加到第一项
			_recentProjectList.unshift(url);
			this.save();
		}
		/**
		 * 消除最近列表 
		 * 
		 */		
		public function deleteRecentProject():void
		{
			_recentProjectList=[];
			this.save();
		}
		/**
		 * 添加自定义分辨率 
		 * @param width
		 * @param height
		 * 
		 */
		public function setCustomResolution(arr:Array):void
		{
			_customResolutionList=arr;
			this.save();
		}

		public function get recentProjectList():Array
		{
			return _recentProjectList;
		}

		public function get customResolutionList():Array
		{
			return _customResolutionList;
		}

	}
}