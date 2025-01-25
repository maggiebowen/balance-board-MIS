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
  int numberMoves;            // to indicate how many moves the ball has made

  Ball(PApplet parent, Serial arduinoPort, float startX, float startY, float radius, int difficulty) {
    this.parent = parent;      // store the parent sketch reference
    
    this.radius = radius;
    this.astroImage = parent.loadImage("images/astronaut.png");
    
    // Adjust start position to ensure the astronaut image stays fully on screen
    float halfImageWidth = astroImage.width / 2;   // Half the astronaut image width
    float halfImageHeight = astroImage.height / 2; // Half the astronaut image height
    
    // Constrain starting position within screen bounds
    startX = PApplet.constrain(startX, halfImageWidth, parent.width - halfImageWidth);
    startY = PApplet.constrain(startY, halfImageHeight, parent.height - halfImageHeight);
    
    this.position = new PVector(startX, startY);
    this.trajectory = new ArrayList<PVector>();
    
    if (difficulty == 1){
      this.velY = 1; 
    } else {
      this.velY = 2;
    }
                
    this.velX = 0;             // initially, it is not falling
    this.started = false;
    this.startTime = parent.millis();
    this.myPort = arduinoPort;
    this.numberMoves = 0;
  }

  void move() {
    // start if time is over 3 seconds
    if (!started && parent.millis() - startTime >= 3000) {
      started = true; 
    }
    
    if (started) {
      // update the number of moves
      numberMoves += 1;

      // ball moves constantly down at speed velY
      position.y += velY;
  
      // lateral movement
      if (myPort.available() > 0) {
        String val = myPort.readStringUntil('\n');
        
        if (val != null) {
          orientationY = val.trim(); // trim
          
          try {
            float orientationYFloat = Float.parseFloat(orientationY); // convert to float
            velX = PApplet.map(orientationYFloat, -90, 90, -50, 50); // map angle to horizontal displacement
            velX = (int) -velX; // change to negative (for orientation purposes) and pass to integer 
          } catch (NumberFormatException e) {
            // parent.println("Error parsing IMU data");
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

  // drawing trajectory
  void draw() {
    parent.noFill();
    parent.stroke(100, 100, 255, 150);
    parent.strokeWeight(this.radius * 2); // match with the ball's diameter
    parent.strokeJoin(BEVEL);
    parent.beginShape();
    
    for (PVector p : trajectory) {
      if (p.y >= this.radius * 5 && p.y <= height - this.radius * 5){
        parent.vertex(p.x, p.y);
      }
    }
    parent.endShape();

    // draw ball as an astronaut image
    parent.imageMode(PApplet.CENTER); // Center the image on its position
    parent.image(astroImage, position.x, position.y, astroImage.width, astroImage.height);
  }
}
