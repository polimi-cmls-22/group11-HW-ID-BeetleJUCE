class Cube {
  
  int speed_obj = 0;
  int h;
  
  // Contructor
  Cube(float pitch) {
    h = int(round(pitch));
  }
  
  // Custom method for updating the variables
  void update() {
    speed_obj -= 3;
  }
  
  // Custom method for drawing the object
  void display() {
    stroke(255);
    fill(0,70,25);
    pushMatrix();
    translate(-100, -300-speed_obj, 25);
    box(20, 20, h);
    popMatrix();
  }
}
