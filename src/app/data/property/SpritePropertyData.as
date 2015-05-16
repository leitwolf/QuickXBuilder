package app.data.property
{
	/**
	 * 对应Property Sprite的数据 
	 * @author lonewolf
	 * 
	 */	
	public class SpritePropertyData extends PropertyDataBase
	{
		//图片
		public var image:String="";
		
		//可能是plist里的图片
		public var imagePlist:String="";
		
		public function SpritePropertyData()
		{
		}
		
		override public function decodeObj(obj:Object):void
		{
			super.decodeObj(obj);
			image=obj.image;
			
			imagePlist=obj.imagePlist;
		}
		
		override public function encodeObj(obj:Object):void
		{
			if(!_isUse)
			{
				return;
			}
			obj.image=image;
			
			obj.imagePlist=imagePlist;
		}
	}
}