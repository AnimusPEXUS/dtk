module dtk.interfaces.ThemeI;


import dtk.interfaces.DrawingSurfaceI;
import dtk.widgets;

interface ThemeI
{
    void drawForm(DrawingSurfaceI ds, Form widget);
    void drawButton(DrawingSurfaceI ds, Button widget);
    void drawImage(DrawingSurfaceI ds, Image widget);
    void drawLabel(DrawingSurfaceI ds, Label widget);
    void drawLayout(DrawingSurfaceI ds, Layout widget);
    void drawMenu(DrawingSurfaceI ds, Menu widget);
    void drawMenuItem(DrawingSurfaceI ds, MenuItem widget);
    void drawBar(DrawingSurfaceI ds, Bar widget);
    void drawScrollBar(DrawingSurfaceI ds, ScrollBar widget);
    void drawTextEntry(DrawingSurfaceI ds, TextEntry widget);
    void drawTextArea(DrawingSurfaceI ds, TextArea widget);
}
