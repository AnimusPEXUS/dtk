import std.stdio;
import std.typecons;
import std.math;

import dtk.main;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;

import dtk.types.EnumKeyboardModCode;

import dtk.miscs.RadioGroup;

import dtk.laf.chicago98.Chicago98Laf;

import dtk.widgets;
import dtk.widgets.DrawingSurface;

void main()
{


    auto pl = instantiatePlatform();

    pl.init();

    pl.setLaf(new Chicago98Laf);

    WindowCreationSettings wcs = {
        title: "123",
        position: Position2D(500, 500),
        size: Size2D(200, 200),
        resizable: true,
    };

    auto w = pl.createWindow(wcs);

    Form form = new Form();

    Layout lo = new Layout();

    auto btn = new Button();
    auto btn2 = new Button();
    auto btn3 = new ButtonRadio();
    auto btn4 = new ButtonCheck();
    auto btn5 = new ButtonRadio();
    auto lbl1 = new Label();
    lbl1.setText("text test");

    /* DS ds = new DS(); */

    auto rg = new RadioGroup();

    btn3.setRadioGroup(rg);
    btn5.setRadioGroup(rg);

    rg.selectButton(btn5);

    btn.setPosition(Position2D(10, 10)).setSize(Size2D(40, 40));
    btn2.setPosition(Position2D(10, 60)).setSize(Size2D(10, 10));
    btn3.setPosition(Position2D(10, 80)).setSize(Size2D(12, 12));
    btn4.setPosition(Position2D(10, 100)).setSize(Size2D(12, 12));
    btn5.setPosition(Position2D(10, 120)).setSize(Size2D(12, 12));
    lbl1.setPosition(Position2D(10, 140)).setSize(Size2D(100, 12));
    /* ds.setPosition(Position2D(50, 50)).setSize(Size2D(50, 50)); */

    lo.packStart(btn, true, true);
    lo.packStart(btn2, false, true);
    lo.packStart(btn3, false, true);
    lo.packStart(btn4, false, true);
    lo.packStart(btn5, false, true);
    lo.packStart(lbl1, false, true);

    form.setChild(lo);

    w.installForm(form);

    /* auto fm = pl.getFontManager();
    auto fi = fm.getFontInfoList();
    foreach(f;fi)
    {
        writeln(f.on_fs_filename);
    }
    auto font = fm.loadFont("/usr/share/fonts/go/Go-Regular.ttf");
    writeln("font loaded"); */

    pl.mainLoop();

    pl.destroy();
}
