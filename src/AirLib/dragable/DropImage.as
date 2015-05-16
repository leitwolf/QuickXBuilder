package AirLib.dragable
{
	import spark.components.Image;
	/**
	 * 拖动后，要生成的图片 
	 * @author lonewolf
	 * 
	 */	
	public class DropImage extends Image implements IDropObject
	{	
		private var _userData:*;
		
		public function DropImage()
		{
			super();
		}
		
		public function setUserData(value:*):void
		{
			_userData=value;
		}
		
		public function userData():*
		{
			return _userData;
		}
		
	}
}