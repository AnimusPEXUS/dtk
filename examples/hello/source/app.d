
import std.stdio;
import std.typecons;

import dtk.main;

import dtk.types.Point;
import dtk.types.Size;
import dtk.types.WindowCreationSettings;

void main()
{
	auto pl = instantiatePlatform();

	pl.init();

	/* Point a = {x:10, y:10};
	Size b = {width:200, height: 200}; */


	WindowCreationSettings wcs = {
		title:"123",
		position: Point(0, 0),
		size: Size(200, 200),
		resizable:true,
	};

	WindowCreationSettings wcs2 = {
		title:"456",
		position: Point(200, 200),
		size: Size(200, 200),
		resizable:true,
	};

	pl.createWindow(wcs);
	pl.createWindow(wcs2);

	pl.mainLoop();

	pl.destroy_();
}
