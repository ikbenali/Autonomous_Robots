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


baseHandle,interModuleDelay,rotationAmount=...
    if (simGetScriptExecutionCount()==0) then
        modulePos=simGetScriptSimulationParameter(sim_handle_self,'modulePosition')
        tip=simGetObjectHandle('hexa_footTip')
        target=simGetObjectHandle('hexa_footTarget')
        j1=simGetObjectHandle('hexa_joint1')
        j2=simGetObjectHandle('hexa_joint2')
        j3=simGetObjectHandle('hexa_joint3')
        simSetJointPosition(j1,0)
        simSetJointPosition(j2,-30*math.pi/180)
        simSetJointPosition(j3,120*math.pi/180)
        footOriginalPos=simGetObjectPosition(tip,baseHandle)
        isf=simGetObjectSizeFactor(baseHandle)
    end

    data=simReceiveData(0,'HEXA_x')
    xMovementTable=simUnpackFloats(data)
    data=simReceiveData(0,'HEXA_y')
    yMovementTable=simUnpackFloats(data)
    data=simReceiveData(0,'HEXA_z')
    zMovementTable=simUnpackFloats(data)

    -- Make sure that scaling during simulation will work flawlessly:
    sf=simGetObjectSizeFactor(baseHandle)
    af=sf/isf

    v={xMovementTable[1+modulePos*interModuleDelay]*sf,yMovementTable[1+modulePos*interModuleDelay]*sf,zMovementTable[1+modulePos*interModuleDelay]*sf}

    -- Here we calculate a rotation component w (so the robot can rotate around its own z-axis):
    m=simGetObjectMatrix(j1,baseHandle)
    m[4]=0
    m[8]=0
    m[12]=0
    if (rotationAmount<0) then
        m2=simBuildMatrix({0,0,0},{0,0,-math.pi/2})
    else
        m2=simBuildMatrix({0,0,0},{0,0,math.pi/2})
    end
    m=simMultiplyMatrices(m,m2)
    w=simMultiplyVector(m,{v[1]*math.abs(rotationAmount),v[2]*math.abs(rotationAmount),v[3]*math.abs(rotationAmount)})

    -- Now we combine the linear and rotation movement components (v and w):
    v={v[1]+w[1],v[2]+w[2],v[3]+w[3]}

    targetNewPos={footOriginalPos[1]*af+v[1],
                footOriginalPos[2]*af+v[2],
                footOriginalPos[3]*af+v[3]}

    simSetObjectPosition(target,baseHandle,targetNewPos)

    simHandleChildScripts(sim_call_type)



------------------------------------------------------------------------------
-- Following few lines automatically added by V-REP to guarantee compatibility
-- with V-REP 3.1.3 and later:
end
------------------------------------------------------------------------------
