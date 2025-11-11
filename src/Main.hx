import haxe.io.Path;
import Data;
import sys.FileSystem;
import sys.io.File;

function main() {
	final args:Array<String> = Sys.args();
	final path:String = args.shift();

	if (!FileSystem.exists(path) || FileSystem.isDirectory(path)) {
		Sys.println('\033[31mSparrow "$path" does not exist\033[39m');
		return;
	}

	final doc:Null<Xml> = try Xml.parse(File.getContent(path)) catch (_) null;
	if (doc == null) {
		Sys.println('\033[31mInvalid XML document "$path"\033[39m');
		return;
	}

	final ta:Xml = doc.firstElement();
	if (ta.nodeName != 'TextureAtlas') {
		Sys.println('\033[31m<TextureAtlas/> does not exist in XML document "$path"\033[39m');
		return;
	}

	final atlas:TextureAtlas = Data.extract(ta);
	
	final b:StringBuf = new StringBuf();

	b.add(atlas.imagePath);
	b.addChar('\n'.code);

	b.add('format: RGBA8888\n');
	b.add('filter: Linear,Linear\n');
	b.add('repeat: none\n');

	for (subtex in atlas.subTextures) {
		final name:String = subtex.name.substring(0, subtex.name.length - 4);
		final index:Int = Std.parseInt(subtex.name.substring(subtex.name.length - 4));

		b.add(name);
		b.addChar('\n'.code);

		b.add('\trotate: ');
		b.add(subtex.rotated);
		b.addChar('\n'.code);

		b.add('\txy: ');
		b.add(subtex.x);
		b.addChar(','.code);
		b.add(subtex.y);
		b.addChar('\n'.code);

		b.add('\tsize: ');
		b.add(subtex.width);
		b.addChar(','.code);
		b.add(subtex.height);
		b.addChar('\n'.code);

		final trimmed:Bool = subtex.frameX != null;

		if (trimmed) {
			final offsetX:Float = -subtex.frameX;
    	final offsetY:Float = subtex.frameHeight - subtex.height + subtex.frameY;

			b.add('\toffset: ');
			b.add(offsetX);
			b.addChar(','.code);
			b.add(offsetY);
			b.addChar('\n'.code);

			b.add('\torig: ');
			b.add(subtex.frameWidth);
			b.addChar(','.code);
			b.add(subtex.frameHeight);
			b.addChar('\n'.code);
		} else {
			final offsetY:Float = -subtex.height;

			b.add('\toffset: 0,');
			b.add(offsetY);
			b.addChar('\n'.code);

			b.add('\torig: ');
			b.add(subtex.frameWidth);
			b.addChar(','.code);
			b.add(subtex.frameHeight);
			b.addChar('\n'.code);
		}

		b.add('\tindex: ');
		b.add(index);
		b.addChar('\n'.code);
	}

	final newPath:String = Path.withoutExtension(path) + '.atlas';
	File.saveContent(newPath, b.toString());
}