Level level;
Ball ball;
PImage bg;

int currentLevel = 1; // Global variable to track the current level

void setup() {
  //fullScreen();
  size(950,950);
  level = new Level(60, 1, 100);     // level with thickness 60, id 1
  // Windows: ball = new Ball(this, "COM3", width / 2, 30, 30); 
  // mac: /dev/cu.usbmodem1101
  ball = new Ball(this, "/dev/cu.usbmodem1101", width / 2, 30, 30, 1); 
  bg = loadImage("space-background3.png");
}

void draw() {
  background(bg); // background image

  // draw the level (the trajectory to be drawn)
  level.draw();
  
  // show info of level
  showInfo();
  // move and draw ball
  ball.move();
  ball.draw();

  //check if level is over, and print information
  //if (ball.position.y > height) {
  //  float accuracy = calculateAccuracy();
  //  println("Accuracy: " + accuracy + "%");
    
  //  // draw text in the center with information
  //  fill(0);
  //  textAlign(CENTER,CENTER);
  //  textSize(100);
  //  text("ACCURACY: " + int(accuracy) + "%", width/2, height/2);
    
    
  //  if (accuracy > 50) {
  //    changeLevel(60, 2, 150, 2);
  //  } else {
  //    noLoop(); // stop program
  //  }
  //}
  
  // Check if level is over, and print information
  if (ball.position.y > height) {
    float accuracy = calculateAccuracy();
    println("Accuracy: " + accuracy + "%");
    
    // Display accuracy information in the center
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(100);
    text("ACCURACY: " + int(accuracy) + "%", width / 2, height / 2);
    
    if (accuracy > 50) {
      // Increment level and adjust difficulty
      currentLevel++;
      float newThickness = 60 - currentLevel * 5; // Decrease thickness with each level
      float newCurveWidth = 100 + currentLevel * 20; // Increase curve complexity
      float newVelY = 2 + currentLevel * 0.5f; // Increase ball speed
      
      // Update the level
      changeLevel(newThickness, currentLevel, newCurveWidth, newVelY);
    } else {
      // Stop the program if accuracy is too low
      println("Game Over. Try Again!");
      noLoop();
    }
  }
  
  // logic:
  // draw instructions
  // draw level one, make it slower that it currently is
  // if accuracy is 50% or higher, draw next level and reset ball (changeLevel function)
    // include a change in ball velcoity 
  // if next level, increase level id by 1, increase 
  

}

// check accuracy 
float calculateAccuracy() {
  int pointsCovered = 0;
  int totalTrajectoryPoints = ball.trajectory.size();
  int totalPathSegments = level.path.size() - 1; // One less than total path points

  for (PVector trajectoryPoint : ball.trajectory) {
    boolean isCovered = false;

    // Check the trajectory point against each segment of the path
    for (int i = 0; i < totalPathSegments; i++) {
      PVector start = level.path.get(i);
      PVector end = level.path.get(i + 1);
      float distance = distToSegment(trajectoryPoint, start, end);

      // If the point is within the ball's radius, count it as covered
      if (distance <= ball.radius) {
        isCovered = true;
        break;
      }
    }

    if (isCovered) {
      pointsCovered++;
    }
  }

  // Return percentage of covered points
  return (float) pointsCovered / totalTrajectoryPoints * 100;
}

// Helper function: Calculate the shortest distance from a point to a line segment
float distToSegment(PVector p, PVector v, PVector w) {
  float l2 = sq(dist(v.x, v.y, w.x, w.y)); // Squared length of segment
  if (l2 == 0) return dist(p.x, p.y, v.x, v.y); // Segment is a point
  float t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
  t = constrain(t, 0, 1); // Clamp t to the segment
  PVector projection = new PVector(v.x + t * (w.x - v.x), v.y + t * (w.y - v.y));
  return dist(p.x, p.y, projection.x, projection.y);
}

void changeLevel(float thickness, float id, float curveWidth, float velY) {
   level = new Level(thickness, id, curveWidth);
   ball.reset(width / 2, 30, velY); // Reset ball to initial position
   loop(); // Restart the draw loop
}

// show Level X (depending on the level)
void showInfo(){
  
  fill(0);
  textAlign(RIGHT,TOP);
  textSize(50);
  text("Level " + int(level.id), width - 50, 50);
}
