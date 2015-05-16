package app.message
{
	/**
	 * IMessager接口的实现类 
	 * @author lonewolf
	 * 
	 */	
	public class Messager implements IMessager
	{
		public function Messager()
		{
		}
		/**
		 * 发送消息，调用消息中心的方法
		 * @param type
		 * 
		 */
		public function sendMessage(type:String):void
		{
			MessageCenter.sendMessage(this,type);
		}
		/**
		 * 延迟发送消息，调用消息中心的方法
		 * @param type
		 * 
		 */
		public function sendMessageDelay(type:String):void
		{
			MessageCenter.sendMessageDelay(this,type);
		}
		/**
		 * 接收消息，在子类实现
		 * @param sender 发送者
		 * @param type
		 * 
		 */		
		public function receiveMessage(sender:Object, type:String):void
		{
		}
	}
}