#version 410

in vec3 v_position;
in vec3 v_normal;
in vec4 v_color;
const int LIGHT_NUM = 3;
uniform struct LightSource {
    vec3 light_pos;
    float light_attenuation;
    vec3 spot_dir;
    float spot_phi;
    float spot_theta;
    float spot_falloff;
    vec4 diffuse_color;
    vec4 ambient_color;
    vec4 specular_color;
    float specular_shininess;
};
uniform LightSource lights[LIGHT_NUM];
uniform vec3 eye_dir;
uniform mat4 pvm_mat;
uniform mat4 model_mat;
uniform vec4 emissive_color;
layout (location=0) out vec4 frag_color;

void main()
{
    vec4 diffuse_total = vec4(0);
    vec4 ambient_total = vec4(0);
    vec4 specular_total = vec4(0);
    for (int i = 0; i < LIGHT_NUM; ++i)
    {
        vec3 light_vec_dir = v_position - lights[i].light_pos;
        float light_len = length(light_vec_dir);
        float attenuation = 1.0 / (lights[i].light_attenuation * light_len * light_len);

        vec3 light_vec_dirN = normalize(light_vec_dir);
        vec3 spor_dirN = normalize(lights[i].spot_dir);
        float cos_alpha = dot(light_vec_dirN, spor_dirN);
        float cos_half_theta = cos(lights[i].spot_theta / 2.0);
        float cos_half_phi = cos(lights[i].spot_phi / 2.0);
        if (cos_alpha <= cos_half_phi)
        {
            // out-range
            // attenuation * 0.f;
            ambient_total += lights[i].ambient_color;
        }
        else
        {
            if (cos_alpha > cos_half_theta)
            {
                // inner corn
                // attenuation * 1.f
            }
            else
            {
                // outer corn
                attenuation *= pow((cos_alpha - cos_half_phi)/(cos_half_theta - cos_half_phi), lights[i].spot_falloff);
            }
            vec3 normal = normalize((vec4(v_normal, 0.0) * model_mat).xyz);
            vec3 light = -light_vec_dirN;
            float diffuse_power = clamp(dot(normal, light), 0.0, 1.0);
            vec3 eye = -normalize(eye_dir);
            vec3 half_vec = normalize(light + eye);
            float specular = pow(clamp(dot(normal, half_vec), 0.0, 1.0), lights[i].specular_shininess);

            diffuse_total += lights[i].diffuse_color * diffuse_power * attenuation;
            ambient_total += lights[i].ambient_color;
            specular_total += lights[i].specular_color * specular;
        }
        frag_color = v_color * diffuse_total + ambient_total + specular_total + emissive_color;
    }
}
