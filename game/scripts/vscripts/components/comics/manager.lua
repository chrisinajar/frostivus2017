Debug.EnabledModules['comics:manager'] = true

ComicManager = ComicManager or class({})

function ComicManager:Init()
  self:ShowSlide('splash')
end

function ComicManager:Show(comicData, callback)
  if not self.hasSplashed then
    self:ShowSlide('splash')
    self.hasSplashed = true
    Timers:CreateTimer(4, function()
      self:Show(comicData, callback)
    end)
    return
  end
  -- show comic, callback when it's done
  -- it either ends when the comic is over or when all users click skip
  local currentIndex = 0
  Timers:CreateTimer(function()
    currentIndex = currentIndex + 1
    if not comicData[currentIndex] then
      self:Hide()
      callback({})
      return
    end
    self:ShowSlide(comicData[currentIndex].image)
    return comicData[currentIndex].duration
  end)
end

function ComicManager:Hide ()
  CustomNetTables:SetTableValue("comics", "state", {
    shown = false
  })
end
function ComicManager:ShowSlide (image)
  DebugPrint('Showing slide: ' .. image)
  CustomNetTables:SetTableValue("comics", "state", {
    shown = true,
    image = image
  })
end
