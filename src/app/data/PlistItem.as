package app.data
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * plist项的属性表 
	 * @author lonewolf
	 * 
	 */	
	public class PlistItem
	{
		//名称
		public var name:String;
		
		// 原始尺寸
		public var width:Number;
		public var height:Number;
		
		//在图像中的偏移
		public var offset:Point=new Point();
		
		// 是否旋转
		public var rotate:Boolean;
		
		//在图像中的位置及尺寸，尺寸是原始尺寸裁去空白之后的尺寸
		public var insideRect:Rectangle=new Rectangle();
		
		public function PlistItem()
		{
		}
	}
}