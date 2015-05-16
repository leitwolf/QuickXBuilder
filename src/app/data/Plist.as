package app.data
{
	import AirLib.Helper;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * 解析plist文件生成组件属性列表 
	 * @author lonewolf
	 * 
	 */	
	public class Plist
	{		
		public function Plist()
		{
		}
		/**
		 * 解析plist文件 
		 * @param url
		 * @return 
		 * 
		 */
		public static function analysePlist(url:String):Array
		{
			var itemList:Array=[];
			var str:String=Helper.readData(url);
			var plist:XML=new XML(str);
			var frames:XML=plist.dict[0].dict[0];
			var len:int=frames.child("key").length();
			var i:int=0;
			for(i=0;i<len;i++)
			{
				var item:PlistItem=new PlistItem();
				item.name=frames.key[i];
				
				//属性
				var prop:XML=frames.dict[i];
				// 把{} 都去除的模式
				var p:RegExp=/{|}| /g;
				
				// {{x,y},{width,height}}
				var frame:String=prop.string[0];
				frame=frame.replace(p,"");
				var arr:Array=frame.split(",");
				item.insideRect.x=Number(arr[0]);
				item.insideRect.y=Number(arr[1]);
				item.insideRect.width=Number(arr[2]);
				item.insideRect.height=Number(arr[3]);
				
				// offset{x,y}
				var offset:String=prop.string[2];
				offset=offset.replace(p,"");
				arr=offset.split(",");
				item.offset.x=Number(arr[0]);
				item.offset.y=Number(arr[1]);
				
				// rotate
				if(prop.hasOwnProperty("true"))
				{
					item.rotate=true;
				}
				
				//size {width,height}
				var size:String=prop.string[3];
				size=size.replace(p,"");
				arr=size.split(",");
				item.width=Number(arr[0]);
				item.height=Number(arr[1]);
				
				itemList.push(item);
			}
			return itemList;
		}
		/**
		 * 从大图中提取图片出来 
		 * @param image
		 * @param item
		 * @return 
		 * 
		 */
		public static function extraImage(image:DisplayObject,item:PlistItem):DisplayObject
		{
			var data:BitmapData=new BitmapData(item.width,item.height,true,0);
			
			// 要裁剪的框
			var rect:Rectangle=item.insideRect.clone();
			rect.x=item.offset.x;
			rect.y=item.offset.y;
			
			// 转换图像
			var m:Matrix=new Matrix();
			m.translate(-item.insideRect.x,-item.insideRect.y);
			if(item.rotate)
			{
				m.rotate(-90/180*Math.PI);
				m.translate(0,item.insideRect.height);
			}
			m.translate(item.offset.x,item.offset.y);
			
			data.draw(image,m,null,null,rect,true);
			return new Bitmap(data);
		}
	}
}