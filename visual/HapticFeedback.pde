class HapticFeedback {
  Serial arduinoPort; // Create object to communicate with Arduino    
  Ball ball;
  Level level;

  HapticFeedback(Ball ball, Level level, Serial arduinoPort) {
    this.ball = ball;
    this.level = level;
    this.arduinoPort = arduinoPort; 
  }

  void sendFeedback(float endTrail) {
    if (ball.numberMoves>=0 && ball.numberMoves<(endTrail/2)){ // Movements quantity that can be done in the path distance
      float ballPositionX = ball.position.x;
      
      float levelPositionX = getXAtBallY(this.level, this.ball);
      
      if (levelPositionX != -1){
        int deadZone = 30;
        
        int leftMotorIntensity = int(map(ballPositionX,0,levelPositionX,450,150));      // If the ball moves away from the path to the left, the motor on the left vibrates
        leftMotorIntensity = Math.max(leftMotorIntensity, 0);                           // Avoid sending negative values to the vibration motor
        int rightMotorIntensity = int(map(ballPositionX,levelPositionX,width,150,450)); // If the ball moves away from the path to the right, the motor on the right vibrates
        rightMotorIntensity = Math.max(rightMotorIntensity, 0);
        
        if (Math.abs(ballPositionX - levelPositionX) < deadZone) {
            leftMotorIntensity = 0;
            rightMotorIntensity = 0;
        }
        
        String command = "R" + rightMotorIntensity + "L" + leftMotorIntensity + "\n";
        arduinoPort.write(command); 
      } 
    }
    
  }
  
  void stopFeedback(){ // When the game stops the vibration motors will stop
      String command = "R" + 0 + "L" + 0 + "\n";
      arduinoPort.write(command);
  }
  
  float getXAtBallY(Level level, Ball ball) {
    for (PVector position : level.path) {
        if (position.y == ball.position.y) {
            return position.x;
        }
    }
    return -1;
  }
  
}
