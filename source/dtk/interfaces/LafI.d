module dtk.interfaces.LafI;

import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.WindowEventMgrI;

import dtk.types.Image;

import dtk.widgets.Form;
import dtk.widgets.Button;
import dtk.widgets.ButtonRadio;
import dtk.widgets.ButtonCheck;
// import dtk.widgets.Image;
import dtk.widgets.Layout;
import dtk.widgets.Menu;
import dtk.widgets.MenuItem;
import dtk.widgets.Bar;
import dtk.widgets.ScrollBar;
import dtk.widgets.TextEntry;

interface LafI
{
    void drawForm(Form widget);
    void drawButton(Button widget);
    void drawButtonRadio(ButtonRadio widget);
    void drawButtonCheck(ButtonCheck widget);
    void drawImage(Image widget);
    /* void drawLabel(Label widget); */
    void drawLayout(Layout widget);
    void drawMenu(Menu widget);
    void drawMenuItem(MenuItem widget);
    void drawBar(Bar widget);
    void drawScrollBar(ScrollBar widget);
    void drawTextEntry(TextEntry widget);
    /* void drawTextArea(TextArea widget); */

    void addEventHandling(WindowEventMgrI mgr);
}
