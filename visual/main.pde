int gameScreen = 0; // Firt screen: start game
boolean nextSublevel = true; // Start next sublevel
int currentLevel = 0; // Level played

Serial arduinoPort; // Create object to communicate with Arduino
Level level;        // Level object  
Ball ball;          // Ball object

import netP5.*;
import oscP5.*;

PrintWriter output; // for writing results in the txt file
String date;        // for the date format used in the file's name
String time;        // for the time format used in the file's name
String filePath; // name of file used for saving results

PImage bg;
PImage initScreenBg;
HapticFeedback hapticFeedback; // haptic Feedback
AuditoryFeedback auditoryFeedback; // auditory feedback

boolean applyHFB = false; // variable to apply haptic feedback --> set to false if testing without
boolean applyAFB = false; // variable to apply auditory feedback --> set to false if testing without

int PDPort = 12000; // Port to communicate with PureData

int currentDifficulty = 1; // Global variable to track the level's difficulty
float radius = 30;        // radius of ball
float startPath = radius*5; // were the trail will begin
float finishPath = radius*5; // distance to bottom to where trail ends
float endTrail;           // were the trail of the level ends

void setup() {
  size(1500,900);
  // Windows: ball = new Ball(this, "COM3", width / 2, 30, 30); 
  // mac: /dev/cu.usbmodem1101
  //arduinoPort = new Serial(this, "COM10", 115200); //change the port name depending on Mac or Windows
  arduinoPort = new Serial(this, "/dev/cu.usbmodem1101", 115200); //change the port name depending on Mac or Windows
  
  date = nf(day(), 2) + "-" + nf(month(), 2); // Format: "day-month"
  time = nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2); // Format: "hour:minute:seconds"


}

void draw() {
  if (gameScreen == 0) {
    initScreen();
  } else if (gameScreen == 1) {
    gameScreen();   
  } else if (gameScreen == 2) {
    gameScreenSecondLevel();   
  } else if (gameScreen == 3) {
    gameOverScreen();   
  }
  
}

// Start Game Screen
void initScreen() {
  initScreenBg = loadImage("images/start-game-background.png");
  background(initScreenBg);
  
  // Draw a semi-transparent rectangle for better text readability
  noStroke(); 
  fill(0, 0, 0, 150); // Black with 150 alpha (transparency)
  rect(width / 2 - 250, height / 2 - 50, 500, 100, 20); // Centered box with rounded corners

  // Draw the text
  textAlign(CENTER, CENTER); // Center horizontally and vertically
  fill(255); // White text color
  textSize(40); // Larger font size for visibility
  text("Click to start the adventure", width / 2, height / 2); // Text centered
}

// Balance Board Game - Firt Level Screen
void gameScreen() {
  if (nextSublevel) { // Only initialize when starting a new sublevel
    initializeGameScreen();
    nextSublevel = false;
  }

  background(bg); // background image

  if (currentDifficulty == 3){
    level.updateAliens();
  }
  level.draw(); // draw the trajectory
  
  showInfo(); // show info of level
  
  ball.move(); // move and draw ball
  ball.draw();
  
  
  if (applyHFB) { // if providing user with haptic feedback
    if (ball.position.y <= endTrail){ // if ball is within the trail's y axis
      hapticFeedback.sendFeedback(endTrail);  
    } 
    else {
       hapticFeedback.stopFeedback();  
    }
  }
  
  if (applyAFB) { // if providing user with auditory feedback
    if ( ball.position.y <= endTrail){ // if ball is within the trail's y axis
      auditoryFeedback.sendFeedback(endTrail);  
    } 
    else {
       auditoryFeedback.stopFeedback();  
    }
  } 
  
  // Check if the level is complete (when the ball falls off the screen)
  if (ball.position.y > height) {
    
    // Calculate the accuracy of the player's trajectory    
    float accuracy = level.calculateAccuracy(level, ball);
    
    // save it in a file
    String fileName = date + "---" + time + "-" + level.id + currentDifficulty+ ".txt"; // Format: "date---time.txt"
    
    filePath = "../results/"+fileName;
    // write the accuracy results
    output = createWriter(filePath); // open the file
    output.println("Level: " + level.id);
    output.println("Difficulty type "+currentDifficulty + ": ");
    output.println("Auditory feedback: " + applyAFB);
    output.println("Haptic feedback: " + applyHFB);
    output.println(accuracy+"\n");
    output.close();
    
    currentDifficulty++;
    nextSublevel = true;
    if (currentDifficulty==4){
      gameScreen = 3;
    }
  }
}

// Second Level Screen
void gameScreenSecondLevel() {
  if (nextSublevel) { // Only initialize when starting a new sublevel
    initializeSecondLevelGameScreen();
    nextSublevel = false;
  }

  background(bg); // background image

  if (currentDifficulty == 3){
    level.updateAliens();
  }
  level.draw(); // draw the trajectory
  
  showInfo(); // show info of level
  
  ball.move(); // move and draw ball
  ball.draw();
  
  
  if (applyHFB) { // if providing user with haptic feedback
    if (ball.position.y <= endTrail){ // if ball is within the trail's y axis
      hapticFeedback.sendFeedback(endTrail);  
    } 
    else {
       hapticFeedback.stopFeedback();  
    }
  }
  
  if (applyAFB) { // if providing user with auditory feedback
    if ( ball.position.y <= endTrail){ // if ball is within the trail's y axis
      auditoryFeedback.sendFeedback(endTrail);  
    } 
    else {
       auditoryFeedback.stopFeedback();  
    }
  } 
  
  // Check if the level is complete (when the ball falls off the screen)
  if (ball.position.y > height) {
    
    // Calculate the accuracy of the player's trajectory    
    float accuracy = level.calculateAccuracy(level, ball);
    // save it in a file
    String fileName = date + "---" + time + "-" + level.id + currentDifficulty+ ".txt"; // Format: "date---time.txt"
    
    filePath = "../results/"+fileName;
    // write the accuracy results
    output = createWriter(filePath); // open the file
    output.println("Level: " + level.id);
    output.println("Difficulty type "+currentDifficulty + ": ");
    output.println("Auditory feedback: " + applyAFB);
    output.println("Haptic feedback: " + applyHFB);
    output.println(accuracy+"\n");
    output.close();
    
    currentDifficulty++;
    nextSublevel = true;
    if (currentDifficulty==4){
      gameScreen = 3;
    }
  }
}

//Game Over Screen
void gameOverScreen() {
  background(initScreenBg);
  
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(40);
  text("Level Completed", width / 2, height / 2 - 200);

  // Button 1: Return to Initial Screen
  noStroke(); 
  fill(0, 0, 0, 150);
  rect(width / 2 - 200, height / 2 - 100, 400, 100); // Centered box with rounded corner
  fill(255); // Text color
  textSize(20);
  text("Return to Main Menu", width / 2, height / 2 - 50);

  // Button 2: Go to Second Level
  if (currentLevel == 1){
    noStroke(); 
    fill(0, 0, 0, 150);
    rect(width / 2 - 200, height / 2 + 40, 400, 100); // Button position and size
    fill(255); // Text color
    textSize(20);
    text("Play Second Level", width / 2, height / 2 + 90);
  }
}

// Initialization logic for the game screen
void initializeGameScreen() {
  bg = loadImage("images/space-background-resize.png");
  endTrail = height - finishPath;

  if (currentDifficulty == 1) {
    level = new SineWaveLevel(60, 1);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, height / 15, radius, currentDifficulty);
  } else if (currentDifficulty == 2) {
    level = new SineWaveLevel(60, 1);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, height / 15, radius, currentDifficulty);
  } else if (currentDifficulty == 3) {
    level = new SineWaveLevel(60, 1);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, height / 15, radius, currentDifficulty);
    level.generateAliens();
  } else {
    noLoop();
  }

  applyFeedbacks(); // Initialize feedback mechanisms
}

void initializeSecondLevelGameScreen() {
  bg = loadImage("images/space-background-resize.png");
  endTrail = height - finishPath;

  if (currentDifficulty == 1) {
    level = new ZigzagLevel(60, 2);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
  } else if (currentDifficulty == 2) {
    level = new ZigzagLevel(60, 2);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
  } else if (currentDifficulty == 3) {
    level = new ZigzagLevel(60, 2);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
    level.generateAliens();
  } else {
    noLoop();
  }

  applyFeedbacks(); // Initialize feedback mechanisms
}


// show Level X (depending on the level)
void showInfo(){
  
  fill(0);
  textAlign(RIGHT,TOP);
  textSize(50);
  text("Level " + int(level.id), width - 50, 50);
}

void applyFeedbacks(){
    if (applyHFB){
      hapticFeedback = new HapticFeedback(ball, level, arduinoPort);
    }
    if (applyAFB){
      auditoryFeedback = new AuditoryFeedback(ball, level, PDPort);
    }
}

/********* INPUTS *********/

public void mousePressed() {
  // if we are on the initial screen when clicked, start the game
  if (gameScreen==0) {
    startGame();
  } else if (gameScreen==3) {
    // Button 1: Check if click is within "Return to Main Menu" button
    if (mouseX > width / 2 - 200 && mouseX < width / 2 + 200 &&
        mouseY > height / 2 - 100 && mouseY < height / 2 ) {
      goHome(); // Go to initial screen
    }

    // Button 2: Check if click is within "Play Second Level" button
    if (currentLevel == 1){
      if (mouseX > width / 2 - 200 && mouseX < width / 2 + 200 &&
          mouseY > height / 2 + 40 && mouseY < height / 2 + 140) {
        startSecondLevel(); // Assume 3 corresponds to gameScreenSecondLevel
      }
    }
  }
}


/********* OTHER FUNCTIONS *********/

// This method sets the necessary variables to start the game  
void startGame() {
  gameScreen=1;    // increase the screen
  currentLevel = 1;  // set the currentLevel as 1
  nextSublevel = true;  
  currentDifficulty = 1;
}
void goHome() {
  gameScreen=0;
}
void startSecondLevel() {
  gameScreen=2;
  currentLevel = 2;
  nextSublevel = true;
  currentDifficulty = 1;
}
