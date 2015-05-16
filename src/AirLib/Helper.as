package AirLib
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert;

	public class Helper
	{
		public function Helper()
		{
		}
		//==========读取数据==========
		public static function readData(url:String):String
		{
			var file:File=new File(url);
			var stream:FileStream=new FileStream();
			stream.open(file,FileMode.READ);
			var data:String=stream.readUTFBytes(stream.bytesAvailable);
			return data;
		}
		//==========保存数据==========
		private static var _data:String;
		private static var _afterSaveFunc:Function;
		/**
		 * 保存数据 
		 * @param data 数据
		 * @param url 保存到的路径 为空则弹出保存对话框
		 * @param callback 保存后执行，会返回保存到的路径
		 * 
		 */		
		public static function saveData(data:String,url:String="",callback:Function=null):void
		{
			if(url!="")
			{
				var file:File = new File(url);
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(data);
				stream.close();
				if(callback!=null)
				{
					callback.call(null,url);
				}				
			}
			else
			{
				_data=data;
				_afterSaveFunc=callback;
				var title:String = "保存到";
				var doc:File = File.documentsDirectory;
				try
				{
					doc.browseForSave(title);
					doc.addEventListener(Event.SELECT, saveSeletedHandler);
				}
				catch (error:Error)
				{
					Alert.show(error.message,"保存失败");
				}
			}
		}
		//已选择保存到的路径
		protected static function saveSeletedHandler(event:Event):void
		{
			var file:File = event.target as File;
			saveData(_data,file.url,_afterSaveFunc);
			_data=null;
			_afterSaveFunc=null;
		}
	}
}