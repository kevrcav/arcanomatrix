--[[ 
@module

]]


local shaders = {elementNodeEdgeShader}

shaders.elementNodeEdgeShader = love.graphics.newShader([[
  
  #ifdef PIXEL
  extern vec4 _elementColor;
  extern vec2 _node1Loc;
  extern number t;
  vec4 effect (vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
  {
    vec2 vecTo1 = _node1Loc - screen_coords;
    number distTo1 = sqrt(pow(vecTo1.x, 2) + pow(vecTo1.y, 2));
    if (sin(distTo1 / 10 + t * 2) > 0) {
      return _elementColor;
    }
    else
    {
      return color;
    }
  }
  #endif
]])

shaders.xpBarBubble = love.graphics.newShader([[
  
  #ifdef PIXEL
  extern vec2 _bubbles[10];
  vec4 effect (vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
  {
    for(int i=0; i < 10; ++i)
    {
      if (length(screen_coords-_bubbles[i]) < 10)
      {
        return color + vec4(0.4, 0.4, 0.4, 1);
      }
    }
    return color;
  }
  #endif
]])


return shaders