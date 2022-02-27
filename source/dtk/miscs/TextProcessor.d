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
import dtk.interfaces.WindowI;
import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FaceI;

import dtk.types.Image;
import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.fontinfo;
import dtk.types.Property;
import dtk.types.EventKeyboard;

import dtk.widgets.Form;

import dtk.miscs.signal_tools;



enum GenVisibilityMapForSubitemsLayout
{
    horizontalLeftToRightAlignTop, // russian, english chars
    verticalTopToBottomAlignLeft, // russian, english, hebrew lines
    horizontalRightToLeftAlignTop, // hebrew chars, japanese lines
    verticalTopToBottomAlignRight, // japanese chars
}

// max_width, max_height - defines page size
// x,y,width,height - selects visible frame form the page
// NOTE: this function does not calculate wrapping. wrapping is based on
//       lines and sublines sizes done by Text.reprocess() and it's subcalls
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
        ulong width, ulong height,
        bool its_the_last_visible_item
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
        ulong items_count = last_visible_item - first_visible_item+1;
        
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
                for (ulong j = 0; j != i; j++)
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
                    return getSubitemWidth(first_visible_item + i)
                - first_visible_item_offset;
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
                for (ulong j = 0; j != i; j++)
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
                    return getSubitemHeight(first_visible_item + i)
                - first_visible_item_offset;
                return getSubitemHeight(first_visible_item + i);
            };
            break;
        }
        
        for (ulong i = 0; i != items_count; i++)
        {
            auto tx = calc_loop_target_x(i);
            auto ty = calc_loop_target_y(i);
            auto sx = calc_loop_source_x(i);
            auto sy = calc_loop_source_y(i);
            auto sw = calc_loop_source_width(i);
            auto sh = calc_loop_source_height(i);
            
            genVisibilityMapForSubitem(
                i,
                tx,
                ty,
                sx, sy,
                sw, sh,
                i == items_count-1
                );
        }
    }
    
    return;
}

class TextCharViewState
{
    GlyphRenderResult* glyph;
    Image resImg;
    // TextLineSubline subline;
}

class TextChar
{
	// TODO: probably this should be replaced with function which throws if line
	//       isn't in text.lines
    TextLine parent_line;
    
    dchar chr;
    
    this(TextLine parent_line)
    {
        this.parent_line = parent_line;
    }
    
    mixin getState!("text_view.text_char_states", TextCharViewState);
    
    ulong getWidth(TextView text_view)
    {
        return getState(text_view).resImg.width;
    }
    
    ulong getHeight(TextView text_view)
    {
        return getState(text_view).resImg.height;
    }
    
    void reprocess(TextView text_view)
    {
        auto state = getState(text_view);
        if (state.glyph is null)
        {
            auto err = collectException(loadGlyph(text_view, chr));
            if (err !is null)
            {
                // TODO: draw replacement
                err = collectException(loadGlyph(text_view, cast(dchar)'?'));
                if (err !is null)
                {
                    // NOTE: considering this fatal error
                    throw err;
                }
            }
            state.resImg = genImage(text_view);
        }
    }
    
    /* alias reprocess = rerender; */
    
    private void loadGlyph(TextView text_view, dchar chr)
    {
        auto state = getState(text_view);
        
        auto f_family = parent_line.parent_text.getFaceFamily();
        auto f_style = parent_line.parent_text.getFaceStyle();
        FaceI face;
        
        auto font_mgr = text_view.getFontManager();
        
        label1:
        auto err = collectException(
            {
                face = font_mgr.loadFace(f_family, f_style);
            }()
            );
        if (err !is null)
        {
            // TODO: better solution required to case if font not found
            if (f_family == "Go")
                throw err;
            f_family = "Go";
            f_style = "Regular";
            goto label1;
        }
        {
            auto x = parent_line.parent_text.getFaceSize();
            face.setCharSize(x, x);
        }
        {
            auto x = parent_line.parent_text.getFaceResolution();
            face.setCharResolution(x, x);
        }
        
        try
        {
            state.glyph = face.renderGlyphByChar(chr);
        }
        catch (Exception e)
        {
            // TODO: replace with dummy glyph
            state.glyph = face.renderGlyphByChar(cast(dchar)'?');
        }
        
    }
    
    private Image genImage(TextView text_view) {
    	
        auto layout = parent_line.parent_text.getLineCharsLayout();
        
        auto state = getState(text_view);
        
        // if (state.glyph is null)
        // {
        // loadGlyph(text_view, chr);
        // }
        
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
        
        return ret;
    }
    
    TextLine calcLine()
    {
        // TODO: maybe it must be exception, if line not text.lines
        return parent_line;
    }
    
    ulong calcLineIndex()
    {
        auto lines = parent_line.parent_text.lines;
        foreach (i, v; lines)
        {
            if (v == parent_line)
            {
                return i;
            }
        }
        throw new Exception("line not found");
    }
    
    ulong calcLineColumnIndex()
    {
        auto textchars = parent_line.textchars;
        foreach (ulong i, v ; textchars)
        {
            if (v == this)
            {
                return i;
            }
        }
        throw new Exception("char not found");
    }
    
    Tuple!(TextLine, ulong) calcLineAndColumnIndex()
    {
        auto textchars = parent_line.textchars;
        foreach (ulong i, v ; textchars)
        {
            if (v == this)
            {
                return tuple(parent_line, i);
            }
        }
        throw new Exception("char not found");
    }
    
    ulong calcSublineIndex(TextView text_view)
    {
        auto line_state = parent_line.getState(text_view);
        auto this_subline = calcSubline(text_view);
        foreach (ulong i, v ; line_state.sublines)
        {
            if (v == this_subline)
            {
                return i;
            }
        }
        throw new Exception("subline not found");
    }
    
    ulong calcSublineColumnIndex(TextView text_view)
    {
        auto this_state = getState(text_view);
        auto this_subline = calcSubline(text_view);
        auto textchars = this_subline.getState(text_view).textchars;
        foreach (ulong i, v ; textchars)
        {
            if (v == this)
            {
                return i;
            }
        }
        throw new Exception("subline column not found");
    }
    
    TextLineSubline calcSubline(TextView text_view)
    {
        foreach (subline;parent_line.getState(text_view).sublines)
        {
            foreach(loc_chr; subline.getState(text_view).textchars)
            {
                if (loc_chr == this)
                {
                    return subline;
                }
            }
        }
        
        throw new Exception("char not found in text line sublines");
    }
    
    // firs ret value for "ok?"
    TextChar calcPrevCharInSubline(TextView text_view, bool search_prev=true)
    {
        auto fail_res = cast(TextChar) null;
        auto subline = calcSubline(text_view);
        auto textchars = subline.getState(text_view).textchars;
        foreach (i, loc_chr ; textchars)
        {
            if (loc_chr == this)
            {
                if (i==(search_prev ? 0 : textchars.length-1))
                {
                    return fail_res;
                }
                else
                {
                    return (search_prev ? textchars[i-1]:textchars[i+1]);
                }
            }
        }
        return fail_res;
    }
    
    TextChar calcNextCharInSubline(TextView text_view)
    {
        return calcPrevCharInSubline(text_view, false);
    }
    
    TextChar calcPrevCharInLine(bool search_prev=true)
    {
        auto fail_res = cast(TextChar) null;
        auto textchars = parent_line.textchars;
        foreach (i, loc_chr ; textchars)
        {
            if (i==(search_prev ? 0 : textchars.length-1))
            {
                return fail_res;
            }
            else
            {
                return (search_prev ? textchars[i-1]:textchars[i+1]);
            }
        }
        return fail_res;
    }
    
    TextChar calcNextCharInLine()
    {
        return calcPrevCharInLine(false);
    }
}

class TextLineSublineViewState
{
    TextChar[] textchars;
    ulong width;
    ulong height;
    // TextChar prev_char;
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
    
    ulong getWidth(TextView text_view)
    {
        return getState(text_view).width;
    }
    
    ulong getHeight(TextView text_view)
    {
        return getState(text_view).height;
    }
    
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
            	if (state.textchars.length != 0)
            	{
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
                }
                else
                {
                	state.height = parent_line.parent_text.getFaceSize()/64;
                }
                break;
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
            	if (state.textchars.length != 0)
            	{
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
                }
                else
                {
                	state.width = parent_line.parent_text.getFaceSize()/64;
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
                return state.textchars[subitem_index].getWidth(text_view);
            },
            
            delegate ulong(ulong subitem_index)
            {
                return state.textchars[subitem_index].getHeight(text_view);
            },
            
            delegate void(
                ulong subitem_index,
                ulong target_x, ulong target_y,
                ulong x, ulong y,
                ulong width, ulong height,
                bool its_the_last_visible_item
                )
            {
                auto evme = new ElementVisibilityMapElement();
                
                evme.map = visibility_map;
                evme.chr = state.textchars[subitem_index];
                
                // evme.line=this_line_index;
                // evme.column=this_line_done_chars_count + subitem_index;
                
                // evme.eovl = its_the_last_visible_item;
                
                evme.target_x=sublines_target_x + target_x;
                evme.target_y=sublines_target_y + target_y;
                evme.x=x;
                evme.y=y;
                evme.width=width;
                evme.height=height;
                
                visibility_map.elements ~= evme;
            }
            );
        return ;
    }
    
    TextLine calcLine()
    {
        // TODO: maybe it must be exception, if line not text.lines
        return parent_line;
    }
    
    ulong calcLineIndex()
    {
        auto lines = parent_line.parent_text.lines;
        foreach (i, v; lines)
        {
            if (v == parent_line)
            {
                return i;
            }
        }
        throw new Exception("line not found");
    }
    
    ulong calcLineColumnIndex()
    {
        auto textchars = parent_line.textchars;
        foreach (ulong i, v ; textchars)
        {
            if (v == this)
            {
                return i;
            }
        }
        throw new Exception("char not found");
    }
    
    Tuple!(TextLine, ulong) calcLineAndColumnIndex()
    {
        auto textchars = parent_line.textchars;
        foreach (ulong i, v ; textchars)
        {
            if (v == this)
            {
                return tuple(parent_line, i);
            }
        }
        throw new Exception("char not found");
    }
    
    ulong calcSublineIndex(TextView text_view)
    {
        auto line_state = parent_line.getState(text_view);
        foreach (ulong i, v ; line_state.sublines)
        {
            if (v == this)
            {
                return i;
            }
        }
        throw new Exception("subline not found");
    }
    
    TextLineSubline calcNextSubline(TextView text_view, bool prev=false)
    {
    	auto line = calcLine();
    	auto line_state = line.getState(text_view);
    	auto line_sublines = line_state.sublines;
    	auto line_index = calcLineIndex();
    	auto subline_index = calcSublineIndex(text_view);
    	auto lines = parent_line.parent_text.lines;
    	
    	TextLine new_line;
    	TextLineSubline new_subline;
    	
    	if (subline_index == (prev ? 0 : line_sublines.length-1))
    	{
    		if (line_index == (prev ? 0 : lines.length-1))
    		{
    			return null;
    		}
    		else
    		{
    			(prev ? line_index--: line_index++);
    			line = lines[line_index];
    			line_sublines = line.getState(text_view).sublines;
    			return line_sublines[(prev ? line_sublines.length -1 : 0)];
    		}
    	}
    	else
    	{
    		(prev ? subline_index--: subline_index++);
    		return line_sublines[subline_index];
    	}
    }
    
    TextLineSubline calcPrevSubline(TextView text_view)
    {
    	return calcNextSubline(text_view, true);
    }
    
    // TextChar getPrevChar(TextView text_view)
    // {
    // auto state = getState(text_view);
    // return state.prev_char();
    // }
    
    TextChar calcCharBeforeEOVL(TextView text_view, bool across_line=false)
    {
    	auto subline = this;
    	auto subline_state = subline.getState(text_view);
    	auto subline_textchars = subline_state.textchars;
    	
    	continue_search:
    	while (true)
    	{
    		if (subline_textchars.length != 0)
    		{
    			return subline_textchars[$-1];
    		}
    		subline = subline.calcPrevSubline(text_view);
    		if (subline is null)
    		{
    			break;
    		}
    		subline_state = subline.getState(text_view);
    		subline_textchars = subline_state.textchars;
    	}
    	
    	if (across_line)
    	{
    		auto line = subline.calcLine().calcPrevLine();
    		if (line is null) {
    			return null;
    		}
    		subline = line.getState(text_view).sublines[$-1];
    		subline_state =  subline.getState(text_view);
    		subline_textchars = subline_state.textchars;
    		
    		goto continue_search;
    	}
    	
    	return null;
    }
    
    // TextChar calcNextCharInLine(TextView text_view)
    // {
    // auto line = calcLine();
    // auto line_sublines = line.getState(text_view).sublines;
    // auto subline_index = calcSublineIndex(text_view);
    // if (subline_index == line_sublines.length-1)
    // {
    // return null;
    // }
    // return line_sublines();
    // }
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
    
    ulong getLength()
    {
        auto ret = textchars.length;
        
        // all lines, except the last one, assumed to have \n in the end
        if (parent_text.lines.length != 0 && parent_text.lines[$-1] != this)
        {
            ret++;
        }
        return  ret;
    }
    
    void setText(dstring txt)
    {
        /* auto state = getState(); */
        
        textchars = textchars[0 .. 0];
        /* sublines = sublines[0 .. 0]; */
        
        foreach (c; txt)
        {
            if (c == cast(dchar) '\n' || c == cast(dchar) '\r')
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
        scope(exit)
        {
            // line must always have at least one subline
            if (state.sublines.length == 0)
            {
                state.sublines ~= new TextLineSubline(this);
            }
        }
        
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
        
        foreach (tc; textchars)
        {
            ulong s;
            
            // auto tc_state = tc.getState(text_view);
            
            switch (parent_text.getLineCharsLayout())
            {
            default:
                throw new Exception(
                    "not supported parent_text.getLineCharsLayout ",
                    to!string(parent_text.getLineCharsLayout())
                    );
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    s = tc.getWidth(text_view);
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                    s = tc.getHeight(text_view);
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
            { // TODO: at least 1 char should be in subline before wrapping
            	TextChar prev_char=state.sublines[$-1].getState(text_view).textchars[$-1];
                state.sublines ~= new TextLineSubline(this);
                current_line++;
                sl = state.sublines[current_line];
                sl_state = sl.getState(text_view);
                // sl_state.prev_char=prev_char;
                current_size = s;
            }
            else
            {
                current_size += s;
            }
            
            sl_state.textchars ~= tc;
            // tc_state.subline = sl;
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
                        
                        state.width += sl_state.width;
                        
                        {
                            auto h = sl_state.height;
                            if (h > state.height)
                                state.height = h;
                        }
                    }
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
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
                ulong width, ulong height,
                bool its_the_last_visible_item
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
    
    ulong calcSublinesCount(TextView text_view)
    {
        auto state = getState(text_view);
        return state.sublines.length;
    }
    
    ulong calcLineIndex()
    {
    	foreach (ulong i, v; parent_text.lines)
    	{
    		if (v == this)
    		{
    			return i;
    		}
    	}
    	throw new Exception("this line is not in text's lines");
    }
    
    TextLine calcNextLine(bool prev=false)
    {
    	auto line_index = calcLineIndex();
    	if (line_index == (prev ? 0 : parent_text.lines.length-1))
    	{
    		return null;
    	}
    	else
    	{
    		return parent_text.lines[(prev ? line_index-1 : line_index+1)];
    	}
    }
    
    TextLine calcPrevLine()
    {
    	return calcNextLine(true);
    }
    
    CursorPosition makeEOLCursor(TextView text_view)
    {
    	auto state = getState(text_view);
    	auto new_cursor = new CursorPosition();
    	new_cursor.subline = state.sublines[$-1];
    	return new_cursor;
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

const auto TextProperties = cast(PropSetting[]) [
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

PropSetting("gs_w_d", "string", "faceFamily", "FaceFamily", q{"Go"}),
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
];

class Text
{
    SignalConnectionContainer con_cont;
    
    // NOTE: lines should remain here, not to be moved into State
    TextLine[] lines;
    
    mixin mixin_installSignal!(
    	"LinesRecalcRequired", 
    	"signal_linesRecalcRequired",
    	false,
    	);
    mixin mixin_installSignal!(
    	"VisibilityMapRecalcRequired", 
    	"signal_visibilityMapRecalcRequired",
    	false,
    	);
    mixin mixin_installSignal!(
    	"ImageRegenRequired", 
    	"signal_imageRegenRequired",
    	false,
    	);
    
    mixin mixin_multiple_properties_define!(TextProperties);
    mixin mixin_multiple_properties_forward!(TextProperties, false);
    
    this()
    {
    	
    	mixin(mixin_multiple_properties_inst(TextProperties));
    	
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
        
        scope(exit)
        {
            signal_linesRecalcRequired.emit();
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
                ulong width, ulong height,
                bool its_the_last_visible_item
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
    
    bool isLineEmpty(ulong line)
    {
        return getTextLine(line).textchars.length == 0;
    }
    
    bool isEOL(
        ulong line, ulong column
        )
    {
        return getTextLine(line).textchars.length == column;
    }
    
    TextLine getTextLine(
        ulong line
        )
    {
        return lines[line];
    }
    
    TextChar getTextLineChar(
        ulong line, ulong column
        )
    {
        return getTextLine(line).textchars[column];
    }
    
    bool isEOL(
        ulong line, ulong subline, ulong subline_column,
        TextView text_view
        )
    {
        return getTextLineSubline(line, subline, text_view).getState(text_view)
        .textchars.length == subline_column
        && getTextLine(line).getState(text_view).sublines.length-1 == subline;
    }
    
    bool isEOSL(
        ulong line, ulong subline, ulong subline_column,
        TextView text_view
        )
    {
        return getTextLineSubline(line, subline, text_view).getState(text_view)
        .textchars.length == subline_column;
    }
    
    TextLineSubline getTextLineSubline(
        ulong line, ulong subline,
        TextView text_view
        )
    {
        return getTextLine(line).getState(text_view).sublines[subline];
    }
    
    TextChar getTextLineSublineChar(
        ulong line, ulong subline, ulong column,
        TextView text_view
        )
    {
        return getTextLineSubline(line, subline, text_view)
        .getState(text_view).textchars[column];
    }
    
    // void concatLines(TextLine line_to_stay, TextLine line_to_delete)
    // {
    // }
    
    void deleteLine(TextLine line)
    {
    	auto line_index = line.calcLineIndex();
    	lines = lines[0 .. line_index] ~ lines[line_index+1 .. $];
    }
}

class CursorPosition
{
    // chr may be null if cursor on virtual entity
    TextChar chr;
    TextLineSubline subline;
    
    bool atEOL()
    {
    	return chr is null;
    }
    
    bool atEOVL(TextView text_view)
    {
    	if (atEOL())
    		return true;
    	
    	auto next_chr = chr.calcNextCharInSubline(text_view);
    	if (next_chr is null)
    	{
    		// debug writeln("no more chars in subline");
    		return false;
    	}
    	
    	if (text_view.visibility_map is null)
    		throw new Exception("text_view.visibility_map is null");
    	
    	foreach (v; text_view.visibility_map.elements)
    	{
    		if (v.chr == next_chr)
    			return false;
    	}
    	
    	debug writeln("chr ", next_chr.chr, " is not in visibility map");
    	
    	return true;
    }
}

enum TextViewMode
{
    singleLine,
    multiLine,
    codeEditor,
}

const auto TextViewProperties = cast(PropSetting[]) [
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

//PropSetting("gs_w_d", "ulong", "cursor_position_line", "CursorPositionLine", "0"),
//PropSetting("gs_w_d", "ulong", "cursor_position_column", "CursorPositionColumn", "0"),

PropSetting("gs_w_d", "bool", "readOnly", "ReadOnly", "false"),

PropSetting("gs_w_d", "TextViewMode", "textViewMode", "TextViewMode", "TextViewMode.singleLine"),

PropSetting("gs_w_d", "bool", "virtualWrapBySpace", "VirtualWrapBySpace", "true"),
PropSetting("gs_w_d", "bool", "virtualWrapByChar", "VirtualWrapByChar", "true"),
];

class TextView
{
	
	mixin mixin_multiple_properties_define!(TextViewProperties);
    mixin mixin_multiple_properties_forward!(TextViewProperties, false);
    
    // NOTE: this is instead of property
    bool cursor_animation_iteration_visible;
    
    CursorPosition[] cursor_positions;
    
    Text text;
    
    Form delegate() getForm;
    DrawingSurfaceI delegate() getDrawingSurface;
    bool delegate() isFocused;
    
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
    
    SignalConnection timer500_signal_connection;
    ubyte skip_cursor_clears;
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(TextViewProperties));
    	
        struct stname {
            string sname;
            string tname;
        }
        
        static foreach(
            v;
            [
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
        this();
        setTextString(txt);
    }
    
    this(Text txt)
    {
        this();
        setText(txt);
    }
    
    
    PlatformI getPlatform()
    {
        return getWindow().getPlatform();
    }
    
    WindowI getWindow()
    {
        assert(getForm !is null);
        return getForm().getWindow();
    }
    
    FontMgrI getFontManager()
    {
        return getPlatform().getFontManager();
    }
    
    void reprocess()
    {
        if (linesRecalcRequired)
        {
            getText().reprocess(this);
            linesRecalcRequired = false;
            visibilityMapRecalcRequired = true;
            imageRegenRequired = true;
        }
        
        if (visibilityMapRecalcRequired)
        {
            genVisibilityMap();
        }
        
        // genImage() uses visibilityMap to speed up rendering, so it must
        // be called after genVisibilityMap()
        if (imageRegenRequired)
        {
            genImage();
        }
    }
    
    Image getRenderedImage()
    {
    	reprocess();
        return _rendered_image;
    }
    
    void completeRedrawToDS(DrawingSurfaceI ds=null)
    {
    	if (ds is null)
    		ds = getDrawingSurface();
        ulong x;
        ulong y;
        ulong width;
        ulong height;
        
        x = getX();
        y = getY();
        width = getWidth();
        height = getHeight();
        
        drawImageToDrawingSurface(x,y,width,height,ds);
    }
    
    // TODO: move this to some more appropriate place
    private ubyte chanBlend(ubyte lower, ubyte higher, real part)
    {
        return cast(ubyte)(lower + ((higher - lower) * part));
    }
    
    void drawImageToDrawingSurface(
        ulong target_x,
        ulong target_y,
        ulong width,
        ulong height,
        DrawingSurfaceI ds
        )
    {
    	if (ds is null)
    		ds = getDrawingSurface();
        auto image = getRenderedImage();
        
        auto p = Position2D(cast(int)target_x,cast(int)target_y);
        auto i = image.getImage(p, Size2D(cast(int)width, cast(int)height));
        ds.drawImage(p, i);
        
        if (ds.canPresent())
        	ds.present();
    }
    
    void ensureTimer500Connection()
    {
        // TODO: maybe mutexes and synchronization have to be used here
        if (!timer500_signal_connection.connected)
        {
            auto p = getPlatform();
            timer500_signal_connection = p.connectToSignal_Timer500(
                delegate void() nothrow{
                    collectException(
                        {
                            auto err = collectException(timer500ms_handle());
                            if (err !is null)
                            {
                                writeln("error handling timer500: ", err);
                            }
                        }()
                        );
                }
                );
        }
    }
    
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
        text_linesRecalcRequired_sc = text.connectToSignal_LinesRecalcRequired(
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
        
        text.genVisibilityMap(
            x,
            y,
            width,
            height,
            this,
            visibility_map
            );
        
        this.visibility_map=visibility_map;
        
        visibilityMapRecalcRequired = false;
        imageRegenRequired=true;
    }
    
    void drawElementVisibilityMapElement(
        ElementVisibilityMapElement e,
        bool redrawOnImage,
        bool copyToDS
        )
    {
        auto chr_state = e.chr.getState(this);
        
        if (redrawOnImage)
        {
        	
            // NOTE: it is intended what character raster doesn't know anything
            //       about color yet, and knows only intensivity, so color
            //       information is required.
            //       maybe in future caharacter images will be with color
            //       already at this point.
            auto fg_color = text.getDefaultFGColor();
            
            auto chr_image = chr_state.resImg.getImage(
                e.x, e.y,
                e.width, e.height
                );
            
            // auto tv_x = getX();
            // auto tv_y = getY();
            
            for (ulong y = 0; y < chr_image.height; y++)
            {
                for (ulong x = 0; x < chr_image.width; x++)
                {
                    auto bg_dot = _rendered_image.getDot(
                        e.target_x+x,
                        e.target_y+y
                        );
                    auto fg_dot = chr_image.getDot(x, y);
                    if (fg_dot.enabled)
                    {
                    	
                        auto bg_color = bg_dot.color;
                        // auto fg_color = fg_dot.color;
                        
                        Color new_color;
                        
                        auto part = fg_dot.intensivity;
                        new_color.r = chanBlend(bg_color.r, fg_color.r, part);
                        new_color.g = chanBlend(bg_color.g, fg_color.g, part);
                        new_color.b = chanBlend(bg_color.b, fg_color.b, part);
                        
                        auto id = ImageDot();
                        id.enabled=true;
                        id.intensivity=1;
                        id.color = new_color;
                        
                        _rendered_image.drawDot(
                            Position2D(
                                cast(int)(x+e.target_x),
                                cast(int)(y+e.target_y)
                                ),
                            id
                            );
                    }
                    else
                    {
                        _rendered_image.drawDot(
                            Position2D(
                                cast(int)(x+e.target_x),
                                cast(int)(y+e.target_y)
                                ),
                            bg_dot
                            );
                    }
                }
            }
            
        }
        
        if (copyToDS)
        drawImageToDrawingSurface(
            e.target_x,
            e.target_y,
            e.width,
            e.height,
            null
            );
    }
    
    void genImage()
    {
        if (text is null)
            throw new Exception("text object is not set");
        
        auto w = getWidth();
        auto h = getHeight();
        
        _rendered_image = new Image(w, h);
        
        {
            auto bg_dot = ImageDot();
            bg_dot.enabled=true;
            bg_dot.intensivity=1;
            bg_dot.color = text.getDefaultBGColor();
            
            for (ulong y = 0; y != h; y++)
            {
                for (ulong x = 0; x != w; x++)
                {
                    _rendered_image.drawDot(
                        Position2D(
                            cast(int)x,
                            cast(int)y
                            ),
                        bg_dot
                        );
                }
            }
        }
        
        if (visibility_map !is null)
        {
            foreach (v; visibility_map.elements)
            {
                drawElementVisibilityMapElement(v, true, false);
            }
        }
        
        imageRegenRequired = false;
        
        // drawImageToDrawingSurface(0, 0, w, h);
    }
    
    void timer500ms_handle()
    {
        timer500ms_handle_cursor();
    }
    
    void cursorMakeLongerVisible()
    {
    	skip_cursor_clears = 3;
    	cursor_animation_iteration_visible = true;
    }
    
    void timer500ms_handle_cursor()
    {
        if (!getCursorEnabled())
        {
            if (cursor_animation_iteration_visible == false)
                goto exit;
            else
                goto force_clear;
        }
        
        if (!isFocused())
        {
            if (cursor_animation_iteration_visible == false)
                goto exit;
            else
                goto force_clear;
        }
        
        goto normal_work;
        
        force_clear:
        cursor_animation_iteration_visible = false;
        
        normal_work:
        
        if (skip_cursor_clears > 0)
        {
        	timer500ms_handle_cursor_draw_operation(false);
        	skip_cursor_clears--;
        }
        else
        {
        	if (cursor_animation_iteration_visible)
        	{
        		timer500ms_handle_cursor_draw_operation(true);
        	}
        	else {
        		timer500ms_handle_cursor_draw_operation(false);
        	}
        }
        
        cursor_animation_iteration_visible =
        !cursor_animation_iteration_visible;
        
        exit:
    }
    
    void timer500ms_handle_cursor_draw_operation(bool clear)
    {
    	
        CursorPosition cusor_pos;
        
        ulong x;
        ulong y;
        ulong width;
        ulong height;
        
        if (visibility_map is null)
        {
            debug writeln("visibility_map is null");
            return;
        }
        
        if (cursor_positions.length == 0)
        {
            debug writeln("cursor_positions.length == 0");
            return;
        }
        
        cusor_pos = cursor_positions[$-1];
        
        auto res = calculateVisibleCursor(cusor_pos);
        if (res[0] == false)
        {
            debug writeln("res[0] == false");
            return;
        }
        
        if (!clear)
            drawCursor(res[1], res[2], res[3], res[4]);
        else
            clearCursor(res[1], res[2], res[3], res[4]);
    }
    
    void drawCursor(ulong x,ulong y,ulong width,ulong height)
    {
        auto ds = getDrawingSurface();
        
        auto dot = ImageDot();
        dot.enabled=true;
        dot.intensivity=1;
        dot.color = Color(cast(ubyte[3])[0,0,0]);
        
        // auto color = Color(cast(ubyte[3])[255,0,0]);
        
        for (ulong i = x; i != x+width; i++)
        {
            for (ulong j = y; j != y+height; j++)
            {
                ds.drawDot(Position2D(cast(int)i,cast(int)j),dot);
            }
        }
        
        ds.present();
    }
    
    void clearCursor(CursorPosition cp)
    {
        auto res = calculateVisibleCursor(cp);
        if (!res[0])
            return;
        clearCursor(res[1], res[2], res[3], res[4]);
    }
    
    void clearCursor(ulong x,ulong y,ulong width,ulong height) {
        drawImageToDrawingSurface(x, y, width, height, null);
    }
    
    Tuple!(bool, ulong, ulong, ulong, ulong) calculateVisibleCursor(
        CursorPosition cursor_pos
        )
    {
        debug {
            write("calculateVisibleCursor:", );
            if (cursor_pos.chr is null)
                writeln("null");
            else
                writeln(cursor_pos.chr.chr);
            writeln("    atEOL:", cursor_pos.atEOL());
            writeln("   atEOVL:", cursor_pos.atEOVL(this));
        }
        
        auto fail_res = tuple(false, 0UL,0UL,0UL,0UL);
        
        ulong x;
        ulong y;
        ulong width;
        ulong height;
        
        if (visibility_map is null)
            return fail_res;
        
        assert(cursor_pos.subline !is null, "cursor_pos.subline must never be null");
        
        if (cursor_pos.atEOVL(this))
        {
        	ElementVisibilityMapElement last;
        	bool subline_started;
        	// bool subline_ended;
        	foreach (ve; visibility_map.elements)
        	{
        		auto ve_subline = ve.chr.calcSubline(this);
        		if (ve_subline == cursor_pos.subline)
        		{
        			if (!subline_started)
        			{
        				subline_started = true;
        			}
        			
        			last = ve;
        		} else {
        			if (subline_started)
        			{
        				// subline_ended = true;
        				break;
        			}
        		}
        	}
        	
        	if (last is null)
        	{
        		debug writeln("calculateVisibleCursor: last is null");
        		return fail_res;
        	}
        	
        	final switch(text.getLineCharsLayout())
        	{
        	case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
        		x = last.target_x+last.width;
        		y = last.target_y;
        		width = 1;
        		height = last.height;
        		break;
        	case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
        		x = last.target_x;
        		y = last.target_y;
        		width = 1;
        		height = last.height;
        		break;
        	case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
        	case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
        		x = last.target_x;
        		y = last.target_y+last.height;
        		width = last.width;
        		height = 1;
        		break;
        	}
        	
        	return tuple(true, x,y,width,height);
        }
        
        if (cursor_pos.chr is null)
        {
            debug writeln("calculateVisibleCursor: cursor_pos.chr is null");
            return fail_res;
        }
        
        foreach (v; visibility_map.elements)
        {
            if (v.chr == cursor_pos.chr)
            {
                final switch(text.getLineCharsLayout())
                {
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                    x = v.target_x;
                    y = v.target_y;
                    width = 1;
                    height = v.height;
                    break;
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    x = v.target_x+v.width;
                    y = v.target_y;
                    width = 1;
                    height = v.height;
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                    x = v.target_x;
                    y = v.target_y;
                    width = v.width;
                    height = 1;
                    break;
                }
                
                return tuple(true, x,y,width,height);
            }
        }
        
        debug writeln("calculateVisibleCursor: default fail");
        return fail_res;
    }
    
    void changeCursorPositionByCoordinates(ulong x, ulong y)
    {
    	
        ulong line;
        ulong column;
        
        auto el_clicked = determineVisibleElementAt(x,y);
        
        // TODO: develop solution for clicks in other places
        if (el_clicked[0] is null)
        {
            debug writeln(new Exception("todo"));
            return;
        }
        
        bool after_clicked;
        
        final switch(text.getLineCharsLayout())
        {
        case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
            if (el_clicked[1] == ElementVisibilityMapElementClickLeanH.right)
                after_clicked = true;
            break;
        case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
            if (el_clicked[1] == ElementVisibilityMapElementClickLeanH.left)
                after_clicked = true;
            break;
        case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
        case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
            if (el_clicked[2] == ElementVisibilityMapElementClickLeanV.bottom)
                after_clicked = true;
            break;
        }
        
        auto cp = new CursorPosition();
        
        // subline is same in any case
        cp.subline = el_clicked[0].chr.calcSubline(this);
        
        if (cp.subline is null)
        {
            throw new Exception("programming error: report a bug");
        }
        
        if (after_clicked)
        {
        	cp.chr = el_clicked[5];
        	/*             if (el_clicked[5] is null)
            {
            cp.chr = null;
            }
            else
            {
            cp.chr = el_clicked[5];
            }
        */        }
        else
        {
            cp.chr=el_clicked[0].chr;
        }
        
        setCursorPosition(cp);
    }
    
    void setCursorPosition(CursorPosition cp)
    {
    	debug {
    		writeln("setCursorPosition");
    		if (cp.chr !is null)
    		{
    			writeln("  chr : ", cp.chr, " ", cp.chr.chr);
    		}
    		else
    		{
    			writeln("  chr : null");
    		}
    		writeln("  EOL : ", cp.atEOL());
    		writeln("  EOVL: ", cp.atEOVL(this));
    	}
    	
        foreach(v;cursor_positions)
        {
            collectException(clearCursor(v));
        }
        
        cursor_positions=cursor_positions[0 .. 0] ~ cp;
        
        cursor_animation_iteration_visible=true;
    }
    
    Tuple!(
        ElementVisibilityMapElement, // 0
        ElementVisibilityMapElementClickLeanH, // 1
        ElementVisibilityMapElementClickLeanV, // 2
        // char before the clicked
        TextChar, // 3
        // element before the clicked (null if it's not in view)
        ElementVisibilityMapElement, // 4
        // char after the clicked
        TextChar, // 5
        // element after the clicked (null if it's not in view)
        ElementVisibilityMapElement, // 6
        )
    determineVisibleElementAt(ulong x, ulong y)
    {
        auto fail_res = tuple(
            cast(ElementVisibilityMapElement) null,
            cast(ElementVisibilityMapElementClickLeanH)0,
            cast(ElementVisibilityMapElementClickLeanV)0,
            cast(TextChar) null,
            cast(ElementVisibilityMapElement) null,
            cast(TextChar) null,
            cast(ElementVisibilityMapElement) null,
            );
        
        if (visibility_map is null)
            return fail_res;
        
        ElementVisibilityMapElement res_element;
        auto lh = ElementVisibilityMapElementClickLeanH.left;
        auto lv = ElementVisibilityMapElementClickLeanV.top;
        TextChar prev_char;
        ElementVisibilityMapElement prev_element;
        TextChar next_char;
        ElementVisibilityMapElement next_element;
        
        foreach (v; visibility_map.elements)
        {
            if (
                (x >= v.target_x && x < v.target_x+v.width)
            &&  (y >= v.target_y && y < v.target_y+v.height)
            )
            {
            	
                if (x >= v.target_x+(v.width/2))
                    lh = ElementVisibilityMapElementClickLeanH.right;
                if (y >= v.target_y+(v.height/2))
                    lv = ElementVisibilityMapElementClickLeanV.bottom;
                
                res_element = v;
                
                prev_char = v.chr.calcPrevCharInSubline(this);
                next_char = v.chr.calcNextCharInSubline(this);
                debug writeln("next_char == ", next_char);
                
                prev_element = visibility_map.getElementByTextChar(prev_char);
                next_element = visibility_map.getElementByTextChar(next_char);
                
                break;
            }
        }
        
        return tuple(
            res_element,
            lh, lv,
            prev_char, prev_element,
            next_char, next_element,
            );
    }
    
    
    void click(ulong x, ulong y)
    {
        if (getCursorEnabled())
        {
            // TODO: maybe there should be better way to ensure timer is connected
            //       as soon, as Platform is available
            ensureTimer500Connection();
            changeCursorPositionByCoordinates(x, y);
        }
    }
    
    void textInput(dstring txt)
    {
        auto cp = getCursorPosition();
        
        if (cp is null)
        {
            debug writeln(new Exception("cp is null"));
            return;
        }
        
        auto cp_chr = cp.chr;
        TextLine line;
        ulong index;
        bool atEOVL=cp.atEOVL(this);
        
        if (cp.chr !is null) {
            auto res = cp.chr.calcLineAndColumnIndex();
            line = res[0];
            index = res[1];
        }
        else
        {
        	// TOOD: what's should behere?
        }
        
        TextChar[] new_chars;
        
        foreach (v; cast(dchar[]) txt)
        {
            auto x = new TextChar(line);
            x.chr = v;
            new_chars ~= x;
        }
        
        line.textchars = line.textchars[0 .. index]
        ~ new_chars
        ~ line.textchars[index .. $];
        
        linesRecalcRequired = true;
        reprocess();
        completeRedrawToDS();
        
        auto new_cp = new CursorPosition();
        new_cp.chr = cp_chr;
        new_cp.subline = cp_chr.calcSubline(this);
        setCursorPosition(new_cp);
    }
    
    void keyboardInput(string type, EventKeyboard* event)
    {
    	// TODO: reproces() and redrawing usage have to be smarter
    	// TODO: this function obviously requires optimizations
        if (event.key_state == EnumKeyboardKeyState.pressed)
        {
        	cursorMakeLongerVisible();
        	
            switch (event.keysym.keycode)
            {
            default:
                break;
            case EnumKeyboardKeyCode.Up:
                final switch(text.getLinesLayout())
                {
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                	cursorMoveToNextOrToPrevLine(true);
                	break;
                }
                return;
            case EnumKeyboardKeyCode.Down:
                final switch(text.getLinesLayout())
                {
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                	cursorMoveToNextOrToPrevLine(false);
                    break;
                }
                return;
            case EnumKeyboardKeyCode.Left:
                final switch(text.getLinesLayout())
                {
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                    break;
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                	final switch(text.getLineCharsLayout())
                	{
                	case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                		cursorMoveToNextOrToPrevChar(true);
                		break;
                	case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                		cursorMoveToNextOrToPrevChar(false);
                		break;
                	case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                		break;
                	case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                		break;
                	}
                	break;
                }
                return;
            case EnumKeyboardKeyCode.Right:
                final switch(text.getLinesLayout())
                {
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                    break;
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                	final switch(text.getLineCharsLayout())
                	{
                	case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                		cursorMoveToNextOrToPrevChar(false);
                		break;
                	case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                		cursorMoveToNextOrToPrevChar(true);
                		break;
                	case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                		break;
                	case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                		break;
                	}
                	break;
                }
                return;
            }
            
            if (event.keysym.keycode == EnumKeyboardKeyCode.BackSpace)
            {
            	auto cp = getCursorPosition();
            	if (cp.chr !is null)
            	{
            		TextLine line;
            		ulong line_column_index;
            		{
            			auto line_and_column_index = cp.chr.calcLineAndColumnIndex();
            			line = line_and_column_index[0];
            			line_column_index = line_and_column_index[1];
            		}
            		
            		if (line_column_index == 0)
            		{
            			auto line_index = line.calcLineIndex();
            			auto prev_line = line.calcPrevLine();
            			if (prev_line !is null)
            			{
            				prev_line.textchars ~= line.textchars;
            				text.lines =
            				text.lines[0 .. line_index]
            				~ text.lines[line_index+1 .. $];
            				
            				foreach (v; prev_line.textchars)
            				{
            					v.parent_line = prev_line;
            				}
            			} else {
            				return;
            			}
            		}
            		else
            		{
            			line.textchars = line.textchars[0 .. line_column_index-1]
            			~ line.textchars[line_column_index .. $];
            		}
            		
            		linesRecalcRequired = true;
            		reprocess();
            		completeRedrawToDS();
            		
            		auto new_cp = new CursorPosition();
            		new_cp.chr = cp.chr;
            		new_cp.subline = cp.chr.calcSubline(this);
            		setCursorPosition(new_cp);
            		return;
            		
            	}
            	else
            	{
            		auto line = cp.subline.calcLine();
            		auto line_textchars = line.textchars;
            		
            		if (line_textchars.length == 0)
            		{
            			auto prev_line = line.calcPrevLine();
            			if (prev_line is null)
            			{
            				return;
            			}
            			
            			text.deleteLine(line);
            			
            			linesRecalcRequired = true;
            			reprocess();
            			completeRedrawToDS();
            			
            			setCursorPosition(prev_line.makeEOLCursor(this));
            			
            			return;
            		} else {
            			auto line_column = cp.chr.calcLineColumnIndex();
            			line.textchars = line_textchars[0 .. line_column-1]
            			~ line_textchars[line_column .. $];
            			
            			linesRecalcRequired = true;
            			reprocess();
            			completeRedrawToDS();
            			
            			auto new_cp = new CursorPosition();
            			new_cp.chr = cp.chr;
            			new_cp.subline = cp.chr.calcSubline(this);
            			setCursorPosition(new_cp);
            			return;
            		}
            		
            	}
            }
            
            if (event.keysym.keycode == EnumKeyboardKeyCode.Delete)
            {
            	auto cp = getCursorPosition();
            	if (cp.chr !is null)
            	{
            		TextLine line;
            		ulong    line_column_index;
            		{
            			auto line_and_index = cp.chr.calcLineAndColumnIndex();
            			line = line_and_index[0];
            			line_column_index = line_and_index[1];
            		}
            		
            		if (line_column_index == line.textchars.length-1)
            		{
            			line.textchars = line.textchars[0..line_column_index];
            			
            			linesRecalcRequired = true;
            			reprocess();
            			completeRedrawToDS();
            			
            			auto new_cp = new CursorPosition();
            			if (line.textchars.length != 0)
            			{
            				new_cp.subline = line.textchars[$-1].calcSubline(this);
            			}
            			else
            			{
            				new_cp.subline = line.getState(this).sublines[0];
            			}
            			setCursorPosition(new_cp);
            			
            			return;
            		}
            		else
            		{
            			auto new_chr = line.textchars[line_column_index+1];
            			
            			line.textchars = line.textchars[0..line_column_index]
            			~ line.textchars[line_column_index+1 .. $];
            			
            			linesRecalcRequired = true;
            			reprocess();
            			completeRedrawToDS();
            			
            			auto new_cp = new CursorPosition();
            			new_cp.chr = new_chr;
            			new_cp.subline = new_chr.calcSubline(this);
            			setCursorPosition(new_cp);
            			
            			return;
            		}
            	}
            	else
            	{
            		TextLine line = cp.subline.calcLine();
					ulong line_index = line.calcLineIndex();
            		if (line_index == text.lines.length-1) {
            			return;
            		}
            		
            		auto next_line_index = line_index+1;
            		auto next_line =text.lines[next_line_index];
            		auto next_line_textchars=next_line.textchars;
            		
            		foreach(v; next_line_textchars)
            		{
            			v.parent_line= line;
            		}
            		
            		TextChar next_line_first_char;
            		if (next_line_textchars.length != 0)
            		{
            			next_line_first_char = next_line_textchars[0];
            		}
            		
            		line.textchars ~= next_line_textchars;
            		
           			text.deleteLine(text.lines[next_line_index]);
           			
            		linesRecalcRequired = true;
            		reprocess();
            		completeRedrawToDS();
            		
            		auto new_cp = new CursorPosition();
            		
            		if (next_line_first_char !is null)
            		{
            			new_cp.chr = next_line_first_char;
            			new_cp.subline = new_cp.chr.calcSubline(this);
            		} else {
            			new_cp.subline = cp.subline;
            		}
            		
            		setCursorPosition(new_cp);
            		
            		return;
            	}
            	
            }
            
            if (event.keysym.keycode == EnumKeyboardKeyCode.Return)
            {
            	
            	return;
            }
        }
    }
    
    void resetCursorPosition()
    {
    	auto cp = new CursorPosition();
    	cp.subline = text.lines[0].getState(this).sublines[0];
    	auto textchars = cp.subline.getState(this).textchars;
    	if (textchars.length != 0)
    	{
    		cp.chr = textchars[0];
    	}
    	setCursorPosition(cp);
    }
    
    void cursorMoveToNextOrToPrevLine(bool prev)
    {
    	debug writeln("cursorMoveToNextOrToPrevLine: ", prev);
        auto cursor = getCursorPosition();
        
        if (cursor is null)
    	{
    		resetCursorPosition();
    		return;
    	}
    	
        TextLine cursor_line;
        ulong cursor_line_index;
        ulong cursor_subline_index;
        ulong cursor_line_subline_count;
        
        TextLineSubline cursor_subline;
        ulong cursor_subline_column_index;
        
        if (cursor.chr !is null)
        {
            cursor_line = cursor.chr.calcLine();
            cursor_line_index = cursor.chr.calcLineIndex();
            cursor_subline_index = cursor.chr.calcSublineIndex(this);
            cursor_line_subline_count = cursor_line.getState(this).sublines.length;
            
            cursor_subline = cursor.chr.calcSubline(this);
            cursor_subline_column_index = cursor.chr.calcSublineColumnIndex(this);
        }
        else
        {
            cursor_line = cursor.subline.calcLine();
            cursor_line_index = cursor.subline.calcLineIndex();
            cursor_subline_index = cursor.subline.calcSublineIndex(this);
            cursor_line_subline_count = cursor_line.getState(this).sublines.length;
            
            cursor_subline = cursor.subline;
        }
        
        ulong same_line_chars_width_or_height;
        
        auto textchars = cursor_subline.getState(this).textchars;
        
        if (cursor.chr is null)
        {
            final switch(text.getLineCharsLayout())
            {
            case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
            case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                same_line_chars_width_or_height = cursor_subline.getWidth(this);
                break;
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                same_line_chars_width_or_height = cursor_subline.getHeight(this);
                break;
            }
        }
        else
        {
            foreach (v; textchars[0 .. cursor_subline_column_index+1])
            {
                final switch(text.getLineCharsLayout())
                {
                case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
                case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                    same_line_chars_width_or_height += v.getWidth(this);
                    break;
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
                case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                    same_line_chars_width_or_height += v.getHeight(this);
                    break;
                }
            }
        }
        
        TextLineSubline new_subline;
        
        if (cursor_subline_index == (prev ? 0 : cursor_line_subline_count-1))
        {
            if (cursor_line_index == (prev ?  0 : text.lines.length-1))
            {
                // do nothing
                // TODO: maybe this should move cursor to start or to end of
                //       whole text
                return;
            }
            else
            {
                TextLine new_line;
                new_line = text.lines[cursor_line_index+(prev ? -1 : +1)];
                auto new_line_sublines = new_line.getState(this).sublines;
                new_subline = new_line_sublines[(prev ? new_line_sublines.length -1 : 0 )];
            }
        }
        else
        {
            new_subline =
            cursor_line.getState(this).sublines[cursor_subline_index+(prev ? -1 : +1)];
        }
        
        TextChar new_char;
        bool new_atEOL;
        bool new_atEOVL;
        ulong new_line_chars_width_or_height;
        
        bool new_char_found = false;
        foreach (v;new_subline.getState(this).textchars)
        {
            final switch(text.getLineCharsLayout())
            {
            case GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop:
            case GenVisibilityMapForSubitemsLayout.horizontalRightToLeftAlignTop:
                new_line_chars_width_or_height += v.getWidth(this);
                break;
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft:
            case GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignRight:
                new_line_chars_width_or_height += v.getHeight(this);
                break;
            }
            
            debug writeln(
                "new_line_chars_width_or_height <= same_line_chars_width_or_height:",
                new_line_chars_width_or_height, ":",
                same_line_chars_width_or_height
                );
            if (new_line_chars_width_or_height <= same_line_chars_width_or_height)
            {
                new_char=v;
            }
            else
            {
                new_char_found = true;
                break;
            }
        }
        
        if (!new_char_found)
        {
            new_char = null;
            new_atEOL = true;
            new_atEOVL = true;
        }
        
        CursorPosition cp = new CursorPosition();
        cp.chr = new_char;
        cp.subline = new_subline;
        
        setCursorPosition(cp);
    }
    
    void cursorMoveToNextOrToPrevChar(bool prev)
    {
    	debug writeln("cursorMoveToNextOrToPrevChar: ", prev);
    	auto cp = getCursorPosition();
    	if (cp is null)
    	{
    		resetCursorPosition();
    		return;
    	}
    	auto subline = cp.subline;
    	auto new_cp = new CursorPosition();
    	if (cp.chr is null)
    	{
    		if (!prev)
    		{
    			auto new_subline = subline.calcNextSubline(this);
    			if (new_subline is null)
    			{
    				return;
    			}
    			auto new_subline_textchars = new_subline.getState(this).textchars;
    			new_cp.subline = new_subline;
    			if (new_subline_textchars.length != 0)
    			{
    				new_cp.chr = new_subline_textchars[0];
    			}
    			setCursorPosition(new_cp);
    			return;
    		}
    		else
    		{
    			auto subline_textchars = subline.getState(this).textchars;
    			if (subline_textchars.length != 0)
    			{
    				new_cp.subline = subline;
    				new_cp.chr = subline_textchars[$-1];
    			}
    			else
    			{
    				auto new_subline = subline.calcPrevSubline(this);
    				new_cp.subline = new_subline;
    			}
    			setCursorPosition(new_cp);
    			return;
    		}
    	}
    	else
    	{
    		ulong chr_index = cp.chr.calcSublineColumnIndex(this);
    		auto subline_textchars = subline.getState(this).textchars;
    		if (!prev)
    		{
    			if (chr_index == subline_textchars.length-1)
    			{
    				new_cp.subline = subline;
    				setCursorPosition(new_cp);
    				return;
    			}
    			else
    			{
    				new_cp.subline = subline;
    				new_cp.chr = subline_textchars[chr_index+1];
    				setCursorPosition(new_cp);
    				return;
    			}
    		}
    		else
    		{
    			if (chr_index == 0)
    			{
    				auto new_subline = subline.calcPrevSubline(this);
    				if (new_subline is null)
    					return;
    				new_cp.subline = new_subline;
    				setCursorPosition(new_cp);
    				return;
    			}
    			else
    			{
    				new_cp.subline = subline;
    				new_cp.chr = subline_textchars[chr_index-1];
    				setCursorPosition(new_cp);
    				return;
    			}
    		}
    	}
    }
    
    CursorPosition getCursorPosition()
    {
        if (cursor_positions.length == 0)
            return cast(CursorPosition) null;
        return cursor_positions[$-1];
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
    mixin(
        q{
            state_type getState(TextView text_view)
            {
                state_type state;
                
                if (this !in %1$s) {
                    state = new state_type();
                    // state.entity = this;
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
    
    ElementVisibilityMapElement getElementByTextChar(TextChar chr)
    {
        auto fail_res = cast(ElementVisibilityMapElement) null;
        if (chr is null)
        {
            return fail_res;
        }
        foreach(v;elements)
        {
            if (v.chr == chr)
            {
                return v;
            }
        }
        return fail_res;
    }
    
    bool isTextCharInView(TextChar chr)
    {
        return getElementByTextChar(chr) !is null;
    }
}
