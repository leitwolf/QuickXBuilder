package app.data.property
{
	/**
	 * 对应Property Layer的数据 
	 * @author lonewolf
	 * 
	 */	
	public class LayerPropertyData extends PropertyDataBase
	{
		public var color:uint=0;
		public var alpha:Number=1;
		
		public function LayerPropertyData()
		{
		}
		
		override public function decodeObj(obj:Object):void
		{
			super.decodeObj(obj);
			color=obj.color;
			alpha=obj.alpha;
		}
		
		override public function encodeObj(obj:Object):void
		{
			if(!_isUse)
			{
				return;
			}
			obj.color=color;
			obj.alpha=alpha;
		}
	}
}