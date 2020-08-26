#ifndef TRANSITION_FUNCTIONS
#define TRANSITION_FUNCTIONS
float spread_from_center(float3 center, float3 coord, float transition, float shift) {

      float distance_to_center = distance(coord, center);
	  float control_value      = saturate(transition - shift);
	  if (control_value * 60.0f < distance_to_center) return 0;
	  else return 1.0f;
}

float split_from_midle(float coordx, float transition, float shift) {

	float distance_to_center = abs(coordx -0.5)*2.0;
	float control_value = saturate(transition - shift);
	if (control_value < distance_to_center) return 0;
	else return 1.0f;
}
#endif