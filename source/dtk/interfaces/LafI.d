module dtk.interfaces.LafI;

import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.WindowEventMgrI;

import dtk.widgets;

interface LafI
{
    void drawForm(Form widget);
    void drawButton(Button widget);
    void drawButtonRadio(ButtonRadio widget);
    void drawButtonCheck(ButtonCheck widget);
    void drawImage(Image widget);
    void drawLabel(Label widget);
    void drawLayout(Layout widget);
    void drawMenu(Menu widget);
    void drawMenuItem(MenuItem widget);
    void drawBar(Bar widget);
    void drawScrollBar(ScrollBar widget);
    void drawTextEntry(TextEntry widget);
    void drawTextArea(TextArea widget);

    void addEventHandling(WindowEventMgrI mgr);
}