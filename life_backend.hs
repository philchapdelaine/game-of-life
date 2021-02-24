module Life_backend where

-- currently I worry we might have a problem where the Board will get too big
-- some solutions could be: - have a set width and height of the board - not a huge fan since the board should be infinite in the game of life
--                          - we trim it when an area is all "dead" - I like this one more and we can probably implement it later rather than sooner

type Position = (Int,Int)

data CellState = Alive | Dead 
    deriving (Eq, Show)

data Cell = Cell CellState Position
    deriving (Eq, Show)

type Board = [Cell]

data Result = EndOfGame Board       -- end of game, everything is dead
            | ContinueGame Board    -- continue with updated board


-- get all the internal postions from a list of cells
getCellPositions :: [Cell] -> [Position]
getCellPositions cells = [position | (Cell state position) <- cells]

-- tests
-- let position = (0,0)
-- let cell = Cell Alive position
-- let cells = [cell]
-- getCellPositions cells
-- let cells = [cell, cell, cell]
-- getCellPositions cells


-- (-1,-1) (0, -1) (1, -1)
-- (-1, 0)         (1 , 0) <- relative adjacent coordinates
-- (-1, 1) (0 , 1) (1 , 1) 

-- get the world coordinates of adjacent cells to a given position
getAdjacents :: Position -> [Position]
getAdjacents (x,y) = map (\ (i,j) -> (i+x, j+y)) adjacent
    where adjacent = [(-1,-1), (0, -1), (1, -1), (-1, 0), (1 , 0), (-1, 1), (0 , 1), (1 , 1)]

-- tests
-- getAdjacents (0,0) 
-- getAdjacents (3,4)


-- given a Cell and the Board it resides on, return a list of it's neighbouring Cells
neighbours :: Cell -> Board -> [Cell]
neighbours (Cell _ position) board = 
    currAdjacents ++ otherAdjacents
    where 
        adjacentPositions = getAdjacents position
        currAdjacents = [(Cell state position) | (Cell state position) <- board,  position `elem` adjacentPositions] -- Already existing cells on board
        otherAdjacents = [(Cell Dead position) | position <- adjacentPositions, not (position `elem` (getCellPositions currAdjacents))] -- Cells currently not on the board

-- tests
-- let cell1 = Cell Alive (3,3)
-- let cell2 = Cell Alive (3,4)
-- let board = [cell1, cell2]
-- neighbours cell1 board
-- returns True if cell is Alive
isAlive :: Cell -> Bool
isAlive (Cell state _)
    | state == Alive = True
    | otherwise = False

-- counts the number of occurances in the list that matches parameter p 
count :: Num p => (t -> Bool) -> [t] -> p
count p [] = 0
count p (h:t) = if p h then 1 + count p t else count p t
    
-- !!TODO!!: given a cell and it's neighbours (and a probability?), return the cell in the next generation
-- A cell with 2 or 3 live neighbours survives
-- A dead cell with 3 live neighbours becomes live
-- All other cells become dead. Dead cells stay dead
nextCellGeneration :: Cell -> [Cell] -> Cell
nextCellGeneration (Cell state position) nb = if state == Alive then stillAlive (Cell Alive position) nb else stillDead (Cell Dead position) nb
   where 
       stillAlive c nb = if count (==True) (map isAlive nb) `elem` [2,3] then (Cell Alive position) else (Cell Dead position)
       stillDead c nb = if count (==True) (map isAlive nb) == 3 then (Cell Alive position) else (Cell Dead position)

--stillAlive:: Cell -> [Cell] -> Cell 
--stillAlive (Cell Alive p) nb = if (count (==True) (map isAlive nb)) `elem` [2,3] then (Cell Alive p) else (Cell Dead p)

--stillDead :: Cell -> [Cell] -> Cell
--stillDead (Cell Dead p) nb = if (count (==True) (map isAlive nb)) == 3 then (Cell Alive p) else (Cell Dead p)

--tests
--c1 = Cell Alive (0,1)
--c2 = Cell Alive (1,0)
--c3 = Cell Alive (1,1)
--c4 = Cell Alive (1,2)
--c5 = Cell Alive (2,1)
--c6 = Cell Dead (2,2)
--board = [c1,c2,c3,c4,c5,c6]
--nb = neighbours c3 board
--neigh = neighbours c6 board

-- returns true if all cells on the board are dead, else false
allDead :: Board -> Bool
allDead board = all (==Dead) [state | (Cell state position) <- board]

-- tests
-- let cell1 = Cell Alive (3,3)
-- let cell2 = Cell Alive (3,3)
-- let board = [cell1, cell2]
-- allDead board
-- let board = [cell1, cell1]
-- allDead board
-- allDead []


-- if all dead then return EndOfGame
-- if not then calculate the next board and return it as part of ContinueGame
gameOfLife :: Board -> Result
gameOfLife board
    | allDead nextBoard = EndOfGame nextBoard
    | otherwise = ContinueGame nextBoard
    where
        nextBoard = [nextCellGeneration cell (neighbours cell board) | cell <- board]


-- !!TODO!!
-- generates the nth iteration of the game of life given a starting board
-- probably a good place to make use of memoization
-- play :: Board -> Int -> IO Board

-- play board 0 = return board

-- play board n = 
--     do
--         let result = gameOfLife board
--         if (result == EndOfGame)
--             then
--                 return newBoard
--             else
--                 play newBoard (n-1)
