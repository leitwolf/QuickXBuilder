package app.data.property
{
	import app.Config;

	/**
	 * 对应Property Node的数据 
	 * @author lonewolf
	 * 
	 */	
	public class NodePropertyData extends PropertyDataBase
	{
		//位置坐标
		public var x:int=0;
		public var y:int=0;
		//位置对齐
		public var xAlign:String=Config.LOCATION_LEFT;
		public var yAlign:String=Config.LOCATION_BOTTOM;
		//锚点
		public var anchorX:Number=0.5;
		public var anchorY:Number=0.5;
		public var tag:int=-1;
		//是否可见
		public var visible:Boolean=true;
		
		public function NodePropertyData()
		{
		}
		
		override public function decodeObj(obj:Object):void
		{
			super.decodeObj(obj);
			x=obj.x;
			y=obj.y;
			xAlign=obj.xAlign;
			yAlign=obj.yAlign;
			anchorX=obj.anchorX;
			anchorY=obj.anchorY;
			tag=obj.tag;
			visible=obj.visible;
		}
		
		override public function encodeObj(obj:Object):void
		{
			if(!_isUse)
			{
				return;
			}
			obj.x=x;
			obj.y=y;
			obj.xAlign=xAlign;
			obj.yAlign=yAlign;
			obj.anchorX=anchorX;
			obj.anchorY=anchorY;
			obj.tag=tag;
			obj.visible=visible;
		}	
	}
}