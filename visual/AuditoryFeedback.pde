import netP5.*;
import oscP5.*;



class AuditoryFeedback {
  int port; // Port object for pd communication  
  Ball ball;
  Level level;
  OscP5 oscP5;
  NetAddress pureData;
  
  boolean playSound = true;

  AuditoryFeedback(Ball ball, Level level, int PDPort) {
    this.ball = ball;
    this.level = level;
    this.port = PDPort; 
    
    oscP5 = new OscP5(this, 8000); 
    pureData = new NetAddress("127.0.0.1", this.port); 
    
  }
  
  void sendFeedback(float endTrail) {
    if (ball.numberMoves >=0 && ball.numberMoves<(endTrail/2) && (playSound)){ // Movements quantity that can be done in the path distance
      float ballPositionX = ball.position.x;
      
      float levelPositionX = getXAtBallY(this.level, this.ball);
      
      if (levelPositionX != -1){
        
        float distance = abs(levelPositionX - ballPositionX);
        OscMessage msg = new OscMessage("/distance");
        msg.add(distance);
        oscP5.send(msg, pureData);
      } 
    }
    
  }
  
  // Function to stop the sound
  void stopFeedback() {
    OscMessage msg = new OscMessage("/distance");
    msg.add(10000); // Turn DSP off
    oscP5.send(msg, pureData);
    playSound = false;
  }
  
  // Function to start the sound
  void startFeedback() {
    OscMessage msg = new OscMessage("/distance");
    msg.add(11000); // Turn DSP off
    oscP5.send(msg, pureData);
    playSound = true;
  }
  
  
  float getXAtBallY(Level level, Ball ball) {
    for (PVector position : level.path) {     // Go through all level points
        if (position.y == ball.position.y) {  // Find the matching x
            return position.x;                // Return it
        }
    }
    return -1;
  }
  
}
