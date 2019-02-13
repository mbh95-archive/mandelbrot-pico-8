pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	reset()
	vc_re=0
	vc_im=0
	scale=2
	max_i=15
	pan_speed=0.05
	zoom_fac=1.1
	steps_per_frame=200
end

function _draw()
	input()
	if not done then
 	for i=1,steps_per_frame do
 		advance()
 	end
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
		scale/=zoom_fac
		reset()
	end
	if btn(5) then
		scale*=zoom_fac
		reset()
	end
end

function reset()
	chunk_size=128
	chunk_tlx=0
	chunk_tly=0
	done=false
end

function advance()
	if done then
		return
	end
	pcx=chunk_tlx+(chunk_size/2)
	pcy=chunk_tly+(chunk_size/2)
	cc_re=(((pcx-64)/128)*scale)+vc_re
	cc_im=(((pcy-64)/128)*scale)+vc_im
	m=mandelbrot(cc_re, cc_im)
	rectfill(chunk_tlx, chunk_tly, chunk_tlx+chunk_size, chunk_tly+chunk_size, 15-m)
	
	chunk_tlx+=chunk_size
	if chunk_tlx>=128 then
		chunk_tlx=0
		chunk_tly+=chunk_size
	end
	if chunk_tly>=128 then
		chunk_tly=0
		if chunk_size==1 then
			done=true
		else
			chunk_size/=2
		end
	end
end

function mandelbrot(re0, im0)
	re=re0
	im=im0
	lsq=(re*re)+(im*im)
	i=0
	while i<max_i and lsq<=4 do
		tre=re
		re=(re*re)-(im*im)+re0
		im=(2*tre*im)+im0
		lsq=(re*re)+(im*im)
		i+=1
	end
	return i
end
