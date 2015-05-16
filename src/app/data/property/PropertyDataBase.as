package app.data.property
{
	/**
	 * 各个组件数据的基类 
	 * @author lonewolf
	 * 
	 */	
	public class PropertyDataBase
	{
		/* 是否可用，如Node组件用不到SpriteData
		 只有解码到的才用到
		 此属性将会决定对应的Property显不显示
		 以及编码动作要不要执行
		*/
		protected var _isUse:Boolean=false;
		
		public function PropertyDataBase()
		{
		}
		/**
		 * 加入到Object中，最后生成JSON字符串 
		 * @param obj
		 * 
		 */
		public function encodeObj(obj:Object):void
		{
		}
		/**
		 * 从Object获取自己需要的字符 
		 * @param obj
		 * 
		 */		
		public function decodeObj(obj:Object):void
		{
			//有解码的表示可用
			_isUse=true;
		}

		public function get isUse():Boolean
		{
			return _isUse;
		}

		public function set isUse(value:Boolean):void
		{
			_isUse = value;
		}

	}
}