local sx,sy = guiGetScreenSize()
local w,h = 258,60
local x,y = (sx-w)/1.02,(sy-h)/19

local fx, fy = guiGetScreenSize()
local ww, hh = 258, 60
local wx, wy = fx - ww - 25, fy - hh - 35

local awesome = exports.vrp_fonts:getFont("AwesomeFont", 11)
local awesomeB = exports.vrp_fonts:getFont("FontAwesome",14)
local awesomeK = exports.vrp_fonts:getFont("FontAwesome",12)
local algos = exports.vrp_fonts:getFont("BoldFont", 11)
local algosID = exports.vrp_fonts:getFont("BoldFont", 13)
local algosID2 = exports.vrp_fonts:getFont("BoldFont", 9)
local discord = exports.vrp_fonts:getFont("BoldFont", 8)
local algosGn = exports.vrp_fonts:getFont("BoldFont", 12)

setTimer(function()
 
	if getElementData(localPlayer,"hud1selected") then
        local playerid = getElementData(getLocalPlayer(), 'playerid')  
        local gunpng = 'components/weapon/kisi.png'
        local hunger = getElementData(localPlayer, 'hunger') / 1.6
        local thirst = getElementData(localPlayer, 'thirst') / 1.6
        local health = (getElementHealth(localPlayer)) / 1.6
        local armor = (getPedArmor(localPlayer)) / 1.6
        local bankmoney = getElementData(localPlayer, 'bankmoney') or 0
        local money = getElementData(localPlayer, 'money') or 0
   local name = localPlayer:getName()
    local nameFull = name:gsub('_', ' ')

      
	  -- dxDrawRoundedRectangle(x,y,w,h,tocolor(230, 230, 230, 150 ),{0.2,0.2,0.2,0.2 } )
        dxDrawRoundedRectangle(x+2,y-25,w-5,h-10,tocolor(0, 0, 0, 200 ),{0.2,0.2,0.2,0.2 } )
	    dxDrawRoundedRectangle(x+119,y-15,w-260,h-30,tocolor(200,200,200,255 ),{0.0,0.0,0.0,0.0 } ) --beyaz çizgi	
		dxDrawText('discord.gg/apexmta',x+7,y-15,w-5,h-10,tocolor( 55, 150,120,200 ),1,discord,'left','top') 
		dxDrawText(getFormattedDate(),x+30,y+5,w-5,h-10,tocolor( 55, 150,120,200 ),1,discord,'left','top') 
	    dxDrawRoundedRectangle(x+175,y-15,w-260,h-30,tocolor(200,200,200,255 ),{0.0,0.0,0.0,0.0 } ) --beyaz çizgi	
		dxDrawText('APEX',x+123,y-12,w-5,h-10,tocolor( 55, 150,120,200 ),1,algosID,'left','top') 
	    dxDrawImage(x+179, y-37, w-185, h+10, gunpng);
		   
		  dxDrawRoundedRectangle(x+2,y+35,w-5,h-20,tocolor(0, 0, 0, 200 ),{0.2,0.2,0.2,0.2 } )
	      dxDrawText(name,x+9,y+47,w,h,tocolor( 200,200,200,255  ),1,algosID2,'left','top') 
		dxDrawText(getHours(),x+210,y+47,w,h,tocolor( 200,200,200,255  ),1,algosID2,'left','top') 
			  
	    dxDrawRoundedRectangle(x+2,y+80,w-130,h-20,tocolor(0, 0, 0, 200 ),{0.2,0.2,0.2,0.2 } )
        dxDrawText('',x+8,y+90,w,h,tocolor(105,89,205,200 ),1,awesomeK,'left','top') 
	    dxDrawText('   '..exports.vrp_global:formatMoney(money)..'',x+19,y+90,w,h,tocolor( 200,200,200,255 ),1,algosID,'left','top') 

	    dxDrawRoundedRectangle(x+135,y+80,w-137,h-20,tocolor(0, 0, 0, 200 ),{0.2,0.2,0.2,0.2 } )		
        dxDrawText('   '..exports.vrp_global:formatMoney(bankmoney)..'',x+150,y+90,w,h,tocolor( 200,200,200,255 ),1,algosID,'left','top') 
        dxDrawText('',x+140,y+90,w,h,tocolor(105,89,205,200),1,awesomeK,'left','top') 
        




		dxDrawRoundedRectangle(wx+110,wy,ww-220,hh+18,tocolor( 7,7,7,255 ),{ 0.9,0.9,0.9,0.9 } )
        if health > 5 then
            dxDrawRoundedRectangle(wx+110,wy,ww-220,health+15,tocolor(200,60,100,200 ),{ 0.9,0.9,0.9,0.9 } ) 
        end      
        dxDrawText('',wx+117,wy+5,ww,hh,tocolor( 200,200,200,255 ),1,awesomeB,'left','top') 

        dxDrawRoundedRectangle(wx+150,wy,ww-220,hh+18,tocolor( 7,7,7,255 ),{ 0.9,0.9,0.9,0.9 } )
        if armor > 5 then
            dxDrawRoundedRectangle(wx+150,wy,ww-220,armor+15,tocolor( 55, 55,120,255 ),{ 0.9,0.9,0.9,0.9 } )
        end    
        dxDrawText('',wx+155,wy+5,ww,hh,tocolor( 200,200,200,255 ),1,awesomeB,'left','top') 

        dxDrawRoundedRectangle(wx+190,wy,ww-220,hh+18,tocolor( 7,7,7,255 ),{ 0.9,0.9,0.9,0.9 } )
        if thirst > 5 then
            dxDrawRoundedRectangle(wx+190,wy,ww-220,hunger+15,tocolor(200,60,100,200 ),{ 0.9,0.9,0.9,0.9 } ) 
        end      
        dxDrawText('',wx+198,wy+5,ww,hh,tocolor( 200,200,200,255 ),1,awesomeB,'left','top') 

        dxDrawRoundedRectangle(wx+230,wy,ww-220,hh+18,tocolor( 7,7,7,255 ),{ 0.9,0.9,0.9,0.9 } )
        if hunger > 5 then
            dxDrawRoundedRectangle(wx+230,wy,ww-220,thirst+15,tocolor(200,60,100,200 ),{ 0.9,0.9,0.9,0.9 } )  
        end
        dxDrawText('',wx+240,wy+5,ww,hh,tocolor( 200,200,200,255 ),1,awesomeB,'left','top') 
		

    end  
end,0,0)

function getHours()
    local time = getRealTime() 
    local hours = time.hour 
    local minutes = time.minute

    if (hours < 10) then 
        hours = '0'..hours 
    end 

    if (minutes < 10) then 
        minutes = '0'..minutes
    end 
    return hours..':'..minutes
end
function getFormattedDate()
    local time = getRealTime()
    local day = time.monthday
    local month = time.month + 1 
    local year = time.year + 1900 

    if (day < 10) then 
        day = '0' .. day 
    end 

    if (month < 10) then 
        month = '0' .. month
    end 

    return day .. '.' .. month .. '.' .. year
end


off = false
function off()
    if off == false then 
        off = true
    else
        off = false
    end
end
addCommandHandler("hud",off)