typedef TextureAtlas = {
	imagePath:String,
	subTextures:Array<SubTexture>
}

typedef SubTexture = {
	name:String,
	x:Int,
	y:Int,
	width:Int,
	height:Int,
	frameX:Int,
	frameY:Int,
	frameWidth:Int,
	frameHeight:Int,
	rotated:Bool
}

class Data {
	public static function extract(ta:Xml):TextureAtlas {
		final texAtlas:TextureAtlas = {
			imagePath: ta.get('imagePath'),
			subTextures: []
		}

		for (st in ta.elementsNamed('SubTexture')) {
			final subTex:SubTexture = {
				name: st.get('name'),
				x: Std.parseInt(st.get('x')),
				y: Std.parseInt(st.get('y')),
				width: Std.parseInt(st.get('width')),
				height: Std.parseInt(st.get('height')),
				frameX: 0,
				frameY: 0,
				frameWidth: 0,
				frameHeight: 0,
				rotated: st.exists('rotated') && st.get('rotated') == 'true'
			}
			if (st.exists('frameX')) subTex.frameX = Std.parseInt(st.get('frameX'));
			if (st.exists('frameY')) subTex.frameY = Std.parseInt(st.get('frameY'));
			if (st.exists('frameWidth')) subTex.frameWidth = Std.parseInt(st.get('frameWidth'));
			if (st.exists('frameHeight')) subTex.frameWidth = Std.parseInt(st.get('frameHeight'));
		
			texAtlas.subTextures.push(subTex);
		}

		return texAtlas;
	}
}