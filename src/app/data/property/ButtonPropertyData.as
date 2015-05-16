package app.data.property
{
	/**
	 * 对应Property Button的数据 
	 * @author lonewolf
	 * 
	 */	
	public class ButtonPropertyData extends PropertyDataBase
	{
		//三种状态的图片
		public var normal:String="";
		public var pressed:String="";
		public var disabled:String="";
		
		//可能是plist里的图片
		public var normalPlist:String="";
		public var pressedPlist:String="";
		public var disabledPlist:String="";
		
		public function ButtonPropertyData()
		{
		}
		
		override public function decodeObj(obj:Object):void
		{
			super.decodeObj(obj);
			
			normal=obj.normal;
			pressed=obj.pressed;
			disabled=obj.disabled;
			
			normalPlist=obj.normalPlist;
			pressedPlist=obj.pressedPlist;
			disabledPlist=obj.disabledPlist;
		}
		
		override public function encodeObj(obj:Object):void
		{
			if(!_isUse)
			{
				return;
			}
			obj.normal=normal;
			obj.pressed=pressed;
			obj.disabled=disabled;
			
			obj.normalPlist=normalPlist;
			obj.pressedPlist=pressedPlist;
			obj.disabledPlist=disabledPlist;
		}	
	}
}