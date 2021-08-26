module dtk.interfaces.ThemeI;


import dtk.interfaces.DrawingSurfaceI;
import dtk.widgets;

interface ThemeI
{
    void drawForm(Form widget);
    void drawButton(Button widget);
    void drawImage(Image widget);
    void drawLabel(Label widget);
    void drawLayout(Layout widget);
    void drawMenu(Menu widget);
    void drawMenuItem(MenuItem widget);
    void drawBar(Bar widget);
    void drawScrollBar(ScrollBar widget);
    void drawTextEntry(TextEntry widget);
    void drawTextArea(TextArea widget);
}
