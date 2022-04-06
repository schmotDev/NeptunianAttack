-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end


local myGame = require("game")


function love.load()
  
  myGame.load()  
end


function love.update(dt)
  
  myGame.update(dt)
end



function love.draw()
  
  myGame.draw()
end

function love.keypressed(key)
  if key == "h" then
    if myGame.ecran ~= "help" then
      myGame.ecranback = myGame.ecran
      myGame.ecran = "help"
    else
      myGame.ecran = myGame.ecranback
    end
  end
  
  if key == "space" then
    if myGame.ecran == "start" then
      myGame.ecran = "playing"
    elseif myGame.ecran == "playing" and (myGame.myHero.status == "playing" or myGame.myHero.status == "warning") then
      myGame.CreeTirHero()
    elseif myGame.ecran == "playing" and myGame.myHero.status == "dead" then
      myGame.load()
    end
  end
  
  
  
end