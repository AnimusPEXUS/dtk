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
import dtk.miscs.TextProcessor;

import dtk.laf.chicago98.Chicago98Laf;

import dtk.widgets.Form;
import dtk.widgets.Button;
import dtk.widgets.ButtonRadio;
import dtk.widgets.ButtonCheck;
import dtk.widgets.TextEntry;
import dtk.widgets.Layout;

void main()
{


    auto pl = instantiatePlatform();

    pl.init();

    pl.setLaf(new Chicago98Laf);

    WindowCreationSettings wcs = {
        title: "123",
        x: 500,
        y: 500,
        width: 300,
        height: 300,
        resizable: true,
    };

    auto w = pl.createWindow(wcs);

    Form form = new Form();
    w.setForm(form);

    Layout lo = new Layout();
    form.setChild(lo);
    
    lo.setX(10).setY(10).setWidth(290).setHeight(290);

    auto btn = new Button();
    auto btn2 = new Button();
    auto btn3 = new ButtonRadio();
    auto btn4 = new ButtonCheck();
    auto btn5 = new ButtonRadio();
    auto lbl1 = new TextEntry();
    lbl1.setText(
        "1234567👍8abcАABCgqpабв|{,_}🏁🏴‍☠️🇮🇱🇺🇸🇷🇺🧑\n"
        ~"вторая строка\n"
        ~"третья строка\n");
    lbl1.setFontFamily("Go");
    lbl1.setFontStyle("Regular");
    lbl1.setFontSize(10);
    lbl1.setVirtualWrapByWord(true);
    lbl1.setDrawBewelAndBackground(true);
    lbl1.setTextSelectable(true);
    lbl1.setTextEditable(true);
    lbl1.setCursorEnabled(true);

    auto rg = new RadioGroup();

    btn3.setRadioGroup(rg);
    btn5.setRadioGroup(rg);

    rg.selectButton(btn5);

    btn.setX(10).setY(10).setWidth(40).setHeight(40);
    btn2.setX(10).setY(60).setWidth(10).setHeight(10);
    btn3.setX(10).setY(80).setWidth(12).setHeight(12);
    btn4.setX(10).setY(100).setWidth(12).setHeight(12);
    btn5.setX(10).setY(120).setWidth(12).setHeight(12);
    lbl1.setX(10).setY(140).setWidth(500).setHeight(100);

    lo.children = [
    	new LayoutChild(btn),
    	new LayoutChild(btn2),
    	new LayoutChild(btn3),
    	new LayoutChild(btn4),
    	new LayoutChild(btn5),
    	new LayoutChild(lbl1)
    ];
    
    pl.mainLoop();

    pl.destroy();
}
