population = {} -- create the matrix
index = 0
N = 10 -- Matrix rows -

function randomFloat(lower, upper)
  return lower + math.random() * (upper - lower);
end

function createpopulation(N)
  -- Create Nx6 Matrix
  for i=0,N do
    population[i] = {}
    population[i][0] = i
    population[i][1] = randomFloat(0.001,0.01)
    population[i][2] = randomFloat(0.001,0.01)
    population[i][3] = 0
    population[i][4] = 0
    population[i][5] = 0
    population[i][6] = randomFloat(0,100)
  end
end

function getChance(fit, sum)
  chance = fit / sum
  return chance
end

function rouletteselection(population)
  -- determine fitness of pool
  fitness_sum = 0
  fitness_min = 200
  fitness_max = 0
  thresholdG1 = 0.8
  thresholdG2 = 0.6
  thresholdG3 = 0.4
  rouletteTable = {}

  for i = 0, N do
    rouletteTable[i][j] = 0
    j = j + 1
  end

  for i=0,N do
    fitness_sum = fitness_sum + population[i][6]
  end

  for i=0,N do
    if (population[i][6] < fitness_min) then
      fitness_min = population[i][6]
    end
  end

  for i=0,N do
    if(population[i][6] > fitness_max) then
      fitness_max = population[i][6]
    end
  end

  for i=0, #population do

    if (getChance(population[i][6]) >= thresholdG1) then
      rouletteTable[0][j] = population[i][6]

    elseif (getChance(population[i][6]) >= thresholdG2) then
      rouletteTable[1][j] = population[i][6]

    elseif (getChance(population[i][6]) >= thresholdG3) then
      rouletteTable[2][j] = population[i][6]

    else
      rouletteTable[3][j] = population[i][6]
    end

    j = j + 1
  end

end

function crossover(population)
  if (epoch %2) then
    -- execute interpolating function and fill until population has been reached
    -- return new population
  else
    -- execute extrapolation function and fill until population has been reached
    -- return new population
  end
end

function interpolation(parent1,parent2)

end

function extrapolation(parent1,parent2)

end
