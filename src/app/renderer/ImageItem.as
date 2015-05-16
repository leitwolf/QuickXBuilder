package app.renderer
{	
	import AirLib.dragable.IDragObject;

	[Bindable]public class ImageItem implements IDragObject
	{
		public var name:String;
		public var image:Object;
		public var url:String;
		
		public function ImageItem()
		{
		}
		
		public function getSource():Object
		{
			return image;
		}
		
		public function userData():*
		{
			return name;
		}
		
	}
}