package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.effects.*;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.shadematerials.GouraudMaterial;
	import org.papervision3d.materials.shadematerials.PhongMaterial;
	import org.papervision3d.materials.shaders.PhongShader;
	import org.papervision3d.materials.shaders.ShadedMaterial;
	import org.papervision3d.materials.special.CompositeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.view.layer.ViewportLayer;
	
	[SWF(frameRate="30", backgroundColor="#000000")]
	
	public class PaintGlossTest extends BasicView
	{
		public var primitive : DisplayObject3D;
		private var light:PointLight3D;
		private var light2:PointLight3D;
		private var light3:PointLight3D;
		private var light4:PointLight3D;
		
		private var plane1:Plane;
		private var plane2:Plane;
		private var plane3:Plane;
		private var planeColor:Plane;
		private var planeContainer:DisplayObject3D;
		private var plane4:Plane;
		
		private var vpl:ViewportLayer;
		
		private var lastMouseX:Number;
		private var color:Number;
		private var colorX:int;
		private var colorY:int;
		
		private var ps4:PhongShader;
		
		//private var oscbright:Number=0;
		//private var oscX:Number=0;
		
		[Embed(source="../assets/PaintTexture.png")] private var BumpImage:Class
		private var bumpImage:Bitmap;
		
		//[Embed(source="../assets/bumpMapTest.jpg")] private var BumpImage:Class
		//private var bumpImage:Bitmap;
		
		[Embed(source="../assets/bar.png")] private var WheelImage:Class
		private var wheel:Bitmap;
		
		public function PaintGlossTest()
		{
			super(800,600);
			lastMouseX = 0;
			bumpImage = new BumpImage();
			wheel = new WheelImage();
			
			camera.fov = 55;
			camera.z = -240;
			
			//** Light.brightness is an added parameter (In papervision3D library) in DisplayObject3D that is then
			// called inside of the EnvMapShader and EnvMapMaterial.  It is added to the dot product
			// near the beginning of the class. ( I identified where with comments inside. )
			// Light.brightness goes between 0 and 2, and then after two it goes back down.
			// it essentially opens up the lights shine diameter.
			
			// Create your point light source
			light = new PointLight3D(true);
			
			light2 = new PointLight3D(true);
			
			light3 = new PointLight3D(true);
			
			light4 = new PointLight3D(true);
			
			createColor();
			
			// Create the 3D objects
			createScene();
			
		}
		
		public function createColor():void
		{
			var wheelBitmapMaterial:BitmapMaterial = new BitmapMaterial(wheel.bitmapData, false);
			wheelBitmapMaterial.doubleSided = true;
			
			planeColor = new Plane(wheelBitmapMaterial, 200,20);
			
			color = 4293725956;
			
			vpl = viewport.getChildLayer(planeColor);
			vpl.addEventListener(MouseEvent.CLICK, mouseClick);
			vpl.buttonMode = true;
			
			planeColor.y = 110;
			planeColor.rotationX = 180;
			
			scene.addChild(planeColor);
		}
		
		public function createScene():void
		{
			var bitmapMaterial:BitmapMaterial = new BitmapMaterial(bumpImage.bitmapData, false);
			bitmapMaterial.smooth = true;
			
			// Can use phongShader for a few light ajustments in color settings.
			ps4 = new PhongShader(light4, color, 0, 1, bumpImage.bitmapData);
			
			// Phong material for the background plane.  this is what gives it more or less shine.
			// Use first color for the Light color.  2nd for the amient color, 3rd for the specular level.
			// You can't necessarily just turn down the shine, it has to be adjusted with the colors themselves.
			// Default values are not particularly optimized.
			var pm1:PhongMaterial = new PhongMaterial(light, 0xFFFFFF, 0x303030, 70);
			var pm2:PhongMaterial = new PhongMaterial(light2, 0xDADAdA, 0x404040, 50);
			//var pm3:PhongMaterial = new PhongMaterial(light3, 0x101010, 0x303030, 50);
			var fm:FlatShadeMaterial =  new FlatShadeMaterial(light3, 0x707070, 0x303030, 30);
			
			var material1:MaterialObject3D = new ShadedMaterial(bitmapMaterial, ps4);
			//var material2:MaterialObject3D = new ShadedMaterial(bitmapMaterial, ps2);
			//var material3:MaterialObject3D = new ShadedMaterial(bitmapMaterial, ps3);
			
			// There is an overlayer plane (plane4) which has the texture built on it.
			// The three underlying planes give the shine, and have transparencies. 
			plane1 = new Plane(pm1, 150, 100);
			plane2 = new Plane(pm2, 150, 100);
			plane3 = new Plane(fm, 150, 100);
			plane4 = new Plane(material1,150,300,4,4);
			
			planeContainer = new DisplayObject3D;
			
			planeContainer.addChild(plane4);
			planeContainer.addChild(plane1);
			planeContainer.addChild(plane2);
			planeContainer.addChild(plane3);
				
			//Plane 1 is the left most, 2 middle, 3 is right.
			plane1.useOwnContainer = true;
			plane2.useOwnContainer = true;
			plane3.useOwnContainer = true;
			//plane4.useOwnContainer = true;
			
			plane1.alpha = .35
			plane2.alpha = .25
			plane3.alpha = .25
			//plane4.alpha = .6;
			
			plane1.y = 100;
			plane3.y = -100;
			
			plane4.z = 1;
	
			planeContainer.rotationZ = 90;
			
			scene.addChild(planeContainer);

			// Initialise Event loop
			addEventListener(Event.ENTER_FRAME, loop);  

		}
		
		private function loop(e:Event):void
		{
			var ROTATION_MAX:Number = 40;
			
			ROTATION_MAX
			
			var halfWidth:int = (stage.stageWidth / 2);
			var currentPos:int = Math.abs(halfWidth - mouseX);
			var multiplier:int = ((halfWidth > mouseX) ? 1 : -1)
			var rotationAmt:int = (currentPos / halfWidth) * ROTATION_MAX * multiplier;
			
			var halfHeight:int = (stage.stageHeight / 2);
			var currentYPos:int = Math.abs(halfHeight - mouseY);
			var yMultiplier:int = ((halfHeight > mouseY) ? 0.01 : -0.01)
			var zRotationAmt:int = (currentPos / halfHeight) * ROTATION_MAX * yMultiplier;
			
			planeContainer.rotationX = rotationAmt;

			singleRender();
			//startRendering();
		}
		
		private function mouseClick(e:MouseEvent):void
		{
			colorX = (e.localX + 315)/1.3;
			colorY = (e.localY + 380)/3.1;
			
			color = wheel.bitmapData.getPixel32(colorX,colorY);
			
			planeContainer.removeChild(plane1);
			planeContainer.removeChild(plane2);
			planeContainer.removeChild(plane3);
			planeContainer.removeChild(plane4);
			scene.removeChild(planeContainer);
			
			removeEventListener(Event.ENTER_FRAME, loop);  
			
			createScene();		
		}
		/*
		
		// This Function can be implemented if you want to oscillate the light back and forth, or it's brightness.
		
		override protected function onRenderTick(event:Event=null):void
		{
		//oscbright++;
		//light.brightness=Math.abs(Math.sin(oscbright/20));
		//light2.brightness=Math.abs(Math.sin(oscbright/20));
		//light3.brightness=Math.abs(Math.sin(oscbright/20));
		
		oscX++;
		light.x = Math.sin(oscX/10)*150 - 250;
		light2.x = Math.sin(oscX/10)*150;
		light3.x = Math.sin(oscX/10)*150 + 250;
		
		super.onRenderTick(event);
		
		}
		*/
		
	}
}