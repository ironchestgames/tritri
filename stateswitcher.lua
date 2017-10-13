--[[
State switcher class: stateswitcher.lua
Author: Daniel Duris, (CC-BY) 2014
dusoft[at]staznosti.sk
http://www.ambience.sk

License: CC-BY 4.0
This work is licensed under the Creative Commons Attribution 4.0
International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by/4.0/ or send a letter to
Creative Commons, 444 Castro Street, Suite 900, Mountain View,
California, 94041, USA.

Modded by Fredrik Vestin
http://www.fredrikvestin.com
It is now used like so:
state.switch('newstate', arg1, arg2, ...)
..where arg1-n can be any type, like a table or a function.
]]--

passvar={}
state={}

function state.switch(_state, ...)
   passvar = ...
   state = _state
   package.loaded[state]=false
   require(state)
   love.load() -- load the new scene
end

function state.clear()
   passvar=nil
end

return state
