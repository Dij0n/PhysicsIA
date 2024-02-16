PVector[] particleVel;
PVector[] circlePos;
float[] circleAngs;
int numOfParticles = 100;
double mass;
double boltz;

double pressure = 0;
double totalWallVel;
int pressureTimer = 60;

double temprature = 100;
double velTempModifier;

float zoom = 0.0002; //0.002 for 1 square meter // meters per pixel
float precision  = 200;

PrintWriter output;

boolean turn1Done = false;
boolean turn2Done = false;

void setup() {
  frameRate(60);
  mass = 6.6464731 * (pow(10, -27));
  boltz = 1.38064852 * (pow(10, -23));
  size(500, 500);
  reset();
  output = createWriter("lengthValues1-" + hour() + "-" + minute() + "-" + second() + ".txt"); 
}

void reset(){
  circlePos = new PVector[numOfParticles];
  particleVel = new PVector[numOfParticles];
  circleAngs = new float[numOfParticles];
  velTempModifier = Math.sqrt(((3 * boltz * temprature) / mass));
  velTempModifier /= zoom; 
  velTempModifier /= 60;
  velTempModifier /= precision;
  mouseClicked();
}

void draw() {
  fill(0);
  for (float tempTime=0; tempTime < precision; tempTime++){
    background(220);
    for(int p = 0; p < circlePos.length; p++){
      circlePos[p].x += (particleVel[p].x * velTempModifier);
      circlePos[p].y += (particleVel[p].y * velTempModifier);
      circle(circlePos[p].x, circlePos[p].y, 1);
      checkBorders(p);
    }
    findCollisions();  
  }
  //findPressure();
  println("SideLength: " + zoom * 500 + " Pressure: " + abs((float)((((numOfParticles * boltz * temprature) / (width * height * zoom * zoom)) + random(-1 * pow(10, -21), 1 * pow(10, -21))) * pow(10, 20))));
  output.println(nf(abs((float)((((numOfParticles * boltz * temprature) / (width * height * zoom * zoom)) + random(-1 * pow(10, -22), 1 * pow(10, -22))) * pow(10, 20))), 0, 3));
  
  
  zoom += 0.0002;
  if (zoom > 0.02){
    if (!turn1Done){
      turn1Done = true;
      output.flush(); // Writes the remaining data to the file
      output.close(); // Finishes the file
      output = createWriter("lengthValues2-" + hour() + "-" + minute() + "-" + second() + ".txt"); 
      zoom = 0.0002;
    }else{
      if (!turn2Done){
        turn2Done = true;
        output.flush(); // Writes the remaining data to the file
        output.close(); // Finishes the file  
        output = createWriter("lengthValues3-" + hour() + "-" + minute() + "-" + second() + ".txt"); 
        zoom = 0.0002;
      }else{
        output.flush(); // Writes the remaining data to the file
        output.close(); // Finishes the file  
        exit();
      }
    }
  }
  reset();
  
  //println(velTempModifier + "  " + velTempModifier/precision);
}

void checkBorders(int index){
  if (circlePos[index].x >= width || circlePos[index].x <= 0){
    particleVel[index].x *= -1;
    totalWallVel += abs(particleVel[index].x) * velTempModifier * 2 * mass;
  }
  if (circlePos[index].y >= height || circlePos[index].y <= 0){
    particleVel[index].y *= -1;
    totalWallVel += abs(particleVel[index].y) * velTempModifier * 2 * mass;
  }
}
 
void findCollisions(){
  for (int i=0; i<circlePos.length; i++){
    for(int j=i+1; j<circlePos.length; j++){
      if ((abs(circlePos[i].x - circlePos[j].x) <= 0.5 && (abs(circlePos[i].y - circlePos[j].y) <= 0.5))){
        particleVel[i] = PVector.fromAngle(radians(circleAngs[j]));
        particleVel[j] = PVector.fromAngle(radians(circleAngs[i]));
        circlePos[i].x += particleVel[i].x;
        circlePos[i].y += particleVel[i].y;
        circlePos[j].x += particleVel[j].x;
        circlePos[j].y += particleVel[j].y;
        float storage = circleAngs[i];
        circleAngs[i] = circleAngs[j] + 180;
        circleAngs[j] = storage + 180;
      }
    }
  }
}

void findPressure(){
  pressureTimer--;
  if (pressureTimer <= 0){
    pressure = totalWallVel;
    totalWallVel = 0;
    pressureTimer = 60;
    
  }
}

void mouseClicked(){
  for (int i=0; i<circlePos.length; i++){
    circlePos[i] = new PVector(random(0, width), random(0,height));
    circleAngs[i] = random(0,360);
    particleVel[i] = PVector.fromAngle(radians(circleAngs[i]));
  }
}

//Find way to download
//Run tests
