module dtk.miscs.calculateVisiblePart;

import std.typecons;

// result values:
//  0 - visible?
//  1, 2, 3, 4 - visible image part
//  5, 6 - vertical and horizontal offset where to put visible part
Tuple!(
	bool, 
	ulong, ulong, ulong, ulong, 
	ulong, ulong
	) calculateVisiblePart(
ulong vp_x,
ulong vp_y,
ulong vp_w,
ulong vp_h,
ulong cx,
ulong cy,
ulong cw,
ulong ch
)
    {
    	auto ret_invisible = tuple(
    		false, 
    		0UL, 0UL, 0UL, 0UL, 
    		0UL, 0UL
    		);
    	ulong x;
    	ulong y;
    	ulong w;
    	ulong h;
    	ulong vx;
    	ulong vy;
    	
    	if (cw==0 || ch==0)
    	{
    		return ret_invisible;
    	}
    	
    	auto cx_p_cw = cx+cw;
    	auto cy_p_ch = cy+ch;
    	auto vp_x_p_vp_w = vp_x+vp_w; 
    	auto vp_y_p_vp_h = vp_y+vp_h; 
    	
    	if (
    		vp_x > cx_p_cw 
    	|| vp_y > cy_p_ch
    	|| vp_x_p_vp_w < cx
    	|| vp_y_p_vp_h < cy
    	)
    	{
    		return ret_invisible;
    	}
    	
    	if (vp_x > cx)
    	{
    		vx = 0;
    	}
    	else
    	{
    		vx = cx - vp_x;
    	}
    	
    	if (vp_y > cy)
    	{
    		vy = 0;
    	}
    	else
    	{
    		vy = cy - vp_y;
    	}
    	
    	{
    		if (vp_x < cx) 
    		{
    			x = 0;
    		}
    		else
    		{
    			x = cx - vp_x;
    		}
    		
    		if (vp_y < cy) 
    		{
    			y = 0;
    		}
    		else
    		{
    			y = cy - vp_y;
    		}
    	}
    	
    	{
    		if (vp_x_p_vp_w > cx_p_cw) 
    		{
    			w = cw;
    		}
    		else
    		{
    			w = cx_p_cw - vp_x_p_vp_w;
    		}
    		
    		if (vp_y_p_vp_h > cy_p_ch) 
    		{
    			h = ch;
    		}
    		else
    		{
    			h = cy_p_ch - vp_y_p_vp_h;
    		}
    		
    		if (x>w) {
    			w=0;
    		} else {
    			w-=x;
    		}
    		
    		if (y>h) {
    			h=0;
    		} else {
    			h-=y;
    		}
    	}
    	
    	if (w==0 || h==0)
    	{
    		return ret_invisible;
    	}
    	
    	return tuple(true, x, y, w, h, vx, vy);
    }