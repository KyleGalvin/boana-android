-- Quaternions
-- Author: Andrew Stacey
-- Website: http://www.math.ntnu.no/~stacey/HowDidIDoThat/iPad/Codea.html
-- Licence: CC0 http://wiki.creativecommons.org/CC0

--[[
This is a class for handling quaternion numbers.  It was originally
designed as a way of encoding rotations of 3 dimensional space.
--]]
require 'class'

local Quaternion = class(nil,{a=0,b=0,c=0,d=0})

--[[
A quaternion can either be specified by giving the four coordinates as
real numbers or by giving the scalar part and the vector part.
--]]

function Quaternion:init(...)
    -- you can accept and set parameters here
    if arg.n == 4 then
        -- four numbers
        self.a = arg[1]
    self.b = arg[2]
    self.c = arg[3]
    self.d = arg[4]
    elseif arg.n == 2 then
        -- real number plus vector
    self.a = arg[1]
    self.b = arg[2].x
    self.c = arg[2].y
    self.d = arg[2].z
    else
        print("Incorrect number of arguments to Quaternion")
    end
end

--[[
Test if we are zero.
--]]

function Quaternion:is_zero()
    print("is zero?")
    -- are we the zero vector
    if self.a ~= 0 or self.b ~= 0 or self.c ~= 0 or self.d ~= 0 then
        return false
    end
    return true
end

--[[
Test if we are real.
--]]

function Quaternion:is_real()
    -- are we the zero vector
    if self.b ~= 0 or self.c ~= 0 or self.d ~= 0 then
        return false
    end
    return true
end

--[[
Test if the real part is zero.
--]]

function Quaternion:is_imaginary()
    -- are we the zero vector
    if self.a ~= 0 then
        return false
    end
    return true
end

--[[
Test for equality.
--]]

function Quaternion:is_eq(q)
    if self.a ~= q.a or self.b ~= q.b or self.c ~= q.c or self.d ~= q.d then
        return false
    end
    return true
end

--[[
Defines the "==" shortcut.
--]]

function Quaternion:__eq(q)
    return self:is_eq(q)
end

--[[
The inner product of two quaternions.
--]]

function Quaternion:dot(q)
    return self.a * q.a + self.b * q.b + self.c * q.c + self.d * q.d
end

--[[
Makes "q .. p" return the inner product.

Probably a bad choice and likely to be removed in future versions.
--]]

function Quaternion:__concat(q)
    return self:dot(q)
end

--[[
Length of a quaternion.
--]]

function Quaternion:len()
    return math.sqrt(math.pow(self.a,2) + math.pow(self.b,2) + math.pow(self.c,2) + math.pow(self.d,2))
end

--[[
Often enough to know the length squared, which is quicker.
--]]

function Quaternion:lensq()
    return math.pow(self.a,2) + math.pow(self.b,2) + math.pow(self.c,2) + math.pow(self.d,2)
end

--[[
Normalise a quaternion to have length 1, if possible.
--]]

function Quaternion:normalise()
    local l
    if self:is_zero() then
        print("Unable to normalise a zero-length quaternion")
        return false
    end
    l = 1/self:len()
    return self:scale(l)
end

--[[
Scale the quaternion.
--]]

function Quaternion:scale(l)
    return Quaternion:Create({self.a * l,self.b * l,self.c * l, self.d * l})
end

--[[
Add two quaternions.  Or add a real number to a quaternion.
--]]

function Quaternion:add(q)
    if type(q) == "number" then
        return Quaternion:Create({self.a + q, self.b, self.c, self.d})
    else
        return Quaternion:Create({self.a + q.a, self.b + q.b, self.c + q.c, self.d + q.d})
    end
end

--[[
q + p
--]]

function Quaternion:__add(q)
    return self:add(q)
end

--[[
Subtraction
--]]

function Quaternion:subtract(q)
    return Quaternion:Create({self.a - q.a, self.b - q.b, self.c - q.c, self.d - q.d})
end

--[[
q - p
--]]

function Quaternion:__sub(q)
    return self:subtract(q)
end

--[[
Negation (-q)
--]]

function Quaternion:__unm()
    return self:scale(-1)
end

--[[
Length (#q)
--]]

function Quaternion:__len()
    return self:len()
end

--[[
Multiply the current quaternion on the right.

Corresponds to composition of rotations.
--]]

function Quaternion:multiplyRight(q)
    local a,b,c,d
    a = self.a * q.a - self.b * q.b - self.c * q.c - self.d * q.d
    b = self.a * q.b + self.b * q.a + self.c * q.d - self.d * q.c
    c = self.a * q.c - self.b * q.d + self.c * q.a + self.d * q.b
    d = self.a * q.d + self.b * q.c - self.c * q.b + self.d * q.a
    return Quaternion:Create({a,b,c,d})
end

--[[
q * p
--]]

function Quaternion:__mul(q)
    if type(q) == "number" then
        return self:scale(q)
    elseif type(q) == "table" then
        if q:is_a(Quaternion) then
                return self:multiplyRight(q)
        end
    end
end

--[[
Multiply the current quaternion on the left.

Corresponds to composition of rotations.
--]]

function Quaternion:multiplyLeft(q)
    return q:multiplyRight(self)
end

--[[
Conjugation (corresponds to inverting a rotation).
--]]

function Quaternion:conjugate()
    return Quaternion:Create({self.a, - self.b, - self.c, - self.d})
end

function Quaternion:co()
    return self:conjugate()
end

--[[
Reciprocal: 1/q
--]]

function Quaternion:reciprocal()
    if self.is_zero() then
        print("Cannot reciprocate a zero quaternion")
        return false
    end
    local q = self:conjugate()
    local l = self:lensq()
    q = q:scale(1/l)
    return q
end

--[[
Integral powers.
--]]

function Quaternion:power(n)
    if n ~= math.floor(n) then
        print("Only able to do integer powers")
        return false
    end
    if n == 0 then
        return Quaternion:Create({1,0,0,0})
    elseif n > 0 then
        return self:multiplyRight(self:power(n-1))
    elseif n < 0 then
        return self:reciprocal():power(-n)
    end
end

--[[
q^n

This is overloaded so that a non-number exponent returns the
conjugate.  This means that one can write things like q^* or q^"" to
get the conjugate of a quaternion.
--]]

function Quaternion:__pow(n)
    if type(n) == "number" then
        return self:power(n)
    else
        return self:conjugate()
    end
end

--[[
Division: q/p
--]]

function Quaternion:__div(q)
    if type(q) == "number" then
        return self:scale(1/q)
    elseif type(q) == "table" then
        if q:is_a(Quaternion) then
                return self:multiplyRight(q:reciprocal())
        end
    end
end

--[[
Returns the real part.
--]]

function Quaternion:real()
    return self.a
end

--[[
Returns the vector (imaginary) part as a Vec3 object.
--]]

function Quaternion:vector()
    return Vec3(self.b, self.c, self.d)
end

--[[
Represents a quaternion as a string.
--]]

function Quaternion:__tostring()
    print("in tostring")
    local s
    local im ={{self.b,"i"},{self.c,"j"},{self.d,"k"}}
    if self.a ~= 0 then
        s = self.a
    end
    for k,v in pairs(im) do
    if v[1] ~= 0 then
        if s then 
                if v[1] > 0 then
                    if v[1] == 1 then
                        s = s .. " + " .. v[2]
                    else
                        s = s .. " + " .. v[1] .. v[2]
                    end
                else
                    if v[1] == -1 then
                        s = s .. " - " .. v[2]
                    else
                        s = s .. " - " .. (-v[1]) .. v[2]
                    end
                end
        else
                if v[1] == 1 then
                    s = v[2]
                elseif v[1] == - 1 then
                    s = "-" .. v[2]
                else
                    s = v[1] .. v[2]
                end
        end
    end
    end
    if s then
        return s
    else
        return "0"
    end
end

--[[
(Not a class function)

Returns a quaternion corresponding to the current gravitational vector
so that after applying the corresponding rotation, the y-axis points
in the gravitational direction and the x-axis is in the plane of the
iPad screen.

When we have access to the compass, the x-axis behaviour might change.
--]]

function Quaternion.Gravity()
    local gxy, gy, gygxy, a, b, c, d
    if Gravity.x == 0 and Gravity.y == 0 then
        return Quaternion:Create({1,0,0,0})
    else
        gy = - Gravity.y
        gxy = math.sqrt(math.pow(Gravity.x,2) + math.pow(Gravity.y,2))
        gygxy = gy/gxy
        a = math.sqrt(1 + gxy - gygxy - gy)/2
        b = math.sqrt(1 - gxy - gygxy + gy)/2
        c = math.sqrt(1 - gxy + gygxy - gy)/2
        d = math.sqrt(1 + gxy + gygxy + gy)/2
        if Gravity.y > 0 then
                a = a
                b = b
        end
        if Gravity.z < 0 then
                b = - b
                c = - c
        end
        if Gravity.x > 0 then
                c = - c
                d = - d
        end
        return Quaternion:Create({a,b,c,d})
    end
end

--[[
Converts a rotation to a quaternion.  The first argument is the angle
to rotate, the rest must specify an axis, either as a Vec3 object or
as three numbers.
--]]

function Quaternion.Rotation(a,...)
    local q,c,s
    q = Quaternion:Create({0,...})
    q = q:normalise()
    c = math.cos(a/2)
    s = math.sin(a/2)
    q = q:scale(s)
    q = q:add(c)
    return q
end

--[[
The unit quaternion.
--]]

function Quaternion.unit()
    print("building unit")
    return Quaternion:Create({1,0,0,0})
end

return Quaternion