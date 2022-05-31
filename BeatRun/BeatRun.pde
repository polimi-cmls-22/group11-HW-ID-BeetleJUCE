import oscP5.*;
import netP5.*;

// Initialize OSC object and ip address
OscP5 oscP5;
NetAddress myBroadcastLocation; 

PFont f; // initialize font object

int d; // distance sensor variable
int p = 0; // bpm sensor trigger
int t1 = 0; // synth 1 trigger
int t2 = 0; // synth 2 trigger

int cols, rows; // grid variables
int scale = 20; // dimension of the square grid unit

int w = 2000, h = 900; //dimensions 

float speed = 0; // grid speed
float speed_m = 0; // mountain speed

float[][] terrain; // terrain grid
int border = 40; // define the width of the valley

// Objects definition
int dim = 15;
Cube[] cubes;
int counter1 = -1;
Ball[] balls;
int counter2 = -1;

void setup() {
  size(800, 600, P3D);
  
  // Set up font
  printArray(PFont.list());
  f = createFont("Verdana", 14);
  textFont(f);
  textAlign(LEFT);
  
  // Set up world grid
  cols = w/scale;
  rows = h/scale;
  
  // Set up mountains
  terrain = new float[cols][rows];
  
  // Set up object arrays
  cubes = new Cube[dim];
  balls = new Ball[dim];
  
  
  /* create a new instance of oscP5. 
   * 12000 is the port number you are listening for incoming osc messages
   * "this" is localhost ip address
   */
  oscP5 = new OscP5(this,12000);
}

void draw(){
  // Set background
  background(0);
  setGradient(-800, -900, -1000, 3500, 1200, color(0,0,130), color(0,0,0));
  
  // Draw fps on screen
  fill(255);
  text("FPS: " + frameRate, 5, 20);
  
  // Set speeds
  speed -= 3;
  if (speed<=-scale){
    speed=0;
  }
  speed_m -= 0.1;

  // Set perlin noise for mountains
  float y_offset = speed_m;
  for (int y = 0; y < rows; y++) {
    float x_offset = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(x_offset, y_offset), 0, 1, -50, 150);
      x_offset += 0.2;
    }
    terrain[border-1][y] = 0;
    terrain[cols-border+1][y] = 0;
    y_offset += 0.2;
  }

  
  // Make the sun pulsate for a frame (depending on p trigger)
  if (p == 1) {
    stroke(255,0,0);
    fill(255,0,0);
    pushMatrix();
    translate(width/2, height/2-200, -1000);
    sphereDetail(30);
    sphere(200+50);
    popMatrix();
    p = 0;
  } else {
    stroke(255,179,25);
    fill(240,100,70);
    pushMatrix();
    translate(width/2, height/2-200, -1000);
    sphereDetail(30);
    sphere(200);
    popMatrix();
  }  
  
  // Translate and rotate world
  translate(width/2, height/2);
  rotateX(PI/2.3);
  
  // Trigger object 1 with t1
  if (t1 == 1) {
    if(++counter1 == dim){
      counter1 = 0;
    }   
    cubes[counter1] = new Cube(d);
    t1 = 0;
  }
  for (int i=0; i<dim; i++) {
    if (cubes[i]!=null){
      cubes[i].update();
      cubes[i].display();
    }
  }
  
  // Trigger object 2 with t2
  if (t2 == 1) {
    if(++counter2 == dim){
      counter2 = 0;
    }   
    balls[counter2] = new Ball();
    t2 = 0;
  }
  for (int i=0; i<dim; i++) {
    if (balls[i]!=null){
      balls[i].update();
      balls[i].display();
    }
  }

  
  
  // Draw central grid
  stroke(217,25,255);
  pushMatrix();
  translate(-w/2, -h/2-speed);
  //fill(0);
  noFill();
  for (int y = 0; y < rows-1; y++) {
    for (int x = 0; x < cols; x++) {
      rect(x*scale+1, y*scale+1, scale, scale);
    }
  }
  popMatrix();
  
  // Draw lateral mountains
  pushMatrix();
  translate(-w/2, -h/2-0.2);
  
  fill(0,0,200);
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < border; x++) {
      vertex(x*scale, y*scale, terrain[x][y]);
      vertex(x*scale, (y+1)*scale, terrain[x][y+1]);
    }
    endShape();
  }
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = cols-border+1; x < cols; x++) {
      vertex(x*scale, y*scale, terrain[x][y]);
      vertex(x*scale, (y+1)*scale, terrain[x][y+1]);
    }
    endShape();
  }
  popMatrix();
  
}

// Receive osc message and store the content in new variables
void oscEvent(OscMessage theOscMessage) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
  if(theOscMessage.checkAddrPattern("/distance")){
    d = theOscMessage.get(0).intValue();
  }
  if(theOscMessage.checkAddrPattern("/trigger0")){
    p = theOscMessage.get(0).intValue();
  }
  if(theOscMessage.checkAddrPattern("/trigger1")){
    t1 = theOscMessage.get(0).intValue();
  }
  if(theOscMessage.checkAddrPattern("/trigger2")){
    t2 = theOscMessage.get(0).intValue();
  }
}

// Custom function for generating a gradient
void setGradient(int x, int y, int z, float w, float h, color c1, color c2) {

  noFill();
  for (int i = y; i <= y+h; i++) {
    float inter = map(i, y, y+h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, z, x+w, i, z);
  }
}
