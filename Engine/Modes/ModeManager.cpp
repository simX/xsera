#include "ModeManager.h"
#include <SDL/SDL.h>
#include "input.h"

#include "Logging.h"

static AppMode* mode = NULL;
static AppMode* nextMode = NULL;

class LuaMode : public AppMode
{
private:
	LuaScript* script;
	std::string name;
public:
	LuaMode ( const std::string& _name )
	: name(_name)
	{
		script = new LuaScript("Modes/" + _name);
	}
	
	virtual ~LuaMode ()
	{
		delete script;
	}
	
	virtual std::string Name ()
	{
		return name;
	}
	
	virtual void Init ()
	{
		script->InvokeSubroutine("init");
	}
	
	virtual void Shutdown ()
	{
		script->InvokeSubroutine("shutdown");
	}
	
	virtual void Update ()
	{
		script->InvokeSubroutine("update");
	}
	
	virtual void Render ()
	{
		script->InvokeSubroutine("render");
	}
	
	virtual void HandleEvent ( const Input::Event& event )
	{
		switch (event.type)
		{
			case Input::Event::KEYDOWN:
				script->InvokeSubroutine("key", event.object);
				break;
			case Input::Event::KEYUP:
				script->InvokeSubroutine("keyup", event.object);
				break;
			case Input::Event::CLICK:
				script->InvokeSubroutine("mouse", event.object, event.mouse.X(), event.mouse.Y());
				break;
			case Input::Event::RELEASE:
				script->InvokeSubroutine("mouse_up", event.object, event.mouse.X(), event.mouse.Y());
				break;
			case Input::Event::MOUSEMOVE:
				script->InvokeSubroutine("mouse_move", event.mouse.X(), event.mouse.Y());
				break;
			default: break;
			case Input::Event::QUIT:
				exit(0);
				break;
		}
	}
};

AppMode* ActiveMode ()
{
	return mode;
}

void InitModeManager ()
{
}

void UpdateModeManager ()
{
	if (nextMode != NULL)
	{
		if (mode)
		{
			mode->Shutdown();
			delete mode;
		}
		LOG("ModeManager", LOG_MESSAGE, "Switching to mode %s", nextMode->Name().c_str());
		mode = nextMode;
		nextMode = NULL;
		if (mode)
		{
			mode->Init();
		}
	}
	if (mode)
	{
		mode->Update();
		Input::Pump();
		while (Input::Event* event = Input::Next())
		{
			mode->HandleEvent(*event);
		}
		mode->Render();
	}
}

const char* QueryMode()
{
	return ActiveMode()->Name().c_str();
}

void SwitchMode ( const std::string& newmode )
{
	LuaMode* newMode = new LuaMode ( newmode );
	SwitchMode ( newMode );
}

void SwitchMode ( AppMode* newmode )
{
	if (nextMode) delete nextMode;
	nextMode = newmode;
}

// 