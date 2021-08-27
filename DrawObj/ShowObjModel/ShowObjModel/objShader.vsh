#version 410
layout (location=0) in vec3 vertex_pos;
layout (location=1) in vec3 vertex_normal;
layout (location=2) in vec4 vertex_color;
uniform mat4 pvm_mat;
uniform mat4 model_mat;
out vec3 v_position;
out vec3 v_normal;
out vec4 v_color;

void main()
{
    v_position = (vec4(vertex_pos, 1.0) * model_mat).xyz;
    v_normal = vertex_normal;
    v_color = vertex_color;
    gl_Position = vec4(vertex_pos, 1.0) * pvm_mat;
}
