pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
epsilon=0.001

function _init()
	reset()
	vc_re=0
	vc_im=0
	scale=2
	pan_speed=0.05
	zoom_fac=1.1
	work_per_frame=4096
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
	m=mandelbrot(cc_re, cc_im, max_i/chunk_size)
	color=(15-(m%16))
	if chunk_size>1 then
		rectfill(chunk_tlx, chunk_tly, chunk_tlx+chunk_size-1, chunk_tly+chunk_size-1, color)
	else
		pset(chunk_tlx, chunk_tly, color)
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
