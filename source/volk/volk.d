module volk.volk;

nothrow @nogc extern(C):

// volk/constant.h
const(char)* volk_prefix();
const(char)* volk_version();
const(char)* volk_c_compiler();
const(char)* volk_compiler_flags();
const(char)* volk_available_machines();


// volk/volk_malloc.h
void* volk_malloc(size_t size, size_t alignment);
void volk_free(void* aptr);


// volk/volk_prefs.h
struct volk_arch_pref_t {
    char[128] name;
    char[128] impl_a;
    char[128] impl_u;
}

void volk_get_config_path(char*, bool);
size_t volk_load_preferences(volk_arch_pref_t**);


// volk/volk.h
struct volk_func_desc_t
{
    const(char*)* impl_names;
    const(int)* impl_deps;
    const(bool)* impl_alignment;
    size_t n_impls;
};

void volk_list_machines();
const(char)* volk_get_machine();
size_t volk_get_alignment();

const(void)* VOLK_OR_PTR(const(void)* p1, const(void)* p2) { return cast(void*)((cast(size_t)p1)|(cast(size_t)p2)); }
bool volk_is_aligned(const void* ptr);

/+
extern(D) private string gen_volk_definition(string name, string args)
{
    import std.format;

    string dst;
    dst ~= format("alias p_%1$s = void function(%2$s);\n", name, args) nothrow @nogc;
    dst ~= format("extern __gshared p_%1$s volk_%1$s;\n", name);
    dst ~= format("extern __gshared p_%1$s volk_%1$s_a;\n", name);
    dst ~= format("extern __gshared p_%1$s volk_%1$s_u;\n", name);
    dst ~= format("extern void volk_%1$s_manual(%2$s, const(char)*);\n", name, args);
    dst ~= format("extern volk_func_desc_t volk_%1$s_get_func_desc();\n", name);
    return dst;
}
+/


struct lv_complex_t(T)
{
    T re, im;
}


import std.complex;


alias lv_8sc_t = lv_complex_t!byte;
alias lv_16sc_t = lv_complex_t!short;
alias lv_32sc_t = lv_complex_t!int;
alias lv_64sc_t = lv_complex_t!long;
alias lv_32fc_t = Complex!float;
alias lv_64fc_t = Complex!double;


/+
static foreach(string[2] name_and_args; [
    ["16i_32fc_dot_prod_32fc", "lv_32fc_t* , const short* , const lv_32fc_t* , uint "],
    ["16i_branch_4_state_8", "short* , short* , char** , short* , short* , short* "],
    ["16i_convert_8i", "byte* , const short* , uint "],
    ["16i_max_star_16i", "short* , short* , uint "],
    ["16i_max_star_horizontal_16i", "short* , short* , uint "],
    ["16i_permute_and_scalar_add", "short* , short* , short* , short* , short* , short* , short* , short* , uint "],
    ["16i_s32f_convert_32f", "float* , const short* , const float , uint "],
    ["16i_x4_quad_max_star_16i", "short* , short* , short* , short* , short* , uint "],
    ["16i_x5_add_quad_16i_x4", "short* , short* , short* , short* , short* , short* , short* , short* , short* , uint "],
    ["16ic_convert_32fc", "lv_32fc_t* , const lv_16sc_t* , uint "],
    ["16ic_deinterleave_16i_x2", "short* , short* , const lv_16sc_t* , uint "],
    ["16ic_deinterleave_real_16i", "short* , const lv_16sc_t* , uint "],
    ["16ic_deinterleave_real_8i", "byte* , const lv_16sc_t* , uint "],
    ["16ic_magnitude_16i", "short* , const lv_16sc_t* , uint "],
    ["16ic_s32f_deinterleave_32f_x2", "float* , float* , const lv_16sc_t* , const float , uint "],
    ["16ic_s32f_deinterleave_real_32f", "float* , const lv_16sc_t* , const float , uint "],
    ["16ic_s32f_magnitude_32f", "float* , const lv_16sc_t* , const float , uint "],
    ["16ic_x2_dot_prod_16ic", "lv_16sc_t* , const lv_16sc_t* , const lv_16sc_t* , uint "],
    ["16ic_x2_multiply_16ic", "lv_16sc_t* , const lv_16sc_t* , const lv_16sc_t* , uint "],
    ["16u_byteswap", "ushort* , uint "],
    ["16u_byteswappuppet_16u", "ushort* , ushort* , uint "],
    ["32f_64f_add_64f", "double* , const float* , const double* , uint "],
    ["32f_64f_multiply_64f", "double* , const float* , const double* , uint "],
    ["32f_8u_polarbutterfly_32f", "float* , ubyte* , const int , const int , const int , const int "],
    ["32f_8u_polarbutterflypuppet_32f", "float* , const float* , ubyte* , const int "],
    ["32f_accumulator_s32f", "float* , const float* , uint "],
    ["32f_acos_32f", "float* , const float* , uint "],
    ["32f_asin_32f", "float* , const float* , uint "],
    ["32f_atan_32f", "float* , const float* , uint "],
    ["32f_binary_slicer_32i", "int* , const float* , uint "],
    ["32f_binary_slicer_8i", "byte* , const float* , uint "],
    ["32f_convert_64f", "double* , const float* , uint "],
    ["32f_cos_32f", "float* , const float* , uint "],
    ["32f_exp_32f", "float* , const float* , uint "],
    ["32f_expfast_32f", "float* , const float* , uint "],
    ["32f_index_max_16u", "ushort* , const float* , uint "],
    ["32f_index_max_32u", "uint* , const float* , uint "],
    ["32f_index_min_16u", "ushort* , const float* , uint "],
    ["32f_index_min_32u", "uint* , const float* , uint "],
    ["32f_invsqrt_32f", "float* , const float* , uint "],
    ["32f_log2_32f", "float* , const float* , uint "],
    ["32f_null_32f", "float* , const float* , uint "],
    ["32f_s32f_32f_fm_detect_32f", "float* , const float* , const float , float* , uint "],
    ["32f_s32f_add_32f", "float* , const float* , const float , uint "],
    ["32f_s32f_calc_spectral_noise_floor_32f", "float* , const float* , const float , const uint "],
    ["32f_s32f_clamppuppet_32f", "float* , const float* , const float , uint "],
    ["32f_s32f_convert_16i", "short* , const float* , const float , uint "],
    ["32f_s32f_convert_32i", "int* , const float* , const float , uint "],
    ["32f_s32f_convert_8i", "byte* , const float* , const float , uint "],
    ["32f_s32f_convertpuppet_8u", "ubyte* , const float* , float , uint "],
    ["32f_s32f_mod_rangepuppet_32f", "float* , const float* , float , uint "],
    ["32f_s32f_multiply_32f", "float* , const float* , const float , uint "],
    ["32f_s32f_normalize", "float* , const float , uint "],
    ["32f_s32f_power_32f", "float* , const float* , const float , uint "],
    ["32f_s32f_s32f_mod_range_32f", "float* , const float* , const float , const float , uint "],
    ["32f_s32f_stddev_32f", "float* , const float* , const float , uint "],
    ["32f_s32f_x2_clamp_32f", "float* , const float* , const float , const float , uint "],
    ["32f_s32f_x2_convert_8u", "ubyte* , const float* , const float , const float , uint "],
    ["32f_sin_32f", "float* , const float* , uint "],
    ["32f_sqrt_32f", "float* , const float* , uint "],
    ["32f_stddev_and_mean_32f_x2", "float* , float* , const float* , uint "],
    ["32f_tan_32f", "float* , const float* , uint "],
    ["32f_tanh_32f", "float* , const float* , uint "],
    ["32f_x2_add_32f", "float* , const float* , const float* , uint "],
    ["32f_x2_divide_32f", "float* , const float* , const float* , uint "],
    ["32f_x2_dot_prod_16i", "short* , const float* , const float* , uint "],
    ["32f_x2_dot_prod_32f", "float* , const float* , const float* , uint "],
    ["32f_x2_fm_detectpuppet_32f", "float* , const float* , float* , uint "],
    ["32f_x2_interleave_32fc", "lv_32fc_t* , const float* , const float* , uint "],
    ["32f_x2_max_32f", "float* , const float* , const float* , uint "],
    ["32f_x2_min_32f", "float* , const float* , const float* , uint "],
    ["32f_x2_multiply_32f", "float* , const float* , const float* , uint "],
    ["32f_x2_pow_32f", "float* , const float* , const float* , uint "],
    ["32f_x2_powpuppet_32f", "float* , const float* , const float* , uint "],
    ["32f_x2_s32f_interleave_16ic", "lv_16sc_t* , const float* , const float* , const float , uint "],
    ["32f_x2_subtract_32f", "float* , const float* , const float* , uint "],
    ["32f_x3_sum_of_poly_32f", "float* , float* , float* , float* , uint "],
    ["32fc_32f_add_32fc", "lv_32fc_t* , const lv_32fc_t* , const float* , uint "],
    ["32fc_32f_dot_prod_32fc", "lv_32fc_t* , const lv_32fc_t* , const float* , uint "],
    ["32fc_32f_multiply_32fc", "lv_32fc_t* , const lv_32fc_t* , const float* , uint "],
    ["32fc_accumulator_s32fc", "lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_conjugate_32fc", "lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_convert_16ic", "lv_16sc_t* , const lv_32fc_t* , uint "],
    ["32fc_deinterleave_32f_x2", "float* , float* , const lv_32fc_t* , uint "],
    ["32fc_deinterleave_64f_x2", "double* , double* , const lv_32fc_t* , uint "],
    ["32fc_deinterleave_imag_32f", "float* , const lv_32fc_t* , uint "],
    ["32fc_deinterleave_real_32f", "float* , const lv_32fc_t* , uint "],
    ["32fc_deinterleave_real_64f", "double* , const lv_32fc_t* , uint "],
    ["32fc_index_max_16u", "ushort* , lv_32fc_t* , uint "],
    ["32fc_index_max_32u", "uint* , lv_32fc_t* , uint "],
    ["32fc_index_min_16u", "ushort* , const lv_32fc_t* , uint "],
    ["32fc_index_min_32u", "uint* , const lv_32fc_t* , uint "],
    ["32fc_magnitude_32f", "float* , const lv_32fc_t* , uint "],
    ["32fc_magnitude_squared_32f", "float* , const lv_32fc_t* , uint "],
    ["32fc_s32f_atan2_32f", "float* , const lv_32fc_t* , const float , uint "],
    ["32fc_s32f_deinterleave_real_16i", "short* , const lv_32fc_t* , const float , uint "],
    ["32fc_s32f_magnitude_16i", "short* , const lv_32fc_t* , const float , uint "],
    ["32fc_s32f_power_32fc", "lv_32fc_t* , const lv_32fc_t* , const float , uint "],
    ["32fc_s32f_power_spectral_densitypuppet_32f", "float* , const lv_32fc_t* , const float , uint "],
    ["32fc_s32f_power_spectrum_32f", "float* , const lv_32fc_t* , const float , uint "],
    ["32fc_s32f_x2_power_spectral_density_32f", "float* , const lv_32fc_t* , const float , const float , uint "],
    ["32fc_s32fc_multiply2_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_s32fc_multiply_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , uint "],
    ["32fc_s32fc_rotator2puppet_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_s32fc_x2_rotator2_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , lv_32fc_t* , uint "],
    ["32fc_s32fc_x2_rotator_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , lv_32fc_t* , uint "],
    ["32fc_x2_add_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_x2_conjugate_dot_prod_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_x2_divide_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_x2_dot_prod_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_x2_multiply_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_x2_multiply_conjugate_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_x2_s32f_square_dist_scalar_mult_32f", "float* , lv_32fc_t* , lv_32fc_t* , float , uint "],
    ["32fc_x2_s32fc_multiply_conjugate_add2_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint "],
    ["32fc_x2_s32fc_multiply_conjugate_add_32fc", "lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , uint "],
    ["32fc_x2_square_dist_32f", "float* , lv_32fc_t* , lv_32fc_t* , uint "],
    ["32i_s32f_convert_32f", "float* , const int* , const float , uint "],
    ["32i_x2_and_32i", "int* , const int* , const int* , uint "],
    ["32i_x2_or_32i", "int* , const int* , const int* , uint "],
    ["32u_byteswap", "uint* , uint "],
    ["32u_byteswappuppet_32u", "uint* , uint* , uint "],
    ["32u_popcnt", "uint* , const uint "],
    ["32u_popcntpuppet_32u", "uint* , const uint* , uint "],
    ["32u_reverse_32u", "uint* , const uint* , uint "],
    ["64f_convert_32f", "float* , const double* , uint "],
    ["64f_x2_add_64f", "double* , const double* , const double* , uint "],
    ["64f_x2_max_64f", "double* , const double* , const double* , uint "],
    ["64f_x2_min_64f", "double* , const double* , const double* , uint "],
    ["64f_x2_multiply_64f", "double* , const double* , const double* , uint "],
    ["64u_byteswap", "ulong* , uint "],
    ["64u_byteswappuppet_64u", "ulong* , ulong* , uint "],
    ["64u_popcnt", "ulong* , const ulong "],
    ["64u_popcntpuppet_64u", "ulong* , const ulong* , uint "],
    ["8i_convert_16i", "short* , const byte* , uint "],
    ["8i_s32f_convert_32f", "float* , const byte* , const float , uint "],
    ["8ic_deinterleave_16i_x2", "short* , short* , const lv_8sc_t* , uint "],
    ["8ic_deinterleave_real_16i", "short* , const lv_8sc_t* , uint "],
    ["8ic_deinterleave_real_8i", "byte* , const lv_8sc_t* , uint "],
    ["8ic_s32f_deinterleave_32f_x2", "float* , float* , const lv_8sc_t* , const float , uint "],
    ["8ic_s32f_deinterleave_real_32f", "float* , const lv_8sc_t* , const float , uint "],
    ["8ic_x2_multiply_conjugate_16ic", "lv_16sc_t* , const lv_8sc_t* , const lv_8sc_t* , uint "],
    ["8ic_x2_s32f_multiply_conjugate_32fc", "lv_32fc_t* , const lv_8sc_t* , const lv_8sc_t* , const float , uint "],
    ["8u_conv_k7_r2puppet_8u", "ubyte* , ubyte* , uint "],
    ["8u_x2_encodeframepolar_8u", "ubyte* , ubyte* , uint "],
    ["8u_x3_encodepolar_8u_x2", "ubyte* , ubyte* , const ubyte* , const ubyte* , const ubyte* , uint "],
    ["8u_x3_encodepolarpuppet_8u", "ubyte* , ubyte* , const ubyte* , const ubyte* , uint "],
    ["8u_x4_conv_k7_r2_8u", "ubyte* , ubyte* , ubyte* , ubyte* , uint , uint , ubyte* "],
])
{
    // pragma(msg, gen_volk_definition(name_and_args[0], name_and_args[1]));
    mixin(gen_volk_definition(name_and_args[0], name_and_args[1]));
}
+/



alias p_16i_32fc_dot_prod_32fc = void function(lv_32fc_t* , const short* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_16i_32fc_dot_prod_32fc volk_16i_32fc_dot_prod_32fc;
extern __gshared p_16i_32fc_dot_prod_32fc volk_16i_32fc_dot_prod_32fc_a;
extern __gshared p_16i_32fc_dot_prod_32fc volk_16i_32fc_dot_prod_32fc_u;
extern void volk_16i_32fc_dot_prod_32fc_manual(lv_32fc_t* , const short* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_16i_32fc_dot_prod_32fc_get_func_desc();

alias p_16i_branch_4_state_8 = void function(short* , short* , char** , short* , short* , short* ) nothrow @nogc;
extern __gshared p_16i_branch_4_state_8 volk_16i_branch_4_state_8;
extern __gshared p_16i_branch_4_state_8 volk_16i_branch_4_state_8_a;
extern __gshared p_16i_branch_4_state_8 volk_16i_branch_4_state_8_u;
extern void volk_16i_branch_4_state_8_manual(short* , short* , char** , short* , short* , short* , const(char)*);
extern volk_func_desc_t volk_16i_branch_4_state_8_get_func_desc();

alias p_16i_convert_8i = void function(byte* , const short* , uint ) nothrow @nogc;
extern __gshared p_16i_convert_8i volk_16i_convert_8i;
extern __gshared p_16i_convert_8i volk_16i_convert_8i_a;
extern __gshared p_16i_convert_8i volk_16i_convert_8i_u;
extern void volk_16i_convert_8i_manual(byte* , const short* , uint , const(char)*);
extern volk_func_desc_t volk_16i_convert_8i_get_func_desc();

alias p_16i_max_star_16i = void function(short* , short* , uint ) nothrow @nogc;
extern __gshared p_16i_max_star_16i volk_16i_max_star_16i;
extern __gshared p_16i_max_star_16i volk_16i_max_star_16i_a;
extern __gshared p_16i_max_star_16i volk_16i_max_star_16i_u;
extern void volk_16i_max_star_16i_manual(short* , short* , uint , const(char)*);
extern volk_func_desc_t volk_16i_max_star_16i_get_func_desc();

alias p_16i_max_star_horizontal_16i = void function(short* , short* , uint ) nothrow @nogc;
extern __gshared p_16i_max_star_horizontal_16i volk_16i_max_star_horizontal_16i;
extern __gshared p_16i_max_star_horizontal_16i volk_16i_max_star_horizontal_16i_a;
extern __gshared p_16i_max_star_horizontal_16i volk_16i_max_star_horizontal_16i_u;
extern void volk_16i_max_star_horizontal_16i_manual(short* , short* , uint , const(char)*);
extern volk_func_desc_t volk_16i_max_star_horizontal_16i_get_func_desc();

alias p_16i_permute_and_scalar_add = void function(short* , short* , short* , short* , short* , short* , short* , short* , uint ) nothrow @nogc;
extern __gshared p_16i_permute_and_scalar_add volk_16i_permute_and_scalar_add;
extern __gshared p_16i_permute_and_scalar_add volk_16i_permute_and_scalar_add_a;
extern __gshared p_16i_permute_and_scalar_add volk_16i_permute_and_scalar_add_u;
extern void volk_16i_permute_and_scalar_add_manual(short* , short* , short* , short* , short* , short* , short* , short* , uint , const(char)*);
extern volk_func_desc_t volk_16i_permute_and_scalar_add_get_func_desc();

alias p_16i_s32f_convert_32f = void function(float* , const short* , const float , uint ) nothrow @nogc;
extern __gshared p_16i_s32f_convert_32f volk_16i_s32f_convert_32f;
extern __gshared p_16i_s32f_convert_32f volk_16i_s32f_convert_32f_a;
extern __gshared p_16i_s32f_convert_32f volk_16i_s32f_convert_32f_u;
extern void volk_16i_s32f_convert_32f_manual(float* , const short* , const float , uint , const(char)*);
extern volk_func_desc_t volk_16i_s32f_convert_32f_get_func_desc();

alias p_16i_x4_quad_max_star_16i = void function(short* , short* , short* , short* , short* , uint ) nothrow @nogc;
extern __gshared p_16i_x4_quad_max_star_16i volk_16i_x4_quad_max_star_16i;
extern __gshared p_16i_x4_quad_max_star_16i volk_16i_x4_quad_max_star_16i_a;
extern __gshared p_16i_x4_quad_max_star_16i volk_16i_x4_quad_max_star_16i_u;
extern void volk_16i_x4_quad_max_star_16i_manual(short* , short* , short* , short* , short* , uint , const(char)*);
extern volk_func_desc_t volk_16i_x4_quad_max_star_16i_get_func_desc();

alias p_16i_x5_add_quad_16i_x4 = void function(short* , short* , short* , short* , short* , short* , short* , short* , short* , uint ) nothrow @nogc;
extern __gshared p_16i_x5_add_quad_16i_x4 volk_16i_x5_add_quad_16i_x4;
extern __gshared p_16i_x5_add_quad_16i_x4 volk_16i_x5_add_quad_16i_x4_a;
extern __gshared p_16i_x5_add_quad_16i_x4 volk_16i_x5_add_quad_16i_x4_u;
extern void volk_16i_x5_add_quad_16i_x4_manual(short* , short* , short* , short* , short* , short* , short* , short* , short* , uint , const(char)*);
extern volk_func_desc_t volk_16i_x5_add_quad_16i_x4_get_func_desc();

alias p_16ic_convert_32fc = void function(lv_32fc_t* , const lv_16sc_t* , uint ) nothrow @nogc;
extern __gshared p_16ic_convert_32fc volk_16ic_convert_32fc;
extern __gshared p_16ic_convert_32fc volk_16ic_convert_32fc_a;
extern __gshared p_16ic_convert_32fc volk_16ic_convert_32fc_u;
extern void volk_16ic_convert_32fc_manual(lv_32fc_t* , const lv_16sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_16ic_convert_32fc_get_func_desc();

alias p_16ic_deinterleave_16i_x2 = void function(short* , short* , const lv_16sc_t* , uint ) nothrow @nogc;
extern __gshared p_16ic_deinterleave_16i_x2 volk_16ic_deinterleave_16i_x2;
extern __gshared p_16ic_deinterleave_16i_x2 volk_16ic_deinterleave_16i_x2_a;
extern __gshared p_16ic_deinterleave_16i_x2 volk_16ic_deinterleave_16i_x2_u;
extern void volk_16ic_deinterleave_16i_x2_manual(short* , short* , const lv_16sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_16ic_deinterleave_16i_x2_get_func_desc();

alias p_16ic_deinterleave_real_16i = void function(short* , const lv_16sc_t* , uint ) nothrow @nogc;
extern __gshared p_16ic_deinterleave_real_16i volk_16ic_deinterleave_real_16i;
extern __gshared p_16ic_deinterleave_real_16i volk_16ic_deinterleave_real_16i_a;
extern __gshared p_16ic_deinterleave_real_16i volk_16ic_deinterleave_real_16i_u;
extern void volk_16ic_deinterleave_real_16i_manual(short* , const lv_16sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_16ic_deinterleave_real_16i_get_func_desc();

alias p_16ic_deinterleave_real_8i = void function(byte* , const lv_16sc_t* , uint ) nothrow @nogc;
extern __gshared p_16ic_deinterleave_real_8i volk_16ic_deinterleave_real_8i;
extern __gshared p_16ic_deinterleave_real_8i volk_16ic_deinterleave_real_8i_a;
extern __gshared p_16ic_deinterleave_real_8i volk_16ic_deinterleave_real_8i_u;
extern void volk_16ic_deinterleave_real_8i_manual(byte* , const lv_16sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_16ic_deinterleave_real_8i_get_func_desc();

alias p_16ic_magnitude_16i = void function(short* , const lv_16sc_t* , uint ) nothrow @nogc;
extern __gshared p_16ic_magnitude_16i volk_16ic_magnitude_16i;
extern __gshared p_16ic_magnitude_16i volk_16ic_magnitude_16i_a;
extern __gshared p_16ic_magnitude_16i volk_16ic_magnitude_16i_u;
extern void volk_16ic_magnitude_16i_manual(short* , const lv_16sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_16ic_magnitude_16i_get_func_desc();

alias p_16ic_s32f_deinterleave_32f_x2 = void function(float* , float* , const lv_16sc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_16ic_s32f_deinterleave_32f_x2 volk_16ic_s32f_deinterleave_32f_x2;
extern __gshared p_16ic_s32f_deinterleave_32f_x2 volk_16ic_s32f_deinterleave_32f_x2_a;
extern __gshared p_16ic_s32f_deinterleave_32f_x2 volk_16ic_s32f_deinterleave_32f_x2_u;
extern void volk_16ic_s32f_deinterleave_32f_x2_manual(float* , float* , const lv_16sc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_16ic_s32f_deinterleave_32f_x2_get_func_desc();

alias p_16ic_s32f_deinterleave_real_32f = void function(float* , const lv_16sc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_16ic_s32f_deinterleave_real_32f volk_16ic_s32f_deinterleave_real_32f;
extern __gshared p_16ic_s32f_deinterleave_real_32f volk_16ic_s32f_deinterleave_real_32f_a;
extern __gshared p_16ic_s32f_deinterleave_real_32f volk_16ic_s32f_deinterleave_real_32f_u;
extern void volk_16ic_s32f_deinterleave_real_32f_manual(float* , const lv_16sc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_16ic_s32f_deinterleave_real_32f_get_func_desc();

alias p_16ic_s32f_magnitude_32f = void function(float* , const lv_16sc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_16ic_s32f_magnitude_32f volk_16ic_s32f_magnitude_32f;
extern __gshared p_16ic_s32f_magnitude_32f volk_16ic_s32f_magnitude_32f_a;
extern __gshared p_16ic_s32f_magnitude_32f volk_16ic_s32f_magnitude_32f_u;
extern void volk_16ic_s32f_magnitude_32f_manual(float* , const lv_16sc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_16ic_s32f_magnitude_32f_get_func_desc();

alias p_16ic_x2_dot_prod_16ic = void function(lv_16sc_t* , const lv_16sc_t* , const lv_16sc_t* , uint ) nothrow @nogc;
extern __gshared p_16ic_x2_dot_prod_16ic volk_16ic_x2_dot_prod_16ic;
extern __gshared p_16ic_x2_dot_prod_16ic volk_16ic_x2_dot_prod_16ic_a;
extern __gshared p_16ic_x2_dot_prod_16ic volk_16ic_x2_dot_prod_16ic_u;
extern void volk_16ic_x2_dot_prod_16ic_manual(lv_16sc_t* , const lv_16sc_t* , const lv_16sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_16ic_x2_dot_prod_16ic_get_func_desc();

alias p_16ic_x2_multiply_16ic = void function(lv_16sc_t* , const lv_16sc_t* , const lv_16sc_t* , uint ) nothrow @nogc;
extern __gshared p_16ic_x2_multiply_16ic volk_16ic_x2_multiply_16ic;
extern __gshared p_16ic_x2_multiply_16ic volk_16ic_x2_multiply_16ic_a;
extern __gshared p_16ic_x2_multiply_16ic volk_16ic_x2_multiply_16ic_u;
extern void volk_16ic_x2_multiply_16ic_manual(lv_16sc_t* , const lv_16sc_t* , const lv_16sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_16ic_x2_multiply_16ic_get_func_desc();

alias p_16u_byteswap = void function(ushort* , uint ) nothrow @nogc;
extern __gshared p_16u_byteswap volk_16u_byteswap;
extern __gshared p_16u_byteswap volk_16u_byteswap_a;
extern __gshared p_16u_byteswap volk_16u_byteswap_u;
extern void volk_16u_byteswap_manual(ushort* , uint , const(char)*);
extern volk_func_desc_t volk_16u_byteswap_get_func_desc();

alias p_16u_byteswappuppet_16u = void function(ushort* , ushort* , uint ) nothrow @nogc;
extern __gshared p_16u_byteswappuppet_16u volk_16u_byteswappuppet_16u;
extern __gshared p_16u_byteswappuppet_16u volk_16u_byteswappuppet_16u_a;
extern __gshared p_16u_byteswappuppet_16u volk_16u_byteswappuppet_16u_u;
extern void volk_16u_byteswappuppet_16u_manual(ushort* , ushort* , uint , const(char)*);
extern volk_func_desc_t volk_16u_byteswappuppet_16u_get_func_desc();

alias p_32f_64f_add_64f = void function(double* , const float* , const double* , uint ) nothrow @nogc;
extern __gshared p_32f_64f_add_64f volk_32f_64f_add_64f;
extern __gshared p_32f_64f_add_64f volk_32f_64f_add_64f_a;
extern __gshared p_32f_64f_add_64f volk_32f_64f_add_64f_u;
extern void volk_32f_64f_add_64f_manual(double* , const float* , const double* , uint , const(char)*);
extern volk_func_desc_t volk_32f_64f_add_64f_get_func_desc();

alias p_32f_64f_multiply_64f = void function(double* , const float* , const double* , uint ) nothrow @nogc;
extern __gshared p_32f_64f_multiply_64f volk_32f_64f_multiply_64f;
extern __gshared p_32f_64f_multiply_64f volk_32f_64f_multiply_64f_a;
extern __gshared p_32f_64f_multiply_64f volk_32f_64f_multiply_64f_u;
extern void volk_32f_64f_multiply_64f_manual(double* , const float* , const double* , uint , const(char)*);
extern volk_func_desc_t volk_32f_64f_multiply_64f_get_func_desc();

alias p_32f_8u_polarbutterfly_32f = void function(float* , ubyte* , const int , const int , const int , const int ) nothrow @nogc;
extern __gshared p_32f_8u_polarbutterfly_32f volk_32f_8u_polarbutterfly_32f;
extern __gshared p_32f_8u_polarbutterfly_32f volk_32f_8u_polarbutterfly_32f_a;
extern __gshared p_32f_8u_polarbutterfly_32f volk_32f_8u_polarbutterfly_32f_u;
extern void volk_32f_8u_polarbutterfly_32f_manual(float* , ubyte* , const int , const int , const int , const int , const(char)*);
extern volk_func_desc_t volk_32f_8u_polarbutterfly_32f_get_func_desc();

alias p_32f_8u_polarbutterflypuppet_32f = void function(float* , const float* , ubyte* , const int ) nothrow @nogc;
extern __gshared p_32f_8u_polarbutterflypuppet_32f volk_32f_8u_polarbutterflypuppet_32f;
extern __gshared p_32f_8u_polarbutterflypuppet_32f volk_32f_8u_polarbutterflypuppet_32f_a;
extern __gshared p_32f_8u_polarbutterflypuppet_32f volk_32f_8u_polarbutterflypuppet_32f_u;
extern void volk_32f_8u_polarbutterflypuppet_32f_manual(float* , const float* , ubyte* , const int , const(char)*);
extern volk_func_desc_t volk_32f_8u_polarbutterflypuppet_32f_get_func_desc();

alias p_32f_accumulator_s32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_accumulator_s32f volk_32f_accumulator_s32f;
extern __gshared p_32f_accumulator_s32f volk_32f_accumulator_s32f_a;
extern __gshared p_32f_accumulator_s32f volk_32f_accumulator_s32f_u;
extern void volk_32f_accumulator_s32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_accumulator_s32f_get_func_desc();

alias p_32f_acos_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_acos_32f volk_32f_acos_32f;
extern __gshared p_32f_acos_32f volk_32f_acos_32f_a;
extern __gshared p_32f_acos_32f volk_32f_acos_32f_u;
extern void volk_32f_acos_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_acos_32f_get_func_desc();

alias p_32f_asin_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_asin_32f volk_32f_asin_32f;
extern __gshared p_32f_asin_32f volk_32f_asin_32f_a;
extern __gshared p_32f_asin_32f volk_32f_asin_32f_u;
extern void volk_32f_asin_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_asin_32f_get_func_desc();

alias p_32f_atan_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_atan_32f volk_32f_atan_32f;
extern __gshared p_32f_atan_32f volk_32f_atan_32f_a;
extern __gshared p_32f_atan_32f volk_32f_atan_32f_u;
extern void volk_32f_atan_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_atan_32f_get_func_desc();

alias p_32f_binary_slicer_32i = void function(int* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_binary_slicer_32i volk_32f_binary_slicer_32i;
extern __gshared p_32f_binary_slicer_32i volk_32f_binary_slicer_32i_a;
extern __gshared p_32f_binary_slicer_32i volk_32f_binary_slicer_32i_u;
extern void volk_32f_binary_slicer_32i_manual(int* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_binary_slicer_32i_get_func_desc();

alias p_32f_binary_slicer_8i = void function(byte* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_binary_slicer_8i volk_32f_binary_slicer_8i;
extern __gshared p_32f_binary_slicer_8i volk_32f_binary_slicer_8i_a;
extern __gshared p_32f_binary_slicer_8i volk_32f_binary_slicer_8i_u;
extern void volk_32f_binary_slicer_8i_manual(byte* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_binary_slicer_8i_get_func_desc();

alias p_32f_convert_64f = void function(double* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_convert_64f volk_32f_convert_64f;
extern __gshared p_32f_convert_64f volk_32f_convert_64f_a;
extern __gshared p_32f_convert_64f volk_32f_convert_64f_u;
extern void volk_32f_convert_64f_manual(double* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_convert_64f_get_func_desc();

alias p_32f_cos_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_cos_32f volk_32f_cos_32f;
extern __gshared p_32f_cos_32f volk_32f_cos_32f_a;
extern __gshared p_32f_cos_32f volk_32f_cos_32f_u;
extern void volk_32f_cos_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_cos_32f_get_func_desc();

alias p_32f_exp_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_exp_32f volk_32f_exp_32f;
extern __gshared p_32f_exp_32f volk_32f_exp_32f_a;
extern __gshared p_32f_exp_32f volk_32f_exp_32f_u;
extern void volk_32f_exp_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_exp_32f_get_func_desc();

alias p_32f_expfast_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_expfast_32f volk_32f_expfast_32f;
extern __gshared p_32f_expfast_32f volk_32f_expfast_32f_a;
extern __gshared p_32f_expfast_32f volk_32f_expfast_32f_u;
extern void volk_32f_expfast_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_expfast_32f_get_func_desc();

alias p_32f_index_max_16u = void function(ushort* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_index_max_16u volk_32f_index_max_16u;
extern __gshared p_32f_index_max_16u volk_32f_index_max_16u_a;
extern __gshared p_32f_index_max_16u volk_32f_index_max_16u_u;
extern void volk_32f_index_max_16u_manual(ushort* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_index_max_16u_get_func_desc();

alias p_32f_index_max_32u = void function(uint* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_index_max_32u volk_32f_index_max_32u;
extern __gshared p_32f_index_max_32u volk_32f_index_max_32u_a;
extern __gshared p_32f_index_max_32u volk_32f_index_max_32u_u;
extern void volk_32f_index_max_32u_manual(uint* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_index_max_32u_get_func_desc();

alias p_32f_index_min_16u = void function(ushort* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_index_min_16u volk_32f_index_min_16u;
extern __gshared p_32f_index_min_16u volk_32f_index_min_16u_a;
extern __gshared p_32f_index_min_16u volk_32f_index_min_16u_u;
extern void volk_32f_index_min_16u_manual(ushort* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_index_min_16u_get_func_desc();

alias p_32f_index_min_32u = void function(uint* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_index_min_32u volk_32f_index_min_32u;
extern __gshared p_32f_index_min_32u volk_32f_index_min_32u_a;
extern __gshared p_32f_index_min_32u volk_32f_index_min_32u_u;
extern void volk_32f_index_min_32u_manual(uint* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_index_min_32u_get_func_desc();

alias p_32f_invsqrt_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_invsqrt_32f volk_32f_invsqrt_32f;
extern __gshared p_32f_invsqrt_32f volk_32f_invsqrt_32f_a;
extern __gshared p_32f_invsqrt_32f volk_32f_invsqrt_32f_u;
extern void volk_32f_invsqrt_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_invsqrt_32f_get_func_desc();

alias p_32f_log2_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_log2_32f volk_32f_log2_32f;
extern __gshared p_32f_log2_32f volk_32f_log2_32f_a;
extern __gshared p_32f_log2_32f volk_32f_log2_32f_u;
extern void volk_32f_log2_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_log2_32f_get_func_desc();

alias p_32f_null_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_null_32f volk_32f_null_32f;
extern __gshared p_32f_null_32f volk_32f_null_32f_a;
extern __gshared p_32f_null_32f volk_32f_null_32f_u;
extern void volk_32f_null_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_null_32f_get_func_desc();

alias p_32f_s32f_32f_fm_detect_32f = void function(float* , const float* , const float , float* , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_32f_fm_detect_32f volk_32f_s32f_32f_fm_detect_32f;
extern __gshared p_32f_s32f_32f_fm_detect_32f volk_32f_s32f_32f_fm_detect_32f_a;
extern __gshared p_32f_s32f_32f_fm_detect_32f volk_32f_s32f_32f_fm_detect_32f_u;
extern void volk_32f_s32f_32f_fm_detect_32f_manual(float* , const float* , const float , float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_32f_fm_detect_32f_get_func_desc();

alias p_32f_s32f_add_32f = void function(float* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_add_32f volk_32f_s32f_add_32f;
extern __gshared p_32f_s32f_add_32f volk_32f_s32f_add_32f_a;
extern __gshared p_32f_s32f_add_32f volk_32f_s32f_add_32f_u;
extern void volk_32f_s32f_add_32f_manual(float* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_add_32f_get_func_desc();

alias p_32f_s32f_calc_spectral_noise_floor_32f = void function(float* , const float* , const float , const uint ) nothrow @nogc;
extern __gshared p_32f_s32f_calc_spectral_noise_floor_32f volk_32f_s32f_calc_spectral_noise_floor_32f;
extern __gshared p_32f_s32f_calc_spectral_noise_floor_32f volk_32f_s32f_calc_spectral_noise_floor_32f_a;
extern __gshared p_32f_s32f_calc_spectral_noise_floor_32f volk_32f_s32f_calc_spectral_noise_floor_32f_u;
extern void volk_32f_s32f_calc_spectral_noise_floor_32f_manual(float* , const float* , const float , const uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_calc_spectral_noise_floor_32f_get_func_desc();

alias p_32f_s32f_clamppuppet_32f = void function(float* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_clamppuppet_32f volk_32f_s32f_clamppuppet_32f;
extern __gshared p_32f_s32f_clamppuppet_32f volk_32f_s32f_clamppuppet_32f_a;
extern __gshared p_32f_s32f_clamppuppet_32f volk_32f_s32f_clamppuppet_32f_u;
extern void volk_32f_s32f_clamppuppet_32f_manual(float* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_clamppuppet_32f_get_func_desc();

alias p_32f_s32f_convert_16i = void function(short* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_convert_16i volk_32f_s32f_convert_16i;
extern __gshared p_32f_s32f_convert_16i volk_32f_s32f_convert_16i_a;
extern __gshared p_32f_s32f_convert_16i volk_32f_s32f_convert_16i_u;
extern void volk_32f_s32f_convert_16i_manual(short* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_convert_16i_get_func_desc();

alias p_32f_s32f_convert_32i = void function(int* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_convert_32i volk_32f_s32f_convert_32i;
extern __gshared p_32f_s32f_convert_32i volk_32f_s32f_convert_32i_a;
extern __gshared p_32f_s32f_convert_32i volk_32f_s32f_convert_32i_u;
extern void volk_32f_s32f_convert_32i_manual(int* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_convert_32i_get_func_desc();

alias p_32f_s32f_convert_8i = void function(byte* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_convert_8i volk_32f_s32f_convert_8i;
extern __gshared p_32f_s32f_convert_8i volk_32f_s32f_convert_8i_a;
extern __gshared p_32f_s32f_convert_8i volk_32f_s32f_convert_8i_u;
extern void volk_32f_s32f_convert_8i_manual(byte* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_convert_8i_get_func_desc();

alias p_32f_s32f_convertpuppet_8u = void function(ubyte* , const float* , float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_convertpuppet_8u volk_32f_s32f_convertpuppet_8u;
extern __gshared p_32f_s32f_convertpuppet_8u volk_32f_s32f_convertpuppet_8u_a;
extern __gshared p_32f_s32f_convertpuppet_8u volk_32f_s32f_convertpuppet_8u_u;
extern void volk_32f_s32f_convertpuppet_8u_manual(ubyte* , const float* , float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_convertpuppet_8u_get_func_desc();

alias p_32f_s32f_mod_rangepuppet_32f = void function(float* , const float* , float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_mod_rangepuppet_32f volk_32f_s32f_mod_rangepuppet_32f;
extern __gshared p_32f_s32f_mod_rangepuppet_32f volk_32f_s32f_mod_rangepuppet_32f_a;
extern __gshared p_32f_s32f_mod_rangepuppet_32f volk_32f_s32f_mod_rangepuppet_32f_u;
extern void volk_32f_s32f_mod_rangepuppet_32f_manual(float* , const float* , float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_mod_rangepuppet_32f_get_func_desc();

alias p_32f_s32f_multiply_32f = void function(float* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_multiply_32f volk_32f_s32f_multiply_32f;
extern __gshared p_32f_s32f_multiply_32f volk_32f_s32f_multiply_32f_a;
extern __gshared p_32f_s32f_multiply_32f volk_32f_s32f_multiply_32f_u;
extern void volk_32f_s32f_multiply_32f_manual(float* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_multiply_32f_get_func_desc();

alias p_32f_s32f_normalize = void function(float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_normalize volk_32f_s32f_normalize;
extern __gshared p_32f_s32f_normalize volk_32f_s32f_normalize_a;
extern __gshared p_32f_s32f_normalize volk_32f_s32f_normalize_u;
extern void volk_32f_s32f_normalize_manual(float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_normalize_get_func_desc();

alias p_32f_s32f_power_32f = void function(float* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_power_32f volk_32f_s32f_power_32f;
extern __gshared p_32f_s32f_power_32f volk_32f_s32f_power_32f_a;
extern __gshared p_32f_s32f_power_32f volk_32f_s32f_power_32f_u;
extern void volk_32f_s32f_power_32f_manual(float* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_power_32f_get_func_desc();

alias p_32f_s32f_s32f_mod_range_32f = void function(float* , const float* , const float , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_s32f_mod_range_32f volk_32f_s32f_s32f_mod_range_32f;
extern __gshared p_32f_s32f_s32f_mod_range_32f volk_32f_s32f_s32f_mod_range_32f_a;
extern __gshared p_32f_s32f_s32f_mod_range_32f volk_32f_s32f_s32f_mod_range_32f_u;
extern void volk_32f_s32f_s32f_mod_range_32f_manual(float* , const float* , const float , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_s32f_mod_range_32f_get_func_desc();

alias p_32f_s32f_stddev_32f = void function(float* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_stddev_32f volk_32f_s32f_stddev_32f;
extern __gshared p_32f_s32f_stddev_32f volk_32f_s32f_stddev_32f_a;
extern __gshared p_32f_s32f_stddev_32f volk_32f_s32f_stddev_32f_u;
extern void volk_32f_s32f_stddev_32f_manual(float* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_stddev_32f_get_func_desc();

alias p_32f_s32f_x2_clamp_32f = void function(float* , const float* , const float , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_x2_clamp_32f volk_32f_s32f_x2_clamp_32f;
extern __gshared p_32f_s32f_x2_clamp_32f volk_32f_s32f_x2_clamp_32f_a;
extern __gshared p_32f_s32f_x2_clamp_32f volk_32f_s32f_x2_clamp_32f_u;
extern void volk_32f_s32f_x2_clamp_32f_manual(float* , const float* , const float , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_x2_clamp_32f_get_func_desc();

alias p_32f_s32f_x2_convert_8u = void function(ubyte* , const float* , const float , const float , uint ) nothrow @nogc;
extern __gshared p_32f_s32f_x2_convert_8u volk_32f_s32f_x2_convert_8u;
extern __gshared p_32f_s32f_x2_convert_8u volk_32f_s32f_x2_convert_8u_a;
extern __gshared p_32f_s32f_x2_convert_8u volk_32f_s32f_x2_convert_8u_u;
extern void volk_32f_s32f_x2_convert_8u_manual(ubyte* , const float* , const float , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_s32f_x2_convert_8u_get_func_desc();

alias p_32f_sin_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_sin_32f volk_32f_sin_32f;
extern __gshared p_32f_sin_32f volk_32f_sin_32f_a;
extern __gshared p_32f_sin_32f volk_32f_sin_32f_u;
extern void volk_32f_sin_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_sin_32f_get_func_desc();

alias p_32f_sqrt_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_sqrt_32f volk_32f_sqrt_32f;
extern __gshared p_32f_sqrt_32f volk_32f_sqrt_32f_a;
extern __gshared p_32f_sqrt_32f volk_32f_sqrt_32f_u;
extern void volk_32f_sqrt_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_sqrt_32f_get_func_desc();

alias p_32f_stddev_and_mean_32f_x2 = void function(float* , float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_stddev_and_mean_32f_x2 volk_32f_stddev_and_mean_32f_x2;
extern __gshared p_32f_stddev_and_mean_32f_x2 volk_32f_stddev_and_mean_32f_x2_a;
extern __gshared p_32f_stddev_and_mean_32f_x2 volk_32f_stddev_and_mean_32f_x2_u;
extern void volk_32f_stddev_and_mean_32f_x2_manual(float* , float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_stddev_and_mean_32f_x2_get_func_desc();

alias p_32f_tan_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_tan_32f volk_32f_tan_32f;
extern __gshared p_32f_tan_32f volk_32f_tan_32f_a;
extern __gshared p_32f_tan_32f volk_32f_tan_32f_u;
extern void volk_32f_tan_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_tan_32f_get_func_desc();

alias p_32f_tanh_32f = void function(float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_tanh_32f volk_32f_tanh_32f;
extern __gshared p_32f_tanh_32f volk_32f_tanh_32f_a;
extern __gshared p_32f_tanh_32f volk_32f_tanh_32f_u;
extern void volk_32f_tanh_32f_manual(float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_tanh_32f_get_func_desc();

alias p_32f_x2_add_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_add_32f volk_32f_x2_add_32f;
extern __gshared p_32f_x2_add_32f volk_32f_x2_add_32f_a;
extern __gshared p_32f_x2_add_32f volk_32f_x2_add_32f_u;
extern void volk_32f_x2_add_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_add_32f_get_func_desc();

alias p_32f_x2_divide_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_divide_32f volk_32f_x2_divide_32f;
extern __gshared p_32f_x2_divide_32f volk_32f_x2_divide_32f_a;
extern __gshared p_32f_x2_divide_32f volk_32f_x2_divide_32f_u;
extern void volk_32f_x2_divide_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_divide_32f_get_func_desc();

alias p_32f_x2_dot_prod_16i = void function(short* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_dot_prod_16i volk_32f_x2_dot_prod_16i;
extern __gshared p_32f_x2_dot_prod_16i volk_32f_x2_dot_prod_16i_a;
extern __gshared p_32f_x2_dot_prod_16i volk_32f_x2_dot_prod_16i_u;
extern void volk_32f_x2_dot_prod_16i_manual(short* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_dot_prod_16i_get_func_desc();

alias p_32f_x2_dot_prod_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_dot_prod_32f volk_32f_x2_dot_prod_32f;
extern __gshared p_32f_x2_dot_prod_32f volk_32f_x2_dot_prod_32f_a;
extern __gshared p_32f_x2_dot_prod_32f volk_32f_x2_dot_prod_32f_u;
extern void volk_32f_x2_dot_prod_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_dot_prod_32f_get_func_desc();

alias p_32f_x2_fm_detectpuppet_32f = void function(float* , const float* , float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_fm_detectpuppet_32f volk_32f_x2_fm_detectpuppet_32f;
extern __gshared p_32f_x2_fm_detectpuppet_32f volk_32f_x2_fm_detectpuppet_32f_a;
extern __gshared p_32f_x2_fm_detectpuppet_32f volk_32f_x2_fm_detectpuppet_32f_u;
extern void volk_32f_x2_fm_detectpuppet_32f_manual(float* , const float* , float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_fm_detectpuppet_32f_get_func_desc();

alias p_32f_x2_interleave_32fc = void function(lv_32fc_t* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_interleave_32fc volk_32f_x2_interleave_32fc;
extern __gshared p_32f_x2_interleave_32fc volk_32f_x2_interleave_32fc_a;
extern __gshared p_32f_x2_interleave_32fc volk_32f_x2_interleave_32fc_u;
extern void volk_32f_x2_interleave_32fc_manual(lv_32fc_t* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_interleave_32fc_get_func_desc();

alias p_32f_x2_max_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_max_32f volk_32f_x2_max_32f;
extern __gshared p_32f_x2_max_32f volk_32f_x2_max_32f_a;
extern __gshared p_32f_x2_max_32f volk_32f_x2_max_32f_u;
extern void volk_32f_x2_max_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_max_32f_get_func_desc();

alias p_32f_x2_min_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_min_32f volk_32f_x2_min_32f;
extern __gshared p_32f_x2_min_32f volk_32f_x2_min_32f_a;
extern __gshared p_32f_x2_min_32f volk_32f_x2_min_32f_u;
extern void volk_32f_x2_min_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_min_32f_get_func_desc();

alias p_32f_x2_multiply_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_multiply_32f volk_32f_x2_multiply_32f;
extern __gshared p_32f_x2_multiply_32f volk_32f_x2_multiply_32f_a;
extern __gshared p_32f_x2_multiply_32f volk_32f_x2_multiply_32f_u;
extern void volk_32f_x2_multiply_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_multiply_32f_get_func_desc();

alias p_32f_x2_pow_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_pow_32f volk_32f_x2_pow_32f;
extern __gshared p_32f_x2_pow_32f volk_32f_x2_pow_32f_a;
extern __gshared p_32f_x2_pow_32f volk_32f_x2_pow_32f_u;
extern void volk_32f_x2_pow_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_pow_32f_get_func_desc();

alias p_32f_x2_powpuppet_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_powpuppet_32f volk_32f_x2_powpuppet_32f;
extern __gshared p_32f_x2_powpuppet_32f volk_32f_x2_powpuppet_32f_a;
extern __gshared p_32f_x2_powpuppet_32f volk_32f_x2_powpuppet_32f_u;
extern void volk_32f_x2_powpuppet_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_powpuppet_32f_get_func_desc();

alias p_32f_x2_s32f_interleave_16ic = void function(lv_16sc_t* , const float* , const float* , const float , uint ) nothrow @nogc;
extern __gshared p_32f_x2_s32f_interleave_16ic volk_32f_x2_s32f_interleave_16ic;
extern __gshared p_32f_x2_s32f_interleave_16ic volk_32f_x2_s32f_interleave_16ic_a;
extern __gshared p_32f_x2_s32f_interleave_16ic volk_32f_x2_s32f_interleave_16ic_u;
extern void volk_32f_x2_s32f_interleave_16ic_manual(lv_16sc_t* , const float* , const float* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_s32f_interleave_16ic_get_func_desc();

alias p_32f_x2_subtract_32f = void function(float* , const float* , const float* , uint ) nothrow @nogc;
extern __gshared p_32f_x2_subtract_32f volk_32f_x2_subtract_32f;
extern __gshared p_32f_x2_subtract_32f volk_32f_x2_subtract_32f_a;
extern __gshared p_32f_x2_subtract_32f volk_32f_x2_subtract_32f_u;
extern void volk_32f_x2_subtract_32f_manual(float* , const float* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x2_subtract_32f_get_func_desc();

alias p_32f_x3_sum_of_poly_32f = void function(float* , float* , float* , float* , uint ) nothrow @nogc;
extern __gshared p_32f_x3_sum_of_poly_32f volk_32f_x3_sum_of_poly_32f;
extern __gshared p_32f_x3_sum_of_poly_32f volk_32f_x3_sum_of_poly_32f_a;
extern __gshared p_32f_x3_sum_of_poly_32f volk_32f_x3_sum_of_poly_32f_u;
extern void volk_32f_x3_sum_of_poly_32f_manual(float* , float* , float* , float* , uint , const(char)*);
extern volk_func_desc_t volk_32f_x3_sum_of_poly_32f_get_func_desc();

alias p_32fc_32f_add_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const float* , uint ) nothrow @nogc;
extern __gshared p_32fc_32f_add_32fc volk_32fc_32f_add_32fc;
extern __gshared p_32fc_32f_add_32fc volk_32fc_32f_add_32fc_a;
extern __gshared p_32fc_32f_add_32fc volk_32fc_32f_add_32fc_u;
extern void volk_32fc_32f_add_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_32f_add_32fc_get_func_desc();

alias p_32fc_32f_dot_prod_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const float* , uint ) nothrow @nogc;
extern __gshared p_32fc_32f_dot_prod_32fc volk_32fc_32f_dot_prod_32fc;
extern __gshared p_32fc_32f_dot_prod_32fc volk_32fc_32f_dot_prod_32fc_a;
extern __gshared p_32fc_32f_dot_prod_32fc volk_32fc_32f_dot_prod_32fc_u;
extern void volk_32fc_32f_dot_prod_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_32f_dot_prod_32fc_get_func_desc();

alias p_32fc_32f_multiply_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const float* , uint ) nothrow @nogc;
extern __gshared p_32fc_32f_multiply_32fc volk_32fc_32f_multiply_32fc;
extern __gshared p_32fc_32f_multiply_32fc volk_32fc_32f_multiply_32fc_a;
extern __gshared p_32fc_32f_multiply_32fc volk_32fc_32f_multiply_32fc_u;
extern void volk_32fc_32f_multiply_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const float* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_32f_multiply_32fc_get_func_desc();

alias p_32fc_accumulator_s32fc = void function(lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_accumulator_s32fc volk_32fc_accumulator_s32fc;
extern __gshared p_32fc_accumulator_s32fc volk_32fc_accumulator_s32fc_a;
extern __gshared p_32fc_accumulator_s32fc volk_32fc_accumulator_s32fc_u;
extern void volk_32fc_accumulator_s32fc_manual(lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_accumulator_s32fc_get_func_desc();

alias p_32fc_conjugate_32fc = void function(lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_conjugate_32fc volk_32fc_conjugate_32fc;
extern __gshared p_32fc_conjugate_32fc volk_32fc_conjugate_32fc_a;
extern __gshared p_32fc_conjugate_32fc volk_32fc_conjugate_32fc_u;
extern void volk_32fc_conjugate_32fc_manual(lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_conjugate_32fc_get_func_desc();

alias p_32fc_convert_16ic = void function(lv_16sc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_convert_16ic volk_32fc_convert_16ic;
extern __gshared p_32fc_convert_16ic volk_32fc_convert_16ic_a;
extern __gshared p_32fc_convert_16ic volk_32fc_convert_16ic_u;
extern void volk_32fc_convert_16ic_manual(lv_16sc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_convert_16ic_get_func_desc();

alias p_32fc_deinterleave_32f_x2 = void function(float* , float* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_deinterleave_32f_x2 volk_32fc_deinterleave_32f_x2;
extern __gshared p_32fc_deinterleave_32f_x2 volk_32fc_deinterleave_32f_x2_a;
extern __gshared p_32fc_deinterleave_32f_x2 volk_32fc_deinterleave_32f_x2_u;
extern void volk_32fc_deinterleave_32f_x2_manual(float* , float* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_deinterleave_32f_x2_get_func_desc();

alias p_32fc_deinterleave_64f_x2 = void function(double* , double* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_deinterleave_64f_x2 volk_32fc_deinterleave_64f_x2;
extern __gshared p_32fc_deinterleave_64f_x2 volk_32fc_deinterleave_64f_x2_a;
extern __gshared p_32fc_deinterleave_64f_x2 volk_32fc_deinterleave_64f_x2_u;
extern void volk_32fc_deinterleave_64f_x2_manual(double* , double* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_deinterleave_64f_x2_get_func_desc();

alias p_32fc_deinterleave_imag_32f = void function(float* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_deinterleave_imag_32f volk_32fc_deinterleave_imag_32f;
extern __gshared p_32fc_deinterleave_imag_32f volk_32fc_deinterleave_imag_32f_a;
extern __gshared p_32fc_deinterleave_imag_32f volk_32fc_deinterleave_imag_32f_u;
extern void volk_32fc_deinterleave_imag_32f_manual(float* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_deinterleave_imag_32f_get_func_desc();

alias p_32fc_deinterleave_real_32f = void function(float* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_deinterleave_real_32f volk_32fc_deinterleave_real_32f;
extern __gshared p_32fc_deinterleave_real_32f volk_32fc_deinterleave_real_32f_a;
extern __gshared p_32fc_deinterleave_real_32f volk_32fc_deinterleave_real_32f_u;
extern void volk_32fc_deinterleave_real_32f_manual(float* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_deinterleave_real_32f_get_func_desc();

alias p_32fc_deinterleave_real_64f = void function(double* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_deinterleave_real_64f volk_32fc_deinterleave_real_64f;
extern __gshared p_32fc_deinterleave_real_64f volk_32fc_deinterleave_real_64f_a;
extern __gshared p_32fc_deinterleave_real_64f volk_32fc_deinterleave_real_64f_u;
extern void volk_32fc_deinterleave_real_64f_manual(double* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_deinterleave_real_64f_get_func_desc();

alias p_32fc_index_max_16u = void function(ushort* , lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_index_max_16u volk_32fc_index_max_16u;
extern __gshared p_32fc_index_max_16u volk_32fc_index_max_16u_a;
extern __gshared p_32fc_index_max_16u volk_32fc_index_max_16u_u;
extern void volk_32fc_index_max_16u_manual(ushort* , lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_index_max_16u_get_func_desc();

alias p_32fc_index_max_32u = void function(uint* , lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_index_max_32u volk_32fc_index_max_32u;
extern __gshared p_32fc_index_max_32u volk_32fc_index_max_32u_a;
extern __gshared p_32fc_index_max_32u volk_32fc_index_max_32u_u;
extern void volk_32fc_index_max_32u_manual(uint* , lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_index_max_32u_get_func_desc();

alias p_32fc_index_min_16u = void function(ushort* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_index_min_16u volk_32fc_index_min_16u;
extern __gshared p_32fc_index_min_16u volk_32fc_index_min_16u_a;
extern __gshared p_32fc_index_min_16u volk_32fc_index_min_16u_u;
extern void volk_32fc_index_min_16u_manual(ushort* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_index_min_16u_get_func_desc();

alias p_32fc_index_min_32u = void function(uint* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_index_min_32u volk_32fc_index_min_32u;
extern __gshared p_32fc_index_min_32u volk_32fc_index_min_32u_a;
extern __gshared p_32fc_index_min_32u volk_32fc_index_min_32u_u;
extern void volk_32fc_index_min_32u_manual(uint* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_index_min_32u_get_func_desc();

alias p_32fc_magnitude_32f = void function(float* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_magnitude_32f volk_32fc_magnitude_32f;
extern __gshared p_32fc_magnitude_32f volk_32fc_magnitude_32f_a;
extern __gshared p_32fc_magnitude_32f volk_32fc_magnitude_32f_u;
extern void volk_32fc_magnitude_32f_manual(float* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_magnitude_32f_get_func_desc();

alias p_32fc_magnitude_squared_32f = void function(float* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_magnitude_squared_32f volk_32fc_magnitude_squared_32f;
extern __gshared p_32fc_magnitude_squared_32f volk_32fc_magnitude_squared_32f_a;
extern __gshared p_32fc_magnitude_squared_32f volk_32fc_magnitude_squared_32f_u;
extern void volk_32fc_magnitude_squared_32f_manual(float* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_magnitude_squared_32f_get_func_desc();

alias p_32fc_s32f_atan2_32f = void function(float* , const lv_32fc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_32fc_s32f_atan2_32f volk_32fc_s32f_atan2_32f;
extern __gshared p_32fc_s32f_atan2_32f volk_32fc_s32f_atan2_32f_a;
extern __gshared p_32fc_s32f_atan2_32f volk_32fc_s32f_atan2_32f_u;
extern void volk_32fc_s32f_atan2_32f_manual(float* , const lv_32fc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32f_atan2_32f_get_func_desc();

alias p_32fc_s32f_deinterleave_real_16i = void function(short* , const lv_32fc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_32fc_s32f_deinterleave_real_16i volk_32fc_s32f_deinterleave_real_16i;
extern __gshared p_32fc_s32f_deinterleave_real_16i volk_32fc_s32f_deinterleave_real_16i_a;
extern __gshared p_32fc_s32f_deinterleave_real_16i volk_32fc_s32f_deinterleave_real_16i_u;
extern void volk_32fc_s32f_deinterleave_real_16i_manual(short* , const lv_32fc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32f_deinterleave_real_16i_get_func_desc();

alias p_32fc_s32f_magnitude_16i = void function(short* , const lv_32fc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_32fc_s32f_magnitude_16i volk_32fc_s32f_magnitude_16i;
extern __gshared p_32fc_s32f_magnitude_16i volk_32fc_s32f_magnitude_16i_a;
extern __gshared p_32fc_s32f_magnitude_16i volk_32fc_s32f_magnitude_16i_u;
extern void volk_32fc_s32f_magnitude_16i_manual(short* , const lv_32fc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32f_magnitude_16i_get_func_desc();

alias p_32fc_s32f_power_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_32fc_s32f_power_32fc volk_32fc_s32f_power_32fc;
extern __gshared p_32fc_s32f_power_32fc volk_32fc_s32f_power_32fc_a;
extern __gshared p_32fc_s32f_power_32fc volk_32fc_s32f_power_32fc_u;
extern void volk_32fc_s32f_power_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32f_power_32fc_get_func_desc();

alias p_32fc_s32f_power_spectral_densitypuppet_32f = void function(float* , const lv_32fc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_32fc_s32f_power_spectral_densitypuppet_32f volk_32fc_s32f_power_spectral_densitypuppet_32f;
extern __gshared p_32fc_s32f_power_spectral_densitypuppet_32f volk_32fc_s32f_power_spectral_densitypuppet_32f_a;
extern __gshared p_32fc_s32f_power_spectral_densitypuppet_32f volk_32fc_s32f_power_spectral_densitypuppet_32f_u;
extern void volk_32fc_s32f_power_spectral_densitypuppet_32f_manual(float* , const lv_32fc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32f_power_spectral_densitypuppet_32f_get_func_desc();

alias p_32fc_s32f_power_spectrum_32f = void function(float* , const lv_32fc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_32fc_s32f_power_spectrum_32f volk_32fc_s32f_power_spectrum_32f;
extern __gshared p_32fc_s32f_power_spectrum_32f volk_32fc_s32f_power_spectrum_32f_a;
extern __gshared p_32fc_s32f_power_spectrum_32f volk_32fc_s32f_power_spectrum_32f_u;
extern void volk_32fc_s32f_power_spectrum_32f_manual(float* , const lv_32fc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32f_power_spectrum_32f_get_func_desc();

alias p_32fc_s32f_x2_power_spectral_density_32f = void function(float* , const lv_32fc_t* , const float , const float , uint ) nothrow @nogc;
extern __gshared p_32fc_s32f_x2_power_spectral_density_32f volk_32fc_s32f_x2_power_spectral_density_32f;
extern __gshared p_32fc_s32f_x2_power_spectral_density_32f volk_32fc_s32f_x2_power_spectral_density_32f_a;
extern __gshared p_32fc_s32f_x2_power_spectral_density_32f volk_32fc_s32f_x2_power_spectral_density_32f_u;
extern void volk_32fc_s32f_x2_power_spectral_density_32f_manual(float* , const lv_32fc_t* , const float , const float , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32f_x2_power_spectral_density_32f_get_func_desc();

alias p_32fc_s32fc_multiply2_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_s32fc_multiply2_32fc volk_32fc_s32fc_multiply2_32fc;
extern __gshared p_32fc_s32fc_multiply2_32fc volk_32fc_s32fc_multiply2_32fc_a;
extern __gshared p_32fc_s32fc_multiply2_32fc volk_32fc_s32fc_multiply2_32fc_u;
extern void volk_32fc_s32fc_multiply2_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32fc_multiply2_32fc_get_func_desc();

alias p_32fc_s32fc_multiply_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , uint ) nothrow @nogc;
extern __gshared p_32fc_s32fc_multiply_32fc volk_32fc_s32fc_multiply_32fc;
extern __gshared p_32fc_s32fc_multiply_32fc volk_32fc_s32fc_multiply_32fc_a;
extern __gshared p_32fc_s32fc_multiply_32fc volk_32fc_s32fc_multiply_32fc_u;
extern void volk_32fc_s32fc_multiply_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32fc_multiply_32fc_get_func_desc();

alias p_32fc_s32fc_rotator2puppet_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_s32fc_rotator2puppet_32fc volk_32fc_s32fc_rotator2puppet_32fc;
extern __gshared p_32fc_s32fc_rotator2puppet_32fc volk_32fc_s32fc_rotator2puppet_32fc_a;
extern __gshared p_32fc_s32fc_rotator2puppet_32fc volk_32fc_s32fc_rotator2puppet_32fc_u;
extern void volk_32fc_s32fc_rotator2puppet_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32fc_rotator2puppet_32fc_get_func_desc();

alias p_32fc_s32fc_x2_rotator2_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_s32fc_x2_rotator2_32fc volk_32fc_s32fc_x2_rotator2_32fc;
extern __gshared p_32fc_s32fc_x2_rotator2_32fc volk_32fc_s32fc_x2_rotator2_32fc_a;
extern __gshared p_32fc_s32fc_x2_rotator2_32fc volk_32fc_s32fc_x2_rotator2_32fc_u;
extern void volk_32fc_s32fc_x2_rotator2_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32fc_x2_rotator2_32fc_get_func_desc();

alias p_32fc_s32fc_x2_rotator_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_s32fc_x2_rotator_32fc volk_32fc_s32fc_x2_rotator_32fc;
extern __gshared p_32fc_s32fc_x2_rotator_32fc volk_32fc_s32fc_x2_rotator_32fc_a;
extern __gshared p_32fc_s32fc_x2_rotator_32fc volk_32fc_s32fc_x2_rotator_32fc_u;
extern void volk_32fc_s32fc_x2_rotator_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_s32fc_x2_rotator_32fc_get_func_desc();

alias p_32fc_x2_add_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_add_32fc volk_32fc_x2_add_32fc;
extern __gshared p_32fc_x2_add_32fc volk_32fc_x2_add_32fc_a;
extern __gshared p_32fc_x2_add_32fc volk_32fc_x2_add_32fc_u;
extern void volk_32fc_x2_add_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_add_32fc_get_func_desc();

alias p_32fc_x2_conjugate_dot_prod_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_conjugate_dot_prod_32fc volk_32fc_x2_conjugate_dot_prod_32fc;
extern __gshared p_32fc_x2_conjugate_dot_prod_32fc volk_32fc_x2_conjugate_dot_prod_32fc_a;
extern __gshared p_32fc_x2_conjugate_dot_prod_32fc volk_32fc_x2_conjugate_dot_prod_32fc_u;
extern void volk_32fc_x2_conjugate_dot_prod_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_conjugate_dot_prod_32fc_get_func_desc();

alias p_32fc_x2_divide_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_divide_32fc volk_32fc_x2_divide_32fc;
extern __gshared p_32fc_x2_divide_32fc volk_32fc_x2_divide_32fc_a;
extern __gshared p_32fc_x2_divide_32fc volk_32fc_x2_divide_32fc_u;
extern void volk_32fc_x2_divide_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_divide_32fc_get_func_desc();

alias p_32fc_x2_dot_prod_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_dot_prod_32fc volk_32fc_x2_dot_prod_32fc;
extern __gshared p_32fc_x2_dot_prod_32fc volk_32fc_x2_dot_prod_32fc_a;
extern __gshared p_32fc_x2_dot_prod_32fc volk_32fc_x2_dot_prod_32fc_u;
extern void volk_32fc_x2_dot_prod_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_dot_prod_32fc_get_func_desc();

alias p_32fc_x2_multiply_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_multiply_32fc volk_32fc_x2_multiply_32fc;
extern __gshared p_32fc_x2_multiply_32fc volk_32fc_x2_multiply_32fc_a;
extern __gshared p_32fc_x2_multiply_32fc volk_32fc_x2_multiply_32fc_u;
extern void volk_32fc_x2_multiply_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_multiply_32fc_get_func_desc();

alias p_32fc_x2_multiply_conjugate_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_multiply_conjugate_32fc volk_32fc_x2_multiply_conjugate_32fc;
extern __gshared p_32fc_x2_multiply_conjugate_32fc volk_32fc_x2_multiply_conjugate_32fc_a;
extern __gshared p_32fc_x2_multiply_conjugate_32fc volk_32fc_x2_multiply_conjugate_32fc_u;
extern void volk_32fc_x2_multiply_conjugate_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_multiply_conjugate_32fc_get_func_desc();

alias p_32fc_x2_s32f_square_dist_scalar_mult_32f = void function(float* , lv_32fc_t* , lv_32fc_t* , float , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_s32f_square_dist_scalar_mult_32f volk_32fc_x2_s32f_square_dist_scalar_mult_32f;
extern __gshared p_32fc_x2_s32f_square_dist_scalar_mult_32f volk_32fc_x2_s32f_square_dist_scalar_mult_32f_a;
extern __gshared p_32fc_x2_s32f_square_dist_scalar_mult_32f volk_32fc_x2_s32f_square_dist_scalar_mult_32f_u;
extern void volk_32fc_x2_s32f_square_dist_scalar_mult_32f_manual(float* , lv_32fc_t* , lv_32fc_t* , float , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_s32f_square_dist_scalar_mult_32f_get_func_desc();

alias p_32fc_x2_s32fc_multiply_conjugate_add2_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_s32fc_multiply_conjugate_add2_32fc volk_32fc_x2_s32fc_multiply_conjugate_add2_32fc;
extern __gshared p_32fc_x2_s32fc_multiply_conjugate_add2_32fc volk_32fc_x2_s32fc_multiply_conjugate_add2_32fc_a;
extern __gshared p_32fc_x2_s32fc_multiply_conjugate_add2_32fc volk_32fc_x2_s32fc_multiply_conjugate_add2_32fc_u;
extern void volk_32fc_x2_s32fc_multiply_conjugate_add2_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_s32fc_multiply_conjugate_add2_32fc_get_func_desc();

alias p_32fc_x2_s32fc_multiply_conjugate_add_32fc = void function(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_s32fc_multiply_conjugate_add_32fc volk_32fc_x2_s32fc_multiply_conjugate_add_32fc;
extern __gshared p_32fc_x2_s32fc_multiply_conjugate_add_32fc volk_32fc_x2_s32fc_multiply_conjugate_add_32fc_a;
extern __gshared p_32fc_x2_s32fc_multiply_conjugate_add_32fc volk_32fc_x2_s32fc_multiply_conjugate_add_32fc_u;
extern void volk_32fc_x2_s32fc_multiply_conjugate_add_32fc_manual(lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t* , const lv_32fc_t , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_s32fc_multiply_conjugate_add_32fc_get_func_desc();

alias p_32fc_x2_square_dist_32f = void function(float* , lv_32fc_t* , lv_32fc_t* , uint ) nothrow @nogc;
extern __gshared p_32fc_x2_square_dist_32f volk_32fc_x2_square_dist_32f;
extern __gshared p_32fc_x2_square_dist_32f volk_32fc_x2_square_dist_32f_a;
extern __gshared p_32fc_x2_square_dist_32f volk_32fc_x2_square_dist_32f_u;
extern void volk_32fc_x2_square_dist_32f_manual(float* , lv_32fc_t* , lv_32fc_t* , uint , const(char)*);
extern volk_func_desc_t volk_32fc_x2_square_dist_32f_get_func_desc();

alias p_32i_s32f_convert_32f = void function(float* , const int* , const float , uint ) nothrow @nogc;
extern __gshared p_32i_s32f_convert_32f volk_32i_s32f_convert_32f;
extern __gshared p_32i_s32f_convert_32f volk_32i_s32f_convert_32f_a;
extern __gshared p_32i_s32f_convert_32f volk_32i_s32f_convert_32f_u;
extern void volk_32i_s32f_convert_32f_manual(float* , const int* , const float , uint , const(char)*);
extern volk_func_desc_t volk_32i_s32f_convert_32f_get_func_desc();

alias p_32i_x2_and_32i = void function(int* , const int* , const int* , uint ) nothrow @nogc;
extern __gshared p_32i_x2_and_32i volk_32i_x2_and_32i;
extern __gshared p_32i_x2_and_32i volk_32i_x2_and_32i_a;
extern __gshared p_32i_x2_and_32i volk_32i_x2_and_32i_u;
extern void volk_32i_x2_and_32i_manual(int* , const int* , const int* , uint , const(char)*);
extern volk_func_desc_t volk_32i_x2_and_32i_get_func_desc();

alias p_32i_x2_or_32i = void function(int* , const int* , const int* , uint ) nothrow @nogc;
extern __gshared p_32i_x2_or_32i volk_32i_x2_or_32i;
extern __gshared p_32i_x2_or_32i volk_32i_x2_or_32i_a;
extern __gshared p_32i_x2_or_32i volk_32i_x2_or_32i_u;
extern void volk_32i_x2_or_32i_manual(int* , const int* , const int* , uint , const(char)*);
extern volk_func_desc_t volk_32i_x2_or_32i_get_func_desc();

alias p_32u_byteswap = void function(uint* , uint ) nothrow @nogc;
extern __gshared p_32u_byteswap volk_32u_byteswap;
extern __gshared p_32u_byteswap volk_32u_byteswap_a;
extern __gshared p_32u_byteswap volk_32u_byteswap_u;
extern void volk_32u_byteswap_manual(uint* , uint , const(char)*);
extern volk_func_desc_t volk_32u_byteswap_get_func_desc();

alias p_32u_byteswappuppet_32u = void function(uint* , uint* , uint ) nothrow @nogc;
extern __gshared p_32u_byteswappuppet_32u volk_32u_byteswappuppet_32u;
extern __gshared p_32u_byteswappuppet_32u volk_32u_byteswappuppet_32u_a;
extern __gshared p_32u_byteswappuppet_32u volk_32u_byteswappuppet_32u_u;
extern void volk_32u_byteswappuppet_32u_manual(uint* , uint* , uint , const(char)*);
extern volk_func_desc_t volk_32u_byteswappuppet_32u_get_func_desc();

alias p_32u_popcnt = void function(uint* , const uint ) nothrow @nogc;
extern __gshared p_32u_popcnt volk_32u_popcnt;
extern __gshared p_32u_popcnt volk_32u_popcnt_a;
extern __gshared p_32u_popcnt volk_32u_popcnt_u;
extern void volk_32u_popcnt_manual(uint* , const uint , const(char)*);
extern volk_func_desc_t volk_32u_popcnt_get_func_desc();

alias p_32u_popcntpuppet_32u = void function(uint* , const uint* , uint ) nothrow @nogc;
extern __gshared p_32u_popcntpuppet_32u volk_32u_popcntpuppet_32u;
extern __gshared p_32u_popcntpuppet_32u volk_32u_popcntpuppet_32u_a;
extern __gshared p_32u_popcntpuppet_32u volk_32u_popcntpuppet_32u_u;
extern void volk_32u_popcntpuppet_32u_manual(uint* , const uint* , uint , const(char)*);
extern volk_func_desc_t volk_32u_popcntpuppet_32u_get_func_desc();

alias p_32u_reverse_32u = void function(uint* , const uint* , uint ) nothrow @nogc;
extern __gshared p_32u_reverse_32u volk_32u_reverse_32u;
extern __gshared p_32u_reverse_32u volk_32u_reverse_32u_a;
extern __gshared p_32u_reverse_32u volk_32u_reverse_32u_u;
extern void volk_32u_reverse_32u_manual(uint* , const uint* , uint , const(char)*);
extern volk_func_desc_t volk_32u_reverse_32u_get_func_desc();

alias p_64f_convert_32f = void function(float* , const double* , uint ) nothrow @nogc;
extern __gshared p_64f_convert_32f volk_64f_convert_32f;
extern __gshared p_64f_convert_32f volk_64f_convert_32f_a;
extern __gshared p_64f_convert_32f volk_64f_convert_32f_u;
extern void volk_64f_convert_32f_manual(float* , const double* , uint , const(char)*);
extern volk_func_desc_t volk_64f_convert_32f_get_func_desc();

alias p_64f_x2_add_64f = void function(double* , const double* , const double* , uint ) nothrow @nogc;
extern __gshared p_64f_x2_add_64f volk_64f_x2_add_64f;
extern __gshared p_64f_x2_add_64f volk_64f_x2_add_64f_a;
extern __gshared p_64f_x2_add_64f volk_64f_x2_add_64f_u;
extern void volk_64f_x2_add_64f_manual(double* , const double* , const double* , uint , const(char)*);
extern volk_func_desc_t volk_64f_x2_add_64f_get_func_desc();

alias p_64f_x2_max_64f = void function(double* , const double* , const double* , uint ) nothrow @nogc;
extern __gshared p_64f_x2_max_64f volk_64f_x2_max_64f;
extern __gshared p_64f_x2_max_64f volk_64f_x2_max_64f_a;
extern __gshared p_64f_x2_max_64f volk_64f_x2_max_64f_u;
extern void volk_64f_x2_max_64f_manual(double* , const double* , const double* , uint , const(char)*);
extern volk_func_desc_t volk_64f_x2_max_64f_get_func_desc();

alias p_64f_x2_min_64f = void function(double* , const double* , const double* , uint ) nothrow @nogc;
extern __gshared p_64f_x2_min_64f volk_64f_x2_min_64f;
extern __gshared p_64f_x2_min_64f volk_64f_x2_min_64f_a;
extern __gshared p_64f_x2_min_64f volk_64f_x2_min_64f_u;
extern void volk_64f_x2_min_64f_manual(double* , const double* , const double* , uint , const(char)*);
extern volk_func_desc_t volk_64f_x2_min_64f_get_func_desc();

alias p_64f_x2_multiply_64f = void function(double* , const double* , const double* , uint ) nothrow @nogc;
extern __gshared p_64f_x2_multiply_64f volk_64f_x2_multiply_64f;
extern __gshared p_64f_x2_multiply_64f volk_64f_x2_multiply_64f_a;
extern __gshared p_64f_x2_multiply_64f volk_64f_x2_multiply_64f_u;
extern void volk_64f_x2_multiply_64f_manual(double* , const double* , const double* , uint , const(char)*);
extern volk_func_desc_t volk_64f_x2_multiply_64f_get_func_desc();

alias p_64u_byteswap = void function(ulong* , uint ) nothrow @nogc;
extern __gshared p_64u_byteswap volk_64u_byteswap;
extern __gshared p_64u_byteswap volk_64u_byteswap_a;
extern __gshared p_64u_byteswap volk_64u_byteswap_u;
extern void volk_64u_byteswap_manual(ulong* , uint , const(char)*);
extern volk_func_desc_t volk_64u_byteswap_get_func_desc();

alias p_64u_byteswappuppet_64u = void function(ulong* , ulong* , uint ) nothrow @nogc;
extern __gshared p_64u_byteswappuppet_64u volk_64u_byteswappuppet_64u;
extern __gshared p_64u_byteswappuppet_64u volk_64u_byteswappuppet_64u_a;
extern __gshared p_64u_byteswappuppet_64u volk_64u_byteswappuppet_64u_u;
extern void volk_64u_byteswappuppet_64u_manual(ulong* , ulong* , uint , const(char)*);
extern volk_func_desc_t volk_64u_byteswappuppet_64u_get_func_desc();

alias p_64u_popcnt = void function(ulong* , const ulong ) nothrow @nogc;
extern __gshared p_64u_popcnt volk_64u_popcnt;
extern __gshared p_64u_popcnt volk_64u_popcnt_a;
extern __gshared p_64u_popcnt volk_64u_popcnt_u;
extern void volk_64u_popcnt_manual(ulong* , const ulong , const(char)*);
extern volk_func_desc_t volk_64u_popcnt_get_func_desc();

alias p_64u_popcntpuppet_64u = void function(ulong* , const ulong* , uint ) nothrow @nogc;
extern __gshared p_64u_popcntpuppet_64u volk_64u_popcntpuppet_64u;
extern __gshared p_64u_popcntpuppet_64u volk_64u_popcntpuppet_64u_a;
extern __gshared p_64u_popcntpuppet_64u volk_64u_popcntpuppet_64u_u;
extern void volk_64u_popcntpuppet_64u_manual(ulong* , const ulong* , uint , const(char)*);
extern volk_func_desc_t volk_64u_popcntpuppet_64u_get_func_desc();

alias p_8i_convert_16i = void function(short* , const byte* , uint ) nothrow @nogc;
extern __gshared p_8i_convert_16i volk_8i_convert_16i;
extern __gshared p_8i_convert_16i volk_8i_convert_16i_a;
extern __gshared p_8i_convert_16i volk_8i_convert_16i_u;
extern void volk_8i_convert_16i_manual(short* , const byte* , uint , const(char)*);
extern volk_func_desc_t volk_8i_convert_16i_get_func_desc();

alias p_8i_s32f_convert_32f = void function(float* , const byte* , const float , uint ) nothrow @nogc;
extern __gshared p_8i_s32f_convert_32f volk_8i_s32f_convert_32f;
extern __gshared p_8i_s32f_convert_32f volk_8i_s32f_convert_32f_a;
extern __gshared p_8i_s32f_convert_32f volk_8i_s32f_convert_32f_u;
extern void volk_8i_s32f_convert_32f_manual(float* , const byte* , const float , uint , const(char)*);
extern volk_func_desc_t volk_8i_s32f_convert_32f_get_func_desc();

alias p_8ic_deinterleave_16i_x2 = void function(short* , short* , const lv_8sc_t* , uint ) nothrow @nogc;
extern __gshared p_8ic_deinterleave_16i_x2 volk_8ic_deinterleave_16i_x2;
extern __gshared p_8ic_deinterleave_16i_x2 volk_8ic_deinterleave_16i_x2_a;
extern __gshared p_8ic_deinterleave_16i_x2 volk_8ic_deinterleave_16i_x2_u;
extern void volk_8ic_deinterleave_16i_x2_manual(short* , short* , const lv_8sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_8ic_deinterleave_16i_x2_get_func_desc();

alias p_8ic_deinterleave_real_16i = void function(short* , const lv_8sc_t* , uint ) nothrow @nogc;
extern __gshared p_8ic_deinterleave_real_16i volk_8ic_deinterleave_real_16i;
extern __gshared p_8ic_deinterleave_real_16i volk_8ic_deinterleave_real_16i_a;
extern __gshared p_8ic_deinterleave_real_16i volk_8ic_deinterleave_real_16i_u;
extern void volk_8ic_deinterleave_real_16i_manual(short* , const lv_8sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_8ic_deinterleave_real_16i_get_func_desc();

alias p_8ic_deinterleave_real_8i = void function(byte* , const lv_8sc_t* , uint ) nothrow @nogc;
extern __gshared p_8ic_deinterleave_real_8i volk_8ic_deinterleave_real_8i;
extern __gshared p_8ic_deinterleave_real_8i volk_8ic_deinterleave_real_8i_a;
extern __gshared p_8ic_deinterleave_real_8i volk_8ic_deinterleave_real_8i_u;
extern void volk_8ic_deinterleave_real_8i_manual(byte* , const lv_8sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_8ic_deinterleave_real_8i_get_func_desc();

alias p_8ic_s32f_deinterleave_32f_x2 = void function(float* , float* , const lv_8sc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_8ic_s32f_deinterleave_32f_x2 volk_8ic_s32f_deinterleave_32f_x2;
extern __gshared p_8ic_s32f_deinterleave_32f_x2 volk_8ic_s32f_deinterleave_32f_x2_a;
extern __gshared p_8ic_s32f_deinterleave_32f_x2 volk_8ic_s32f_deinterleave_32f_x2_u;
extern void volk_8ic_s32f_deinterleave_32f_x2_manual(float* , float* , const lv_8sc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_8ic_s32f_deinterleave_32f_x2_get_func_desc();

alias p_8ic_s32f_deinterleave_real_32f = void function(float* , const lv_8sc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_8ic_s32f_deinterleave_real_32f volk_8ic_s32f_deinterleave_real_32f;
extern __gshared p_8ic_s32f_deinterleave_real_32f volk_8ic_s32f_deinterleave_real_32f_a;
extern __gshared p_8ic_s32f_deinterleave_real_32f volk_8ic_s32f_deinterleave_real_32f_u;
extern void volk_8ic_s32f_deinterleave_real_32f_manual(float* , const lv_8sc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_8ic_s32f_deinterleave_real_32f_get_func_desc();

alias p_8ic_x2_multiply_conjugate_16ic = void function(lv_16sc_t* , const lv_8sc_t* , const lv_8sc_t* , uint ) nothrow @nogc;
extern __gshared p_8ic_x2_multiply_conjugate_16ic volk_8ic_x2_multiply_conjugate_16ic;
extern __gshared p_8ic_x2_multiply_conjugate_16ic volk_8ic_x2_multiply_conjugate_16ic_a;
extern __gshared p_8ic_x2_multiply_conjugate_16ic volk_8ic_x2_multiply_conjugate_16ic_u;
extern void volk_8ic_x2_multiply_conjugate_16ic_manual(lv_16sc_t* , const lv_8sc_t* , const lv_8sc_t* , uint , const(char)*);
extern volk_func_desc_t volk_8ic_x2_multiply_conjugate_16ic_get_func_desc();

alias p_8ic_x2_s32f_multiply_conjugate_32fc = void function(lv_32fc_t* , const lv_8sc_t* , const lv_8sc_t* , const float , uint ) nothrow @nogc;
extern __gshared p_8ic_x2_s32f_multiply_conjugate_32fc volk_8ic_x2_s32f_multiply_conjugate_32fc;
extern __gshared p_8ic_x2_s32f_multiply_conjugate_32fc volk_8ic_x2_s32f_multiply_conjugate_32fc_a;
extern __gshared p_8ic_x2_s32f_multiply_conjugate_32fc volk_8ic_x2_s32f_multiply_conjugate_32fc_u;
extern void volk_8ic_x2_s32f_multiply_conjugate_32fc_manual(lv_32fc_t* , const lv_8sc_t* , const lv_8sc_t* , const float , uint , const(char)*);
extern volk_func_desc_t volk_8ic_x2_s32f_multiply_conjugate_32fc_get_func_desc();

alias p_8u_conv_k7_r2puppet_8u = void function(ubyte* , ubyte* , uint ) nothrow @nogc;
extern __gshared p_8u_conv_k7_r2puppet_8u volk_8u_conv_k7_r2puppet_8u;
extern __gshared p_8u_conv_k7_r2puppet_8u volk_8u_conv_k7_r2puppet_8u_a;
extern __gshared p_8u_conv_k7_r2puppet_8u volk_8u_conv_k7_r2puppet_8u_u;
extern void volk_8u_conv_k7_r2puppet_8u_manual(ubyte* , ubyte* , uint , const(char)*);
extern volk_func_desc_t volk_8u_conv_k7_r2puppet_8u_get_func_desc();

alias p_8u_x2_encodeframepolar_8u = void function(ubyte* , ubyte* , uint ) nothrow @nogc;
extern __gshared p_8u_x2_encodeframepolar_8u volk_8u_x2_encodeframepolar_8u;
extern __gshared p_8u_x2_encodeframepolar_8u volk_8u_x2_encodeframepolar_8u_a;
extern __gshared p_8u_x2_encodeframepolar_8u volk_8u_x2_encodeframepolar_8u_u;
extern void volk_8u_x2_encodeframepolar_8u_manual(ubyte* , ubyte* , uint , const(char)*);
extern volk_func_desc_t volk_8u_x2_encodeframepolar_8u_get_func_desc();

alias p_8u_x3_encodepolar_8u_x2 = void function(ubyte* , ubyte* , const ubyte* , const ubyte* , const ubyte* , uint ) nothrow @nogc;
extern __gshared p_8u_x3_encodepolar_8u_x2 volk_8u_x3_encodepolar_8u_x2;
extern __gshared p_8u_x3_encodepolar_8u_x2 volk_8u_x3_encodepolar_8u_x2_a;
extern __gshared p_8u_x3_encodepolar_8u_x2 volk_8u_x3_encodepolar_8u_x2_u;
extern void volk_8u_x3_encodepolar_8u_x2_manual(ubyte* , ubyte* , const ubyte* , const ubyte* , const ubyte* , uint , const(char)*);
extern volk_func_desc_t volk_8u_x3_encodepolar_8u_x2_get_func_desc();

alias p_8u_x3_encodepolarpuppet_8u = void function(ubyte* , ubyte* , const ubyte* , const ubyte* , uint ) nothrow @nogc;
extern __gshared p_8u_x3_encodepolarpuppet_8u volk_8u_x3_encodepolarpuppet_8u;
extern __gshared p_8u_x3_encodepolarpuppet_8u volk_8u_x3_encodepolarpuppet_8u_a;
extern __gshared p_8u_x3_encodepolarpuppet_8u volk_8u_x3_encodepolarpuppet_8u_u;
extern void volk_8u_x3_encodepolarpuppet_8u_manual(ubyte* , ubyte* , const ubyte* , const ubyte* , uint , const(char)*);
extern volk_func_desc_t volk_8u_x3_encodepolarpuppet_8u_get_func_desc();

alias p_8u_x4_conv_k7_r2_8u = void function(ubyte* , ubyte* , ubyte* , ubyte* , uint , uint , ubyte* ) nothrow @nogc;
extern __gshared p_8u_x4_conv_k7_r2_8u volk_8u_x4_conv_k7_r2_8u;
extern __gshared p_8u_x4_conv_k7_r2_8u volk_8u_x4_conv_k7_r2_8u_a;
extern __gshared p_8u_x4_conv_k7_r2_8u volk_8u_x4_conv_k7_r2_8u_u;
extern void volk_8u_x4_conv_k7_r2_8u_manual(ubyte* , ubyte* , ubyte* , ubyte* , uint , uint , ubyte* , const(char)*);
extern volk_func_desc_t volk_8u_x4_conv_k7_r2_8u_get_func_desc();



unittest
{
    import std.stdio;
    import std.string;

    float[4] data1 = [1, 2, 3, 4];
    double[4] data2 = [5, 6, 7, 8];
    double[4] output;

    volk_32f_64f_multiply_64f(output.ptr, data1.ptr, data2.ptr, 4);
    assert(output == [5, 12, 21, 32]);
}
