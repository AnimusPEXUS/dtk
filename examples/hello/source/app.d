
import std.stdio;
import std.typecons;

import dtk.main;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;
import dtk.themes.chicago98.Chicago98Theme;

import dtk.widgets.Form;
import dtk.widgets.Layout;
import dtk.widgets.Button;

void main()
{
	auto pl = instantiatePlatform();

	pl.init();

	pl.setTheme(new Chicago98Theme);

	WindowCreationSettings wcs = {
		title:"123",
		position: Position2D(300, 300),
		size: Size2D(200, 200),
		resizable:true,
	};

	auto w = pl.createWindow(wcs);

	Form form = new Form();

	Layout lo = new Layout();

	Button btn = new Button();
	Button btn2 = new Button();

	btn.setPosition(Position2D(20, 20)).setSize(Size2D(40, 40));
	btn2.setPosition(Position2D(100, 20)).setSize(Size2D(40, 40));

	lo.packStart(btn,true, true);
	lo.packStart(btn2,false, true);

	form.setChild(lo);

	w.installForm(form);

	pl.mainLoop();

	pl.destroy_();
}
