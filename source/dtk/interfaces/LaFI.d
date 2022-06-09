module dtk.interfaces.LaFI;

import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Image;
import dtk.types.Widget;

import dtk.widgets.Form;
import dtk.widgets.Button;

//import dtk.widgets.ButtonRadio;
import dtk.widgets.ButtonCheck;

// import dtk.widgets.Picture;
import dtk.widgets.Layout;
import dtk.widgets.Menu;
import dtk.widgets.MenuItem;
import dtk.widgets.ScrollBar;
import dtk.widgets.TextEntry;

interface LaFI
{
    void drawForm(Form e, DrawingSurfaceI ds);
    void drawButton(Button e, DrawingSurfaceI ds);
    void drawButtonRadio(ButtonCheck e, DrawingSurfaceI ds);
    void drawButtonCheck(ButtonCheck e, DrawingSurfaceI ds);
    //void drawPicture(Picture e, DrawingSurfaceI ds);
    void drawLayout(Layout e, DrawingSurfaceI ds);
    void drawMenu(Menu e, DrawingSurfaceI ds);
    void drawMenuItem(MenuItem e, DrawingSurfaceI ds);
    // void drawBar(Bar widget, DrawingSurfaceI ds);
    void drawScrollBar(ScrollBar e, DrawingSurfaceI ds);
    void drawTextEntry(TextEntry e, DrawingSurfaceI ds);
}
