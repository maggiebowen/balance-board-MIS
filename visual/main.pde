int gameScreen = 0; // First screen: start game
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
PImage alien1;
PImage alien2;
PImage alien3;

//import to change to custom font
PFont font;

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
  
  //make font fit pixel-art style
  font = createFont("Silkscreen-Bold.ttf", 120);
  textFont(font);
  
  // Load alien images
  alien1 = loadImage("images/alien1.png");
  alien2 = loadImage("images/alien2.png");
  alien3 = loadImage("images/alien3.png");
  
  // Windows: ball = new Ball(this, "COM3", width / 2, 30, 30); 
  // mac: /dev/cu.usbmodem1101
  // arduinoPort = new Serial(this, "COM10", 115200); //change the port name depending on Mac or Windows
  arduinoPort = new Serial(this, "/dev/cu.usbmodem1101", 115200); //change the port name depending on Mac or Windows
  //arduinoPort = new Serial(this, "COM3", 115200); //change the port name depending on Mac or Windows
  
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
    gameScreenThirdLevel();   
  } else if (gameScreen == 4) {
    gameOverScreen();   
  }
  
}

// Start Game Screen
void initScreen() {
  initScreenBg = loadImage("images/start-screen-background.png");
  background(initScreenBg);
  
  // Draw a semi-transparent rectangle for better text readability
  noStroke(); 
  fill(0, 0, 0, 200); // Black with 150 alpha (transparency)
  rect(width / 2 - 250, height / 2 - 50, 500, 100); 
  
  // Draw a semi-transparent rectangle for better text readability
  noStroke(); 
  fill(95, 107, 200, 150); // Black with 150 alpha (transparency)
  rect(width / 2 - 350, height / 5, 700, 400); 

  //draw title
  textAlign(CENTER, CENTER); // Center horizontally and vertically
  fill(255); // White text color
  textSize(100); // Larger font size for visibility
  text("EquiLuna", width / 2, height / 3); // Text centered

  // Draw the text
  textAlign(CENTER, CENTER); // Center horizontally and vertically
  fill(255); // White text color
  textSize(40); // Larger font size for visibility
  text("Click to start", width / 2, height / 2); // Text centered
}

// EASY - First Level Screen 
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
    float similarity = level.calculateSimilarity(level, ball);
    // save it in a file
    String fileName = date + "---" + time + "-" + level.id + currentDifficulty+ ".txt"; // Format: "date---time.txt"
    
    filePath = "../results/"+fileName;
    // write the accuracy results
    output = createWriter(filePath); // open the file
    output.println("Level: " + level.id);
    output.println("Difficulty type "+currentDifficulty + ": ");
    output.println("Auditory feedback: " + applyAFB);
    output.println("Haptic feedback: " + applyHFB);
    output.println("Accuracy: " +accuracy);
    output.println("Similarity: " +similarity);
    output.close();
    
    currentDifficulty++;
    nextSublevel = true;
    //After finishing difficulty 3, go to screen 4 (transition)
    if (currentDifficulty==4){
      gameScreen = 4;
      currentLevel = 1; 
      currentDifficulty = 1;
    }
  }
}

// MEDIUM - Second Level Screen
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
    float similarity = level.calculateSimilarity(level, ball);
    // save it in a file
    String fileName = date + "---" + time + "-" + level.id + currentDifficulty+ ".txt"; // Format: "date---time.txt"
    
    filePath = "../results/"+fileName;
    // write the accuracy results
    output = createWriter(filePath); // open the file
    output.println("Level: " + level.id);
    output.println("Difficulty type "+currentDifficulty + ": ");
    output.println("Auditory feedback: " + applyAFB);
    output.println("Haptic feedback: " + applyHFB);
    output.println("Accuracy: " +accuracy);
    output.println("Similarity: " +similarity);
    output.close();
    
    currentDifficulty++;
    nextSublevel = true;
    
    //After finishing difficulty 3, go to screen 4 (transition)
    if (currentDifficulty==4){
      gameScreen = 4;
      currentLevel = 2;    
      currentDifficulty = 1; 
    }
  }
}

// HARD - Third Level Screen
void gameScreenThirdLevel() {
  if (nextSublevel) { // Only initialize when starting a new sublevel
    initializeThirdLevelGameScreen();
    nextSublevel = false;
  }

  background(bg); // background image

  if (currentDifficulty == 3){
    level.updateAliens();
  }
  level.draw(); // draw the trajectory
  
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
    float similarity = level.calculateSimilarity(level, ball);
    // save it in a file
    String fileName = date + "---" + time + "-" + level.id + currentDifficulty+ ".txt"; // Format: "date---time.txt"
    
    filePath = "../results/"+fileName;
    // write the accuracy results
    output = createWriter(filePath); // open the file
    output.println("Level: " + level.id);
    output.println("Difficulty type "+currentDifficulty + ": ");
    output.println("Auditory feedback: " + applyAFB);
    output.println("Haptic feedback: " + applyHFB);
    output.println("Accuracy: " +accuracy);
    output.println("Similarity: " +similarity);
    output.close();
    
    currentDifficulty++;
    nextSublevel = true;
    
    if (currentDifficulty==4){
      gameScreen = 4;     
      currentLevel = 3;    
      currentDifficulty = 1; 
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
  fill(0, 0, 0, 200);
  rect(width / 2 - 200, height / 2 - 100, 400, 100); 
  fill(255); // Text color
  textSize(20);
  text("Return to Main Menu", width / 2, height / 2 - 50);

  // Button 2: Go to Second Level
  if (currentLevel == 1){
    noStroke(); 
    fill(0, 0, 0, 200);
    rect(width / 2 - 200, height / 2 + 40, 400, 100); // Button position and size
    fill(255); // Text color
    textSize(20);
    text("Play Second Level", width / 2, height / 2 + 90);
  }
  
  // Button 3: Go to Third Level
  if (currentLevel == 2){
    noStroke(); 
    fill(0, 0, 0, 200);
    rect(width / 2 - 200, height / 2 + 40, 400, 100); // Button position and size
    fill(255); // Text color
    textSize(20);
    text("Play Third Level", width / 2, height / 2 + 90);
  }
}

// Initialization logic for the game screen
void initializeGameScreen() {
  bg = loadImage("images/space-background-resize.png");
  endTrail = height - finishPath;

  if (currentDifficulty == 1) {
    level = new easyLevel(60, 1, alien1, alien2, alien3);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, height / 15, radius, currentDifficulty);
  } else if (currentDifficulty == 2) {
    level = new easyLevel(60, 1, alien1, alien2, alien3);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, height / 15, radius, currentDifficulty);
  } else if (currentDifficulty == 3) {
    level = new easyLevel(60, 1, alien1, alien2, alien3);
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
    level = new mediumLevel(60, 2, alien1, alien2, alien3);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
  } else if (currentDifficulty == 2) {
    level = new mediumLevel(60, 2, alien1, alien2, alien3);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
  } else if (currentDifficulty == 3) {
    level = new mediumLevel(60, 2, alien1, alien2, alien3);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
    level.generateAliens();
  } else {
    noLoop();
  }

  applyFeedbacks(); // Initialize feedback mechanisms
}

void initializeThirdLevelGameScreen() {
  bg = loadImage("images/space-background-resize.png");
  endTrail = height - finishPath;

  if (currentDifficulty == 1) {
    level = new hardLevel(60, 3, alien1, alien2, alien3);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
  } else if (currentDifficulty == 2) {
    level = new hardLevel(60, 3, alien1, alien2, alien3);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
  } else if (currentDifficulty == 3) {
    level = new hardLevel(60, 3, alien1, alien2, alien3);
    level.generatePath(100, startPath, finishPath);
    ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
    level.generateAliens();
  } else {
    noLoop();
  }

  applyFeedbacks(); // Initialize feedback mechanisms
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
  } 
  else if (gameScreen==4) { 
    // Button 1: Check if click is within "Return to Main Menu" button
    if (mouseX > width / 2 - 200 && mouseX < width / 2 + 200 &&
        mouseY > height / 2 - 100 && mouseY < height / 2 ) {
      goHome(); // Go to initial screen
    }
    else if (currentLevel == 1){
      if (mouseX > width / 2 - 200 && mouseX < width / 2 + 200 &&
          mouseY > height / 2 + 40 && mouseY < height / 2 + 140) {
        startSecondLevel(); 
      }
    }
    else if (currentLevel == 2){
      if (mouseX > width / 2 - 200 && mouseX < width / 2 + 200 &&
          mouseY > height / 2 + 40 && mouseY < height / 2 + 140) {
        startThirdLevel(); 
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
void startThirdLevel() {
  gameScreen=3;
  currentLevel = 3;
  nextSublevel = true;
  currentDifficulty = 1;
}
