-- class.lua
function class(baseClass, body)
   local ret = body or {};
   print('building class', tostring(baseClass), tostring(ret))
   -- if there’s a base class, attach our new class to it
   if (baseClass ~= nil) then
      print('setting index')
      setmetatable(ret, ret);
      ret.__index = baseClass;
   end
   -- Add the Create() function
   ret.Create = function(self, constructionData, originalSubClass)
      local obj;
      if (self.__index ~= nil) then
         print("has __index")
         if (originalSubClass ~= nil) then
            print("1")
         obj = self.__index:Create(constructionData, originalSubClass);
         else
            print("2")
         obj = self.__index:Create(constructionData, self);
         end
      else
         print("No index")
         obj = constructionData or {};
      end
      setmetatable(obj, obj);
      obj.__index = self;
      -- copy any operators over
      if (self.__operators ~= nil) then
         print("operators found!")
         for key, val in pairs(self.__operators) do
            obj[key] = val;
         end
      end
      return obj;
   end
   return ret;
end