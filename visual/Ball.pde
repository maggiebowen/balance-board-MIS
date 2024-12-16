class Ball {
  PVector position;        // position of Ball
  ArrayList<PVector> trajectory; // trajectory of ball
  float radius;                 // ball's radius
  int startTime;              // to measure the start time of the program
  boolean started;            // indicates if ball started moving

  Ball(float startX, float startY, float radius) {
    this.position = new PVector(startX, startY);
    this.trajectory = new ArrayList<PVector>();
    this.radius = radius;
    this.started = false;
    this.startTime = millis();
  }

  void move() {
    
    // start if time is over 1 second
    if (!started && millis() - startTime >= 1000) {
      started = true; 
    }
    
    if (started){
      // ball moves constantly down at speed 2 (could be modified)
      position.y += 3;
  
      // lateral movement (will be changed in future for sensors)
      if (keyPressed) {
        if (keyCode == LEFT) { // move left
          position.x -= 2;
        } 
        
        if (keyCode == RIGHT) {
          position.x += 2; // move right
         } 
      }
  
      // add trajectory
      trajectory.add(new PVector(position.x, position.y));
    }
  }
  
  // drawing trajectory
  void draw() {
    noFill();
    stroke(100, 100, 255, 150);
    strokeWeight(this.radius*2); // match with the ball's diamater
    beginShape();
    for (PVector p : trajectory) {
      vertex(p.x, p.y);
    }
    endShape();

    // draw ball
    fill(0);
    noStroke();
    ellipse(position.x, position.y, radius * 2, radius * 2);
  }
}
