module GameState where

import           Graphics.Gloss.Interface.Pure.Game

snakeSize = 30 :: Float

data SnakeGame = Game
  { snakePosition :: [(Float, Float)]
  , direction     :: (Float, Float)
  }

initialState =
  Game
    { snakePosition =
        [ (-195, 285)
        , (-210, 285)
        , (-225, 285)
        , (-240, 285)
        , (-255, 285)
        , (-270, 285)
        , (-285, 285)
        ]
    , direction = (1, 0)
    }

renderGame game = pictures [snakeBody]
  where
    snakeBody = renderFullSnake (snakePosition game)

renderSnakeBodyPart (x, y) = translate x y $ rectangleSolid snakeSize snakeSize

renderFullSnake snakePosition = pictures $ map renderSnakeBodyPart snakePosition

nextFrame _ game = checkGameOver $ game {snakePosition = nextSnakePosition}
  where
    nextSnakePosition = moveSnake (direction game) (snakePosition game)

moveSnake (dirX, dirY) snakePosition = nextPosition
  where
    (headX, headY) = head snakePosition
    newHead =
      teleportThroughWalls $
      (headX + (dirX * snakeSize), headY + (dirY * snakeSize))
    nextPosition = newHead : init snakePosition

checkCollisionWithOwnBody snakePosition = collides
  where
    snakeHead = head snakePosition
    collides = elem snakeHead $ tail snakePosition

checkGameOver game
  | collidesWithOwnBody = initialState
  | otherwise = game
  where
    collidesWithOwnBody = checkCollisionWithOwnBody $ snakePosition game

teleportThroughWalls (x, y) = (newX, newY)
  where
    newX
      | x > 300 = -285
      | x < -300 = 285
      | otherwise = x
    newY
      | y > 300 = -285
      | y < -300 = 285
      | otherwise = y

changeDirection (x, y) game = game {direction = updatedDirection}
  where
    updatedDirection =
      if x /= (-1 * (fst $ direction game))
        then (x, y)
        else direction game

handleKeys (EventKey (SpecialKey KeyUp) _ _ _) game =
  changeDirection (0, 1) game
handleKeys (EventKey (SpecialKey KeyDown) _ _ _) game =
  changeDirection (0, -1) game
handleKeys (EventKey (SpecialKey KeyLeft) _ _ _) game =
  changeDirection (-1, 0) game
handleKeys (EventKey (SpecialKey KeyRight) _ _ _) game =
  changeDirection (1, 0) game
handleKeys (EventKey (Char 'r') _ _ _) game = initialState
handleKeys _ game = game
