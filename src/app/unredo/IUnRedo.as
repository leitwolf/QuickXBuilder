package app.unredo
{
	/**
	 * 撤销/重做操作接口 
	 * @author lonewolf
	 * 
	 */	
	public interface IUnRedo
	{
		/**
		 * 执行撤销操作 
		 * 
		 */
		function undo():void;
		/**
		 * 执行重做操作 
		 * 
		 */
		function redo():void;
	}
}