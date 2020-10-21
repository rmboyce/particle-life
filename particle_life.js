class Particle {
  //Three types, red - 0, green - 1, blue - 2
  constructor(particleType, pos, mass, velocity) {
    this.pType = particleType;
    this.position = pos;
    this.m = mass;
    this.v = velocity;
		
    //For testing only
    this.a = 0;
  }
}

//Input
var mouseHeld = false;
var timeStep = 0.75;
var circles = false;
var velocityLines = false;
var forceLines = false;
var sideWrap = false;

var restart = false;
var randomOption = false;

//Particle stuff
var numParticles = 200;
var particleList = new Array(numParticles);

//Negative is attract, positive is repel
//                 r   g  b
var rForces = [-1, -1, 2];
var gForces = [-1, 2, -5];
var bForces = [15, 15, -5];
var forces = [rForces, gForces, bForces];

var oldTime;
var frictionCoefficient = 0.15;
var particleRadius = 2.5;
var sightDist = 75;

var padding = 50;

var centerX = 50;
var centerY = 50;
var circleRadius = 150;

//Cool combo: 0r 40g 60b
// 40r 40g 20b

//Percent of particles
var percentRed = 0;
var percentGreen = 40;
var percentBlue = 100 - percentRed - percentGreen;

const INTERFACE_X = 375;
const MOUSE_CIRCLE_RADIUS = 100;

var hs1;
var hs2;
var hs3;
var b1;
var b2;
var c1;
var c2;

function setup() {
  createCanvas(650, 400);
	
  hs1 = new HScrollbar(400, 100, 200, 10, 3);
  hs2 = new HScrollbar(400, 150, 200, 10, 3);
  hs3 = new HScrollbar(400, 250, 200, 10, 3);
  b1 = new Button(400, 350, 75, 25);
  b2 = new Button(525, 350, 75, 25);
  c1 = new Checkbox(475, 300, 20, 20);   
  c2 = new Checkbox(580, 300, 20, 20);
	
  centerX = 200;
  centerY = height / 2;
  strokeWeight(0);
  textSize(20);
  oldTime = millis();
  RandomizeParticles();
  hs1.setNormalPos(percentRed / 100);
  hs2.setNormalPos(percentGreen / 100);
}

//hs: HScrollbar, s: text above, per: percentage text below
function TextHScrollbar(hs, s, per) {
  textSize(15);
  text(s, hs.xpos, hs.ypos - 5);
  hs.update();
  hs.display();
  fill(0, 0, 0);
  text(per, hs.xpos, hs.ypos + 25);
}

function DrawPartDist(xPos, yPos, barWidth, barHeight, title, subtitle, perRed, perGreen, perBlue) {
  text(title, xPos, yPos - 10);
  let tempRedLength = barWidth * perRed / 100;
  let tempGreenLength = barWidth * perGreen / 100;
  fill(255, 0, 0);
  rect(xPos, yPos - 5, tempRedLength, barHeight);
  fill(0, 255, 0);
  rect(xPos + tempRedLength, yPos - 5, tempGreenLength, barHeight);
  fill(0, 0, 255);
  rect(xPos + tempRedLength + tempGreenLength, yPos - 5, barWidth * perBlue / 100, barHeight);
  fill(0, 0, 0);
  text(subtitle, xPos, yPos + 20);
}

function TextButton(b, s) {
  b.update();
  b.display();
  fill(255, 255, 255);
  text(s, b.rectX + 12, b.rectY + 17);
}

function TextCheckbox(c, s, xOffset) {
  fill(0, 0, 0);
  text(s, c.rectX - xOffset, c.rectY + 15);
  c.update();
  c.display();
}

function draw() {
  background(200, 200, 200);
  fill(0, 0, 0);
  textSize(20);
  noStroke();
  text("Options", 400, 60);
  
  percentRed = (int) (hs1.normalPos * 100 + 0.5);
  TextHScrollbar(hs1, "Percent Red", percentRed);
  
  if (hs2.normalPos > 1 - hs1.normalPos) {
    hs2.setPos(hs2.sposMin + (1 - hs1.normalPos) * (hs2.sposMax - hs2.sposMin));
  }
  percentGreen = (int) (hs2.normalPos * 100 + 0.5);
  TextHScrollbar(hs2, "Percent Green", percentGreen);
  
  percentBlue = 100 - percentRed - percentGreen;
  DrawPartDist(400, 200, 200, 10, "Particle Percentages", "Percent Blue: " + percentBlue, percentRed, percentGreen, percentBlue);
  
  timeStep = round(hs3.normalPos, 3);
  TextHScrollbar(hs3, "Timestep", timeStep);
  
  TextButton(b1, "Restart");
  TextButton(b2, "Random");
  
  TextCheckbox(c1, "Sight Dist.", 75);
  TextCheckbox(c2, "Velocity", 58);
  
  stroke(0, 0, 0);
  fill(0, 0, 0);
  
  if (randomOption) {
    randomOption = false;
    restart = true;
    percentRed = (int) (random(0, 100));
    percentGreen = (int) (random(0, 100 - percentRed));
    percentBlue = 100 - percentRed - percentGreen;
    hs1.setNormalPos(percentRed / 100);
    hs2.setNormalPos(percentGreen / 100);
  }
  
  if (restart) {
    restart = false;
    RandomizeParticles();
  }
  
  //Draw circle when clicking with mouse
  if (mouseHeld) {
    for (let i = 0; i < numParticles; i++) {
      let p = particleList[i];
      let pos = p.position;
      let dX = mouseX - pos.x;
      let dY = mouseY - pos.y;
      let dist = pow(pow(dX, 2) + pow(dY, 2), 0.5);
      let distFunction = pow(2, 4 - abs(dist/10));
      if (dist < MOUSE_CIRCLE_RADIUS) {
        dX /= dist;
        dY /= dist;
        p.v = createVector(p.v.x + -GetSign(dX) * distFunction, p.v.y + -GetSign(dY) * distFunction);
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
  strokeWeight(1);
  circle(centerX, centerY, circleRadius * 2 + particleRadius);
  
  //Apply forces from particles
  for (let i = 0; i < numParticles; i++) {
    let p = particleList[i];
    let pPos = p.position;
    //float lowestDist = 10000;
    let inAnotherParticleDetected = false;
    let vX = 0;
    let vY = 0;
    let j = 0;
    while (j < numParticles) {
      if (j != i) {
        let otherP = particleList[j];
        let otherPPos = otherP.position;
        let dX = pPos.x - otherPPos.x;
        let dY = pPos.y - otherPPos.y;
        let dist = pow(pow(dX, 2) + pow(dY, 2), 0.5);
        if (dist <= sightDist) {
          dX /= dist;
          dY /= dist;
          let forceMultiplier = forces[p.pType][otherP.pType];
          let distFunction = 1 - abs((dist - sightDist/2 + particleRadius)/(2 * particleRadius - sightDist/2 + particleRadius));
          if (inAnotherParticleDetected) {
            distFunction *= 0.8;
          }
          if (dist < particleRadius * 2) {
            if (!inAnotherParticleDetected) {
              vX = 0;
              vY = 0;
              j = 0;
              inAnotherParticleDetected = true;
            }
            distFunction = pow(2, 4 - abs(dist/1.6));
            dX = GetSign(dX);
            dY = GetSign(dY);
            forceMultiplier = 1;
          }
          
          //Force away from edges of screen
          vX += (dX * distFunction * forceMultiplier) / p.m;
          vY += (dY * distFunction * forceMultiplier) / p.m;
        }
      }
      j++;
    }
    p.v = createVector((p.v.x + vX) * frictionCoefficient, (p.v.y + vY) * frictionCoefficient);
    if (forceLines) {
      p.a = createVector(vX * p.m, vY * p.m);
    }
  }
  
  //Change positions
  //Draw particles
  let changeTime = timeStep * (millis() - oldTime);
  for (let i = 0; i < numParticles; i++) {
    let p = particleList[i];
    let pX = p.position.x;
    let pY = p.position.y;
    
    let changePosX = p.v.x * changeTime;
    let changePosY = p.v.y * changeTime;
    
    let newX = pX + changePosX;
    let newY = pY + changePosY;
    
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
      let distX = newX - centerX;
      let distY = newY - centerY;
      if (sqrt(pow(distX, 2) + pow(distY, 2)) > circleRadius) {
        let radDiff = sqrt(pow(distX, 2) + pow(distY, 2)) - circleRadius;
        let angle = atan2(newY - centerY, newX - centerX);
        newX -= radDiff * cos(angle);
        newY -= radDiff * sin(angle);
      }
    }
    
    p.position = createVector(newX, newY);
    
    noStroke();
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
    circle(pX, pY, particleRadius * 2);
		
    strokeWeight(1);
    if (circles) {
      stroke(75);
      noFill();
      circle(pX, pY, sightDist);
    }
    if (velocityLines) {
      stroke(255, 0, 0);
      line(pX, pY, pX + p.v.x * 100, pY + p.v.y * 100);
      stroke(0, 0, 0);
    }
    if (forceLines) {
      stroke(0, 0, 255);
      line(pX, pY, pX + p.a.x * 10, pY + p.a.y * 10);
      stroke(0, 0, 0);
    }
  }
  
  oldTime = millis();
}

function RandomizeParticles() {
  for (let i = 0; i < numParticles; i++) {
    let r = (int)(random(100));
    let rand;
    if (r < percentRed) {
      rand = 0;
    }
    else if (r < percentRed + percentGreen) {
      rand = 1;
    }
    else {
      rand = 2;
    }
    particleList[i] = new Particle(rand, createVector(random(0, centerX + circleRadius), random(0, height)), 10, createVector(0, 0));
  }
}

function mousePressed() {
  mouseHeld = true;
}

function mouseReleased() {
  mouseHeld = false;
  
  b1.tryClick();
  if (b1.pressed) {
    restart = true;
  }
  
  b2.tryClick();
  if (b2.pressed) {
    randomOption = true;
  }
  
  c1.tryClick();
  c2.tryClick();
  
  circles = c1.pressed;
  velocityLines = c2.pressed;
}

function GetSign(input) {
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
