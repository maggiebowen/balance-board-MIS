Level level;
Ball ball;

void setup() {
  fullScreen();
  level = new Level(60, 1);         // level with thickness 60, id 1
  ball = new Ball(width / 2, 0, 30); // Ball centered at the topwith radius 30
}

void draw() {
  background(255); // white

  // draw the level (the trajectory to be drawn)
  level.draw();
  
  // show info of level
  showInfo();
  // move and draw ball
  ball.move();
  ball.draw();

  //check if level is over, and print information
  if (ball.position.y > height) {
    float accuracy = calculateAccuracy();
    println("Accuracy: " + accuracy + "%");
    
    // draw text in the center with information
    fill(0);
    textAlign(CENTER,CENTER);
    textSize(100);
    text("ACCURACY: " + int(accuracy) + "%", width/2, height/2);
    noLoop(); // stop program
  }
}

// check accuracy 
float calculateAccuracy() {
  int pointsCovered = 0;
  int totalPoints = level.path.size();


  for (PVector p : level.path) {
    // see if level point is within trajectory of ball
    for (PVector ballPoint : ball.trajectory) {
      // if the distance between each point of the level is lower than the radius
      // ball.radius/2 can be used maybe, if not a bit easy?
      if (dist(p.x, p.y, ballPoint.x, ballPoint.y) <= ball.radius) { 
        pointsCovered++; // increase the count
        break; 
      }
    }
  }

  return (float)pointsCovered / totalPoints * 100; // return the % of covered points
}

// show Level X (depending on the level)
void showInfo(){
  
  fill(0);
  textAlign(RIGHT,TOP);
  textSize(50);
  text("Level " + int(level.id), width - 50, 50);
  
}
