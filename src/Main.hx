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

	final texAtlas:TextureAtlas = Data.extract(ta);
	
	final b:StringBuf = new StringBuf();

	b.add('${texAtlas.imagePath}\n');
	b.add('format: RGBA8888\n');
	b.add('filter: Linear,Linear\n');
	b.add('repeat: none\n');

	for (subTex in texAtlas.subTextures) {
		final name:String = subTex.name.substring(0, subTex.name.length - 4);
		final index:Int = Std.parseInt(subTex.name.substring(subTex.name.length - 4));

		b.add(name); // remove digits
		b.add('\trotate: ${subTex.rotated}\n');
		b.add('\txy: ${subTex.x},${subTex.y}\n');
		b.add('\tsize: ${subTex.width},${subTex.height}\n');
		if (subTex.frameX != 0 || subTex.frameY != 0)
			b.add('\toffset: ${-subTex.frameX},${-subTex.frameY}\n');
		if (subTex.frameWidth != 0 || subTex.frameWidth != 0)
			b.add('\torig: ${subTex.frameWidth},${subTex.frameHeight}\n');
		b.add('\tindex: $index\n');
	}

	final newPath:String = Path.withoutExtension(path) + '.atlas';
	File.saveContent(newPath, b.toString());
}