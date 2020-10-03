class Checkbox {
  float rectX, rectY;          // Position of square button
  float rectXSize, rectYSize;  // Diameter of rect
  boolean rectOver = false;
  boolean pressed = false;
  
  Checkbox (float xb, float yb, float xSize, float ySize) {
    rectX = xb;
    rectY = yb;
    rectXSize = xSize;
    rectYSize = ySize;
  }
  
  void update() {
    if (overEvent(rectX, rectY, rectXSize, rectYSize)) {
      rectOver = true;
    }
    else {
      rectOver = false;
    }
  }
  
  void tryClick() {
    if (rectOver) {
      pressed = !pressed;
    }
  }
  
  void display() {
    noStroke();
    if (rectOver) {
      fill(102, 102, 102);
    }
    /*
    else if (pressed) {
      //fill(0, 0, 0);
    } */
    else {
      fill(255, 255, 255);
    }
    rect(rectX, rectY, rectXSize, rectYSize);
    if (pressed) {
      strokeWeight(7);
      stroke(0);
      line(rectX, rectY, rectX + rectXSize, rectY + rectYSize);
      line(rectX + rectXSize, rectY, rectX, rectY + rectYSize);
    }
  }
  
  boolean overEvent(float x, float y, float width, float height)  {
    if (mouseX >= x && mouseX <= x+width && 
        mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
  }
}
