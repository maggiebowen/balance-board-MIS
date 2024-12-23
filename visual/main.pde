import netP5.*;
import oscP5.*;


Level level;
Ball ball;


OscP5 oscP5;
NetAddress pureData;

void setup() {
  fullScreen();
  
  oscP5 = new OscP5(this, 12000); 
  pureData = new NetAddress("127.0.0.1", 8000); 
 
  level = new Level(60, 1);         // level with thickness 60, id 1
  ball = new Ball(this, "COM3", width / 2, 30, 30); 
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
  
  // calculate minDistance
  float minDistance = calculateHorizontalDistance();
  
  OscMessage msg = new OscMessage("/distance");
  msg.add(minDistance);
  oscP5.send(msg, pureData);

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


float calculateHorizontalDistance() {
  float minDistance = Float.MAX_VALUE;
  for (PVector p : level.path) {
    float distHorizontal = abs(ball.position.x - p.x);
    if (distHorizontal < minDistance) {
      minDistance = distHorizontal;
    }
  }
  println(minDistance);
  return minDistance;
}
