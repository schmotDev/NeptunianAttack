local Game = {}


Game.imgStart = love.graphics.newImage("images/start.png")
Game.imgHelp = love.graphics.newImage("images/help.png")
Game.imgDead = love.graphics.newImage("images/dead.png")
Game.imgWin = love.graphics.newImage("images/win.png")

Game.sndExplose = love.audio.newSource("sons/crash.wav", "static")

Game.warning = false
Game.warningCount = 100
Game.imgWarning = love.graphics.newImage("images/warning.png")
Game.sndWarning = love.audio.newSource("sons/alarm.wav", "static")

Game.transition = false
Game.transitionTimer = 200
Game.imgTransition = love.graphics.newImage("images/transition.png")

myNiveau = require("niveau")
Game.currentNiveau = 1
Game.maxNiveau = 7

Game.myHero = {}
Game.myHero.image = love.graphics.newImage("images/shipHero.png")
Game.myHero.largeur = Game.myHero.image:getWidth()
Game.myHero.hauteur = Game.myHero.image:getHeight()
Game.myHero.x = 0
Game.myHero.y = 0
Game.myHero.vx = 0
Game.myHero.vy = 0

Game.myHero.listeTirs = {}
Game.myHero.sndTir = love.audio.newSource("sons/shoot.wav", "static")
Game.myHero.sndShoot = love.audio.newSource("sons/explode_touch.wav", "static")

Game.listeTirsAlien = {}

Game.myHero.imgCrash = {}
local i
for i = 1,5 do
  Game.myHero.imgCrash[i] = love.graphics.newImage("images/explode_"..i..".png")
end
Game.myHero.crashFrame = 1
Game.myHero.crash_vy = 0

Game.myHero.imgExplose = {}
local id
for id = 1,9 do
  Game.myHero.imgExplose[id] = love.graphics.newImage("images/explosion"..id..".png")
end
Game.myHero.exploseFrame = 1
Game.myHero.exploseX = 0
Game.myHero.exploseY = 0

Game.alienExplose = {}
Game.imgAlienExplose = {}
local y
for y = 1,5 do
  Game.imgAlienExplose[y] = love.graphics.newImage("images/explode_"..y..".png")
end

Game.imgBossEnergy = love.graphics.newImage("images/boss_energy.png")

function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

function CreeAlienExplose(pX, pY)
  local explo = {}
  explo.x = pX
  explo.y = pY
  explo.listeFrames = Game.imgAlienExplose
  explo.frame = 1
  table.insert(Game.alienExplose, explo)
end

function collision(a1, a2)
  if (a1==a2) then return false end
  return a1.x < (a2.x + a2.image:getWidth()) and
         a2.x < (a1.x + a1.image:getWidth()) and
         a1.y < (a2.y + a2.image:getHeight()) and
         a2.y < (a1.y + a1.image:getHeight())
end

function Game.initHero()
  Game.myHero.status = "playing"
  
  Game.myHero.crashFrame = 1
  Game.myHero.exploseFrame = 1
  
  local n
  for n=1,#Game.myHero.listeTirs do
    table.remove(Game.myHero.listeTirs, n)
  end
end


function Game.myHero.CreeTir()
  local tir = {}
  tir.image = love.graphics.newImage("images/shootHero.png")
  tir.x = Game.myHero.x + 26
  tir.y = Game.myHero.y + 26 - tir.image:getHeight()/2
  tir.vx = 10
  table.insert(Game.myHero.listeTirs, tir)
  Game.myHero.sndTir:play()
end

function Game.CreeTirAlien(pX, pY, pVX, pVY)
  local tirAlien = {}
  tirAlien.image = love.graphics.newImage("images/tirAlien.png")
  tirAlien.x = pX
  tirAlien.y = pY
  tirAlien.vx = pVX
  tirAlien.vy = pVY
  table.insert(Game.listeTirsAlien, tirAlien)
  --Game.myHero.sndTir:play()
end

function Game.load()
  Game.largeur = 1280
  Game.hauteur = 768
  love.window.setMode(Game.largeur, Game.hauteur)
  love.window.setTitle("Neptunian Attack - by SCHMOT 2022")
  
  for i=#myNiveau.liste_enemy, 1, -1 do
    table.remove(myNiveau.liste_enemy, i)
  end
  for i=#Game.listeTirsAlien, 1, -1 do
    table.remove(Game.listeTirsAlien, i)
  end
  
  Game.ecran = "start"
  myNiveau.setNiveau(1)
  Game.currentNiveau = 1
  Game.transition = false
  Game.transitionTimer = 200
  
  Game.warning = false
  Game.warningCount = 100

  Game.myHero.x = 10
  Game.myHero.y = Game.hauteur/2 - Game.myHero.hauteur/2
  Game.initHero()
  
end


function Game.update(dt)
  if Game.ecran == "playing" then
    -- on update le background du niveau
    myNiveau.bgX = myNiveau.bgX - 120*dt
    if myNiveau.bgX <= 0-myNiveau.image:getWidth() then
      myNiveau.bgX = 1
    end
    
    -- on bouge les enemis
    for i=#myNiveau.liste_enemy, 1, -1 do
      local alien
      alien = myNiveau.liste_enemy[i]
      alien.x = alien.x + alien.vx
      alien.y = alien.y + alien.vy
      if alien.type == 2 then
        if alien.y <= alien.image:getHeight()*2 or alien.y >= Game.hauteur - 300 then
          alien.vy = alien.vy * (-1)
        end
      end  
      if alien.type == 3 then
        if alien.y <= alien.image:getHeight()*2 or alien.y >= Game.hauteur - 400 then
          alien.vy = alien.vy * (-1)
        end
        --if alien.y == (((Game.hauteur - 400) - alien.image:getHeight()*2)/2) + alien.image:getHeight()*2 then
        
      end
      if alien.type == "boss" then
        if alien.x < Game.largeur *2/3 then alien.vx = 0 end
        alien.timerTir = alien.timerTir - 1
        if alien.timerTir <= 0 then
          alien.timerTir = 30
          local vx, vy
          local angle
          angle = math.angle(alien.x+alien.image:getWidth()/2, alien.y+alien.image:getHeight()/2, Game.myHero.x, Game.myHero.y)
          vx = 10 * math.cos(angle)
          vy = 10 * math.sin(angle)
          Game.CreeTirAlien(alien.x+alien.image:getWidth()/2, alien.y+alien.image:getHeight()/2, vx, vy)
        end  
      end
      
      if (alien.x + alien.image:getWidth()) < 0 then
        table.remove(myNiveau.liste_enemy, i)
      end
      if alien.x <= Game.largeur then 
        alien.visible = true
      end
    end
  
    -- on bouge les tirs du hero
    local n
    for n=#Game.myHero.listeTirs,1,-1 do
      local t = Game.myHero.listeTirs[n]
      t.x = t.x + t.vx
      if t.x > Game.largeur then
        table.remove(Game.myHero.listeTirs, n)
      end
    end
    
    local na
    for na=#Game.listeTirsAlien,1,-1 do
      local t = Game.listeTirsAlien[na]
      t.x = t.x + t.vx
      t.y = t.y + t.vy
      if t.x > Game.largeur or t.x < 0 or t.y < 0 or t.y > Game.hauteur then
        table.remove(Game.listeTirsAlien, na)
      end
    end
    
    
    -- on check la liste des ennmis, si elle est vide on passe au niveau suivant
    if #myNiveau.liste_enemy == 0 and Game.myHero.status == "playing" then
      Game.transition = true
    end
  
    -- si le hero est playing ou warning il peut bouger
    if (Game.myHero.status == "warning" or Game.myHero.status == "playing") then
      if love.keyboard.isDown("w") or love.keyboard.isDown("z") and Game.myHero.y > 0 then
          Game.myHero.y = Game.myHero.y - 3
      end
      if love.keyboard.isDown("d") and Game.myHero.x < Game.largeur/2 then
          Game.myHero.x = Game.myHero.x + 3
      end
      if love.keyboard.isDown("s") and Game.myHero.y+Game.myHero.hauteur < Game.hauteur then
          Game.myHero.y = Game.myHero.y + 3
      end
      if love.keyboard.isDown("a") or love.keyboard.isDown("q") and Game.myHero.x > 0 then
          Game.myHero.x = Game.myHero.x - 3
      end
    
      -- on check si le hero vole trop bas
      if Game.myHero.y > Game.hauteur - Game.myHero.hauteur - 200 then
        Game.myHero.status = "warning"
        Game.warningCount = Game.warningCount - 1*(60*dt)
        Game.sndWarning:play()
        if Game.warningCount < 0 then 
          Game.myHero.status = "crashing"
          --Game.ecran = "crashing"
          --Game.warning = false
          Game.sndExplose:play()
        end
      else
        Game.myHero.status = "playing"
        --Game.warning = false
        Game.warningCount = 100
      end
      
      -- on check si collision hero avec enemis
      for i=#myNiveau.liste_enemy, 1, -1 do
        local alien
        alien = myNiveau.liste_enemy[i]
        if collision(Game.myHero, alien) == true then
          Game.myHero.status = "shooted"
          table.remove(myNiveau.liste_enemy, i)
          Game.myHero.exploseX = Game.myHero.x
          Game.myHero.exploseY = Game.myHero.y
        end
      end
      
      for i=#myNiveau.liste_enemy, 1, -1 do
        local alien
        alien = myNiveau.liste_enemy[i]
        for t=#Game.myHero.listeTirs,1,-1 do
          local tir = Game.myHero.listeTirs[t]
          if collision(tir, alien) == true then
            alien.energy = alien.energy - 10
            table.remove(Game.myHero.listeTirs, t)
            CreeAlienExplose(alien.x+alien.image:getWidth()/2, alien.y+alien.image:getHeight()/2)
            Game.myHero.sndShoot:play()
            if alien.energy == 0 then
              table.remove(myNiveau.liste_enemy, i)
            end
          end
        end
      end
      
      for ex=#Game.alienExplose,1,-1 do
        local explo
        explo = Game.alienExplose[ex]
        explo.frame = explo.frame + 0.4
        if math.floor(explo.frame) >= 5 then
          table.remove(Game.alienExplose, ex)
        end
          
      end
      
      
      if Game.transition == true then
        Game.transitionTimer = Game.transitionTimer - 1
        if Game.transitionTimer == 0 then
          Game.transitionTimer = 200
          Game.transition = false
          Game.currentNiveau = Game.currentNiveau + 1
          if Game.currentNiveau > Game.maxNiveau then
            Game.ecran = "winner"
          end
          myNiveau.setNiveau(Game.currentNiveau)
          Game.initHero()
        end
      end
    end
    
    if Game.myHero.status == "crashing" then
      Game.myHero.crashFrame = Game.myHero.crashFrame + 0.02
      Game.myHero.crash_vy = (Game.hauteur-Game.myHero.y)/5 * (Game.myHero.crashFrame-2)
      if math.floor(Game.myHero.crashFrame) >= 6 then
        Game.myHero.status = "dead"
        --Game.ecran = "dead"
      end
      
    end
    
    if Game.myHero.status == "shooted" then
      Game.myHero.exploseFrame = Game.myHero.exploseFrame + 0.18
        --Game.myHero.crash_vy = (Game.hauteur-Game.myHero.exploseY)/5 * (Game.myHero.crashFrame-2)
      if math.floor(Game.myHero.exploseFrame) >= 10 then
        Game.myHero.status = "dead"
        --Game.ecran = "dead"
      end
    end
    
  end
  
  
end


function Game.draw()
  if Game.ecran == "start" then
    love.graphics.draw(Game.imgStart, 0,0, 0, Game.largeur/Game.imgStart:getWidth(), Game.hauteur/Game.imgStart:getHeight())
  
  elseif Game.ecran == "help" then
    love.graphics.draw(Game.imgHelp, 0,0, 0, Game.largeur/Game.imgHelp:getWidth(), Game.hauteur/Game.imgHelp:getHeight())
  
  elseif Game.ecran == "winner" then
    love.graphics.draw(Game.imgWin, 0,0, 0, Game.largeur/Game.imgWin:getWidth(), Game.hauteur/Game.imgWin:getHeight())  
  
  elseif Game.ecran == "playing" then  
    -- on dessine le background du niveau
    love.graphics.draw(myNiveau.image,myNiveau.bgX,1)
    if myNiveau.bgX < 1 then
      love.graphics.draw(myNiveau.image,myNiveau.bgX + myNiveau.image:getWidth(),1)
    end
    
    local i
    for i=#myNiveau.liste_enemy, 1, -1 do
      local alien
      alien = myNiveau.liste_enemy[i]
      if alien.visible == true then
        love.graphics.draw(alien.image, alien.x, alien.y, 0, 1,1)
      end
      if alien.type == "boss" then
        love.graphics.draw(Game.imgBossEnergy, 900, 10, 0, 1,1)
        love.graphics.rectangle("line", 970, 12, 200, 22)
        love.graphics.setColor(255,0,0)
        love.graphics.rectangle("fill", 970, 13, alien.energy, 20)
        love.graphics.setColor(255,255,255)
        
      end
    end
    
    local n
    for n=1,#Game.myHero.listeTirs do
      local t = Game.myHero.listeTirs[n]
      love.graphics.draw(t.image, t.x, t.y, 0, 0.5, 0.5)
    end
    
    local na
    for na=1,#Game.listeTirsAlien do
      local t = Game.listeTirsAlien[na]
      love.graphics.draw(t.image, t.x, t.y, 0, 1, 1)
    end
    
    
    for ex=#Game.alienExplose,1,-1 do
      local explo
      explo = Game.alienExplose[ex]
      love.graphics.draw(explo.listeFrames[math.floor(explo.frame)], explo.x, explo.y, 0, 2,2)
    end
      
    
    if Game.myHero.status == "playing" or Game.myHero.status == "warning" then
      love.graphics.draw(Game.myHero.image, Game.myHero.x, Game.myHero.y, 0, 1,1)
      
      if Game.transition == true and Game.currentNiveau < Game.maxNiveau then
        love.graphics.draw(Game.imgTransition, Game.largeur/2-Game.imgTransition:getWidth()/2, Game.hauteur/4)
      end
      
    end
    
    if Game.myHero.status == "warning" then
      love.graphics.draw(Game.imgWarning, 300, 40, 0, 1.5,1.5)
    end
    
    if Game.myHero.status == "crashing" then
      love.graphics.draw(Game.myHero.imgCrash[math.floor(Game.myHero.crashFrame)], Game.myHero.x+ math.random(-10,10), Game.myHero.y+ math.random(-10,10) + Game.myHero.crash_vy, 0, 3,3)
    end
    
    if Game.myHero.status == "shooted" then
      local image = Game.myHero.imgExplose[math.floor(Game.myHero.exploseFrame)]
      love.graphics.draw(image, Game.myHero.x, Game.myHero.y-Game.myHero.image:getHeight()/2, 0, 0.5,0.5)
    end
    
    if Game.myHero.status == "dead" then
      love.graphics.draw(Game.imgDead, Game.largeur/2-Game.imgDead:getWidth()/2, Game.hauteur/4)
    end
    
    
      --love.graphics.print("nb enemy = "..#myNiveau.liste_enemy, 0,20)
      --love.graphics.print("nb tirs = "..#Game.myHero.listeTirs, 0,0)
      --love.graphics.print("transition: "..tostring(Game.transition), 0, 40)
      --love.graphics.print("transition timer: "..Game.transitionTimer, 0, 60)
      --love.graphics.print("niveau = "..Game.currentNiveau, 0, 80)
      --love.graphics.print("ecran = "..Game.ecran, 120, 0)
      --love.graphics.print("status = "..Game.myHero.status, 120, 20)
      
      --love.graphics.print("warningcount = "..Game.warningCount, 300, 0)
      --love.graphics.print("alien explose = "..#Game.alienExplose, 300, 20)
      --love.graphics.print("tirs alien = "..#Game.listeTirsAlien, 300, 40)
  end
end


return Game