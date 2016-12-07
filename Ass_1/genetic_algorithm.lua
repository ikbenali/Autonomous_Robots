------------------------------------------------------------------------------
-- Following few lines automatically added by V-REP to guarantee compatibility
-- with V-REP 3.1.3 and later:
if (sim_call_type==sim_childscriptcall_initialization) then
  simSetScriptAttribute(sim_handle_self,sim_childscriptattribute_automaticcascadingcalls,false)
end
if (sim_call_type==sim_childscriptcall_cleanup) then

end
if (sim_call_type==sim_childscriptcall_sensing) then
  simHandleChildScripts(sim_call_type)
end
if (sim_call_type==sim_childscriptcall_actuation) then
  if not firstTimeHere93846738 then
    firstTimeHere93846738=0
  end
  simSetScriptAttribute(sim_handle_self,sim_scriptattribute_executioncount,firstTimeHere93846738)
  firstTimeHere93846738=firstTimeHere93846738+1

  ------------------------------------------------------------------------------

  -- ************************************************************************
  -- Genetic Algorithm
  -- ************************************************************************
  math.randomseed( os.time() )

  function randomFloat(lower, upper)
    return lower + math.random() * (upper - lower);
  end

  function createpopulation(N)
    -- Create Nx6 Matrix
    local population = {}

    for i = 1, N do
      population[i] = {}
      population[i][1] = i
      population[i][2] = randomFloat(0.001,0.01)
      population[i][3] = randomFloat(0.001,0.01)
      population[i][4] = - randomFloat(0,0.04)
      population[i][5] = 0
      population[i][6] = 0
      population[i][7] = 0
    end
    return population
  end

  function print_population(population)

    for key,val in pairs(population) do
      print(val[1],val[2],val[3],val[4],val[5],val[6],val[7])
    end
  end
  -- Returns fitness within 0-200
  function fitness_test(finish_time, distance)
    if distance == 7 then
      return 100 + fitness_speed(finish_time)
    else
      return fitness_distance(distance)
    end
  end

  -- Returns fitness for time spend
  function fitness_speed(finish_time)
    return (finish_time / 20.0) * 100.0
  end

  -- Returns fitness for distance cleared
  function fitness_distance(distance)
    return (distance / 7.0) * 100.0
  end

  -- Save a generations data to a csv file
  function save_gen_csv(population, gen)
    local file = assert(io.open('/Users/aliulhaq/Documents/V-REP_PRO_EDU_V3_3_2_Mac/scenes/V-Rep_Ass1/gen_' .. gen .. '.txt', 'w+'))
    for key,val in pairs(population) do
      for k,v in pairs(val) do
        file:write(v .. "; ")
      end
      file:write('\n')
    end
    file:close()
  end

  function fitness_stats(population)
    -- determine fitness of pool
    fitness_min = 200
    fitness_max = 0
    fitness_sum = 0

    --get min,sum,max
    for i = 1, #population do
      if population[i][7] < fitness_min then
        fitness_min = population[i][7]
      end

      if population[i][7] > fitness_max then
        fitness_max = population[i][7]
      end

      fitness_sum = fitness_sum + population[i][7]
    end

    fitness_average = fitness_sum / N
    save_growth_csv(fitness_max, fitness_average, fitness_min)
    return fitness_sum
  end

  --Select Parents
  function getParent(population, fitness_sum)
    random_val = math.random() * fitness_sum
    prev = 0.0

    for key,val in pairs(population) do
      if prev <= random_val and random_val <= (prev + val[7]) then
        if (val[7] > 0 ) then
          return val
        else
          prev = prev + val[7]
        end
      else
        prev = prev + val[7]
      end
    end
  end

  function add_to_population(population,children, fitness_sum)

    mutationChance = randomFloat(0, 1)
    if mutationChance <= 0.001 then
      parent = getParent(population, fitness_sum)
      child = mutation(parent, population,children)
    else
      parent1 = getParent(population, fitness_sum)
      parent2 = {}
      repeat
        parent2 = getParent(population, fitness_sum)
      until(parent1 ~= parent2)
      print("The chosen parents are with fitness:",parent1[7],parent2[7])
      child = crossover(parent1, parent2, generation, population,children)
    end

    return child
  end

  function crossover(parent1, parent2, generation, population,children)
    if generation % 2 == 0 then
      return interpolation(parent1, parent2, population,children)
    else
      return extrapolation(parent1, parent2, population,children)
    end
  end

  function interpolation(parent1, parent2, population,children)
    child = {0,0,0,0,0,0,0}
    -- Child has same structure as parent child(index,VAR1,VAR2,VAR3,xdist,time,fit)
    child[1] = #children
    alpha = randomFloat(0,1)
    beta = (alpha * parent1[7]) / (alpha * parent1[7] + (1 - alpha) * parent2[7])

    for i = 2, 4 do
      child[i] = beta * parent1[i] + (1-beta) * parent2[i]
    end

    return child
  end

  function extrapolation(parent1, parent2, population,children)
    child = {0,0,0,0,0,0,0}
    child[1] = #children
    -- Child has same structure as parent child(index,VAR1,VAR2,VAR3,xdist,time,fit)

    alpha = randomFloat(0,1)
    beta = 2*(alpha * parent1[7]) / (alpha * parent1[7] + (1 - alpha) * parent2[7])

    for i = 2, 4 do
      if (beta < 1) then
        child[i] = parent2[i] + ((1-beta) * parent1[i]) * (parent1[i] - parent2[i])
      else
        child[i] = parent1[i] + (beta-1) * parent2[i] * (parent2[i] - parent1[i])
      end
    end
    return child
  end

  function mutation(person, population,children)
    child = {0,0,0,0,0,0,0}
    child[1] = #children
    for i = 2, 4 do
      child[i] = person[i] + randomFloat(0 , 0.0001)
    end
    return child
  end

  -- Save growth data to a csv file to create graph
  function save_growth_csv(maximum, average, minimum)
    local file = assert(io.open('/Users/aliulhaq/Documents/Github/Autonomous_Robots/Ass_1/growth.txt', 'a+'))
    file:write(maximum .. "; " .. average .. "; " .. minimum .. '\n')
    file:close()
  end

  -- After 200 generations save the best individual and shut down.
  function finish_and_close(population)
    spider = {0,0,0,0,0,0,0}
    for k,v in pairs(population) do
      if v[7] > spider[7] then
        spider = v
      end
    end

    local file = assert(io.open('/Users/aliulhaq/Documents/Github/Autonomous_Robots/Ass_1/growth.txt', 'a+'))
    file:write("Best Spider parameters;")
    file:write("step; " .. spider[2] .. ";")
    file:write("vstep; " .. spider[3] .. ";")
    file:write("rearExtent; " .. spider[4] .. ";")
    file:close()

    simStopSimulation();
  end

  -- This hexapod model demonstrates distributed control, where each leg is controlled by its own script
  -- This is meant as an example only. Have a look at the control method of the "ant hexapod", that is much simpler.

  -- This is the initialization (only executed once)
  if (simGetScriptExecutionCount()==0) then

    generation = 0
    counter = 1
    N = 10 -- Matrix rows and population size-
    population = createpopulation(N) -- create the matrix

    baseHandle=simGetObjectHandle('hexa_base') -- get pointer to the base
    interModuleDelay=4 -- each leg has a delay of 4 entries in the movement table (offset in sliding window)
    xMovementTable={} -- movement data for all directions (sliding window)
    yMovementTable={}
    zMovementTable={}
    tableLength=5*interModuleDelay+1 -- size of sliding window sufficient to keep movement data for all legs
    for i=1,tableLength,1 do -- fill table with zeros
      table.insert(xMovementTable,0)
      table.insert(yMovementTable,0)
      table.insert(zMovementTable,0)
    end

    population[1][2] = 0.002 -- Reset to original values
    population[1][3] = 0.005
    population[1][4] = 0

    phase=0 -- phase = movement phase (finite state machine)
    r=0 -- horizontal movement position in step
    z = population[1][4] -- vertical movement position in step
    step = population[1][2] -- goal (max) horizontal step size
    vstep = population[1][3] -- goal (max) vertical step size
    rearExtent = -0.04
    cnt=0 -- expired simulation time
    c=8
    cm0=4
    cm1=16
    prevSt=1

    -- KEEP CONSTANT, no evolution here
    rotation = 0 -- amount the robot rotates around its own axis (-1 to 1)
    direction = 0 -- direction the robot is travelling (0 to math.pi*2)
    forwardVel=1 -- velocity of movement

    -- SAVE (one time in the beginning)
    botPositionInitial = {}
    botOrientationInitial = {}
    t={simGetObjectHandle('hexapod')}
    while (#t~=0) do
      h=t[1]
      botPositionInitial[h] = simGetObjectPosition(h, -1)
      botOrientationInitial[h] = simGetObjectOrientation(h, -1)
      table.remove(t,1)
      ind=0
      child=simGetObjectChild(h,ind)
      while (child~=-1) do
        table.insert(t,child)
        ind=ind+1
        child=simGetObjectChild(h,ind)
      end
    end
    -- END SAVE
  end

  -- Following makes the robot first move straight, then in a circle (while keeping its orientation),
  -- then again in a circle but this time also rotating.
  -- **********************************************************************
  cnt=cnt+simGetSimulationTimeStep()

  -- Following piece of code is just to adjust for a simulationTimeStep change
  -- In that case the table lengths have to be adjusted and the interModule delays, the step sizes, etc.
  -- **********************************************************************
  st=math.floor((0.05/simGetSimulationTimeStep())+0.5)
  if (st~=prevSt) then
    c=c*(st/prevSt)
    cm0=cm0*(st/prevSt)
    cm1=cm1*(st/prevSt)
    interModuleDelay=interModuleDelay*(st/prevSt)
    otx=xMovementTable
    oty=yMovementTable
    otz=zMovementTable
    otl=tableLength
    xMovementTable={}
    yMovementTable={}
    zMovementTable={}
    tableLength=5*interModuleDelay+1
    if ((st/prevSt)>1) then
      for i=1,tableLength,1 do
        table.insert(xMovementTable,otx[math.floor((i/(st/prevSt))+0.51)])
        table.insert(yMovementTable,oty[math.floor((i/(st/prevSt))+0.51)])
        table.insert(zMovementTable,otz[math.floor((i/(st/prevSt))+0.51)])
      end
    else
      for i=1,tableLength,1 do
        table.insert(xMovementTable,otx[math.floor(i*(st/prevSt))])
        table.insert(yMovementTable,oty[math.floor(i*(st/prevSt))])
        table.insert(zMovementTable,otz[math.floor(i*(st/prevSt))])
      end
    end
    prevSt=st
  end
  -- **********************************************************************

  -- Calculate movement data at this time point
  if (phase==2) then
    r=r+step*2/st
    z=z-vstep/st
    c=c+1
    if (c>=cm0) then
      phase=0
      c=0
    end
  end
  if (phase==1) then
    r=r+step*2/st
    z=z+vstep/st
    c=c+1
    if (c>=cm0) then
      phase=2
      c=0
    end
  end
  if (phase==0) then
    r=r-step/st
    c=c+1
    if (c>=cm1) then
      phase=1
      c=0
    end
  end

  -- **********************************************************************

  if (cnt>=20 or simGetObjectPosition(h,-1)[1] == 7) then

    xdist = simGetObjectPosition(h,-1)[1]
    finish_time = cnt

    -- RESTORE (reset to test new individual)
    -- // reset bot to its initial position
    -- // code taken from: http://www.forum.coppeliarobotics.com/viewtopic.php?f=9&t=685
    -- // apparently simSetObjectPosition() itself does not implicitly/sufficiently call simResetDynamicObject() for all the children

    t={simGetObjectHandle('hexapod')}
    while (#t~=0) do
      h=t[1]
      simResetDynamicObject(h)
      simSetObjectPosition(h, -1, botPositionInitial[h])
      simSetObjectOrientation(h, -1, botOrientationInitial[h])
      table.remove(t,1)
      ind=0
      child=simGetObjectChild(h,ind)
      while (child~=-1) do
        table.insert(t,child)
        ind=ind+1
        child=simGetObjectChild(h,ind)
      end
    end

    if (counter == N) then
      save_gen_csv(population, generation)
      fitness_sum = fitness_stats(population)

      if generation >= 200 then
        finish_and_close(population)
      else
        children = {}
        io.write("population " .. #population .. "\n children " .. #children .."\n----------------------\n")
        i = 1
        while #children < N do
          children[i] = add_to_population(population, children,fitness_sum)
          print("I am child No.:",children[i][1])
          i = i +1
        end

        io.write("population " .. #population .. "\n children " .. #children .."\n----------------------\n")
        population = children
        io.write("population " .. #population .. "\n children " .. #children .."\n----------------------\n")
      end

      counter = 1
      generation = generation + 1
      print("The next generation is:",generation)

    end

    cnt = 0
    population[counter][5] = xdist
    population[counter][6] = finish_time
    population[counter][7] = fitness_test(finish_time,xdist)
    counter = counter + 1
    step = population[counter][2]
    vstep = population[counter][3]
    z = population[counter][4]
    print("These may be retard spider values:",step,vstep,z)
  end
  -- END RESTORE

  -- **********************************************************************

  -- convert magnitude r to x-y vector according to set direction (but, we normally only go straight ahead)
  x=forwardVel*r*math.cos(direction)
  y=forwardVel*r*math.sin(direction)

  table.remove(xMovementTable,tableLength) -- remove last item of FIFOs
  table.remove(yMovementTable,tableLength)
  table.remove(zMovementTable,tableLength)
  table.insert(xMovementTable,1,x) -- Insert position data in FIFOs
  table.insert(yMovementTable,1,y)
  table.insert(zMovementTable,1,z)

  -- Communicate data (FIFOs) to each of the legs

  simSendData(sim_handle_tree,0,'HEXA_x',simPackFloats(xMovementTable))
  simSendData(sim_handle_tree,0,'HEXA_y',simPackFloats(yMovementTable))
  simSendData(sim_handle_tree,0,'HEXA_z',simPackFloats(zMovementTable))

  -- execute child scripts
  simHandleChildScripts(sim_call_type,baseHandle,interModuleDelay,rotation)

  ------------------------------------------------------------------------------
  -- Following few lines automatically added by V-REP to guarantee compatibility
  -- with V-REP 3.1.3 and later:
end
------------------------------------------------------------------------------
