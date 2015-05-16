package AirLib.dragable
{
	/**
	 * 要放置的物体 
	 * @author lonewolf
	 * 
	 */	
	public interface IDropObject
	{
		/**
		 * 设置用户数据 
		 * @param value
		 * 
		 */		
		function setUserData(value:*):void;
		/**
		 * 所包含的用户数据 
		 * @return 
		 * 
		 */		
		function userData():*;
	}
}