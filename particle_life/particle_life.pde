class Particle {
  //Three types, red - 0, green - 1, blue - 2
  public int pType;
  public PVector position;
  public int m;
  public PVector v;
  
  //For testing only
  public PVector a;
  
  public Particle(int particleType, PVector pos, int mass, PVector velocity) {
    pType = particleType;
    position = pos;
    m = mass;
    v = velocity;
  }
}

//Input
boolean mouseHeld = false;
//float mouseWheel = 0;
float timeStep = 0.75;
boolean circles = false;
boolean velocityLines = false;
boolean forceLines = false;
boolean sideWrap = false;

boolean restart = false;
boolean random = false;

//Particle stuff
int numParticles = 200;
Particle[] particleList = new Particle[numParticles];

//Negative is attract, positive is repel
//                 r   g  b
float[] rForces = {-1, -1, 2};
float[] gForces = {-1, 2, -5};
float[] bForces = {15, 15, -5};
float[][] forces = {rForces, gForces, bForces};

int oldTime;
float frictionCoefficient = 0.15;
int particleRadius = 5;
int sightDist = 200;

int padding = 50;

int centerX = 50;
int centerY = 50;
int circleRadius = 300;

//Cool combo: 0r 40g 60b
// 40r 40g 20b

//Percent of particles
int percentRed = 0;
int percentGreen = 40;
int percentBlue = 100 - percentRed - percentGreen;

final int INTERFACE_X = 750;
final int MOUSE_CIRCLE_RADIUS = 200;

HScrollbar hs1 = new HScrollbar(800, 200, 400, 20, 3);
HScrollbar hs2 = new HScrollbar(800, 300, 400, 20, 3);
HScrollbar hs3 = new HScrollbar(800, 500, 400, 20, 3);
Button b1 = new Button(800, 700, 150, 50);
Button b2 = new Button(1050, 700, 150, 50);
Checkbox c1 = new Checkbox(950, 600, 40, 40);
Checkbox c2 = new Checkbox(1160, 600, 40, 40);

void setup() {
  size(1300, 800);
  centerX = 400;
  centerY = height / 2;
  strokeWeight(0);
  textSize(20);
  oldTime = millis();
  RandomizeParticles();
  hs1.setNormalPos((float) percentRed / 100f);
  hs2.setNormalPos((float) percentGreen / 100f);
}

//hs: HScrollbar, s: text above, per: percentage text below
void TextHScrollbar(HScrollbar hs, String s, float per, boolean isPerInt) {
  textSize(20);
  text(s, hs.xpos, hs.ypos - 15);
  hs.update();
  hs.display();
  fill(0, 0, 0);
  if (isPerInt) {
    text((int)per, hs.xpos, hs.ypos + 45);
  }
  else {
    text(per, hs.xpos, hs.ypos + 45);
  }
}

void DrawPartDist(int xPos, int yPos, int barWidth, int barHeight, String title, 
                  String subtitle, int perRed, int perGreen, int perBlue) {
  text(title, xPos, yPos - 25);
  int tempRedLength = barWidth * perRed / 100;
  int tempGreenLength = barWidth * perGreen / 100;
  fill(255, 0, 0);
  rect(xPos, yPos - 10, tempRedLength, barHeight);
  fill(0, 255, 0);
  rect(xPos + tempRedLength, yPos - 10, tempGreenLength, barHeight);
  fill(0, 0, 255);
  rect(xPos + tempRedLength + tempGreenLength, yPos - 10, barWidth * perBlue / 100, barHeight);
  fill(0, 0, 0);
  text(subtitle, xPos, yPos + 35);
}

void TextButton(Button b, String s) {
  b.update();
  b.display();
  fill(255, 255, 255);
  text(s, b.rectX + 37, b.rectY + 30);
}

void TextCheckbox(Checkbox c, String s, int xOffset) {
  fill(0, 0, 0);
  text(s, c.rectX - xOffset, c.rectY + 25);
  c.update();
  c.display();
}

void draw() {
  background(200, 200, 200);
  fill(0, 0, 0);
  //text("Timestep: " + nf(timeStep, 1, 2) + ";  %red: " + percentRed + ";  %green: " +percentGreen + ";  %blue: " + percentBlue, 5, 30);
  textSize(40);
  text("Options", 800, 120);
  
  percentRed = (int) (hs1.normalPos * 100 + 0.5);
  TextHScrollbar(hs1, "Percent Red", percentRed, true);
  
  if (hs2.normalPos > 1f - hs1.normalPos) {
    hs2.setPos(hs2.sposMin + (1f - hs1.normalPos) * (hs2.sposMax - hs2.sposMin));
  }
  percentGreen = (int) (hs2.normalPos * 100 + 0.5);
  TextHScrollbar(hs2, "Percent Green", percentGreen, true);
  
  percentBlue = 100 - percentRed - percentGreen;
  DrawPartDist(800, 400, 400, 20, "Particle Percentages", 
              "Percent Blue: " + percentBlue, percentRed, percentGreen, percentBlue);
  
  timeStep = hs3.normalPos;
  TextHScrollbar(hs3, "Timestep", timeStep, false);
  
  TextButton(b1, "Restart");
  TextButton(b2, "Random");
  
  TextCheckbox(c1, "Sight Distance", 150);
  TextCheckbox(c2, "Velocity Lines", 145);
  
  stroke(0, 0, 0);
  fill(0, 0, 0);
  
  if (random) {
    random = false;
    restart = true;
    percentRed = (int) random(0, 100);
    percentGreen = (int) random(0, 100 - percentRed);
    percentBlue = 100 - percentRed - percentGreen;
    hs1.setNormalPos((float) percentRed / 100f);
    hs2.setNormalPos((float) percentGreen / 100f);
  }
  
  if (restart) {
    restart = false;
    RandomizeParticles();
  }
  
  //Draw circle when clicking with mouse
  if (mouseHeld) {
    for (int i = 0; i < numParticles; i++) {
      Particle p = particleList[i];
      PVector pos = p.position;
      float dX = mouseX - pos.x;
      float dY = mouseY - pos.y;
      float dist = pow(pow(dX, 2) + pow(dY, 2), 0.5f);
      float distFunction = pow(2, 4f - abs(dist/10f));
      if (dist < MOUSE_CIRCLE_RADIUS) {
        dX /= dist;
        dY /= dist;
        p.v = new PVector(p.v.x + -GetSign(dX) * distFunction, p.v.y + -GetSign(dY) * distFunction);
      }
    }
    noFill();
    strokeWeight(1);
    if (mouseX < INTERFACE_X) {
      circle(mouseX, mouseY, MOUSE_CIRCLE_RADIUS);
    }
  }
  
  //Draw bounding circle
  noFill();
  strokeWeight(2);
  circle(centerX, centerY, circleRadius * 2 + particleRadius);
  
  //Apply forces from particles
  for (int i = 0; i < numParticles; i++) {
    Particle p = particleList[i];
    PVector pPos = p.position;
    //float lowestDist = 10000;
    boolean inAnotherParticleDetected = false;
    float vX = 0;
    float vY = 0;
    int j = 0;
    while (j < numParticles) {
      if (j != i) {
        Particle otherP = particleList[j];
        PVector otherPPos = otherP.position;
        float dX = pPos.x - otherPPos.x;
        float dY = pPos.y - otherPPos.y;
        float dist = pow(pow(dX, 2) + pow(dY, 2), 0.5f);
        if (dist <= sightDist) {
          dX /= dist;
          dY /= dist;
          float forceMultiplier = forces[p.pType][otherP.pType];
          float distFunction = 1 - abs((dist - sightDist/2 + particleRadius)/(2 * particleRadius - sightDist/2 + particleRadius));
          if (inAnotherParticleDetected) {
            distFunction *= 0.8f;
          }
          if (dist < particleRadius * 2) {
            if (!inAnotherParticleDetected) {
              vX = 0;
              vY = 0;
              j = 0;
              inAnotherParticleDetected = true;
            }
            distFunction = pow(2, 4f - abs(dist/1.6f));
            dX = GetSign(dX);
            dY = GetSign(dY);
            forceMultiplier = 1;
          }
          
          //Force away from edges of screen
          /*
          float edgeWeightedMultX = ( width / 2f - min(width - pPos.x, pPos.x) ) / (width / 2f);
          float edgeWeightedMultY = ( height / 2f - min(height - pPos.y, pPos.y) ) / (height / 2f);
          float addIfBluePointX = 0f;
          float addIfBluePointY = 0f;
          float signX = ((width - pPos.x) - pPos.x) / abs((width - pPos.x) - pPos.x);
          float signY = ((height - pPos.y) - pPos.y) / abs((height - pPos.y) - pPos.y);
          if (p.pType == 2) {
            addIfBluePointX = random(10f) * signX;
            addIfBluePointY = random(10f) * signY;
          }
          vX += ( (dX * distFunction * forceMultiplier) * (1f - edgeWeightedMultX) + 
                pow(1.01f, abs((width - pPos.x) - pPos.x + addIfBluePointX)) * signX * 0.0001f * edgeWeightedMultX )
                / (float)p.m;
          vY += ( (dY * distFunction * forceMultiplier) * (1f - edgeWeightedMultY) +
                pow(1.01f, abs((height - pPos.y) - pPos.y + addIfBluePointY)) * signY * 0.0001f * edgeWeightedMultY )
                / (float)p.m;
          */
          vX += (dX * distFunction * forceMultiplier)
                / (float)p.m;
          vY += (dY * distFunction * forceMultiplier)
                / (float)p.m;
        }
      }
      j++;
    }
    p.v = new PVector((p.v.x + vX) * frictionCoefficient, (p.v.y + vY) * frictionCoefficient);
    if (forceLines) {
      p.a = new PVector(vX * (float)p.m, vY * (float)p.m);
    }
  }
  
  //Change positions
  //Draw particles
  float changeTime = timeStep * (millis() - oldTime);
  for (int i = 0; i < numParticles; i++) {
    Particle p = particleList[i];
    float pX = p.position.x;
    float pY = p.position.y;
    
    float changePosX = p.v.x * changeTime;
    float changePosY = p.v.y * changeTime;
    
    float newX = pX + changePosX;
    float newY = pY + changePosY;
    
    if (sideWrap) {
      if (newX < 0) {
        newX = width - (newX % width);
      }
      if (pX > width) {
        newX = (newX % width);
      }
      if (pY < 0) {
        newY = height - (newY % height);
      }
      if (pY > height) {
        newY = (newY % height);
      }
    }
    else {
      float distX = newX - centerX;
      float distY = newY - centerY;
      if (sqrt(pow(distX, 2) + pow(distY, 2)) > circleRadius) {
        float radDiff = sqrt(pow(distX, 2) + pow(distY, 2)) - circleRadius;
        float angle = atan2(newY - centerY, newX - centerX);
        newX -= radDiff * cos(angle);
        newY -= radDiff * sin(angle);
      }
    }
    
    p.position = new PVector(newX, newY);
    
    if (p.pType == 0) {
      fill(255, 0, 0);
    }
    else if (p.pType == 1) {
      fill(0, 255, 0);
    }
    else if (p.pType == 2) {
      fill(0, 0, 255);
    }
    else {
      fill(0, 0, 0);
    }
    strokeWeight(0);
    circle(pX, pY, particleRadius * 2);
    if (circles) {
      noFill();
      circle(pX, pY, sightDist);
    }
    if (velocityLines) {
      strokeWeight(2);
      stroke(255, 0, 0);
      line(pX, pY, pX + p.v.x * 100, pY + p.v.y * 100);
      stroke(0, 0, 0);
    }
    if (forceLines) {
      strokeWeight(2);
      stroke(0, 0, 255);
      line(pX, pY, pX + p.a.x * 10, pY + p.a.y * 10);
      stroke(0, 0, 0);
    }
  }
  
  oldTime = millis();
}

void RandomizeParticles() {
  for (int i = 0; i < numParticles; i++) {
    float r = (int)random(100);
    int rand;
    if (r < percentRed) {
      rand = 0;
    }
    else if (r < percentRed + percentGreen) {
      rand = 1;
    }
    else {
      rand = 2;
    }
    particleList[i] = new Particle(rand, new PVector(random(0, 800), random(0, 800)), 10, new PVector(0, 0));
  }
}

void mousePressed() {
  mouseHeld = true;
}

void mouseReleased() {
  mouseHeld = false;
  
  b1.tryClick();
  if (b1.pressed) {
    restart = true;
  }
  
  b2.tryClick();
  if (b2.pressed) {
    random = true;
  }
  
  c1.tryClick();
  c2.tryClick();
  
  circles = c1.pressed;
  velocityLines = c2.pressed;
}

float GetSign(float input) {
  if (input < 0) {
    return -1;
  }
  else if (input > 0) {
    return 1;
  }
  else {
    return 0;
  }
}
