module dtk.miscs.TextProcessor;

import std.conv;
import std.format;
import std.container;
import std.range.primitives;
import std.stdio;
import std.utf;
import std.typecons;
import std.exception;

import observable.signal;

import dtk.interfaces.FontMgrI;

import dtk.types.Image;
import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.fontinfo;
import dtk.types.Signal;
import dtk.types.Property;


enum GenVisibilityMapForSubitemsLayout
{
    horizontalLeftToRightAlignTop, // russian, english chars
    verticalTopToBottomAlignLeft, // russian, english, hebrew lines
    horizontalRightToLeftAlignTop, // hebrew chars, japanese lines
    verticalTopToBottomAlignRight, // japanese chars
}

// max_width, max_height - defines page size
// x,y,width,height - selects visible frame form the page
void genVisibilityMapForSubitems(
    ulong max_width, ulong max_height,
    
    ulong x, ulong y,
    ulong width, ulong height,
    
    GenVisibilityMapForSubitemsLayout layout,
    
    ulong delegate() getSubitemCount,
    ulong delegate(ulong subitem_index) getSubitemWidth,
    ulong delegate(ulong subitem_index) getSubitemHeight,
    void delegate(
        ulong subitem_index,
        ulong target_x, ulong target_y,
        ulong x, ulong y,
        ulong width, ulong height
        ) genVisibilityMapForSubitem,)
{
	
    /* Image ret = new Image(width, height); */
    
    if (x > width || y > height)
        return;
    
    auto actual_width = (x + width > max_width ? max_width - x : width);
    auto actual_height = (y + height > max_height ? max_height - y : height);
    
    auto x2 = x + width;
    auto y2 = y + height;
    
    ulong first_visible_item;
    bool first_visible_item_found;
    ulong first_visible_item_offset;
    
    ulong last_visible_item;
    bool last_visible_item_found;
    ulong last_visible_item_offset;
    
    ulong subitem_count = getSubitemCount();
    
    {
        ulong processed_size;
        
        {
            ulong z;
            ulong z2;
            
            ulong current_size;
            
            switch (layout)
            {
            default:
                throw new Exception("unknown layout");
            case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                z = x;
                z2 = x2;
                break;
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                z = y;
                z2 = y2;
                break;
            }
            
            for (ulong i = 0; i != subitem_count; i++)
            {
            	
                switch (layout)
                {
                default:
                    throw new Exception("unknown layout");
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                    current_size = getSubitemWidth(i);
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                    current_size = getSubitemHeight(i);
                    break;
                }
                
                if (!first_visible_item_found && z >= processed_size
                    && z < processed_size + current_size)
                {
                    first_visible_item = i;
                    first_visible_item_found = true;
                    first_visible_item_offset = z - processed_size;
                }
                
                if (!last_visible_item_found && z2 >= processed_size
                    && z2 < processed_size + current_size)
                {
                    last_visible_item = i;
                    last_visible_item_found = true;
                    last_visible_item_offset = processed_size + current_size - z2;
                }
                
                if (first_visible_item_found && last_visible_item_found)
                    break;
                
                processed_size += current_size;
            }
        }
    }
    
    if (!first_visible_item_found)
        return;
    
    if (!last_visible_item_found)
    {
        last_visible_item = subitem_count - 1;
    }
    
    {
        ulong items_count = last_visible_item - first_visible_item;
        
        ulong delegate(ulong i) calc_loop_target_x;
        ulong delegate(ulong i) calc_loop_target_y;
        ulong delegate(ulong i) calc_loop_source_x;
        ulong delegate(ulong i) calc_loop_source_y;
        ulong delegate(ulong i) calc_loop_source_width;
        ulong delegate(ulong i) calc_loop_source_height;
        
        switch (layout)
        {
        default:
            throw new Exception("unknown layout");
        case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
            calc_loop_target_x = delegate ulong(ulong i) {
                if (i == 0)
                    return 0;
                ulong width;
                for (ulong j = 0; j < i; j++)
                {
                    width += getSubitemWidth(first_visible_item + j);
                }
                return width - first_visible_item_offset;
            };
            
            calc_loop_target_y = delegate ulong(ulong i) { return 0; };
            
            calc_loop_source_x = delegate ulong(ulong i) {
                if (i == 0)
                    return first_visible_item_offset;
                return 0;
            };
            
            calc_loop_source_y = delegate ulong(ulong i) { return 0; };
            
            calc_loop_source_width = delegate ulong(ulong i) {
                if (i == 0)
                    return getSubitemWidth(first_visible_item + i) - first_visible_item_offset;
                return getSubitemWidth(first_visible_item + i);
            };
            
            calc_loop_source_height = delegate ulong(ulong i) {
                return getSubitemHeight(first_visible_item + i);
            };
            break;
        case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
            calc_loop_target_x = delegate ulong(ulong i) { return 0; };
            
            calc_loop_target_y = delegate ulong(ulong i) {
                if (i == 0)
                    return 0;
                ulong height;
                for (ulong j = 0; j < i; j++)
                {
                    height += getSubitemHeight(first_visible_item + j);
                }
                return height - first_visible_item_offset;
            };
            
            calc_loop_source_x = delegate ulong(ulong i) { return 0; };
            
            calc_loop_source_y = delegate ulong(ulong i) {
                if (i == 0)
                    return first_visible_item_offset;
                return 0;
            };
            
            calc_loop_source_width = delegate ulong(ulong i) {
                return getSubitemWidth(first_visible_item + i);
            };
            
            calc_loop_source_height = delegate ulong(ulong i) {
                if (i == 0)
                    return getSubitemHeight(first_visible_item + i) - first_visible_item_offset;
                return getSubitemHeight(first_visible_item + i);
            };
            break;
        }
        
        debug for (ulong i = 0; i <= items_count; i++)
        {
            auto tx = calc_loop_target_x(i);
            auto ty = calc_loop_target_y(i);
            auto sx = calc_loop_source_x(i);
            auto sy = calc_loop_source_y(i);
            auto sw = calc_loop_source_width(i);
            auto sh = calc_loop_source_height(i);
            
            // writeln("
            // i                         : %d
            // calc_loop_target_x(i)     : %d
            // calc_loop_target_y(i)     : %d
            // calc_loop_source_x(i)     : %d
            // calc_loop_source_y(i)     : %d
            // calc_loop_source_width(i) : %d
            // calc_loop_source_height(i): %d
            // ".format(i,tx,ty,sx,sy,sw,sh));
            
            genVisibilityMapForSubitem(
                i,
                tx,
                ty,
                sx, sy,
                sw, sh
                );
        }
    }
    
    return;
}

class TextCharViewState
{
    /* ulong width;
    ulong height;
    */
    GlyphRenderResult* glyph;
    Image resImg;
}

class TextChar
{
    TextLine parent_line;
    
    dchar chr;
    
    this(TextLine parent_line)
    {
        this.parent_line = parent_line;
    }
    
    mixin getState!("text_view.text_char_states", TextCharViewState);
    
    void reprocess(TextView text_view)
    {
        auto state = getState(text_view);
        if (state.glyph is null)
        {
            loadGlyph(text_view);
            state.resImg = genImage(text_view);
        }
    }
    
    /* alias reprocess = rerender; */
    
    private void loadGlyph(TextView text_view)
    {
        auto state = getState(text_view);
        
        /* state.width = 0;
        state.height = 0; */
        
        debug writeln("rendering char: ", chr);
        
        auto font_mgr = text_view.getFontManager();
        auto face = font_mgr.loadFace(
            parent_line.parent_text.getFaceFamily(),
            parent_line.parent_text.getFaceStyle()
            );
        
        {
            auto x = parent_line.parent_text.getFaceSize();
            debug writeln("setting size to ", x);
            face.setCharSize(x, x);
        }
        {
            auto x = parent_line.parent_text.getFaceResolution();
            debug writeln("setting resolution to ", x);
            face.setCharResolution(x, x);
        }
        
        try
        {
            state.glyph = face.renderGlyphByChar(chr);
            /* state.width = state.glyph.bitmap.width;
            state.height = state.glyph.bitmap.height; */
        }
        catch (Exception e)
        {
            // TODO: replace with dummy glyph
            debug writeln("(non fatal) error: ", e);
            state.glyph = face.renderGlyphByChar(cast(dchar)'?');
            /* state.width = state.glyph.bitmap.width;
            state.height = state.glyph.bitmap.height; */
        }
    }
    
    private Image genImage(TextView text_view) {
    	
        auto layout = parent_line.parent_text.getLineCharsLayout();
        
        auto state = getState(text_view);
        
        if (state.glyph is null)
        {
            loadGlyph(text_view);
        }
        
        auto gi = state.glyph.glyph_info;
        
        auto width = gi.advance.x / 64;
        auto bearing_x = gi.metrics.horiBearing.x / 64;
        auto bearing_y = gi.metrics.horiBearing.y;
        if (bearing_y < 0)
            bearing_y = -bearing_y;
        bearing_y /= 64;
        
        auto ascend =gi.face_info.size.ascender;
        if (ascend < 0)
            ascend = -ascend;
        ascend /= 64;
        
        auto descend =gi.face_info.size.descender;
        if (descend < 0)
            descend = -descend;
        descend /= 64;
        
        auto height = ascend + descend;
        
        auto ret = new Image(width,height);
        
        for (ulong x= 0 ; x != state.glyph.bitmap.width; x++)
        {
            auto tx = x+bearing_x;
            for (ulong y= 0 ; y != state.glyph.bitmap.height; y++)
            {
                auto ty = y+ascend-bearing_y;
                auto dot = state.glyph.bitmap.getDot(x,y);
                ret.setDot(tx,ty,dot);
            }
        }
        
        debug writeln("TextChar.genImage");
        debug ret.printImage();
        
        return ret;
        
    }
    
}

class TextLineSublineViewState
{
    TextChar[] textchars;
    ulong width;
    ulong height;
}

// NOTE: this is needed, because each subline can have it's own perpendicular
//       size
class TextLineSubline
{
    TextLine parent_line;
    
    this(TextLine parent_line)
    {
        this.parent_line=parent_line;
    }
    
    mixin getState!(
        "text_view.text_line_subline_states",
        TextLineSublineViewState
        );
    
    void recalculateWidthAndHeight(TextView text_view)
    {
    	
        auto state = getState(text_view);
        
        state.width = 0;
        state.height = 0;
        
        switch (parent_line.parent_text.getLineCharsLayout())
        {
        default:
            throw new Exception(
                "parent_text.getLineCharsLayout ",
                to!string(parent_line.parent_text.getLineCharsLayout())
                );
            case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
            case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                foreach (tc; state.textchars)
                {
                    auto tc_state = tc.getState(text_view);
                    
                    state.width += tc_state.resImg.width;
                    
                    {
                        auto h = tc_state.resImg.height;
                        if (h > state.height)
                            state.height = h;
                    }
                }
                break;
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                foreach (tc; state.textchars)
                {
                    auto tc_state = tc.getState(text_view);
                    
                    state.height += tc_state.resImg.height;
                    
                    {
                        auto w = tc_state.resImg.width;
                        if (w > state.width)
                            state.width = w;
                    }
                }
                break;
        }
        
    }
    
    void genVisibilityMap(
        ulong this_line_index,
        ulong this_subline_index,
        ulong this_line_done_chars_count,
        
        ulong sublines_target_x,
        ulong sublines_target_y,
        
        ulong x,
        ulong y,
        ulong width,
        ulong height,
        
        TextView text_view,
        ElementVisibilityMap visibility_map
        )
    {
    	
        debug writeln("genVisibilityMap at ", __LINE__);
        debug writeln(" chars layout ", parent_line.parent_text.getLineCharsLayout());
        
        auto state = getState(text_view);
        
        genVisibilityMapForSubitems(
            state.width, state.height,
            
            x, y,
            width, height,
            
            parent_line.parent_text.getLineCharsLayout(),
            
            delegate ulong()
            {
                return state.textchars.length;
            },
            
            delegate ulong(ulong subitem_index)
            {
                return state.textchars[subitem_index].getState(
                    text_view
                    ).resImg.width;
            },
            
            delegate ulong(ulong subitem_index)
            {
                return state.textchars[subitem_index].getState(
                    text_view
                    ).resImg.height;
            },
            
            delegate void(
                ulong subitem_index,
                ulong target_x, ulong target_y,
                ulong x, ulong y,
                ulong width, ulong height
                )
            {
                auto evme = new ElementVisibilityMapElement();
                
                evme.map = visibility_map;
                evme.chr = state.textchars[subitem_index];
                
                evme.line=this_line_index;
                evme.line_char=this_line_done_chars_count + subitem_index;
                
                evme.target_x=sublines_target_x + target_x;
                evme.target_y=sublines_target_y + target_y;
                evme.x=x;
                evme.y=y;
                evme.width=width;
                evme.height=height;
                
                debug writefln(
                    "adding evme to elements (%d) %s",
                    visibility_map.elements.length, evme.chr.chr
                    );
                visibility_map.elements ~= evme;
            }
            );
        return ;
    }
    
}

// NOTE: TextLine have it's own contextual status, because in text wrap mode
//       line size depends on context's size
class TextLineViewState
{
    TextLineSubline[] sublines;
    ulong width;
    ulong height;
}

class TextLine
{
    Text parent_text;
    
    TextChar[] textchars;
    
    this(Text parent)
    {
        this.parent_text = parent;
    }
    
    mixin getState!("text_view.text_line_states", TextLineViewState);
    
    void setText(dstring txt)
    {
        /* auto state = getState(); */
        
        textchars = textchars[0 .. 0];
        /* sublines = sublines[0 .. 0]; */
        
        foreach (c; txt)
        {
            if (c == cast(dchar) '\n')
            {
                throw new Exception(
                    "TextLine.setText() does not accepts strings with new lines"
                    );
            }
        }
        
        foreach (c; txt)
        {
            auto tc = new TextChar(this);
            tc.chr = c;
            textchars ~= tc;
        }
    }
    
    void reprocessUnits(TextView text_view)
    {
        foreach (tc; textchars)
        {
            tc.reprocess(text_view);
        }
    }
    
    // recreates sublines
    void recreateSublines(TextView text_view)
    {
        auto state = getState(text_view);
        
        state.sublines = state.sublines[0 .. 0];
        
        // each line always have at least one subline
        state.sublines ~= new TextLineSubline(this);
        ulong current_line = 0;
        
        // TODO: comment this out?
        /* reprocessUnits(text_view); */
        
        // TODO: optimization required
        ulong required_size;
        
        if (text_view.getVirtualWrapBySpace()
            || text_view.getVirtualWrapByChar())
        {
            switch (parent_text.getLineCharsLayout())
            {
            default:
                throw new Exception(
                    "not supported parent_text.getLineCharsLayout ",
                    to!string(parent_text.getLineCharsLayout())
                    );
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    required_size = text_view.getWidth();
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                    required_size = text_view.getHeight();
                    break;
            }
        }
        
        ulong current_size = 0;
        
        auto sl = state.sublines[current_line];
        auto sl_state = sl.getState(text_view);
        
        sl_state.textchars=sl_state.textchars[0 .. 0];
        
        debug writeln("recreateSublines textchars.length ", textchars.length);
        
        foreach (tc; textchars)
        {
            ulong s;
            
            auto tc_state = tc.getState(text_view);
            
            switch (parent_text.getLineCharsLayout())
            {
            default:
                throw new Exception(
                    "not supported parent_text.getLineCharsLayout ",
                    to!string(parent_text.getLineCharsLayout())
                    );
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    s = tc_state.resImg.width;
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                    s = tc_state.resImg.height;
                    break;
            }
            
            if (text_view.getVirtualWrapBySpace()
                || text_view.getVirtualWrapByChar())
            {
                if (s > required_size)
                {
                    // NOTE: not error
                    return;
                }
            }
            
            if ((text_view.getVirtualWrapBySpace()
                || text_view.getVirtualWrapByChar())
                && required_size <= current_size + s)
            {
                state.sublines ~= new TextLineSubline(this);
                current_line++;
                sl = state.sublines[current_line];
                sl_state = sl.getState(text_view);
                current_size = s;
            }
            else
            {
                current_size += s;
            }
            
            sl_state.textchars ~= tc;
        }
        
    }
    
    void recalculateSublinesWidthsAndHeights(TextView text_view)
    {
        auto state = getState(text_view);
        
        foreach (sl; state.sublines)
        {
            sl.recalculateWidthAndHeight(text_view);
        }
    }
    
    void recalculateWidthAndHeight(TextView text_view)
    {
    	
        auto state = getState(text_view);
        
        state.width = 0;
        state.height = 0;
        
        if (state.sublines.length != 0)
        {
        	
            switch (parent_text.getLinesLayout())
            {
            default:
                throw new Exception(
                    "parent_text.getLinesLayout ",
                    to!string(parent_text.getLinesLayout())
                    );
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    foreach (sl; state.sublines)
                    {
                        auto sl_state = sl.getState(text_view);
                        
                        {
                            auto w = sl_state.width;
                            if (w > state.width)
                                state.width = w;
                        }
                        
                        state.height += sl_state.height;
                    }
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                    foreach (sl; state.sublines)
                    {
                        auto sl_state = sl.getState(text_view);
                        
                        state.width += sl_state.width;
                        
                        {
                            auto h = sl_state.height;
                            if (h > state.height)
                                state.height = h;
                        }
                    }
                    break;
            }
        }
    }
    
    dstring getText()
    {
        dstring ret;
        foreach (tc; textchars)
        {
            ret ~= tc.chr;
        }
        return ret;
    }
    
    dstring getText(ulong start, ulong stop)
    {
        dstring ret;
        
        for (ulong i = start; i != stop; i++)
        {
            ret ~= textchars[i].chr;
        }
        
        return ret;
    }
    
    void genVisibilityMap(
        // this is passed deeper to TextChar and stored to visibility_map items
        ulong this_line_index,
        
        ulong lines_target_x,
        ulong lines_target_y,
        
        ulong x,
        ulong y,
        ulong width,
        ulong height,
        
        TextView text_view,
        ElementVisibilityMap visibility_map
        )
    {
        debug writeln("genVisibilityMap at ", __LINE__);
        
        auto state = getState(text_view);
        
        genVisibilityMapForSubitems(
            state.width, state.height,
            
            x, y,
            width, height,
            
            parent_text.getLinesLayout(),
            
            delegate ulong()
            {
                return state.sublines.length;
            },
            
            delegate ulong(ulong subitem_index)
            {
                return state.sublines[subitem_index].getState(text_view).width;
            },
            
            delegate ulong(ulong subitem_index)
            {
                return state.sublines[subitem_index].getState(text_view).height;
            },
            delegate  void(
                ulong subitem_index,
                ulong target_x, ulong target_y,
                ulong x, ulong y,
                ulong width, ulong height
                )
            {
                ulong sum=0;
                /* ulong width_or_height_offset=0; */
                foreach (v;state.sublines[0 .. subitem_index])
                {
                    sum += v.getState(text_view).textchars.length;
                }
                
                state.sublines[subitem_index].genVisibilityMap(
                    this_line_index,
                    subitem_index,
                    sum,
                    lines_target_x+target_x, lines_target_y+target_y,
                    x, y,
                    width, height,
                    text_view,
                    visibility_map
                    );
            }
            );
        
    }
    
}

enum TextMarkupType
{
    none,
    plain = none,
    
    asciidocPlain,
    bbcodePlain,
    markdownPlain,
    markdownExtraPlain,
    podPlain,
}

class TextViewState
{
    ulong width;
    ulong height;
}

class Text
{
	
    SignalConnectionContainer con_cont;
    
    mixin mixin_install_multiple_properties!(
        cast(PropSetting[])[
        PropSetting(
            "gs_w_d",
            "TextMarkupType",
            "textMarkupType",
            "TextMarkupType",
            "TextMarkupType.plain"
            ),
        
        PropSetting(
            "gs_w_d",
            "GenVisibilityMapForSubitemsLayout",
            "lines_layout",
            "LinesLayout",
            "GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft"
            ),
        PropSetting(
            "gs_w_d",
            "GenVisibilityMapForSubitemsLayout",
            "line_chars_layout",
            "LineCharsLayout",
            "GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop"
            ),
        
        PropSetting("gs_w_d", "string", "faceFamily", "FaceFamily", "\"Go\""),
        PropSetting("gs_w_d", "string", "faceStyle", "FaceStyle", "\"Regular\""),
        PropSetting("gs_w_d", "uint", "faceSize", "FaceSize", "20*64"),
        PropSetting("gs_w_d", "uint", "faceResolution", "FaceResolution", "72"),
        
        PropSetting("gs_w_d", "bool", "bold", "Bold", "false"),
        PropSetting("gs_w_d", "bool", "italic", "Italic", "false"),
        PropSetting("gs_w_d", "bool", "underline", "Underlined", "false"),
        
        PropSetting(
            "gs_w_d",
            "bool",
            "defaultFGColorEnabled",
            "DefaultFGColorEnabled",
            "true"
            ),
        PropSetting(
            "gs_w_d",
            "Color",
            "defaultFGColor",
            "DefaultFGColor",
            q{Color(0)}
            ),
        
        PropSetting(
            "gs_w_d",
            "bool",
            "defaultBGColorEnabled",
            "DefaultBGColorEnabled",
            "true"
            ),
        PropSetting(
            "gs_w_d",
            "Color",
            "defaultBGColor",
            "DefaultBGColor",
            q{Color(cast(ubyte[3])[255,255,255])}
            ),
        
        ]
        );
    
    // NOTE: lines should remain here, not to be moved into State
    TextLine[] lines;
    
    mixin installSignal!("LinesRecalcRequired", "signal_linesRecalcRequired");
    mixin installSignal!("VisibilityMapRecalcRequired", "signal_visibilityMapRecalcRequired");
    mixin installSignal!("ImageRegenRequired", "signal_imageRegenRequired");
    
    this()
    {
        struct stname {
            string sname;
            string tname;
        }
        
        static foreach(
            v;
            [
            // stname("X", "ulong"),
            // stname("Y", "ulong"),
            stname("TextMarkupType", "TextMarkupType"),
            stname("LinesLayout", "GenVisibilityMapForSubitemsLayout"),
            stname("LineCharsLayout", "GenVisibilityMapForSubitemsLayout"),
            
            stname("FaceFamily", "string"),
            stname("FaceStyle", "string"),
            stname("FaceSize", "uint"),
            stname("FaceResolution", "uint"),
            
            stname("Bold", "bool"),
            stname("Italic", "bool"),
            stname("Underlined", "bool"),
            
            stname("DefaultFGColorEnabled", "bool"),
            stname("DefaultFGColor", "Color"),
            
            stname("DefaultBGColorEnabled", "bool"),
            stname("DefaultBGColor", "Color"),
            ]
            )
        {
            mixin(
                q{
                    pragma(msg, "connectTo%1$s_onAfterChanged");
                    con_cont.add(
                        connectTo%1$s_onAfterChanged(
                            delegate void (%2$s v1, %2$s v2) nothrow
                            {
                                collectException(
                                    signal_linesRecalcRequired.emit()
                                    );
                            }
                            )
                        );
                }.format(v.sname, v.tname));
        }
    }
    
    mixin getState!("text_view.text_states", TextViewState,);
    
    void recalculateWidthAndHeight(TextView text_view)
    {
    	
        auto state = getState(text_view);
        
        // foreach (sl; state.sublines)
        // {
        // sl.recalculateWidthAndHeight(text_view);
        // }
        //
        state.width = 0;
        state.height = 0;
        
        if (lines.length != 0)
        {
        	
            switch (getLinesLayout())
            {
            default:
                throw new Exception(
                    "getLinesLayout ",
                    to!string(getLinesLayout())
                    );
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    foreach (l; lines)
                    {
                        auto l_state = l.getState(text_view);
                        
                        {
                            auto w = l_state.width;
                            if (w > state.width)
                                state.width = w;
                        }
                        
                        state.height += l_state.height;
                    }
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                    foreach (l; lines)
                    {
                        auto l_state = l.getState(text_view);
                        
                        state.width += l_state.width;
                        
                        {
                            auto h = l_state.height;
                            if (h > state.height)
                                state.height = h;
                        }
                    }
                    break;
            }
        }
    }
    
    void setText(dstring txt)
    {
        lines = lines[0 .. 0];
        
        debug writeln("setText entering slicing loop");
        debug scope(exit)
        {
            signal_linesRecalcRequired.emit();
            writeln("setText exited slicing loop");
        }
        
        auto line_ended = false;
        
        /* int length */
        
        main_loop:
        while (true)
        {
            foreach (i,c; txt)
            {
                if (c == '\r')
                {
                    if (i == 0)
                    {
                        txt = txt[i+1 .. $];
                        continue main_loop;
                    }
                    if (i == txt.length -1)
                    {
                        break;
                    }
                }
                if (c == '\n')
                {
                    auto line = txt[0 .. i];
                    txt = txt[i+1 .. $];
                    auto tl = new TextLine(this);
                    tl.setText(line);
                    lines ~= tl;
                    continue main_loop;
                }
            }
            
            auto tl = new TextLine(this);
            tl.setText(txt);
            lines ~= tl;
            break;
        }
        
    }
    
    // the target of reprocess is to calculate Text width and height
    // in order to do so, each structural unit must have (or have recalculated)
    // it's width and height
    void reprocess(TextView text_view)
    {
        debug writeln("Text.reprocess called");
        
        // obviously, each character's size have to be known
        // in systems with freetype this also renders characters at once
        reprocessUnits(text_view);
        
        // disect Lines to Sublines
        recreateSublines(text_view);
        
        // sublines widths and heights necessary to know lines widths and
        // heights
        recalculateSublinesWidthsAndHeights(text_view);
        
        // lines widths and heights necessary to know text width and height
        recalculateLinesWidthsAndHeights(text_view);
        
        // do the final step
        recalculateWidthAndHeight(text_view);
    }
    
    void reprocessUnits(TextView text_view)
    {
        foreach (l; lines)
        {
            l.reprocessUnits(text_view);
        }
    }
    
    void recreateSublines(TextView text_view)
    {
        foreach (l; lines)
        {
            l.recreateSublines(text_view);
        }
    }
    
    void recalculateSublinesWidthsAndHeights(TextView text_view)
    {
        foreach (l; lines)
        {
            l.recalculateSublinesWidthsAndHeights(text_view);
        }
    }
    
    void recalculateLinesWidthsAndHeights(TextView text_view)
    {
        foreach (l; lines)
        {
            l.recalculateWidthAndHeight(text_view);
        }
    }
    
    // void reprocessText(TextView text_view)
    // {
    // }
    
    dstring getText()
    {
        debug writeln("dstring getText() ", this, " ", lines.length);
        dstring ret;
        
        if (lines.length == 0)
        {
            return ret;
        }
        
        ret = lines[0].getText();
        
        if (lines.length == 1)
        {
            return ret;
        }
        
        foreach (l; lines[1 .. $])
        {
            ret ~= "\n" ~ l.getText();
        }
        
        return ret;
    }
    
    dstring getText(ulong start, ulong stop)
    {
        bool first_found = false;
        ulong first_text_textchar;
        ulong first_text_textchar_index;
        
        bool last_found = false;
        ulong last_text_textchar;
        ulong last_text_textchar_index;
        
        bool searching_first = true;
        
        /* ulong prev_length = 0; */
        ulong calc_length = 0;
        
        {
            if (start > stop)
                throw new Exception("start is behind stop");
            auto l = getLength();
            if (start > l)
                throw new Exception("start is behind text length");
            if (stop > l)
                throw new Exception("stop is behind text length");
        }
        
        foreach (i, l; lines)
        {
            auto l_l = l.textchars.length;
            if (i < lines.length)
                l_l += 1; // add new line
            
            if (start < calc_length + l_l)
            {
                first_found = true;
                first_text_textchar = i;
                first_text_textchar_index = start - calc_length;
            }
            
            if (stop < calc_length + l_l)
            {
                last_found = true;
                last_text_textchar = i;
                last_text_textchar_index = stop - calc_length;
            }
            
            if (first_found && last_found)
                break;
            
            calc_length += l_l;
        }
        
        if (first_text_textchar == last_text_textchar)
        {
            return lines[first_text_textchar].getText(
                first_text_textchar_index,
                last_text_textchar_index + 1
                );
        }
        
        dstring ret;
        
        ret ~= lines[first_text_textchar].getText(first_text_textchar_index,
            lines[first_text_textchar].textchars.length);
        
        if (last_text_textchar - first_text_textchar > 1)
        {
            for (ulong i = first_text_textchar + 1; i < last_text_textchar; i++)
            {
                ret ~= "\n" ~ lines[i].getText();
            }
        }
        
        ret ~= "\n" ~ lines[last_text_textchar].getText(
            0,
            last_text_textchar_index
            );
        
        return ret;
    }
    
    void genVisibilityMap(
        ulong x, ulong y,
        ulong width, ulong height,
        TextView text_view,
        ElementVisibilityMap visibility_map
        )
    {
        debug writeln("genVisibilityMap at ", __LINE__);
        
        auto state = getState(text_view);
        
        genVisibilityMapForSubitems(
            state.width, state.height,
            
            x, y,
            width, height,
            
            getLinesLayout(),
            
            delegate ulong()
            {
                return lines.length;
            },
            delegate ulong(ulong subitem_index)
            {
                return lines[subitem_index].getState(text_view).width;
            },
            delegate ulong(ulong subitem_index)
            {
                return lines[subitem_index].getState(text_view).height;
            },
            delegate void(
                ulong subitem_index,
                ulong target_x, ulong target_y,
                ulong x, ulong y,
                ulong width, ulong height
                )
            {
                lines[subitem_index].genVisibilityMap(
                    subitem_index,
                    target_x, target_y,
                    x, y,
                    width, height,
                    text_view,
                    visibility_map
                    );
            }
            );
        
    }
    
    ulong getLength()
    {
        ulong ret;
        foreach (i, l; lines)
        {
            ret += l.textchars.length;
        }
        ret += lines.length - 1; // new line symbol count
        return ret;
    }
}

enum TextViewMode
{
    singleLine,
    multiLine,
    codeEditor,
}

class TextView
{
	
    mixin mixin_install_multiple_properties!(
        cast(PropSetting[])[
        PropSetting("gs_w_d", "ulong", "x", "X", "0"),
        PropSetting("gs_w_d", "ulong", "y", "Y", "0"),
        PropSetting("gs_w_d", "ulong", "width", "Width", "0"),
        PropSetting("gs_w_d", "ulong", "height", "Height", "0"),
        
        // TODO: text selection mechanism looks dumb
        PropSetting("gs_w_d", "bool", "text_selection_enabled", "TextSelectionEnabled", "true"),
        PropSetting("gs_w_d", "bool", "text_selected", "TextSelected", "false"),
        PropSetting("gs_w_d", "ulong", "selection_start", "TextSelectionStart", "0"),
        PropSetting("gs_w_d", "ulong", "selection_end", "TextSelectionEnd", "0"),
        
        PropSetting("gs_w_d", "bool", "cursor_enabled", "CursorEnabled", "false"),
        
        // NOTE: I think it's better not to create entire property for this
        // PropSetting("gs_w_d", "bool", "cursor_animation_iteration_visible", "CursorAnimationIterationVisible", "false"),
        
        PropSetting("gs_w_d", "ulong", "cursor_position_line", "CursorPositionLine", "0"),
        PropSetting("gs_w_d", "ulong", "cursor_position_column", "CursorPositionColumn", "0"),
        
        PropSetting("gs_w_d", "TextViewMode", "textViewMode", "TextViewMode", "TextViewMode.singleLine"),
        
        PropSetting("gs_w_d", "bool", "virtualWrapBySpace", "VirtualWrapBySpace", "true"),
        PropSetting("gs_w_d", "bool", "virtualWrapByChar", "VirtualWrapByChar", "true"),
        ]
        );
    
    // NOTE: this is instead of property
    bool cursor_animation_iteration_visible;
    
    // ulong cursor_position_line;
    // ulong cursor_position_column;
    //
    ElementVisibilityMapElement cursor_after;
    ElementVisibilityMapElement cursor_before;
    
    // Mode mode;
    //
    // bool getVirtualWrapBySpace();
    // bool getVirtualWrapByChar();
    
    Text text;
    
    FontMgrI delegate() getFontManager;
    
    TextCharViewState[TextChar] text_char_states;
    TextLineSublineViewState[TextLineSubline] text_line_subline_states;
    TextLineViewState[TextLine] text_line_states;
    TextViewState[Text] text_states;
    
    ElementVisibilityMap visibility_map;
    Image _rendered_image;
    
    bool linesRecalcRequired = true;
    bool visibilityMapRecalcRequired=true;
    bool imageRegenRequired = true;
    
    // this one is for Text object
    SignalConnection text_linesRecalcRequired_sc;
    // this one is for this object
    SignalConnectionContainer con_cont;
    
    Image getRenderedImage()
    {
        if (linesRecalcRequired)
        {
            debug writeln("linesRecalcRequired requested");
            getText().reprocess(this);
            linesRecalcRequired = false;
            visibilityMapRecalcRequired = true;
            imageRegenRequired = true;
        }
        
        if (visibilityMapRecalcRequired)
        {
            debug writeln("visibilityMapRecalcRequired requested");
            genVisibilityMap();
        }
        
        // genImage() uses visibilityMap to speed up rendering, so it must
        // be called after genVisibilityMap()
        if (imageRegenRequired)
        {
            debug writeln("imageRegenRequired requested");
            genImage();
        }
        
        return _rendered_image;
    }
    
    // Signal!(ulong, ulong, ulong, ulong) redrawRequest;
    mixin installSignal!(
        "PerformRedraw", "signal_perform_redraw",
        ulong,ulong, ulong, ulong,
        );
    
    this()
    {
    	
        struct stname {
            string sname;
            string tname;
        }
        
        static foreach(
            v;
            [
            // stname("X", "ulong"),
            // stname("Y", "ulong"),
            stname("Width", "ulong"),
            stname("Height", "ulong"),
            
            stname("TextViewMode", "TextViewMode"),
            stname("VirtualWrapBySpace", "bool"),
            stname("VirtualWrapByChar", "bool"),
            ]
            )
        {
            mixin(
                q{
                    pragma(msg, "connectTo%1$s_onAfterChanged");
                    con_cont.add(
                        connectTo%1$s_onAfterChanged(
                            delegate void (%2$s v1, %2$s v2) nothrow
                            {
                                linesRecalcRequired = true;
                            }
                            )
                        );
                }.format(v.sname, v.tname));
        }
        
        
        static foreach(
            v;
            [
            stname("X", "ulong"),
            stname("Y", "ulong"),
            // stname("Width", "ulong"),
            // stname("Height", "ulong"),
            ]
            )
        {
            mixin(
                q{
                    pragma(msg, "connectTo%1$s_onAfterChanged");
                    con_cont.add(
                        connectTo%1$s_onAfterChanged(
                            delegate void (%2$s v1, %2$s v2) nothrow
                            {
                                visibilityMapRecalcRequired = true;
                            }
                            )
                        );
                }.format(v.sname, v.tname));
        }
        
        setTextString("");
        
    }
    
    this(dstring txt)
    {
        setTextString(txt);
    }
    
    this(Text txt)
    {
        setText(txt);
    }
    
    // void on_text_requires_line_recalc() nothrow
    // {
    // linesRecalcRequired=true;
    // }
    //
    void setTextString(dstring txt = "")
    {
        if (text is null)
        {
            text = new Text();
        }
        
        text.setText(txt);
    }
    
    dstring getTextString()
    {
        dstring ret;
        
        if (text !is null)
        {
            ret = text.getText();
        }
        
        return ret;
    }
    
    void setText(dstring txt)
    {
        setTextString(txt);
    }
    
    void setText(Text txt)
    {
        text = txt;
        text_linesRecalcRequired_sc = text.connectTo_LinesRecalcRequired(
            delegate void() nothrow
            {
                linesRecalcRequired=true;
            }
            );
    }
    
    Text getText()
    {
        if (text is null)
            setTextString();
        return text;
    }
    
    void genVisibilityMap()
    {
        if (text is null)
            throw new Exception("text object is not set");
        
        this.visibility_map = null;
        
        auto visibility_map = new ElementVisibilityMap(this);
        
        auto x = getX();
        auto y = getY();
        auto width = getWidth();
        auto height = getHeight();
        
        debug writefln(
            "genVisibilityMap for %s %s %s %s",
            x,
            y,
            width,
            height,
            );
        
        text.genVisibilityMap(
            x,
            y,
            width,
            height,
            this,
            visibility_map
            );
        
        debug writefln(
            "genVisibilityMap length %s",
            visibility_map.elements.length
            );
        
        this.visibility_map=visibility_map;
        
        visibilityMapRecalcRequired = false;
        imageRegenRequired=true;
    }
    
    void drawElementVisibilityMapElement(ElementVisibilityMapElement e, bool emit)
    {
        auto chr_state = e.chr.getState(this);
        
        debug writefln("putting char to picture (%s): ", e);
        
        auto z = chr_state.resImg.getImage(
            getX(), getY(),
            e.width, e.height
            );
        
        // debug z.printImage();
        
        _rendered_image.putImage(
            e.target_x,
            e.target_y,
            z
            );
        
        if (emit)
            signal_perform_redraw.emit(e.target_x, e.target_y, e.width,  e.height);
    }
    
    void genImage()
    {
        if (text is null)
            throw new Exception("text object is not set");
        
        auto w = getWidth();
        auto h = getHeight();
        
        _rendered_image = new Image(w, h);
        
        debug writeln(
            "genImage visibility_map.elements.length ",
            visibility_map.elements.length
            );
        
        if (visibility_map !is null)
        {
            foreach (v; visibility_map.elements)
            {
                drawElementVisibilityMapElement(v, false);
            }
        }
        
        imageRegenRequired = false;
        
        signal_perform_redraw.emit(0, 0, w, h);
    }
    
    // void reprocess()
    // {
    // getText().reprocess(this);
    // genVisibilityMap();
    // }
    
    /* void printInfo()
    {
    getText().printInfo(this);
    } */
    
    void click(ulong x, ulong y)
    {
        debug writeln("processor clicked [", x, ":", y, "]");
        if (getCursorEnabled())
            changeCursorPosition(x, y);
    }
    
    void timer500ms_handle()
    {
        timer500ms_handle_cursor();
    }
    
    void timer500ms_handle_cursor_draw()
    {
    	
        ulong x;
        ulong y;
        ulong width;
        ulong height;
        
        const ulong cursor_width = 2;
        
        if (cursor_after is null && cursor_before is null)
            return;
        
        if (cursor_after !is null)
        {
            final switch(text.getLineCharsLayout())
            {
            case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                x = cursor_after.target_x+cursor_after.width;
                y = cursor_after.target_y;
                width = cursor_width;
                height = cursor_after.height;
                break;
            case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                x = cursor_after.target_x;
                y = cursor_after.target_y;
                width = cursor_width;
                height = cursor_after.height;
                break;
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                x = cursor_after.target_x;
                y = cursor_after.target_y+cursor_after.height;
                width = cursor_after.width;
                height = cursor_width;
            }
        }
        else
        {
            final switch(text.getLineCharsLayout())
            {
            case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                x = cursor_before.target_x+cursor_before.width;
                y = cursor_before.target_y;
                width = cursor_width;
                height = cursor_before.height;
                break;
            case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                x = cursor_before.target_x;
                y = cursor_before.target_y;
                width = cursor_width;
                height = cursor_before.height;
                break;
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                x = cursor_before.target_x;
                y = cursor_before.target_y+cursor_after.height;
                width = cursor_before.width;
                height = cursor_width;
            }
        }
        
        drawCursor(x,y,width,height);
        
        signal_perform_redraw.emit(x,y,width,height);
    }
    
    void drawCursor(ulong x,ulong y,ulong width,ulong height)
    {
        auto dot = ImageDot();
        dot.enabled=true;
        dot.intensivity=1;
        dot.color = Color(cast(ubyte[3])[255,0,0]);
        for (ulong i = x; i != x+width; i++)
        {
            for (ulong j = y; j != y+height; j++)
            {
                _rendered_image.setDot(x,y,dot);
            }
        }
    }
    
    void timer500ms_handle_cursor_clear() {
        if (cursor_before !is null)
            drawElementVisibilityMapElement(cursor_before, true);
        if (cursor_after !is null)
            drawElementVisibilityMapElement(cursor_after, true);
    }
    
    void timer500ms_handle_cursor()
    {
        if (!getCursorEnabled())
            return;
        
        if (cursor_animation_iteration_visible)
            timer500ms_handle_cursor_draw();
        else
            timer500ms_handle_cursor_clear();
    }
    
    void changeCursorPosition(ulong x, ulong y)
    {
        cursor_after = null;
        cursor_before = null;
        auto el_clicked = determineVisibleElementAt(x,y);
        
        if (el_clicked[0] is null)
            return;
        
        setCursorPositionLine(el_clicked[0].line);
        
        bool add_one_char;
        
        final switch(text.getLineCharsLayout())
        {
        case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
            if (el_clicked[1] == ElementVisibilityMapElementClickLeanH.right)
                add_one_char = true;
            break;
        case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
            if (el_clicked[1] == ElementVisibilityMapElementClickLeanH.left)
                add_one_char = true;
            break;
        case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
            if (el_clicked[2] == ElementVisibilityMapElementClickLeanV.bottom)
                add_one_char = true;
            break;
        case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
            if (el_clicked[2] == ElementVisibilityMapElementClickLeanV.bottom)
                add_one_char = true;
            break;
        }
        
        setCursorPositionColumn(el_clicked[0].line_char);
        cursor_before = el_clicked[0];
        if (add_one_char)
            cursor_after = cursor_before;
        cursor_before = null;
        setCursorPositionColumn(getCursorPositionColumn()+1);
        
        cursor_animation_iteration_visible=true;
    }
    
    Tuple!(
        ElementVisibilityMapElement,
        ElementVisibilityMapElementClickLeanH,
        ElementVisibilityMapElementClickLeanV
        )
    determineVisibleElementAt(ulong x, ulong y)
    {
        auto fail_res = tuple(
            cast(ElementVisibilityMapElement) null,
            cast(ElementVisibilityMapElementClickLeanH)0,
            cast(ElementVisibilityMapElementClickLeanV)0,
            );
        
        if (visibility_map is null)
            return fail_res;
        
        foreach (v; visibility_map.elements)
        {
            if (
                (x >= v.target_x && x <= v.target_x+v.width)
            &&
            (y >= v.target_y && y <= v.target_y+v.height)
            )
            {
                auto lh = ElementVisibilityMapElementClickLeanH.left;
                auto lv = ElementVisibilityMapElementClickLeanV.top;
                
                if (x >= v.target_x+(v.width/2))
                    lh = ElementVisibilityMapElementClickLeanH.right;
                if (y >= v.target_y+(v.height/2))
                    lv = ElementVisibilityMapElementClickLeanV.bottom;
                return tuple(v,lh,lv);
            }
        }
        
        return fail_res;
    }
    
}

enum ElementVisibilityMapElementClickLeanH : ubyte
{
    left,
    right,
}

enum ElementVisibilityMapElementClickLeanV : ubyte
{
    top,
    bottom,
}


mixin template getState(string state_container, alias state_type)
{
    mixin(q{
            state_type getState(TextView text_view)
            {
                state_type state;
                
                if (this !in %1$s) {
                    state = new state_type();
                    %1$s[this] = state;
                } else {
                    state = %1$s[this];
                }
                
                return state;
            }
    }.format(state_container)
    );
}

class ElementVisibilityMapElement
{
    ElementVisibilityMap map;
    TextChar chr;
    
    ulong line;
    ulong line_char;
    
    ulong target_x;
    ulong target_y;
    ulong x;
    ulong y;
    ulong width;
    ulong height;
}

class ElementVisibilityMap
{
    TextView textview;
    
    ElementVisibilityMapElement[] elements;
    
    this(TextView textview)
    {
        this.textview = textview;
    }
}
