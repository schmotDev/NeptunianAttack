local Game = {}


imgStart = love.graphics.newImage("images/start.png")
imgHelp = love.graphics.newImage("images/help.png")
imgDead = love.graphics.newImage("images/dead.png")
imgWin = love.graphics.newImage("images/win.png")

sndExplose = love.audio.newSource("sons/crash.wav", "static")
 
warning = false
warningCount = 100
imgWarning = love.graphics.newImage("images/warning.png")
sndWarning = love.audio.newSource("sons/alarm.wav", "static")

transition = false
transitionTimer = 200
imgTransition = love.graphics.newImage("images/transition.png")

myNiveau = require("niveau")
currentNiveau = 1
maxNiveau = 7


Game.myHero = {}
Game.myHero.image = love.graphics.newImage("images/shipHero.png")
Game.myHero.largeur = Game.myHero.image:getWidth()
Game.myHero.hauteur = Game.myHero.image:getHeight()
Game.myHero.x = 0
Game.myHero.y = 0
Game.myHero.vx = 0
Game.myHero.vy = 0

listeTirsHero = {}
sndTirHero = love.audio.newSource("sons/shoot.wav", "static")
sndShootHero = love.audio.newSource("sons/explode_touch.wav", "static")

listeTirsAlien = {}

imgHeroCrash = {}
imgHeroCrash.image = love.graphics.newImage("images/heroCrashSheet1.png")
local i = 1
local co,li
for li = 1,3 do
  for co =1,5 do
    imgHeroCrash[i] = love.graphics.newQuad(64*(co-1), 64*(li-1), 64,64, imgHeroCrash.image:getWidth(), imgHeroCrash.image:getHeight())
    i = i + 1
  end
end
HeroCrashFrame = 1
HeroCrash_X = 0
HeroCrash_Y = 0
HeroCrash_vy = 0
HeroCrash_vx = 0

imgHeroExplose = {}
local id
for id = 1,9 do
  imgHeroExplose[id] = love.graphics.newImage("images/explosion"..id..".png")
end
HeroExploseFrame = 1
HeroExploseX = 0
HeroEXploseY = 0


imgBossExplose = {}
imgBossExplose.image = love.graphics.newImage("images/BossExploseSheet.png")
local ib = 1
local c,l
for l = 1,5 do
  for c = 1,5 do
    imgBossExplose[ib] = love.graphics.newQuad(64*(c-1), 64*(l-1), 64, 64, imgBossExplose.image:getWidth(), imgBossExplose.image:getHeight())
    ib = ib +1
  end
end
bossExploseFrame = 1
bossExplose = false



alienExploseListe = {}
imgAlienEXplose = {}
local y
for y = 1,5 do
  imgAlienEXplose[y] = love.graphics.newImage("images/explode_"..y..".png")
end

imgBossEnergy = love.graphics.newImage("images/boss_energy.png")
targetBoss = {}
targetBoss.image = love.graphics.newImage("images/targetboss.png")
targetBoss.x = 233
targetBoss.y = 267
targetBossFade = 0
targetBossFadeSens = -1

function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

function CreeAlienExplose(pX, pY)
  local explo = {}
  explo.x = pX
  explo.y = pY
  explo.listeFrames = imgAlienEXplose
  explo.frame = 1
  table.insert(alienExploseListe, explo)
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
  
  HeroCrashFrame = 1
  HeroCrash_vy = 0
  HeroCrash_vx = 0

  HeroExploseFrame = 1
  
  local n
  for n=1,#listeTirsHero do
    table.remove(listeTirsHero, n)
  end
end


function Game.CreeTirHero()
  local tir = {}
  tir.image = love.graphics.newImage("images/shootHero.png")
  tir.x = Game.myHero.x + 26
  tir.y = Game.myHero.y + 26 - tir.image:getHeight()/2
  tir.vx = 10
  table.insert(listeTirsHero, tir)
  sndTirHero:play()
end

function CreeTirAlien(pX, pY, pVX, pVY)
  local tirAlien = {}
  tirAlien.image = love.graphics.newImage("images/tirAlien.png")
  tirAlien.x = pX
  tirAlien.y = pY
  tirAlien.vx = pVX
  tirAlien.vy = pVY
  table.insert(listeTirsAlien, tirAlien)
  --sndTirHero:play()
end

function Game.load()
  Game.largeur = 1280
  Game.hauteur = 768
  love.window.setMode(Game.largeur, Game.hauteur)
  love.window.setTitle("Neptunian Attack - by SCHMOT 2022")
  
  for i=#myNiveau.liste_enemy, 1, -1 do
    table.remove(myNiveau.liste_enemy, i)
  end
  for i=#listeTirsAlien, 1, -1 do
    table.remove(listeTirsAlien, i)
  end
  
  Game.ecran = "start"
  myNiveau.setNiveau(1)
  currentNiveau = 1
  transition = false
  transitionTimer = 200
  
  warning = false
  warningCount = 100

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
      if alien.shooter == true then
        alien.timerTir = alien.timerTir - 1
        if alien.timerTir <= 0 then
          alien.timerTir = 30
          local vx, vy
          local angle
          angle = math.angle(alien.x+alien.image:getWidth()/2, alien.y+alien.image:getHeight()/2, Game.myHero.x, Game.myHero.y)
          vx = 10 * math.cos(angle)
          vy = 10 * math.sin(angle)
          CreeTirAlien(alien.x+alien.image:getWidth()/2, alien.y+alien.image:getHeight()/2, vx, vy)
        end  
      end
      
      if alien.type == "boss" then
        targetBoss.x = alien.x+233
        targetBoss.y = alien.y+267
        if alien.x < Game.largeur *2/3 then alien.vx = 0 end
        
        targetBossFade = targetBossFade + targetBossFadeSens*dt
        if targetBossFade < 0 or targetBossFade > 1 then targetBossFadeSens = targetBossFadeSens*(-1) end
        
        
      end
      
      if (alien.x + alien.image:getWidth()) < 0 then
        table.remove(myNiveau.liste_enemy, i)
      end
      if alien.x <= (Game.largeur) then 
        alien.visible = true
      end
    end
  
    -- on bouge les tirs du hero
    local n
    for n=#listeTirsHero,1,-1 do
      local t = listeTirsHero[n]
      t.x = t.x + t.vx
      if t.x > Game.largeur then
        table.remove(listeTirsHero, n)
      end
    end
    
    local na
    for na=#listeTirsAlien,1,-1 do
      local t = listeTirsAlien[na]
      t.x = t.x + t.vx
      t.y = t.y + t.vy
      if t.x > Game.largeur or t.x < 0 or t.y < 0 or t.y > Game.hauteur then
        table.remove(listeTirsAlien, na)
      end
    end
    
    
    -- on check la liste des ennmis, si elle est vide on passe au niveau suivant
    if #myNiveau.liste_enemy == 0 and Game.myHero.status == "playing" then
      transition = true
    end
  
    -- si le hero est playing ou warning il peut bouger
    if (Game.myHero.status == "warning" or Game.myHero.status == "playing") then
      if (love.keyboard.isDown("w") or love.keyboard.isDown("z")) and Game.myHero.y > 0 then
          Game.myHero.y = Game.myHero.y - 3
      end
      if love.keyboard.isDown("d") and Game.myHero.x < Game.largeur/2 then
          Game.myHero.x = Game.myHero.x + 3
      end
      if love.keyboard.isDown("s") and Game.myHero.y+Game.myHero.hauteur < Game.hauteur then
          Game.myHero.y = Game.myHero.y + 3
      end
      if (love.keyboard.isDown("a") or love.keyboard.isDown("q")) and Game.myHero.x > 0 then
          Game.myHero.x = Game.myHero.x - 3
      end
    
      -- on check si le hero vole trop bas
      if Game.myHero.y > Game.hauteur - Game.myHero.hauteur - 200 then
        Game.myHero.status = "warning"
        warningCount = warningCount - 1*(60*dt)
        sndWarning:play()
        if warningCount < 0 then 
          Game.myHero.status = "crashing"
          --Game.ecran = "crashing"
          --warning = false
          sndExplose:play()
        end
      else
        Game.myHero.status = "playing"
        --warning = false
        warningCount = 100
      end
      
      -- on check si collision hero avec enemis
      for i=#myNiveau.liste_enemy, 1, -1 do
        local alien
        alien = myNiveau.liste_enemy[i]
        if collision(Game.myHero, alien) == true then
          Game.myHero.status = "shooted"
          table.remove(myNiveau.liste_enemy, i)
          HeroExploseX = Game.myHero.x
          HeroEXploseY = Game.myHero.y
        end
      end
      
      for i=#myNiveau.liste_enemy, 1, -1 do
        local alien
        alien = myNiveau.liste_enemy[i]
        
        for t=#listeTirsHero,1,-1 do
          local tir = listeTirsHero[t]
        
        
          if alien.type == "boss" then
            if collision(tir, targetBoss) then
              alien.energy = alien.energy - 10
              CreeAlienExplose(targetBoss.x-20, targetBoss.y-20)
              sndShootHero:play()
              table.remove(listeTirsHero, t)
              if alien.energy == 0 then
                table.remove(myNiveau.liste_enemy, i)
                bossExplose = true
              end
            end  
          elseif collision(tir, alien) == true then
              alien.energy = alien.energy - 10
              CreeAlienExplose(alien.x, alien.y)
              sndShootHero:play()
              table.remove(listeTirsHero, t)
              if alien.energy == 0 then
                table.remove(myNiveau.liste_enemy, i)
              end
          end
        end
        
        
      end
      
      for na=#listeTirsAlien,1,-1 do
        local t = listeTirsAlien[na]
        if collision(Game.myHero, t) == true then
          Game.myHero.status = "shooted"
          table.remove(listeTirsAlien, na)
          HeroExploseX = Game.myHero.x
          HeroEXploseY = Game.myHero.y
        end
      end
      
      
      for ex=#alienExploseListe,1,-1 do
        local explo
        explo = alienExploseListe[ex]
        explo.frame = explo.frame + 0.4
        if math.floor(explo.frame) >= 5 then
          table.remove(alienExploseListe, ex)
        end
          
      end
      
      
      if transition == true then
        transitionTimer = transitionTimer - 1
        if transitionTimer == 0 then
          transitionTimer = 200
          transition = false
          currentNiveau = currentNiveau + 1
          if currentNiveau > maxNiveau then
            Game.ecran = "winner"
          end
          myNiveau.setNiveau(currentNiveau)
          Game.initHero()
        end
      end
    end
    
    if Game.myHero.status == "crashing" then
      HeroCrashFrame = HeroCrashFrame + 0.08
      HeroCrash_vy = (Game.hauteur-Game.myHero.y)/5 * (HeroCrashFrame-2)
      HeroCrash_X = Game.myHero.x + HeroCrash_vx--+ math.random(-10,10)
      HeroCrash_Y = Game.myHero.y + HeroCrash_vy --+ math.random(-10,10) + HeroCrash_vy
      if math.floor(HeroCrashFrame) >= 16 then
        Game.myHero.status = "dead"
        --Game.ecran = "dead"
      else
        local image = imgHeroCrash[math.floor(HeroCrashFrame)]
        if HeroCrash_Y >= (Game.hauteur-64) then 
          HeroCrash_Y = (Game.hauteur-64)
          HeroCrash_vx = HeroCrash_vx -2
        end
      end
      
    end
    
    if Game.myHero.status == "shooted" then
      HeroExploseFrame = HeroExploseFrame + 0.18
        --HeroCrash_vy = (Game.hauteur-HeroEXploseY)/5 * (HeroCrashFrame-2)
      if math.floor(HeroExploseFrame) >= 10 then
        Game.myHero.status = "dead"
        --Game.ecran = "dead"
      end
    end
    
    if bossExplose == true then
      bossExploseFrame = bossExploseFrame + 0.2
      if math.floor(bossExploseFrame) >= 24 then
        bossExplose = false
      end
    end
    
    
  end
  
end


function Game.draw()
  if Game.ecran == "start" then
    love.graphics.draw(imgStart, 0,0, 0, Game.largeur/imgStart:getWidth(), Game.hauteur/imgStart:getHeight())
  
  elseif Game.ecran == "help" then
    love.graphics.draw(imgHelp, 0,0, 0, Game.largeur/imgHelp:getWidth(), Game.hauteur/imgHelp:getHeight())
  
  elseif Game.ecran == "winner" then
    love.graphics.draw(imgWin, 0,0, 0, Game.largeur/imgWin:getWidth(), Game.hauteur/imgWin:getHeight())  
  
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
        love.graphics.draw(imgBossEnergy, 900, 10, 0, 1,1)
        love.graphics.rectangle("line", 970, 12, 200, 22)
        love.graphics.setColor(255,0,0)
        love.graphics.rectangle("fill", 970, 13, alien.energy, 20)
        love.graphics.setColor(255,0,0, targetBossFade)
        love.graphics.draw(targetBoss.image, targetBoss.x, targetBoss.y)
        love.graphics.setColor(255,255,255)
        
        
      end
    end
    
    local n
    for n=1,#listeTirsHero do
      local t = listeTirsHero[n]
      love.graphics.draw(t.image, t.x, t.y, 0, 0.5, 0.5)
    end
    
    local na
    for na=1,#listeTirsAlien do
      local t = listeTirsAlien[na]
      love.graphics.draw(t.image, t.x, t.y, 0, 1, 1)
    end
    
    
    for ex=#alienExploseListe,1,-1 do
      local explo
      explo = alienExploseListe[ex]
      love.graphics.draw(explo.listeFrames[math.floor(explo.frame)], explo.x, explo.y, 0, 2,2)
    end
    
    
    if Game.myHero.status == "playing" or Game.myHero.status == "warning" then
      love.graphics.draw(Game.myHero.image, Game.myHero.x, Game.myHero.y, 0, 1,1)
      
      if transition == true and currentNiveau < maxNiveau then
        love.graphics.draw(imgTransition, Game.largeur/2-imgTransition:getWidth()/2, Game.hauteur/4)
      end
      
    end
    
    if bossExplose == true then
      local image = imgBossExplose[math.floor(bossExploseFrame)]
      love.graphics.draw(imgBossExplose.image, image, targetBoss.x - 64*5, targetBoss.y-64*5, 0, 5,5)
    end
    
    
    if Game.myHero.status == "warning" then
      love.graphics.draw(imgWarning, 300, 40, 0, 1.5,1.5)
    end
    
    if Game.myHero.status == "crashing" then
      local image = imgHeroCrash[math.floor(HeroCrashFrame)]
      love.graphics.draw(imgHeroCrash.image, image, HeroCrash_X, HeroCrash_Y, 0, 1,1)
    end
    
    if Game.myHero.status == "shooted" then
      local image = imgHeroExplose[math.floor(HeroExploseFrame)]
      love.graphics.draw(image, Game.myHero.x, Game.myHero.y-Game.myHero.image:getHeight()/2, 0, 0.5,0.5)
    end
    
    if Game.myHero.status == "dead" then
      love.graphics.draw(imgDead, Game.largeur/2-imgDead:getWidth()/2, Game.hauteur/4)
    end
    
    
      --love.graphics.print("nb enemy = "..#myNiveau.liste_enemy, 0,20)
      --love.graphics.print("nb tirs = "..#listeTirsHero, 0,0)
      --love.graphics.print("transition: "..tostring(transition), 0, 40)
      --love.graphics.print("transition timer: "..transitionTimer, 0, 60)
      --love.graphics.print("niveau = "..currentNiveau, 0, 80)
      --love.graphics.print("ecran = "..Game.ecran, 120, 0)
      --love.graphics.print("status = "..Game.myHero.status, 120, 20)
      
      --love.graphics.print("warningcount = "..warningCount, 300, 0)
      --love.graphics.print("alien explose = "..#alienExploseListe, 300, 20)
      --love.graphics.print("tirs alien = "..#listeTirsAlien, 300, 40)
      
      --love.graphics.print("target X = "..targetBoss.x, 300, 100)
      --love.graphics.print("target Y = "..targetBoss.y, 300, 120)
      --love.graphics.print("target fade = "..targetBossFade, 300, 140)
      
      --love.graphics.print("boss exlose frame = "..math.floor(bossExploseFrame), 300, 140)
      
      
  end
end


return Game