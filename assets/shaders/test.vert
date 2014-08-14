attribute vec4 vPosition;
uniform mat4 projection;
 
void main()
{
    gl_Position =  vPosition;
    gl_Position = projection * gl_Position;
}
