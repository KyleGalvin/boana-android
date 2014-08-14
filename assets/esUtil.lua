--esUtil.lua
--Source: https://raw.githubusercontent.com/malkia/ufo/master/ffi/OpenGLES2.lua
local ffi   = require( "ffi" )

ffi.cdef[[

	typedef void             GLvoid;
	typedef char             GLchar;
	typedef unsigned int     GLenum;
	typedef unsigned char    GLboolean;
	typedef unsigned int     GLbitfield;
	typedef int8_t           GLbyte;
	typedef short            GLshort;
	typedef int              GLint;
	typedef int              GLsizei;
	typedef uint8_t          GLubyte;
	typedef unsigned short   GLushort;
	typedef unsigned int     GLuint;
	typedef float            GLfloat;
	typedef float            GLclampf;
	typedef int32_t          GLfixed;
	typedef intptr_t         GLintptr;
	typedef size_t           GLsizeiptr;

	typedef struct
	{
		GLfloat   m[4][4];
	} ESMatrix;

	typedef struct ESContext ESContext;

	struct ESContext
	{
	   void       *platformData;
	   void       *userData;
	   GLint       width;
	   GLint       height;
	   void ( *drawFunc ) ( ESContext * );
	   void ( *shutdownFunc ) ( ESContext * );
	   void ( *keyFunc ) ( ESContext *, unsigned char, int, int );
	   void ( *updateFunc ) ( ESContext *, float deltaTime );
	};

	GLboolean  esCreateWindow ( ESContext *esContext, const char *title, GLint width, GLint height, GLuint flags );
	void  esRegisterDrawFunc ( ESContext *esContext, void (  *drawFunc ) ( ESContext * ) );
	void  esRegisterShutdownFunc ( ESContext *esContext, void (  *shutdownFunc ) ( ESContext * ) );
	void  esRegisterUpdateFunc ( ESContext *esContext, void (  *updateFunc ) ( ESContext *, float ) );
	void  esRegisterKeyFunc ( ESContext *esContext,void (  *drawFunc ) ( ESContext *, unsigned char, int, int ) );
	void  esLogMessage ( const char *formatStr, ... );
	GLuint  esLoadShader ( GLenum type, const char *shaderSrc );
	GLuint  esLoadProgram ( const char *vertShaderSrc, const char *fragShaderSrc );
	int  esGenSphere ( int numSlices, float radius, GLfloat **vertices, GLfloat **normals,GLfloat **texCoords, GLuint **indices );
	int  esGenCube ( float scale, GLfloat **vertices, GLfloat **normals,GLfloat **texCoords, GLuint **indices );
	int  esGenSquareGrid ( int size, GLfloat **vertices, GLuint **indices );
	char * esLoadTGA ( void *ioContext, const char *fileName, int *width, int *height );
	void  esScale ( ESMatrix *result, GLfloat sx, GLfloat sy, GLfloat sz );
	void  esTranslate ( ESMatrix *result, GLfloat tx, GLfloat ty, GLfloat tz );
	void  esRotate ( ESMatrix *result, GLfloat angle, GLfloat x, GLfloat y, GLfloat z );
	void  esFrustum ( ESMatrix *result, float left, float right, float bottom, float top, float nearZ, float farZ );
	void  esPerspective ( ESMatrix *result, float fovy, float aspect, float nearZ, float farZ );
	void  esOrtho ( ESMatrix *result, float left, float right, float bottom, float top, float nearZ, float farZ );
	void  esMatrixMultiply ( ESMatrix *result, ESMatrix *srcA, ESMatrix *srcB );
	void  esMatrixLoadIdentity ( ESMatrix *result );
	void  esMatrixLookAt ( ESMatrix *result, float posX, float posY, float posZ, float lookAtX, float lookAtY, float lookAtZ, float upX, float upY, float upZ );
]]

return ffi.C