module dtk.miscs.calculateVisiblePart;

import std.typecons;

// If there is space, which have object c on it and parto of space is viewed
// via viewport vp - get visible part of c and c position in viewport

// result values:
//  0 - visible?
//  1, 2, 3, 4 - visible image (object) part
//  5, 6 - vertical and horizontal offset where to put visible part
Tuple!(
	bool,
	int, int, int, int,
	int, int
	) calculateVisiblePart(
int vpx,
int vpy,
int vpw,
int vph,
int cx,
int cy,
int cw,
int ch
)
    {
    	
    	// assert(vpx >= 0);
    	// assert(vpy >= 0);
    	// assert(vpw >= 0);
    	// assert(vph >= 0);
    	// assert(cx >= 0);
    	// assert(cy >= 0);
    	// assert(cw >= 0);
    	// assert(ch >= 0);
    	
    	auto ret_invisible = tuple(
    		false,
    		0, 0, 0, 0,
    		0, 0
    		);
    	
    	int x;
    	int y;
    	int w;
    	int h;
    	int vx;
    	int vy;
    	
    	if (cw==0 || ch==0)
    	{
    		return ret_invisible;
    	}
    	
    	auto cx_p_cw = cx+cw;
    	auto cy_p_ch = cy+ch;
    	auto vpx_p_vpw = vpx+vpw;
    	auto vpy_p_vph = vpy+vph;
    	
    	if (
    		vpx > cx_p_cw
    	|| vpy > cy_p_ch
    	|| vpx_p_vpw < cx
    	|| vpy_p_vph < cy
    	)
    	{
    		return ret_invisible;
    	}
    	
    	{
    		if (vpx >= cx)
    		{
    			vx = 0;
    		}
    		else
    		{
    			vx = cx - vpx;
    		}
    		
    		if (vpy >= cy)
    		{
    			vy = 0;
    		}
    		else
    		{
    			vy = cy - vpy;
    		}
    	}
    	
    	{
    		if (vpx < cx)
    		{
    			x = 0;
    		}
    		else
    		{
    			x = vpx - cx;
    		}
    		
    		if (vpy < cy)
    		{
    			y = 0;
    		}
    		else
    		{
    			y = vpy - cy;
    		}
    	}
    	
    	{
    		if (vpx_p_vpw > cx_p_cw)
    		{
    			w = cw;
    		}
    		else
    		{
    			w = cw - (cx_p_cw - vpx_p_vpw);
    		}
    		
    		if (vpy_p_vph > cy_p_ch)
    		{
    			h = ch;
    		}
    		else
    		{
    			h = ch - (cy_p_ch - vpy_p_vph);
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
