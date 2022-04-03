local niveau = {}

niveau.bgX = 1

niveau.liste_enemy = {}

function niveau.setNiveau(pLevel)
  print("niveau ="..pLevel)
  if pLevel == 1 then
    niveau.image = love.graphics.newImage("images/niveau1.png")
    
    niveau.CreeEnemy(1, 2500, 200, false)
    niveau.CreeEnemy(1, 2550, 150, false)
    niveau.CreeEnemy(1, 2550, 250, false)
    
  elseif pLevel == 2 then
    niveau.image = love.graphics.newImage("images/niveau2.png")
    
    niveau.CreeEnemy(2, 2500, 200, false)
    niveau.CreeEnemy(2, 2550, 150, false)
    niveau.CreeEnemy(2, 2550, 250, false)
  
  elseif pLevel == 3 then
    niveau.image = love.graphics.newImage("images/niveau3.png")
    niveau.CreeEnemy(3, 2500, 200, false)
    niveau.CreeEnemy(3, 2600, 250, false)
    niveau.CreeEnemy(3, 2700, 300, false)
    niveau.CreeEnemy(3, 2800, 350, false)
    niveau.CreeEnemy(3, 2900, 300, false)
    niveau.CreeEnemy(3, 3000, 250, false)
    
  elseif pLevel == 4 then
    niveau.image = love.graphics.newImage("images/niveau4.png")
  elseif pLevel == 5 then
    niveau.image = love.graphics.newImage("images/niveau5.png")
  elseif pLevel == 6 then
    niveau.image = love.graphics.newImage("images/niveau6.png")
  
  
  elseif pLevel == 7 then
    niveau.image = love.graphics.newImage("images/niveau7.png")
    
    niveau.CreeEnemy("boss", 1800,200, true)
    
  
    
  end
  
  

end


function niveau.CreeEnemy(pType, pX, pY, pTir)
  local alien = {}
  alien.type = pType
  alien.image = love.graphics.newImage("images/enemy_"..alien.type..".png")
  alien.x = pX
  alien.y = pY
  alien.energy = 10
  alien.timerTir = 1
  alien.visible = false
  alien.boss = false
  
  if alien.type == 1 then
    alien.vx = -4 
    alien.vy = 0
    
    
  elseif alien.type == 2 then
    alien.vx = -4
    alien.vy = 6
  
  elseif alien.type == 3 then
    alien.vx = -4
    alien.vy = 4
    
  elseif alien.type == "boss" then
    alien.vx = -4
    alien.vy = 0
    alien.energy = 200
  end
  
  table.insert(niveau.liste_enemy, alien)
end






function niveau.load()
end


function niveau.update(dt)
end


function niveau.draw()
end


return niveau