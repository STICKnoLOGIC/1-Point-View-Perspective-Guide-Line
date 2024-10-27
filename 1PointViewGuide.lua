local PreviewCanvas = dofile('./PreviewCanvas.lua')

local info
local image
local rect=Rectangle(30,30,30,30)
local imgw
local imgh
local previewImage, position,clone
local RepaintPreviewImage
local color, fut_color


-- create a usable perspective in canvas
function drawInCanvas(cx,cy,cz)
	local zg=info.data.zgs
	local xg=info.data.xgs
	app.command.ClearCel()
	for i=0,1,1/xg do for j=0,1 do
		app.useTool{
			tool="line",
			color=color,
			brush=Brush(1),
			points={Point(imgw*i,imgh*j),Point(cx,cy)}
		} end end
		for i=0,1 do for j=0,1,1/xg do
		app.useTool{
			tool="line",
			color=color,
			brush=Brush(1),
			points={Point(imgw*i,imgh*j),Point(cx,cy)}
		} end end
		
		
		for i=0,10,10/zg do
		local zz=(i+cz)%(10/zg)+i
		app.useTool{
			tool="rectangle",
			color=color,
			brush=Brush(1),
			points={Point(cx-cx/zz,cy-cy/zz),Point(cx-(cx-imgw)/(zz),cy-(cy-imgh)/zz)}
		}
		end
		
end

-- TODO: generate animation frames to view in preview
-- function genFrames(cx,cy)
-- 	frames={}
-- 	local fc=math.max(info.data.fcount,8)
-- 	local xm=info.data.mox
-- 	local ym=info.data.moy
-- 	local zm=info.data.moz
-- 	local cz=0
-- 	for q=1,fc do
-- 			local dx=info.data.cenx
-- 			local dy=info.data.ceny
-- 		if info.data.fcount>0 then
-- 		if info.data.anlin then
-- 			cx=((dx+xm)/2)+(dx-xm)*math.cos(((q-1)/fc)*math.pi)/2
-- 			cy=((dy+ym)/2)+(dy-ym)*math.cos(((q-1)/fc)*math.pi)/2
-- 		else
-- 			cx=info.data.cenx+((xm-dx)/fc)*q
-- 			cy=info.data.ceny+((ym-dy)/fc)*q
-- 		end
-- 		end
-- 		if info.data.anliz then
-- 			cz=zm+(zm)*math.cos(((q-1)/fc)*math.pi)
-- 		else
-- 			cz=zm*(q/fc)
-- 		end
-- 		drawFrame(cx,cy,cz)
-- 		frames[q-1]=Image(previewImage)
-- 		previewImage=Image(clone)
-- 	end
-- end

-- create and save
function doIt()
	local cx=info.data.cenx --start points
	local cy=info.data.ceny
	local fc=math.max(info.data.fcount,1)
	local xm=info.data.mox
	local ym=info.data.moy
	local zg=info.data.zgs
	local xg=info.data.xgs
	local zm=info.data.moz
	local cz=0
	local nll = image:newLayer()
	nll.name='1 Point Perspective'

	if info.data.isAnim then
		for q=1,fc do
			local dx=info.data.cenx
			local dy=info.data.ceny
			if info.data.fcount>0 then
				if info.data.anlin then
					cx=((dx+xm)/2)+(dx-xm)*math.cos(((q-1)/fc)*math.pi)/2
					cy=((dy+ym)/2)+(dy-ym)*math.cos(((q-1)/fc)*math.pi)/2
				else
					cx=info.data.cenx+((xm-dx)/fc)*q
					cy=info.data.ceny+((ym-dy)/fc)*q
				end
				end
			if info.data.anliz then
				cz=zm+(zm)*math.cos(((q-1)/fc)*math.pi)
				else
					cz=zm*(q/fc)
				end
			drawInCanvas(cx,cy,cz)
			if fc>1 and q<fc then
				app.command.NewFrame()	end
		end
	else
		drawInCanvas(cx,cy,cz)
	end
end

-- get image and pos
function GetActiveSpritePreview()
    local previewImage = Image(image.width, image.height, image.colorMode)
	
	for _, layer in ipairs(app.frame.sprite.layers) do
		if layer.isVisible then
			previewImage:drawSprite(layer.sprite,app.frame.frameNumber)
		end
	end

	clone=Image(previewImage)
    return previewImage
end
-- draw pixel in canvasPreview
function drawperpixel(img,xx,yy,dx,dy,dd,isAnim)
	local nn = math.ceil( 1.0 * dd )
    if nn < 1 then nn = 1 end
    
    local sx = dx / nn
    local sy = dy / nn
	
    
    for i=1,nn do
      xx = xx + sx
      yy = yy + sy
	  if isAnim then
		img:drawPixel(xx,yy,fut_color)
	  else
		img:drawPixel(xx,yy,color)
	  end
    end  
end
-- draw rectangles
function box(img,t,l,b,r,isAnim)
	if not img then return end
	img:drawPixel(t,l)

	local a1=t-t
	local a2=r-l
	local b1=b-t
	local b2=r-r
	local c1=b-b
	local c2=l-r
	local d1=t-b
	local d2=l-l

	local p1=math.sqrt(a1*a1+a2*a2)
	local p2=math.sqrt(b1*b1+b2*b2)
	local p3=math.sqrt(c1*c1+c2*c2)
	local p4=math.sqrt(d1*d1+d2*d2)

	if p1 > 0.00001 then
		drawperpixel(img,t,l,a1,a2,p1,isAnim)
	end
	if p2 > 0.00001 then
		drawperpixel(img,t,r,b1,b2,p2,isAnim)
	end
	if p3 > 0.00001 then
		drawperpixel(img,b,r,c1,c2,p3,isAnim)
	end
	if p4 > 0.00001 then
		drawperpixel(img,b,l,d1,d2,p4,isAnim)
	end
end
-- draw lines
function line(img,x1,y1,x2,y2,isAnim)
    if not img then return end
    
    img:drawPixel(x1,y1)
    
    local dx = x2 - x1
    local dy = y2 - y1

    local dd = math.sqrt( dx * dx + dy * dy )
    if dd > 0.00001 then 
		drawperpixel(img,x1,y1,dx,dy,dd,isAnim)
	end
  end
-- draw the perspective frame
function drawFrame(cx,cy,cz,isAnim)
	local zg=info.data.zgs
	local xg=info.data.xgs

	for i=0,1,1/xg do for j=0,1 do
		line(previewImage,imgw*i,imgh*j,cx,cy,isAnim)
   end end
   for i=0,1 do for j=0,1,1/xg do
		line(previewImage,imgw*i,imgh*j,cx,cy,isAnim)
   end end
   for i=0,10,10/zg do
	local zz=(i+cz)%(10/zg)+i
	box(previewImage,cx-cx/zz,cy-cy/zz,cx-(cx-imgw)/(zz),cy-(cy-imgh)/(zz),isAnim)
	end
end
function drawPerspective()
	local cx=info.data.cenx --start points
	local cy=info.data.ceny
	local cz=0
	if info.data.isAnim then
		drawFrame(info.data.mox,info.data.moy,info.data.moz,true)
	end
	drawFrame(cx,cy,cz)
end
--
function preview()
	if clone == nil then
	previewImage = GetActiveSpritePreview()
	else
		previewImage=Image(clone)
	end
	drawPerspective()
	RepaintPreviewImage(previewImage)
end


--------------------------------------
-- UI
--------------------------------------
function init(plugin)
	--
	plugin:newCommand{
	  id="1pointViewPerspectiveGuideLine",
	  title="1 point View Perspective Guide Line",
	  group="layer_new", --locate this in Layer/New../1 Point Perspective Guide
	  onenabled=function()
		return app.activeSprite ~= nil
	  end,
	  onclick=function()
		if info ~=nil then
			info:close()
			return
		end
		color=app.fgColor
		fut_color=app.bgColor
		fut_color.alpha=128
		image = app.sprite
		imgw = image.width
		imgh= image.height
		previewImage = GetActiveSpritePreview()
		clone=Image(previewImage)
 		info = Dialog{title="1 point View Perspective Guide Line",notitlebar=false,onclose=function()
			clone=nil
			info=nil
		end}

		RepaintPreviewImage = PreviewCanvas(info, 250, 200, app.sprite, previewImage)
		
		info --
		:separator{id="guidesep",text="Guide Lines Settings"}
		:label{text='Color Guide'}
		:color{id="clr",color=color,onchange=function()
			color=info.data.clr
			preview()
		end}
		:label{text='Center X'}
		:slider{
			id="cenx",
			min=0, 
			max=imgw,
			value=imgw/2,
			onchange=function()
				preview()	
			end
		}

		:label{text='Center Y'}
		:slider{
			id="ceny",
			min=0,
			max=imgh,
			value=imgh/2,
			onchange=function()
				preview()	
			end
		}

		:label{text='Z Gridline Count'}
		:slider{id="zgs",min=1,max=30,value=5,
		onchange=function()
			preview()	
		end}

		:label{text='X/Y Gridline Count'}
		:slider{id="xgs",min=1,max=30,value=5,
		onchange=function()
			preview()	
		end}

		:separator{id="animsep",text="Animation Settings"}

		:check{id="isAnim",text="Enable Animation Template",onclick=function(_)
			preview()
		end}

		:label{text='Frame Count'}
		:slider{id="fcount",min=8,max=64,value=8}
		:label{text='Move to X'}
		:slider{id="mox",min=0,max=imgw,value=imgw/2,onchange=function()
			preview()	
		end}
		:label{text='Move to Y'}
		:slider{id="moy",min=0,max=imgh,value=imgh/2,onchange=function()
			preview()	
		end}
		:label{text='Move by Z'}
		:slider{id="moz",min=1,max=30,value=1,onchange=function()
			preview()	
		end}
		:check{id="anlin",text="Smooth Animation X/Y"}
		:check{id="anliz",text="Smooth Animation Z"}

		:separator{id="sep1"}
		:button{id="ok",text="Create Guide",onclick=function() 
		app.transaction(doIt)
			info:close()
		end}

		preview()
		info:show{wait=false,autoscrollbars=true}
	  end
	}
  end
  
  function exit(plugin)
	if info ~= nil then
		info:close()
	end
  end

  function err(msg)
	app.alert{title="Error Occurred", text=msg, buttons="OK"}
  end