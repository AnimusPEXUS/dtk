
import std.stdio;
import std.typecons;

import dtk.main;

import dtk.types.Point;
import dtk.types.Size;
import dtk.types.WindowCreationSettings;

import dtk.widgets.Form;
import dtk.widgets.Layout;
import dtk.widgets.Button;

void main()
{
	auto pl = instantiatePlatform();

	pl.init();

	WindowCreationSettings wcs = {
		title:"123",
		position: Point(0, 0),
		size: Size(200, 200),
		resizable:true,
	};

	auto w = pl.createWindow(wcs);

	Form form = new Form();

	Layout lo = new Layout();

	Button btn = new Button();

	form.setChild(lo);

	w.installForm(form);

	pl.mainLoop();

	pl.destroy_();
}
