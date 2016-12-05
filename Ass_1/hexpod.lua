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

-- ******************
-- global variabeles
   counter = 0
   N = 10          -- Matrix rows  -

    function randomFloat(lower, upper)
        return lower + math.random()  * (upper - lower);
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
        population[i][6] = 0
      end

      return population
    end

    function rouletteselection(population)
      -- determine fitness of pool
      fitness_sum = 0
      for i=0,N do
        fitness_sum = fitness_sum + population[i][6]
      end
      return fitness_sum
    end

-- This hexapod model demonstrates distributed control, where each leg is controlled by its own script
    -- This is meant as an example only. Have a look at the control method of the "ant hexapod", that is much simpler.

    -- This is the initialization (only executed once)
    if (simGetScriptExecutionCount()==0) then
        population = createpopulation(N)                     -- create the matrix


        baseHandle=simGetObjectHandle('hexa_base')    -- get pointer to the base
        interModuleDelay=4                          -- each leg has a delay of 4 entries in the movement table (offset in sliding window)
        xMovementTable={}                              -- movement data for all directions (sliding window)
        yMovementTable={}
        zMovementTable={}
        tableLength=5*interModuleDelay+1             -- size of sliding window sufficient to keep movement data for all legs
        for i=1,tableLength,1 do                    -- fill table with zeros
            table.insert(xMovementTable,0)
            table.insert(yMovementTable,0)
            table.insert(zMovementTable,0)
        end
        phase=0                                     -- phase = movement phase (finite state machine)
        r=0                                            -- horizontal movement position in step
        z=0                                            -- vertical movement position in step
        step=population[0][1]                                     -- goal (max) horizontal step size
        vstep=population[0][2]                                  -- goal (max) vertical step size
        rearExtent = population[0][3]
        cnt=0                                        -- expired simulation time
        c=8
        cm0=4
        cm1=16
        prevSt=1

        -- KEEP CONSTANT, no evolution here
        rotation = 0                                     -- amount the robot rotates around its own axis (-1 to 1)
        direction = 0                                 -- direction the robot is travelling (0 to math.pi*2)
        forwardVel=1                                 -- velocity of movement

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
    --  then again in a circle but this time also rotating.
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

    if (cnt>=20) then -- or xdist has reached final
      -- time == cnt
      -- xdist = simGetObjectPosition(h,-1)


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

          -- End of populatio reached, calculate fitness of population
          -- crossover
          -- Mutation
          -- set i to zero again an rerun population

        else
          cnt = 0
          step = population[counter][1]
          vstep = population[counter][2]
          rearExtent= population[counter][3]
          counter = counter + 1
        end

    end
    -- END RESTORE

    -- **********************************************************************

    -- convert magnitude r to x-y vector according to set direction (but, we normally only go straight ahead)
    x=forwardVel*r*math.cos(direction)
    y=forwardVel*r*math.sin(direction)

    table.remove(xMovementTable,tableLength)        -- remove last item of FIFOs
    table.remove(yMovementTable,tableLength)
    table.remove(zMovementTable,tableLength)
    table.insert(xMovementTable,1,x)                -- Insert position data in FIFOs
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
