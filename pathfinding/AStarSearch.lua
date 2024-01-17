#include "priorityQueue.lua"
#include "mapNode.lua"


--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        AStarSearch.lua             
*
* DESCRIPTION :
*       Implements A Star search in Teardown 2020
*
*       
*
*
* NOTES :
*
*       Yes, i know while loops are bad. This can be optimised by 
*       using for loops and making it async       
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
*                            Release Date :    29 Nov 2021 
*
]]

__ASTAR_DEBUG = false

AStar = {
    APPROACHES = {
        [1] = 'traditional',
        [2] = 'enhanced',
        [3] = 'enhanced',
        [4] = 'enhanced',
        [5] = 'traditional',

    },
    heuristic_approach = "enhanced", -- traditional or enhanced
    maxChecks = 1000,
    cameFrom = {},
    costSoFar = {},
    maxIterations = 10,
    currentIteration = 0,

    heuristicWeight = 21.78,
    vert_heuristic_weight = 1.25,
    vert_limit = 3

}

path_variables = {
    frontier =nil, 
    cameFrom = nil, 
    costSoFar = nil,
    start = nil,
    goal = nil,
    checks = 0
}

active_search = {}





function AStar:Heuristic(a, b)
      return (math.abs(a[1] - b[1]) + math.abs(a[2] - b[2])) * self.heuristicWeight
 end 


function AStar:Heuristic_3d(a, b)
      return (math.abs(a[1] - b[1]) + math.abs(a[2] - b[2])) * self.heuristicWeight
 end 

function AStar:heuristic_vec_3d(node_a,node_b)
    return VecLength(VecSub(node_a:getPos(),node_b:getPos()))* self.vert_heuristic_weight

end


function AStar:AStarSearch(graph, start, goal)
    
        frontier =  deepcopy(PriorityQueue)
        frontier:init(#graph,#graph[1])
        frontier:put(deepcopy(start), 0);

        local startIndex = start:getIndex()
        -- DebugPrint(type(start:getIndex()).." | "..type(start:getIndex()[2]))
        -- DebugPrint("Val = " ..startIndex[1]..startIndex[2])
        local cameFrom = {}
        cameFrom[startIndex[2]] = {}
        cameFrom[startIndex[2]][startIndex[1]] = start;
        local lastIndex = nil
        local costSoFar = {}
        costSoFar[startIndex[2]] = {}
        costSoFar[startIndex[2]][startIndex[1]] = start:getCost();

        local current = nil
        local currentIndex = nil
        local nextNode = nil
        local newCost = 0
        local priority = 0
        local currentIndex = nil
        local nodeExists = false
        local next_node_cost =0
        local next_node_vert_cost = 0
        local totalNodes = 0
        -- DebugPrint(frontier:empty())
        -- for i=1,self.maxChecks do 
        local checks = 0
        for i=1,frontier:size() do 
       --- while not frontier:empty() do
            checks = checks + 1
        
            current = deepcopy(frontier:get()) 

            totalNodes = totalNodes + 1
            if (type(current)~="table" or not current or  current:Equals(goal)) then
                -- DebugPrint("goal found")

                if(_AI_DEBUG_PATHING) then 
                    DebugWatch("goal found, checks taken",checks)
                end
                break
            end  
            currentIndex = current:getIndex()
             for key, val in ipairs(current:getNeighbors()) do
                    nextNode =  deepcopy(graph[val.y][val.x])
                    next_node_cost =  nextNode:getCost()
                    newCost = costSoFar[currentIndex[2]][currentIndex[1]] + next_node_cost
                    nodeExists = ( self:nodeExists(costSoFar,val.y,val.x) )
                    if(nextNode.validTerrain and( not nodeExists or (not (cameFrom[currentIndex[2]][currentIndex[1]]:indexEquals({val.y,val.x}))  and 
                                        newCost < costSoFar[val.y][val.x])) )
                    then 
                        if(not nodeExists) then 
                            if(not costSoFar[val.y]) then 
                                costSoFar[val.y] = {}
                                cameFrom[val.y] = {}
                            end
                        end
                        nextNode:setCost(next_node_cost)
                        costSoFar[val.y][val.x] = newCost
                        priority =   newCost +  self:Heuristic(nextNode:getIndex(),goal:getIndex())
                        frontier:put(nextNode, priority)
                        cameFrom[val.y][val.x] = deepcopy(current)

                        -- DebugPrint(newCost.." | "..val.y.." | "..val.x.." | ")
                        -- lastIndex = deepcopy(val)
                        
                        -- DebugPrint(nextNode:getIndex()[1].." | "..nextNode:getIndex()[2])
                    --+ graph.Cost(current, next);
                    end
             end
         end
         -- DebugPrint("total checks = "..checks)
         
         local path = self:reconstructPath(graph,cameFrom,current,start,totalNodes)
         -- DebugPrint("total nodes: "..totalNodes)
         return path
 end


function AStar:init(graph, start, goal)
        self.heuristic_approach = self.APPROACHES[math.random(1,5)]

        if(_AI_DEBUG_PATHING) then 
            DebugWatch("heuristic_approach",self.heuristic_approach)
        end

        frontier =  deepcopy(PriorityQueue)
        frontier:init(#graph,#graph[1])
        frontier:put(deepcopy(start), 0);

        local startIndex = start:getIndex()
        -- DebugPrint(type(start:getIndex()).." | "..type(start:getIndex()[2]))
        -- DebugPrint("Val = " ..startIndex[1]..startIndex[2])
        local cameFrom = {}
        cameFrom[startIndex[2]] = {}
        cameFrom[startIndex[2]][startIndex[1]] = start;
        local lastIndex = nil
        local costSoFar = {}
        costSoFar[startIndex[2]] = {}
        costSoFar[startIndex[2]][startIndex[1]] = start:getCost();

        local current = nil
        local currentIndex = nil
        local nextNode = nil
        local newCost = 0
        local priority = 0
        local currentIndex = nil
        local nodeExists = false
        local next_node_cost =0
        local totalNodes = 0
        -- DebugPrint(frontier:empty())
        -- for i=1,self.maxChecks do 
        local checks = 0
        active_search = deepcopy(path_variables)
        start_time = GetTime()
        active_search = {
            frontier =frontier, 
            cameFrom = cameFrom, 
            costSoFar = costSoFar,
            start = start,
            goal = goal,
            checks = 0,
        }
        return graph
    end


function AStar:AStarSearch_2(graph)

        
        local frontier =active_search['frontier'] 
        local cameFrom = active_search['cameFrom']
        local costSoFar = active_search['costSoFar']
        local start = active_search['start']
        local goal = active_search['goal']
        local checks = active_search['checks']
        

        local path = nil
        local goal_found = nil
        local current = nil
        local currentIndex = nil
        local nextNode = nil
        local newCost = 0
        local priority = 0
        local currentIndex = nil
        local nodeExists = false
        local next_node_cost =0
        local totalNodes = 0
        local next_node_vert_cost = 0
        local current_time = GetTime()
        -- DebugPrint(frontier:empty())
        -- for i=1,self.maxChecks do 
        search_length = math.max(5,100/current_time) 
        for i=1,search_length do 
       --- while not frontier:empty() do
            checks = checks + 1
        
            current = deepcopy(frontier:get()) 

            totalNodes = totalNodes + 1

            if(type(current)~="table" or not current) then 
                return -1
            elseif  (GetTime() - start_time >5) then 
                goal_found = true
            elseif (current:Equals(goal)) then
                -- DebugPrint("goal found")
                goal_found = true
                    -- local start_tpime = active_search['search_start']
                -- DebugWatch("goal found, time start:", start_time )

                if(_AI_DEBUG_PATHING) then 
                    DebugWatch("goal found, time taken:", current_time - start_time)
                    
                    DebugWatch("goal found, checks taken",checks)
                end
                break
            end  
            currentIndex = current:getIndex()
            for key, val in ipairs(current:getNeighbors()) do
                    nextNode =  deepcopy(graph[val.y][val.x])
                    next_node_cost =  nextNode:getCost()
                    -- next_node_vert_cost = self:heuristic_vec_3d(current,nextNode)
                    if(__ASTAR_DEBUG) then 
                        DebugLine(current:getPos(),nextNode:getPos())
                    end
                    newCost = costSoFar[currentIndex[2]][currentIndex[1]] + next_node_cost --+next_node_vert_cost
                    nodeExists = ( self:nodeExists(costSoFar,val.y,val.x) )
                    if(nextNode.validTerrain and( not nodeExists or (not (cameFrom[currentIndex[2]][currentIndex[1]]:indexEquals({val.y,val.x}))  and 
                                        newCost < costSoFar[val.y][val.x])) )
                    then 
                        if(not nodeExists) then 
                            if(not costSoFar[val.y]) then 
                                costSoFar[val.y] = {}
                                cameFrom[val.y] = {}
                            end
                        end
                        nextNode:setCost(next_node_cost)
                        costSoFar[val.y][val.x] = newCost
                        if(self.heuristic_approach == "traditional") then 
                            priority =   newCost + (self:heuristic_vec_3d(current,nextNode)*self:Heuristic(nextNode:getIndex(),goal:getIndex()))
                        elseif(self.heuristic_approach == "enhanced") then 
                            priority =   newCost *  (self:heuristic_vec_3d(current,nextNode)*self:Heuristic(nextNode:getIndex(),goal:getIndex()))
                        else 
                            priority =   newCost + (self:heuristic_vec_3d(current,nextNode)*self:Heuristic(nextNode:getIndex(),goal:getIndex()))
                        end
                        frontier:put(nextNode, priority)
                        cameFrom[val.y][val.x] = deepcopy(current)

                        -- DebugPrint(newCost.." | "..val.y.." | "..val.x.." | ")
                        -- lastIndex = deepcopy(val)
                        
                        -- DebugPrint(nextNode:getIndex()[1].." | "..nextNode:getIndex()[2])
                    --+ graph.Cost(current, next);
                    end
             end
        end
         -- DebugPrint("total checks = "..checks)
        active_search = {
            frontier =frontier, 
            cameFrom = cameFrom, 
            costSoFar = costSoFar,
            start = start,
            goal = goal,
            checks = checks
        }        
        if(goal_found) then 
            path = self:reconstructPath(graph,cameFrom,current,start,totalNodes)
        end
         -- DebugPrint("total nodes: "..totalNodes)
        return path

 end

 function AStar:nodeExists(listVar,y,x)
     if(listVar[y] and listVar[y][x]) then
        return true
    else
        return false
    end
 end

function AStar:reconstructPath(graph,cameFrom,current,start,totalNodes)
    local path = {}
    local index = current:getIndex()
    -- for i=1,100 do 
    while not current:Equals(start) do
    -- DebugPrint("came from: "..index[1].." | "..index[2])
        path[#path+1] = graph[index[2]][index[1]]:getPos()
        index = cameFrom[current:getIndex()[2]][current:getIndex()[1]]:getIndex()
        current = deepcopy(graph[index[2]][index[1]])
        
        if(current:Equals(start)) then
                -- DebugPrint("found, nodes: "..totalNodes) 

            break

        end


    end
    local tmp = {}
    for i = #path, 1, -1 do
        tmp[#tmp+1] = path[i]
    end
    path = tmp
    return path


end

function AStar:path_to_pos(graph,cameFrom,current,start,totalNodes)
    local path = {}
    local index = current:getIndex()
    -- for i=1,100 do 
    while not current:Equals(start) do
    -- DebugPrint("came from: "..index[1].." | "..index[2])
        path[#path+1] = index
        index = cameFrom[current:getIndex()[2]][current:getIndex()[1]]:getIndex()
        current = deepcopy(graph[index[2]][index[1]])
        
        if(current:Equals(start)) then
                -- DebugPrint("found, nodes: "..totalNodes) 

            break

        end


    end
    local tmp = {}
    for i = #path, 1, -1 do
        tmp[#tmp+1] = path[i]
    end
    path = tmp
    return path


end

 function AStar:drawPath(graph,path)
    local node1,node2 = nil,nil
    for i = 1, #path-1 do
        node1 = graph[path[i][2]][path[i][1]]:getPos()
        node2 = graph[path[i+1][2]][path[i+1][1]]:getPos()
        DebugLine(node1,node2, 1, 0, 0)
    end
 end

 function AStar:drawPath2(graph,path,colours)
    local node1,node2 = nil,nil

    for i = 1, #path-1 do
        node1 = graph[path[i][2]][path[i][1]]:getPos()
        node2 = graph[path[i+1][2]][path[i+1][1]]:getPos()
        DebugLine(node1,node2, 1,0,0)
    end
 end


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
