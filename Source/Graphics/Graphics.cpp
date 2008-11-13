#include "Graphics.h"
#include <OpenGL/gl.h>
#include <SDL/SDL.h>

const static float circlePoints[] = {
   0.000, 1.000,
   0.098, 0.995,
   0.195, 0.981,
   0.290, 0.957,
   0.383, 0.924,
   0.471, 0.882,
   0.556, 0.831,
   0.634, 0.773,
   0.707, 0.707,
   0.773, 0.634,
   0.831, 0.556,
   0.882, 0.471,
   0.924, 0.383,
   0.957, 0.290,
   0.981, 0.195,
   0.995, 0.098,
   1.000, -0.000,
   0.995, -0.098,
   0.981, -0.195,
   0.957, -0.290,
   0.924, -0.383,
   0.882, -0.471,
   0.831, -0.556,
   0.773, -0.634,
   0.707, -0.707,
   0.634, -0.773,
   0.556, -0.831,
   0.471, -0.882,
   0.383, -0.924,
   0.290, -0.957,
   0.195, -0.981,
   0.098, -0.995,
   -0.000, -1.000,
   -0.098, -0.995,
   -0.195, -0.981,
   -0.290, -0.957,
   -0.383, -0.924,
   -0.471, -0.882,
   -0.556, -0.831,
   -0.634, -0.773,
   -0.707, -0.707,
   -0.773, -0.634,
   -0.831, -0.556,
   -0.882, -0.471,
   -0.924, -0.383,
   -0.957, -0.290,
   -0.981, -0.195,
   -0.995, -0.098,
   -1.000, 0.000,
   -0.995, 0.098,
   -0.981, 0.195,
   -0.957, 0.290,
   -0.924, 0.383,
   -0.882, 0.471,
   -0.831, 0.556,
   -0.773, 0.634,
   -0.707, 0.707,
   -0.634, 0.773,
   -0.556, 0.831,
   -0.471, 0.882,
   -0.383, 0.924,
   -0.290, 0.957,
   -0.195, 0.981,
   -0.098, 0.995,
   -0.000, 1.000};

namespace Graphics
{

void Init ( int w, int h, bool fullscreen )
{
	SDL_InitSubSystem ( SDL_INIT_VIDEO );
	SDL_GL_SetAttribute ( SDL_GL_RED_SIZE, 8 );
	SDL_GL_SetAttribute ( SDL_GL_BLUE_SIZE, 8 );
	SDL_GL_SetAttribute ( SDL_GL_GREEN_SIZE, 8 );
	SDL_GL_SetAttribute ( SDL_GL_ALPHA_SIZE, 0 );
	SDL_GL_SetAttribute ( SDL_GL_DOUBLEBUFFER, 1 );
	SDL_GL_SetAttribute ( SDL_GL_DEPTH_SIZE, 0 );
	SDL_GL_SetAttribute ( SDL_GL_MULTISAMPLESAMPLES, 4 );
	SDL_GL_SetAttribute ( SDL_GL_MULTISAMPLEBUFFERS, 1 );
	SDL_GL_SetAttribute ( SDL_GL_SWAP_CONTROL, 1 );
	Uint32 flags = SDL_OPENGL;
	if (fullscreen)
		flags |= SDL_FULLSCREEN;
	if (!SDL_SetVideoMode(w, h, 0, flags))
	{
		SDL_GL_SetAttribute ( SDL_GL_MULTISAMPLESAMPLES, 0 );
		SDL_GL_SetAttribute ( SDL_GL_MULTISAMPLEBUFFERS, 0 );
		printf("[GRAPHICS] Warning: card does not support FSAA\n");
		if (!SDL_SetVideoMode(w, h, 0, flags))
		{
			printf("[GRAPHICS] Warning: card does not support normal video options\n");
			SDL_GL_SetAttribute ( SDL_GL_RED_SIZE, 5 );
			SDL_GL_SetAttribute ( SDL_GL_GREEN_SIZE, 5 );
			SDL_GL_SetAttribute ( SDL_GL_BLUE_SIZE, 5 );
			if (!SDL_SetVideoMode(w, h, 0, flags))
			{
				printf("[GRAPHICS] Error: bad graphics driver!\n");
				exit(1);
			}
		}
	}
	
	glClear ( GL_COLOR_BUFFER_BIT );
	
	glEnable ( GL_BLEND );
	glBlendFunc ( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	glEnable ( GL_LINE_SMOOTH );
	glEnable ( GL_POINT_SMOOTH );
	
	glHint ( GL_LINE_SMOOTH_HINT, GL_NICEST );
	glHint ( GL_POINT_SMOOTH_HINT, GL_NICEST );
	
	glEnableClientState ( GL_TEXTURE_COORD_ARRAY );
}

static void EnableTexturing ()
{
	glEnable ( GL_TEXTURE_RECTANGLE_ARB );
	glEnableClientState ( GL_TEXTURE_COORD_ARRAY );
}

static void DisableTexturing ()
{
	glDisable ( GL_TEXTURE_RECTANGLE_ARB );
	glDisableClientState ( GL_TEXTURE_COORD_ARRAY );
}

static void SetColour ( const colour& col )
{
	if (sizeof(col) == sizeof(float) * 4)
	{
		glColor4fv((const GLfloat*)&col);
	}
	else
	{
		glColor4f(col.red(), col.green(), col.blue(), col.alpha());
	}
}

static void ClearColour ()
{
	const uint32_t white = 0xFFFFFFFF;
	glColor4ubv((const GLubyte*)&white);
}

void DrawSprite ( const std::string& sheetname, int sheet_x, int sheet_y, vec2 location, vec2 size, float rotation )
{
	// TODO
}

void DrawText ( const std::string& text, const std::string& font, int fontsize, colour col, float rotation )
{
	// TODO
}

void DrawLine ( vec2 coordinate1, vec2 coordinate2, float width, colour col )
{
	DisableTexturing();
	glLineWidth(width);
	SetColour(col);
	float vertices[4] = { coordinate1.X(), coordinate1.Y(),
	                      coordinate2.X(), coordinate2.Y() };
	glVertexPointer ( 2, GL_FLOAT, 0, vertices );
	glDrawArrays ( GL_LINES, 0, 2 );
}

void DrawCircle ( vec2 centre, float radius, float width, colour col )
{
	DisableTexturing ();
	glLineWidth(width);
	glPushMatrix ();
	glTranslatef ( centre.X(), centre.Y(), 0.0f );
	SetColour ( col );
	glScalef ( radius, radius, 1.0f );
	glVertexPointer(2, GL_FLOAT, 0, circlePoints);
	glDrawArrays(GL_LINE_LOOP, 0, sizeof(circlePoints) / (2 * sizeof(float)));
	glPopMatrix ();
}

void DrawParticles ( const vec2* locations, unsigned int count, colour col )
{
	DisableTexturing();
	glVertexPointer ( 2, GL_FLOAT, 0, locations );
	SetColour(col);
	glDrawArrays ( GL_POINTS, 0, count );
}

void SetCamera ( vec2 corner1, vec2 corner2, float rotation )
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(corner1.X(), corner2.X(), corner1.Y(), corner2.Y(), 0.0, 1.0);
	glRotatef(rotation, 0.0f, 0.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
}

void BeginFrame ()
{
	glClear(GL_COLOR_BUFFER_BIT);
	glLoadIdentity();
}

void EndFrame ()
{
	SDL_GL_SwapBuffers();
}

}