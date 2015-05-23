package app.data
{
	import app.Config;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;

	/**
	 * 资源管理，这里负责加载图片，声音资源
	 * 并可根据条件查找相对应的BitmapData
	 * @author lonewolf
	 * 
	 */	
	public class ResourceManager
	{
		// demo所在文件夹名称
		public static const demoDir:String="_demo";
		// 总的node
		private var _data:ResourceNodeData=null;
		
		public function ResourceManager()
		{
		}
		
		/**
		 * 从res文件夹开始加载
		 * 
		 */
		public function load():void
		{
			_data=new ResourceNodeData();
			_data.label="root";
			// 先加载demo
			var file:File=Config.projectData.sceneFilesDirFile;
			if(file!=null&&file.exists&&file.isDirectory)
			{
				file=file.resolvePath(demoDir);
				if(file.exists&&file.isDirectory)
				{
					var demo:ResourceNodeData=ResourceNodeData.load(file);
					if(demo.isValid)
					{
						_data.addChild(demo);
					}
				}
			}
			// 再加载资源文件夹
			file=Config.projectData.resourceDirFile;
			if(file!=null&&file.exists&&file.isDirectory)
			{
				var node:ResourceNodeData=ResourceNodeData.load(file);
				_data.addChild(node);
			}
		}
		/**
		 * 查找对应的图像数据 
		 * @param path
		 * @param plist
		 * @return 
		 * 
		 */		
		public function findImage(path:String,plist:String):DisplayObject
		{
			return this.findImageFromData(_data,path,plist);
		}
		/**
		 * 从ResourceNodeData查找相应的图像数据
		 * @param data
		 * @param path
		 * @param plist
		 * @return 
		 * 
		 */		
		private function findImageFromData(data:ResourceNodeData,path:String,plist:String):DisplayObject
		{
			if(data==null)
			{
				return null;
			}
			else if(data.path==path&&data.plist==plist)
			{
				return data.image;
			}
			else if(data.children)
			{
				for each(var d:ResourceNodeData in data.children)
				{
					var image:DisplayObject=this.findImageFromData(d,path,plist);
					if(image!=null)
					{
						return image;
					}
				}
			}
			return null;
		}

		public function get data():ResourceNodeData
		{
			return _data;
		}

	}
}