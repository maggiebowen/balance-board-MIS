Serial arduinoPort; // Create object to communicate with Arduino
Level level;
Ball ball;

PrintWriter output; // for writing in the txt file
String date;
String time;
String filePath; // name of file used for saving results

PImage bg;
HapticFeedback hapticFeedback;
AuditoryFeedback auditoryFeedback;

boolean applyHFB = false; // variable to apply haptic feedback --> set to false if testing without
boolean applyAFB = true; // variable to apply auditory feedback

int PDPort = 12000;

int currentDifficulty = 1; // Global variable to track the level's difficulty
float radius = 30;
float startPath = radius*5; // were the trail will begin
float finishPath = radius*5; // distance to bottom to where trail ends
float endTrail; 


void setup() {
  //fullScreen();
  size(1500,900);
  level = new SineWaveLevel(60, 1);     // level with thickness 60, id 1
  //level = new ZigzagLevel(60,2);
  level.generatePath(100, startPath, finishPath);

  
  // Windows: ball = new Ball(this, "COM3", width / 2, 30, 30); 
  // mac: /dev/cu.usbmodem1101
  // arduinoPort = new Serial(this, "COM10", 115200); //change the port name depending on Mac or Windows
  arduinoPort = new Serial(this, "COM3", 115200); //change the port name depending on Mac or Windows
  ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty); 
  bg = loadImage("images/space-background-extended.png");
  
  //endTrail = height - finishPath - startPath;
  endTrail = height - finishPath;
  applyFeedbacks();
  
  date = nf(day(), 2) + "-" + nf(month(), 2); // Format: "day-month"
  time = nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2); // Format: "hour:minute:seconds"
  
  
}

void draw() {
  background(bg); // background image

  // draw the level (the trajectory to be drawn)
  if (currentDifficulty == 3){
    level.updateAliens();
  }
  level.draw();
  
  // show info of level
  showInfo();
  // move and draw ball
  ball.move();
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
  if (ball.position.y >= height) {
    
    // Calculate the accuracy of the player's trajectory    
    float accuracy = level.calculateAccuracy(level, ball);
    
    String fileName = date + "---" + time + "-" + currentDifficulty+ ".txt"; // Format: "date---time.txt"

    filePath = "../results/"+fileName;
    // write the accuracy results
    output = createWriter(filePath); // open the file
    output.println("Level: " + level.id);
    output.println("Difficulty type "+currentDifficulty + ": ");
    output.println(accuracy+"\n");
    output.close();
    
    
    // increase difficulty
    currentDifficulty++;
    if (currentDifficulty == 2){ // increased velocity
      level = new SineWaveLevel(60, 1);
      // level = new ZigZagLevel(60, 1);
      level.generatePath(100, startPath, finishPath);
      ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
    
    }
    else if (currentDifficulty == 3){ // add aliens
      level = new SineWaveLevel(60, 1);
      // level = new ZigZagLevel(60, 1);
      level.generatePath(100, startPath, finishPath);
      ball = new Ball(this, arduinoPort, width / 2, radius, radius, currentDifficulty);
      level.generateAliens(3);
    }
    else { 
      noLoop();
      
    }
    applyFeedbacks();
    
   
  }
  
  
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
