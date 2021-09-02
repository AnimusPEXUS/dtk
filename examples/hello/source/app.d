
import std.stdio;
import std.typecons;
import std.math;

import dtk.main;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;
import dtk.themes.chicago98.Chicago98Theme;

import dtk.widgets.Form;
import dtk.widgets.Layout;
import dtk.widgets.Button;
import dtk.widgets.DrawingSurface;

class DS : DrawingSurface
{
	override void redraw()
	{
		auto ds = getDrawingSurface();
		ds.drawDot(Position2D(100, 100), Color(0x0));
		ds.drawCircle(Position2D(100, 100), 100, PI/180, Color(0));
	}
}

void main()
{
	auto pl = instantiatePlatform();

	pl.init();

	pl.setTheme(new Chicago98Theme);

	WindowCreationSettings wcs = {
		title:"123",
		position: Position2D(500, 500),
		size: Size2D(200, 200),
		resizable:true,
	};

	auto w = pl.createWindow(wcs);

	Form form = new Form();

	Layout lo = new Layout();

	Button btn = new Button();
	Button btn2 = new Button();

	DS ds = new DS();

	btn.setPosition(Position2D(20, 20)).setSize(Size2D(40, 40));
	btn2.setPosition(Position2D(100, 20)).setSize(Size2D(40, 40));
	ds.setPosition(Position2D(200, 200)).setSize(Size2D(200, 200));


	lo.packStart(btn,true, true);
	lo.packStart(btn2,false, true);
	lo.packStart(ds,false, true);

	form.setChild(lo);

	w.installForm(form);

	pl.mainLoop();

	pl.destroy_();
}
