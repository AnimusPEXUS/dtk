import std.stdio;
import std.typecons;
import std.math;

import dtk.main;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;
import dtk.themes.chicago98.Chicago98Theme;

import dtk.widgets;
import dtk.widgets.DrawingSurface;

/* class DS : DrawingSurface
{
    override void redraw()
    {
        auto ds = getDrawingSurface();

        auto t = new Chicago98Theme();

		auto p_45 = PI / 4;
		auto p_m45 = -p_45;
		auto p_135 = PI/2 + p_45;
		auto p_135m2 = PI*2 - p_45;
		auto step = PI / 180;

        ds.drawArc(Position2D(100, 100), 6, p_m45, p_135, step, t.elementLightedColor);
        ds.drawArc(Position2D(100, 100), 6, p_135, p_135m2, step, t.elementDarkedColor2);

        ds.drawArc(Position2D(100, 100), 5, p_m45, p_135, step, t.elementLightedColor2);
        ds.drawArc(Position2D(100, 100), 5, p_135, p_135m2, step, t.elementDarkedColor);

		/* ds.drawCircle(Position2D(100, 100), 4, step, Color(0xffffff)); * /

		for (auto i = 4; i!=2; i--)
		{
			ds.drawCircle(Position2D(100, 100), i, step, Color(0xffffff));
		}

		for (auto i = 2; i!=-1; i--)
		{
			ds.drawCircle(Position2D(100, 100), i, step, Color(0));
		}

		ds.drawDot(Position2D(100, 100),Color(0));

    }
} */

void main()
{
    auto pl = instantiatePlatform();

    pl.init();

    pl.setTheme(new Chicago98Theme);

    WindowCreationSettings wcs = {
        title: "123", position: Position2D(500, 500), size: Size2D(200, 200), resizable: true,
    };

    auto w = pl.createWindow(wcs);

    Form form = new Form();

    Layout lo = new Layout();

    Button btn = new Button();
    Button btn2 = new Button();
    Button btn3 = new ButtonRadio();
    Button btn4 = new ButtonCheck();

    /* DS ds = new DS(); */

    btn.setPosition(Position2D(10, 10)).setSize(Size2D(40, 40));
    btn2.setPosition(Position2D(10, 60)).setSize(Size2D(10, 10));
    btn3.setPosition(Position2D(10, 80)).setSize(Size2D(20, 20));
    btn4.setPosition(Position2D(10, 100)).setSize(Size2D(20, 20));
    /* ds.setPosition(Position2D(50, 50)).setSize(Size2D(50, 50)); */

    lo.packStart(btn, true, true);
    lo.packStart(btn2, false, true);
    lo.packStart(btn3, false, true);
    lo.packStart(btn4, false, true);
    /* lo.packStart(ds, false, true); */

    form.setChild(lo);

    w.installForm(form);

    pl.mainLoop();

    pl.destroy_();
}
