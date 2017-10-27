
ComicManager = ComicManager or class({})

function ComicManager:Show(comicData, callback)
  -- show comic, callback when it's done
  -- it either ends when the comic is over or when all users click skip
  Timers:CreateTimer(2, function()
    callback({})
  end)
end
