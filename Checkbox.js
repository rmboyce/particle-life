class Checkbox {
  constructor(xb, yb, xSize, ySize) {
    this.rectX = xb;
    this.rectY = yb;
    this.rectXSize = xSize;
    this.rectYSize = ySize;
    this.rectOver = false;
    this.pressed = false;
  }
  
  update() {
    if (this.overEvent(this.rectX, this.rectY, this.rectXSize, this.rectYSize)) {
      this.rectOver = true;
    }
    else {
      this.rectOver = false;
    }
  }
  
  tryClick() {
    if (this.rectOver) {
      this.pressed = !this.pressed;
    }
  }
  
  display() {
    noStroke();
    if (this.rectOver) {
      fill(102, 102, 102);
    }
    else {
      fill(255, 255, 255);
    }
    rect(this.rectX, this.rectY, this.rectXSize, this.rectYSize);
    if (this.pressed) {
      strokeWeight(3);
      stroke(0);
      line(this.rectX, this.rectY, this.rectX + this.rectXSize, this.rectY + this.rectYSize);
      line(this.rectX + this.rectXSize, this.rectY, this.rectX, this.rectY + this.rectYSize);
      noStroke();
    }
  }
  
  overEvent(x, y, width, height)  {
    if (mouseX >= x && mouseX <= x+width && 
        mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
  }
}
