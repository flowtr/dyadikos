local glfw = require('dyadikos.glfw')({
	'/usr/local/lib/libglfw.so.3',
	bind_vulkan = true,
})
local vk = require('dyadikos.vulkan.vulkan')
local ffi = require('ffi')
local GLFW = glfw.const

local App = { width = 1280, height = 720, title = 'Hello' }

function App:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	if glfw.Init() == 0 then
		return
	end

	-- Create a self.windowed mode self.window and its OpenGL context
	self.window = glfw.CreateWindow(self.width, self.height, self.title)
	if self.window == GLFW.NULL then
		glfw.Terminate()
		error('Failed to create Window')
	end

	-- Make the self.window's context current
	self.window:MakeContextCurrent()

	local vkAppInfo = ffi.new('VkApplicationInfo')
	vkAppInfo.sType = ffi.C.VK_STRUCTURE_TYPE_APPLICATION_INFO
	vkAppInfo.pApplicationName = self.title
	vkAppInfo.applicationVersion = vk.makeVersion(1, 0, 0)
	vkAppInfo.pEngineName = 'No Engine'
	vkAppInfo.engineVersion = vk.makeVersion(1, 0, 0)
	vkAppInfo.apiVersion = vk.makeVersion(1, 0, 0)

	local vkInstanceCreateInfo = ffi.new('VkInstanceCreateInfo')
	vkInstanceCreateInfo.sType = ffi.C.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
	vkInstanceCreateInfo.pApplicationInfo = vkAppInfo

	local glfwExtensions, glfwExtensionsCount =
		glfw.GetRequiredInstanceExtensions()

	local vkGlfwExtensions =
		ffi.new('const char*[?]', glfwExtensionsCount + 1, glfwExtensions)
	vkGlfwExtensions[glfwExtensionsCount] = nil

	vkInstanceCreateInfo.enabledExtensionCount = glfwExtensionsCount
	vkInstanceCreateInfo.ppEnabledExtensionNames = vkGlfwExtensions

	local instance = ffi.new('VkInstance[1]')

	local result = ffi.C.vkCreateInstance(vkInstanceCreateInfo, nil, instance + 1)

	if result ~= 0 then
		error('Failed to create vulkan instance')
	end

	return o
end

function App:run(callback)
	while self.window:ShouldClose() == 0 do
		callback()

		self.window:SwapBuffers()
		glfw.PollEvents()
	end

	glfw.Terminate()
end

return App
