package app.data.property
{
	/**
	 * 对应Property Sprite的数据 
	 * @author lonewolf
	 * 
	 */	
	public class BasicPropertyData extends PropertyDataBase
	{
		public var name:String="";
		public var type:String="";
		
		public function BasicPropertyData()
		{
		}
		
		override public function decodeObj(obj:Object):void
		{
			super.decodeObj(obj);
			name=obj.name;
			type=obj.type;
		}
		
		override public function encodeObj(obj:Object):void
		{
			if(!_isUse)
			{
				return;
			}
			obj.name=name;
		}	
		
	}
}