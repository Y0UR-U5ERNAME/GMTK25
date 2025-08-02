shader_type canvas_item;

const vec2 screen_size = vec2(256., 192.);
uniform float size = 50.;
uniform vec2 pos = vec2(0.0, 0.0);
uniform int mode = 0;

void fragment() {
	switch (mode) {
		case 0: // circle
			if (distance(UV * screen_size, pos) < size) COLOR.a = 0.;
			break;
		case 1: // open/close horizontal
			if (abs(UV.x * screen_size.x - pos.x - 5.*sin(UV.y * screen_size.y/5.)) - 5. < size) COLOR.a = 0.;
			break;
		case 2: // open/close vertical
			if (abs(UV.y * screen_size.y - pos.y) < size) COLOR.a = 0.;
			break;
		case 3: // eye
			//if (distance(UV * screen_size, pos) < size) COLOR.a = 0.;
			vec2 shifted = UV - vec2(.5, .5);
			if (shifted.x*shifted.x + 1./size/size * shifted.y*shifted.y < .5) COLOR.a = 0.;
			break;
	}
}