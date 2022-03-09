module dtk.interfaces.LafI;

import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Image;

import dtk.widgets.Form;
import dtk.widgets.Button;
import dtk.widgets.ButtonRadio;
import dtk.widgets.ButtonCheck;
import dtk.widgets.Layout;
// import dtk.widgets.Menu;
// import dtk.widgets.MenuItem;
// import dtk.widgets.Bar;
import dtk.widgets.ScrollBar;
import dtk.widgets.TextEntry;
import dtk.widgets.Picture;


interface LafI
{
    void drawForm(Form widget, DrawingSurfaceI ds);
    void drawButton(Button widget, DrawingSurfaceI ds);
    void drawButtonRadio(ButtonRadio widget, DrawingSurfaceI ds);
    void drawButtonCheck(ButtonCheck widget, DrawingSurfaceI ds);
    void drawPicture(Picture widget, DrawingSurfaceI ds);
    void drawLayout(Layout widget, DrawingSurfaceI ds);
    // void drawMenu(Menu widget, DrawingSurfaceI ds);
    // void drawMenuItem(MenuItem widget, DrawingSurfaceI ds);
    // void drawBar(Bar widget, DrawingSurfaceI ds);
    void drawScrollBar(ScrollBar widget, DrawingSurfaceI ds);
    void drawTextEntry(TextEntry widget, DrawingSurfaceI ds);
}
