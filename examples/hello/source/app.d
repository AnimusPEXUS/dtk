import std.stdio;
import std.typecons;
import std.math;

import dtk.main;

import dtk.interfaces.LaFI;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;

import dtk.types.EnumKeyboardModCode;

import dtk.miscs.RadioGroup;
import dtk.miscs.TextProcessor;

import dtk.laf.chicago98.Chicago98Laf;

import dtk.elements.StdFactory;

void main()
{


    auto pl = instantiatePlatform();

    pl.init();
    
    auto laf = new Chicago98Laf;
    
    pl.setOnGetLaf(
    	delegate LaFI()
    	{
    		return laf;
    	}
    	);
    
    WindowCreationSettings wcs = {
        title: "123",
        x: 500,
        y: 500,
        width: 300,
        height: 300,
        resizable: true,
    };

    auto w = pl.createWindow(wcs);

    auto factory = new StdFactory();
    
    auto form = factory.Form();
    w.setForm(form);

    auto lo = factory.Layout();
    
    writeln("before form.setChild");
    form.setChild(lo);
    writeln("after form.setChild");
    
    lo.setX(10).setY(10).setWidth(290).setHeight(290);

    auto btn = factory.Button().setTextLabel("Button 1");
    auto btn2 = factory.Button().setTextLabel("Button 2");
    auto btn3 = factory.ButtonRadio();
    auto btn4 = factory.ButtonCheck();
    auto btn5 = factory.ButtonRadio();
    auto lbl1 = factory.TextEntry();
    auto lbl2 = factory.Label("text2");

    foreach(v; [btn, btn2, btn3,
    	btn4, btn5, lbl1, lbl2
    	])
    {
    	lo.addChild(v);
    }        
    
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
    lbl2.setX(10).setY(260).setWidth(500).setHeight(20);
    
    pl.mainLoop();

    pl.destroy();
}
