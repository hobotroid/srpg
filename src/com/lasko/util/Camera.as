package com.lasko.util 
{
	import net.flashpunk.FP;
	
	import com.lasko.Game;
	import com.lasko.Global;
	import com.lasko.entity.Character;

	public class Camera
	{
		private var cameraOffset:int;
		private var cameraSpeed:int;
		
		public function Camera(_cameraOffset:int, _cameraSpeed:int) 
		{
			cameraOffset = _cameraOffset;
			cameraSpeed = _cameraSpeed;
		}
		
		public function adjustToCharacter(mapWidth:int, mapHeight:int, character:Character):void
		{
			// Find the coordinates to that would center the player 
			var newCameraX:int = (character.x + character.width/2) - FP.width / 2;
			var newCameraY:int = (character.y + character.height/2) - FP.height / 2;
			
			// Check if they go beyond map boundaries
			if (newCameraX < 0) newCameraX = 0;
			else if (newCameraX + FP.width > mapWidth) newCameraX = mapWidth - FP.width;
			
			if (newCameraY < 0) newCameraY = 0;
			else if (newCameraY + FP.height > mapHeight) newCameraY = mapHeight - FP.height;
			
			// Set the camera coordinates
			FP.camera.x = newCameraX;
			FP.camera.y = newCameraY;
		}
		
		public function followCharacter(mapWidth:int, mapHeight:int, character:Character):void
		{
			// Check horizontal axis
			if (character.x - FP.camera.x < cameraOffset) 
			{
				// Only if the screen's left edge 
				// didn't hit the left most boundary x=0
				if (FP.camera.x > 0) FP.camera.x -= cameraSpeed;
			}
			else if ((FP.camera.x + FP.width) -  (character.x + character.width) < cameraOffset)
			{
				// Only if the screen's right edge 
				// didn't hit the right most boundary x=mapWidth
				if (FP.camera.x + FP.width < mapWidth) FP.camera.x += cameraSpeed;
			}
			
			// Check vertical axis
			if (character.y - FP.camera.y < cameraOffset) 
			{
				// Only if the screen's upper edge 
				// didn't hit the up most boundary y=0
				if (FP.camera.y > 0) FP.camera.y -= cameraSpeed;
			}
			else if ((FP.camera.y + FP.height) - (character.y + character.height) < cameraOffset)
			{
				// Only if the screen's bottom edge 
				// didn't hit the bottom most boundary x=mapHeight
				if (FP.camera.y + FP.height < mapHeight) FP.camera.y += cameraSpeed;
			}
		}
	}
}