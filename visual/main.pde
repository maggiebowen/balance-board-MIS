Serial arduinoPort; // Create object to communicate with Arduino
Level level;
Ball ball;
PImage bg;
HapticFeedback hapticFeedback;

boolean applyHFB = true; // variable to apply haptic feedback --> set to false if testing without
int currentLevel = 1; // Global variable to track the current level

void setup() {
  //fullScreen();
  size(1500,900);
  level = new Level(60, 1, 100);     // level with thickness 60, id 1
  // Windows: ball = new Ball(this, "COM3", width / 2, 30, 30); 
  // mac: /dev/cu.usbmodem1101
  arduinoPort = new Serial(this, "COM3", 115200); //change the port name depending on Mac or Windows
  ball = new Ball(this, arduinoPort, width / 2, 30, 30); 
  bg = loadImage("images/space-background-extended.png");
  
  if (applyHFB){
    hapticFeedback = new HapticFeedback(ball, level, arduinoPort);
  }
  
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
  
  if (applyHFB) { // if providing user with haptic feedback
    hapticFeedback.sendFeedback();
  }
  
  
  // Check if the level is complete (when the ball falls off the screen)
  if (ball.position.y > height) {
    // Calculate the accuracy of the player's trajectory
    float accuracy = level.calculateAccuracy(ball);
    println("Accuracy: " + accuracy + "%");
    
    // Display the accuracy information in the center of the screen
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(100);
    text("ACCURACY: " + int(accuracy) + "%", width / 2, height / 2);
    
    // If accuracy is above the threshold, advance to the next level
    if (accuracy > 50) {
      currentLevel++; // Increment the level number

      // Adjust the difficulty for the new level
      float newThickness = 60 - currentLevel * 5; // Decrease thickness with each level
      float newCurveWidth = 100 + currentLevel * 20; // Increase curve complexity
      float newVelY = 2 + currentLevel * 0.5f; // Increase ball speed
      
      // Update the level with new parameters
      // changeLevel(newThickness, currentLevel, newCurveWidth, newVelY);
    } else {
      // If accuracy is too low, end the game
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

// void changeLevel(float thickness, float id, float curveWidth, float velY) {
//   level = new Level(thickness, id, curveWidth);
//   ball.reset(width / 2, 30, velY); // Reset ball to initial position
//   loop(); // Restart the draw loop
// }


// show Level X (depending on the level)
void showInfo(){
  
  fill(0);
  textAlign(RIGHT,TOP);
  textSize(50);
  text("Level " + int(level.id), width - 50, 50);
}
