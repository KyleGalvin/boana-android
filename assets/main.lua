--main.lua
local ffi = require 'ffi'
local sdl = require 'SDL2'
local ogl = require 'OpenGLES2'
local esu = require 'esUtil'
local Quaternion = require 'quaternion'

function loadShader(type, shaderSrc )

	--convert gles shader program string into c data type
	--local test= ffi.cast("point *", ffi.new("char[?]", ffi.sizeof(shaderSrc)));
	--local cSourceStr = ffi.new("const char *[?]",#shaderSrc)

	--ffi.copy(cSourceStr,shaderSrc)

	local shader
	local compiled = ffi.new("int[1]")
	compiled = ffi.cast("int*",compiled)
	
	local cSourceStrPtr = ffi.new("const char ["..#shaderSrc.."]",shaderSrc)
	local cSourceStrPtrPtr = ffi.new("const char *[1]",cSourceStrPtr)
	--cSourceStrPtr = ffi.cast("const char **",cSourceStrPtr)
	--print("source again:",ffi.string(cSourceStrPtr, #shaderSrc))   

	--Create the shader object
	shader = ogl.glCreateShader(type)

	if shader == 0 then
		return 0
	end

	--Load the shader source
	local srcLen = ffi.new("int[1]", #shaderSrc)

	ogl.glShaderSource(shader, 1, cSourceStrPtrPtr, srcLen)

	--Compile the shader
	ogl.glCompileShader(shader)

	--print("inside shader: ", shader)

	--Check the compile status
	ogl.glGetShaderiv(shader, ogl.GL_COMPILE_STATUS, compiled)
	if compiled[0] == ogl.GL_FALSE then
		print("ERROR LOADING SHADER")
		local infoLen = ffi.new("int[1]")
		infoLen = ffi.cast("int*",compiled)

		ogl.glGetShaderiv(shader, ogl.GL_INFO_LOG_LENGTH, infoLen)

		if infoLen[0] > 1 then
			print("GLES shader loading error. retrieving log:", infoLen[0])
			local infoLog = ffi.new("char[200]")
			local infoLog = ffi.cast("char*",infoLog)
			ogl.glGetShaderInfoLog(shader, infoLen[0], NULL, infoLog)

			print("Error: ",ffi.string(infoLog, infoLen[0]))    
		end

		ogl.glDeleteShader(shader)
		return 0
	end

	return shader

end

function initOGLES2(esContext)


	local triangleColors =
		{
		    1.0, 0.0, 0.0, 1.0,
		    0.0, 1.0, 0.0, 1.0,
		    0.0, 1.0, 0.0, 1.0,
		}

	local vShaderSrc = _lua_get_script("shaders/test.vert")
	local fShaderSrc = _lua_get_script("shaders/test.frag")


	local vShaderID = loadShader(ogl.GL_VERTEX_SHADER, vShaderSrc)
	local fShaderID = loadShader(ogl.GL_FRAGMENT_SHADER, fShaderSrc)

	local programObject = ogl.glCreateProgram()

	if programObject == 0 then
		return 0
	end
	--print("vshader:", vShaderID, fShaderID, programObject)

	ogl.glAttachShader(programObject,vShaderID)
	ogl.glAttachShader(programObject,fShaderID)

	ogl.glBindAttribLocation(programObject,0,"vPosition")

	ogl.glLinkProgram(programObject)

	local linked = ffi.new("int[1]")
	linked = ffi.cast("int*",linked)
	ogl.glGetProgramiv(programObject, ogl.GL_LINK_STATUS, linked)
	if linked[0] == ogl.GL_FALSE then
		local infoLen = ffi.new("int[1]")
		infoLen = ffi.cast("int*",infoLen)	
		ogl.glGetProgramiv(programObject, ogl.GL_INFO_LOG_LENGTH, infoLen)

		if infoLen[0] > 1 then
			print("GLES shader linking error. retrieving log:")
			local infoLog = ffi.new("char[200]")
			local infoLog = ffi.cast("char*",infoLog)
			ogl.glGetProgramInfoLog(programObject, infoLen[0], nil, infoLog)

			print("Error: ",ffi.string(infoLog, infoLen[0]))
		end

		ogl.glDeleteProgram(programObject)
		return false
	end

	esContext.userData.programObject = programObject

	print("done initialize")
	return true
end

function Draw(esContext, window) -- Here's Where We Do All The Drawing

    local triangleVertices =
		{
			0.0, 0.5, 0.0,
			-0.5, -0.5, 0.0,
			0.5, -0.5, 0.0,
		}
	local CTriangleVerts = ffi.new("float["..#triangleVertices.."]",triangleVertices)
	--local triVertPtr = ffi.cast("float*",triangleVertices)
	--print("dimensions: ",esContext.width, esContext.height)
	esu.glViewport(0,0,esContext.width, esContext.height)

	ogl.glUseProgram(esContext.userData.programObject)
	local uniformVar =  ogl.glGetUniformLocation(esContext.userData.programObject, "projection")
	local myMat4 = ffi.new("float [16]", { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 })
	--print("didnt crash 1")
	ogl.glUniformMatrix4fv(uniformVar, 1, ogl.GL_FALSE, myMat4)
	--print("didnt crash 2")
	ogl.glVertexAttribPointer(0,3,ogl.GL_FLOAT,ogl.GL_FALSE,0,CTriangleVerts)

	ogl.glEnableVertexAttribArray(0)

	ogl.glDrawArrays(ogl.GL_TRIANGLES,0,3)

	sdl.gL_SwapWindow(window)
    

end

function Main()

	-- Initialize SDL.
	if sdl.init(sdl.INIT_VIDEO) < 0 then
		return 1
	end

	sdl.gL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_ES)
	sdl.gL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 2)

	sdl.gL_SetAttribute(sdl.GL_ACCELERATED_VISUAL, 1)
	sdl.gL_SetAttribute(sdl.GL_DOUBLEBUFFER, 1)
	sdl.gL_SetAttribute(sdl.GL_DEPTH_SIZE, 24)
	-- create the window and renderer
	-- note that the renderer is accelerated

	local width = 1000
	local height = 1000

	local win = sdl.createWindow("Image Loading", 0, 0, width, height, bit.bor(sdl.WINDOW_OPENGL, sdl.WINDOW_FULLSCREEN_DESKTOP, sdl.WINDOW_RESIZABLE)) 
	local gl_context = sdl.gL_CreateContext(win)
	local renderer = sdl.createRenderer(win, -1, sdl.RENDERER_ACCELERATED)	

	--ogl.glViewport (0, 0, width, height)

	local touchX = 0
	local touchY = 0

	local esContext = {}

	esContext.userData = {}
	esContext.width = width
	esContext.height = height
	esContext.ratio = width/height


	-- start openGL ES 2 program
	initOGLES2(esContext)
	local e = ffi.new("SDL_Event")

	print("Entering main game loop")
	local p = Quaternion.unit()
	local q = Quaternion:Create({1,0,1,0})
	q:is_zero()
	print("quaternion: ", tostring(q))
	-- main loop
	while 1 do
		
		-- event handling
		if sdl.pollEvent(e) then
			if e.type == sdl.QUIT then
				break
			elseif e.type == sdl.FINGERMOTION then
				touchX = e.tfinger.x
				touchY = e.tfinger.y
			elseif e.type == sdl.FINGERDOWN then
				touchX = e.tfinger.x
				touchY = e.tfinger.y

			elseif e.type == sdl.WINDOWEVENT then
				local wEvent = e.window.event
					if wEvent == sdl.WINDOWEVENT_RESIZED then
						esContext.width = e.window.data1
						esContext.height = e.window.data2
						esContext.ratio = e.window.data1 / e.window.data2
					end
			elseif e.type == sdl.KEYUP and e.key.keysym.sym == sdl.SDLK_ESCAPE then
				break
			end
		end


		-- modify the scene
		ogl.glClearColor(touchX,0,touchY,1)
		ogl.glClear(bit.bor(ogl.GL_COLOR_BUFFER_BIT , ogl.GL_DEPTH_BUFFER_BIT , ogl.GL_STENCIL_BUFFER_BIT))

		local res = sdl.renderClear(renderer)


		Draw(esContext, win)
		--print('done draw')


		-- flip the backbuffer to the screen in order to render changes
		sdl.renderPresent(renderer)
		
	end
	print("exiting")
	--cleanup before exiting
	sdl.destroyRenderer(renderer)
	sdl.destroyWindow(win)

end

Main()