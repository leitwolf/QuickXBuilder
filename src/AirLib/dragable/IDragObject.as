package AirLib.dragable
{
	/**
	 * 拖动的物体，里面有它必须包含的属性 
	 * @author lonewolf
	 * 
	 */	
	public interface IDragObject
	{
		/**
		 * 源，用于Image 
		 * @return 
		 * 
		 */
		function getSource():Object;
		/**
		 * 保存的用户数据 
		 * @return 
		 * 
		 */		
		function userData():*;
	}
}