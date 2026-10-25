pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
lvl={
	"11111111",
	"10000001",
	"10001001",
	"10011001",
	"10000001",
	"10111101",
	"10000001",
	"11111111"
}

objects={
	{s=2,x=3,y=2},
	{s=2,x=6,y=4}
}

player={
	x=1.5,
	y=1.5,
	a=0,
	speed=0.05,
	turn=0.01
}

function wall(x,y)
	local tx=flr(x)+1
	local ty=flr(y)+1

	if tx<1 or tx>8 or ty<1 or ty>8 then
		return true
	end

	return sub(lvl[ty],tx,tx)=="1"
end

function _update()
	if btn(0) then player.a-=player.turn end
	if btn(1) then player.a+=player.turn end

	local move=0
	if btn(2) then move=player.speed end
	if btn(3) then move=-player.speed end

	local nx=player.x+cos(player.a)*move
	local ny=player.y+sin(player.a)*move
	local r=0.15

	if not (
		wall(nx-r,player.y-r) or
		wall(nx+r,player.y-r) or
		wall(nx-r,player.y+r) or
		wall(nx+r,player.y+r)
	) then
		player.x=nx
	end

	if not (
		wall(player.x-r,ny-r) or
		wall(player.x+r,ny-r) or
		wall(player.x-r,ny+r) or
		wall(player.x+r,ny+r)
	) then
		player.y=ny
	end
end

function _draw()
	cls(1)
	rectfill(0,64,127,127,13)

	local zbuf={}

	for i=0,31 do
		local offset=(i/31-0.5)*0.25
		local ray_a=player.a+offset
		local dist=0.05
		local prevx=player.x
		local prevy=player.y
		local rx=player.x
		local ry=player.y

		while dist<8 do
			rx=player.x+cos(ray_a)*dist
			ry=player.y+sin(ray_a)*dist

			if wall(rx,ry) then
				break
			end

			prevx=rx
			prevy=ry
			dist+=0.05
		end

		local texcoord

		if flr(rx)~=flr(prevx) then
			texcoord=ry-flr(ry)
		else
			texcoord=rx-flr(rx)
		end

		local tex_x=mid(0,flr(texcoord*8),7)
		local corrected=max(dist*cos(offset),0.1)
		local h=mid(1,flr(72/corrected),128)
		local top=64-flr(h/2)

		zbuf[i]=corrected
		sspr(8+tex_x,0,1,8,i*4,top,4,h)
	end

	local projected={}

	for o in all(objects) do
		local dx=o.x-player.x
		local dy=o.y-player.y
		local forward=dx*cos(player.a)+dy*sin(player.a)
		local side=dx*cos(player.a+0.25)+dy*sin(player.a+0.25)

		if forward>0.1 and forward<8 then
			projected[#projected+1]={
				s=o.s,
				x=64+side/forward*64,
				d=forward,
				size=50/forward
			}
		end
	end

	for a=1,#projected do
		for b=a+1,#projected do
			if projected[a].d<projected[b].d then
				local temp=projected[a]
				projected[a]=projected[b]
				projected[b]=temp
			end
		end
	end

	for o in all(projected) do
		local left=o.x-o.size/2
		local top=64-o.size/2

		for i=0,31 do
			local column_x=i*4+2

			if column_x>=left
			and column_x<left+o.size
			and o.d<zbuf[i] then
				local tex_x=mid(
					0,
					flr((column_x-left)/o.size*8),
					7
				)

				local sx=(o.s%16)*8+tex_x
				local sy=flr(o.s/16)*8

				sspr(sx,sy,1,8,i*4,top,4,o.size)
			end
		end
	end
end

__gfx__
0000000055555555000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000566666650ddeedd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000056666665deeddeed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000056666665d88ee88d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000056666665dee88eed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000056666665deeeeeed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000566666650ddeedd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055555555000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
