class Ball {
  
  int speed_sph = 0;
  
  // Contructor
  Ball() {}
  
  // Custom method for updating the variables
  void update() {
    speed_sph -= 3;
  }
  
  // Custom method for drawing the object
  void display() {
    stroke(0,70,25);
    fill(255);
    pushMatrix();
    translate(100, -300-speed_sph, 25);
    rotateX(PI/2);
    sphereDetail(10);
    sphere(10);
    popMatrix();
  }
}
