
import std.format;
import std.stdio;
import std.typecons;
import std.math;

import dtk.main;

import dtk.interfaces.LaFI;

import dtk.types.EventForm;
import dtk.types.Orientation;
import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;
import dtk.types.Widget;

import dtk.types.EnumKeyboardModCode;

import dtk.miscs.RadioGroup;
import dtk.miscs.TextProcessor;
import dtk.miscs.layoutCollection;

import dtk.laf.chicago98.Chicago98Laf;

import dtk.widgets.Form;
import dtk.widgets.Menu;
import dtk.widgets.MenuItem;
import dtk.widgets.Layout;
import dtk.widgets.Button;
import dtk.widgets.ButtonCheck;
import dtk.widgets.TextEntry;
import dtk.widgets.ScrollBar;

Menu makeMainMenu()
{
	Menu m0 = MenuBar();
	Layout m0lo = new Layout();
	MenuItem m0mi0 = new MenuItem();
	m0.setLayout(m0lo);
	m0lo.addLayoutChild(m0mi0);
	
	Menu m1 = MenuPopup();
	Layout m1lo = new Layout();
	MenuItem m1mi0 = new MenuItem();
	MenuItem m1mi1 = new MenuItem();
	m1.setLayout(m1lo);
	m1lo.addLayoutChild(m1mi0);
	m1lo.addLayoutChild(m1mi1);
	
	m0mi0.setWidget(Label("File"));
	m0mi0.setSubmenu(m1);
	
	m1mi0.setWidget(Label("Open"));
	m1mi1.setWidget(Label("Save"));
	
	m0.setPerformLayout(
		delegate void(Widget w1)
		{
			auto w = cast(Menu) w1;
			auto c = w.getLayout();
			
			// w.setDesiredWidth(w.getWidth());
			// w.setDesiredHeight(w.getHeight());
			
			c.setWidth(w.getWidth());
			c.setHeight(c.getDesiredHeight());
			debug writeln(
				"m0 layout activated: ww = %s, wh = %s, cw = %s, ch = %s".format(
					w.getWidth(),
					w.getHeight(),
					c.getWidth(),
					c.getHeight()
					)
				);
		}
		);
	
	m0lo.setPerformLayout(
		delegate void(Widget w1)
		{
			auto w = cast(Layout) w1;
			debug writeln(
				"m0lo layout activated: ww = %s, wh = %s".format(
					w.getWidth(),
					w.getHeight(),
					)
				);
			
			w.setViewPortWidth(w.getWidth());
			w.setViewPortHeight(w.getHeight());
			
			// move this into linearLayout
			int height;
			
			for (int i = 0; i != w.getLayoutChildCount(); i++)
			{
				auto c = w.getLayoutChild(i);
				auto ch = c.getDesiredHeight();
				if (ch > height)
					height = ch;
			}
			
			w.setDesiredHeight(height);
			
			linearLayout(w, Orientation.horizontal);
			for (int i = 0; i != w.getLayoutChildCount(); i++)
			{
				auto c = w.getLayoutChild(i);
				debug writeln(
					"   m0lo child %d: x = %s, y = %s, w = %s, h = %s".format(
						i,
						c.getX(),
						c.getY(),
						c.getWidth(),
						c.getHeight()
						)
					);
			}
		}
		);
	
	m1lo.setPerformLayout(
		delegate void(Widget w1)
		{
			auto w = cast(Layout) w1;
			debug writeln("m1lo layout activated");

			w.setViewPortWidth(w.getWidth());
			w.setViewPortHeight(w.getHeight());
			
			int width;
			
			for (int i = 0; i != w.getLayoutChildCount(); i++)
			{
				auto c = w.getLayoutChild(i);
				auto cw = c.getDesiredWidth();
				if (cw > width)
					width = cw;
			}
			
			linearLayout(w, Orientation.vertical);
		}
		);
	
	return m0;
}

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
        title: "Example",
        x: 200,
        y: 200,
        width: 800,
        height: 800,
        resizable: true,
    };
    
    auto w = pl.createWindow(wcs);
    
    
    auto form = new Form();
    w.setForm(form);
    
    auto lo = new Layout();
    
    writeln("before form.setChild");
    form.setMainWidget(lo);
    writeln("after form.setChild");
    
    // lo.setX(10).setY(10).setWidth(780).setHeight(780);
    
    auto rg = new RadioGroup();
    
    auto mm = makeMainMenu();
    
    auto btn = new Button().setTextLabel("Button 1");
    auto btn2 = new Button().setTextLabel("Button 2");
    auto btn3 = new ButtonCheck().setTextLabel("ButtonRadio 1").setRadioGroup(rg);
    auto btn4 = new ButtonCheck().setTextLabel("CheckButton 1");
    auto btn5 = new ButtonCheck().setTextLabel("ButtonRadio 2").setRadioGroup(rg);
    auto lbl1 = new TextEntry();
    auto lbl2 = Label("text2");
    
    auto sb1 = new ScrollBar().setOrientation(Orientation.horizontal);
    
    foreach(v; [
    	mm,
    	btn,
    	btn2,
    	btn3,
    	btn4,
    	btn5,
    	lbl1,
    	lbl2,
    	sb1
    	])
    {
    	lo.addLayoutChild(v);
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
    
    rg.selectButton(btn5);
    
    form.performLayout = delegate void(Widget w)
    {
    	auto ww = cast(Form) w;
    	auto c = ww.getMainWidget();
    	if (c)
    	{
    		c.setX(0);
    		c.setY(0);
    		c.setWidth(ww.getWidth());
    		c.setHeight(ww.getHeight());
    	}
    };
    
    lo.performLayout = delegate void(Widget w1)
    {
    	Layout w = cast(Layout)w1;
    	w.setViewPortPosX(0);
    	w.setViewPortPosY(0);
    	w.setViewPortWidth(w.getWidth());
    	w.setViewPortHeight(w.getHeight());
    	auto wm = w.getViewPortWidth();
    	auto wm20 = wm-20;
    	mm.setX(0).setY(0).setWidth(wm).setHeight(20);
    	btn.setX(10).setY(mm.getY()+mm.getHeight()+5).setWidth(wm20/4).setHeight(20);
    	btn2.setX(btn.getX()+btn.getWidth()+5).setY(btn.getY()).setWidth(wm-(btn.getX()*2)-btn.getWidth()-5).setHeight(20);
    	btn3.setX(10).setY(btn2.getY()+btn2.getHeight()+5).setWidth(wm20).setHeight(12);
    	btn4.setX(10).setY(btn3.getY()+btn3.getHeight()+5).setWidth(wm20).setHeight(12);
    	btn5.setX(10).setY(btn4.getY()+btn4.getHeight()+5).setWidth(wm20).setHeight(12);
    	lbl1.setX(10).setY(btn5.getY()+btn5.getHeight()+5).setWidth(wm20).setHeight(100);
    	lbl2.setX(10).setY(lbl1.getY()+lbl1.getHeight()+5).setWidth(wm20).setHeight(20);
    	sb1.setX(10).setY(lbl2.getY()+lbl2.getHeight()+5).setWidth(wm20).setHeight(16);
    };

    pl.mainLoop();
    
    pl.destroy();
}
