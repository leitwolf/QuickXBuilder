package app.unredo
{
	/**
	 * 撤销/重做模块管理，每个针对一个文件
	 * 提供添加操作、撤销以及重做操作功能
	 * 操作分很多类型
	 * @author lonewolf
	 * 
	 */	
	public class UnRedoManager
	{
		// 保存数量，默认20个
		private var _num:uint=20;
		// 操作列表 
		private var _opList:Array=[];
		// 当前操作所在位置
		private var _index:int=-1;
		
		public function UnRedoManager()
		{
		}
		/**
		 * 要保存操作的数量，多于该操作则把头部去掉
		 * 默认20
		 * @param num
		 * 
		 */
		public function setNum(num:uint=20):void
		{
			_num=num;
		}
		/**
		 * 添加操作 
		 * @param item
		 * 
		 */		
		public function addItem(item:IUnRedo):void
		{
			// 如果位置不在尾部，则先删去重做的部分
			var len:int=_opList.length;
			if(len>0&&_index!=len-1)
			{
				_opList.splice(_index);
			}
			_opList.push(item);
			// 检测是否超过长度了
			if(_opList.length>_num)
			{
				_opList.shift();
			}
			// 当前位置在最后
			_index=_opList.length-1;
		}
		/**
		 * 执行撤销操作 
		 * @return 返回要撤销的操作
		 * 
		 */
		public function undo():IUnRedo
		{
			if(_opList.length>0&&_index>=0)
			{
				var op:IUnRedo=_opList[_index] as IUnRedo;
				op.undo();
				_index--;
				return op;
			}
			return null;
		}
		/**
		 * 执行重做操作 
		 * @return 返回要重做的操作
		 * 
		 */
		public function redo():IUnRedo
		{
			if(_opList.length>0&&_index<(_opList.length-1))
			{
				var op:IUnRedo=_opList[_index] as IUnRedo;
				op.redo();
				_index++;
				return op;
			}
			return null;
		}
		/**
		 * 是否可以撤销 
		 * @return 
		 * 
		 */		
		public function get undoEnable():Boolean
		{
			return _opList.length>0&&_index>=0;
		}
		/**
		 * 是否可以重做
		 * @return 
		 * 
		 */		
		public function get redoEnable():Boolean
		{
			return _opList.length>0&&_index<(_opList.length-1);
		}
	}
}