import processing.serial.*;

class Ball {
  PVector position;        // position of Ball
  ArrayList<PVector> trajectory; // trajectory of ball
  float velY;            // vertical velocity
  float velX;           // horizontal velocity (it will change)
  float radius;                 // ball's radius
  int startTime;              // to measure the start time of the program
  boolean started;            // indicates if ball started moving
  Serial myPort;       // serial connection for sensor input
  String orientationY = "";   // IMU's value received (pitch at Y direction)
  PApplet parent;             // reference to the parent sketch
  PImage astroImage;           // astronaut image

  Ball(PApplet parent, String portName, float startX, float startY, float radius, float velY) {
    this.parent = parent;      // store the parent sketch reference
    this.position = new PVector(startX, startY);
    this.trajectory = new ArrayList<PVector>();
    this.radius = radius;
    this.velY = velY;             // default vertical speed
    this.velX = 0;             // initially, it is not falling
    this.started = false;
    this.startTime = parent.millis();
    
    myPort = new Serial(parent, portName, 115200); // Use parent reference here
    
    astroImage = parent.loadImage("astronaut.png");
  }

  void move() {
    // start if time is over 3 second
    if (!started && parent.millis() - startTime >= 3000) {
      started = true; 
    }
    
    if (started) {
      // ball moves constantly down at speed 2 (could be modified)
      position.y += velY;
  
      // lateral movement (will be changed in future for sensors)
      if (myPort.available() > 0) {
        String val = myPort.readStringUntil('\n');
        
        if (val != null) {
          orientationY = val.trim(); // trim
          
          try {
            float orientationYFloat = Float.parseFloat(orientationY); // convert to float
            velX = PApplet.map(orientationYFloat, -90, 90, -50, 50); // map angle to horizontal displacement
            velX = (int) -velX; // change to negative (for orientation purposes) and pass to integer 
   
          } catch (NumberFormatException e) {
            parent.println("Error parsing IMU data");
          }
        }
      }
      
      // Update horizontal position
      position.x += velX;
      
      // Prevent ball from leaving the screen horizontally
      if (position.x < radius) {
        position.x = radius;
      }
      if (position.x > parent.width - radius) {
        position.x = parent.width - radius;
      }
 
      // add trajectory
      trajectory.add(new PVector(position.x, position.y));
    }
  }
  
  // reset ball for next level
  void reset(float startX, float startY, float velY) {
    // Reset position to the starting coordinates
    position.set(startX, startY);

    // Clear trajectory to remove old paths
    trajectory.clear();

    // Reset velocities
    velY = 2;  // Default vertical speed
    velX = 0;  // No horizontal movement initially

    // Reset time and movement state
    startTime = parent.millis();
    started = false;

    // Optionally, clear serial buffer to avoid leftover data
    if (myPort != null && myPort.available() > 0) {
        myPort.clear();
    }
  }

  
  // drawing trajectory
  void draw() {
    parent.noFill();
    parent.stroke(100, 100, 255, 150);
    parent.strokeWeight(this.radius * 2); // match with the ball's diameter
    parent.strokeJoin(BEVEL);
    parent.beginShape();
    for (PVector p : trajectory) {
      parent.vertex(p.x, p.y);
    }
    parent.endShape();

    // draw ball as an astronaut image
    parent.imageMode(PApplet.CENTER); // Center the image on its position
    parent.image(astroImage, position.x, position.y, radius * 2, radius * 2);
  }
}
