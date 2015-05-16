package app.data
{
	/**
	 * 列表或树控件的结点基类，携带数据 
	 * @author lonewolf
	 * 
	 */	
	public class NodeDataBase
	{
		// 显示标签
		public var label:String="";
		// 子结点列表
		private var _children:Array=null;
		// 父节点
		public var parent:NodeDataBase=null;
		
		public function NodeDataBase()
		{
		}
		/**
		 * 添加子结点 
		 * @param child
		 * 
		 */		
		public function addChild(child:NodeDataBase):void
		{
			if(_children==null)
			{
				_children=[];
			}
			child.parent=this;
			_children.push(child);
		}

		public function get children():Array
		{
			return _children;
		}

	}
}