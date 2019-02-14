pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
epsilon=0.001

bw_palette={0,1,1,1,5,5,5,5,6,6,6,6,7,7,7,7}
wb_palette={7,6,6,6,5,5,5,5,1,1,1,1,0,0,0,0}
roygbiv_palette={0,8,8,9,9,10,10,11,11,3,12,12,1,1,2,2}
vibgyor_palette={0,2,2,1,1,12,12,3,11,11,10,10,9,9,8,8}

function _init()
	reset()
	vc_re=0
	vc_im=0
	scale=2
	pan_speed=0.05
	zoom_fac=1.1
	work_per_frame=4096
	shading_mode=0
	num_shading_modes=2
	palette=0
	num_palettes=5
end

function _draw()
	input()
	if not done then
		work_done=0
		repeat 
			work_done+=advance()
		until work_done>(work_per_frame-max_i)
	end
end

function input()
	if btn(0) then
		vc_re-=(pan_speed*scale)
		reset()
	end
	if btn(1) then
		vc_re+=(pan_speed*scale)
		reset()
	end
	if btn(2) then
		vc_im-=(pan_speed*scale)
		reset()
	end
	if btn(3) then
		vc_im+=(pan_speed*scale)
		reset()
	end
	if btn(4) then
		prev_scale=scale
		scale/=zoom_fac
		if scale<=epsilon then
			scale=prev_scale
		end
		reset()
	end
	if btn(5) then
		prev_scale=scale
		scale*=zoom_fac
		if scale<=epsilon then
			scale=prev_scale
		end
		reset()
	end
	if btnp(4, 1) then
		shading_mode+=1
		shading_mode%=num_shading_modes
		reset()
	end
	if btnp(5, 1) then
		palette+=1
		palette%=num_palettes
		set_palette_by_index(palette)
	end
end

function reset()
	chunk_size=128
	chunk_tlx=0
	chunk_tly=0
	max_i=256
	done=false
end

function advance()
	if done then
		return 0
	end
	// render current chunk
	pcx=chunk_tlx+(chunk_size/2)
	pcy=chunk_tly+(chunk_size/2)
	cc_re=(((pcx-64)/128)*scale)+vc_re
	cc_im=(((pcy-64)/128)*scale)+vc_im
	lim=max_i/chunk_size
	m=mandelbrot(cc_re, cc_im, lim)
	if shading_mode==0 then
		// repeat shading (gets noisy at high detail)
		shade=(15-(m%16))
	elseif shading_mode==1 then
		// fractional shading (less detail when function is sparse)
		shade=15-ceil((m/lim)*15)
	end
	if chunk_size>1 then
		rectfill(chunk_tlx, chunk_tly, chunk_tlx+chunk_size-1, chunk_tly+chunk_size-1, shade)
	else
		pset(chunk_tlx, chunk_tly, shade)
	end
	
	//advance state to next chunk or detect when done
	chunk_tlx+=chunk_size
	if chunk_tlx>=128 then
		chunk_tlx=0
		chunk_tly+=chunk_size
	end
	if chunk_tly>=128 then
		chunk_tly=0
		if chunk_size==1 then
			max_i*=2
		else
			chunk_size/=2
		end
	end
	if max_i>8192 then
		done = true
	end
	// add 8 to account for rendering overhead
	return m+8
end

function set_palette_by_index(palette_index)
	if palette_index==0 then
		pal()
	elseif palette_index==1 then
		// black to white gradient
		swap_to_palette(bw_palette)
	elseif palette_index==2 then
		// white to black gradient
		swap_to_palette(wb_palette)
	elseif palette_index==3 then
		// rainbow!
		swap_to_palette(roygbiv_palette)
	elseif palette_index==4 then
		// rainbow!
		swap_to_palette(vibgyor_palette)
	end
end

function swap_to_palette(palette_list)
	for i=0,(#palette_list-1) do
		pal(i, palette_list[i], 1)
	end
end

function mandelbrot(re0, im0, lim)
	// terminate early to get rid of macro-noise due to overflow
	if abs(re0)>4 or abs(im0)>4 then
		return 0
	end
	re=re0
	im=im0
	lsq=(re*re)+(im*im)
	i=0
	while i<(lim-1) and lsq<=4 do
		tre=re
		re=(re*re)-(im*im)+re0
		im=(2*tre*im)+im0
		lsq=(re*re)+(im*im)
		i+=1
	end
	return i
end
