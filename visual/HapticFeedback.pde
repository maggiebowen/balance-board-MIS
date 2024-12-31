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
    if (ball.numberMoves>=0 && ball.numberMoves<(endTrail/2)){ //movements quantity that can be done in the path distance
      float ballPositionX = ball.position.x;
      
      float levelPositionX = getXAtBallY(this.level, this.ball);
      //float levelPositionX = level.path.get(ball.numberMoves).x; //The path and the ball have the same quantity of xy vectors
      
      if (levelPositionX != -1){
        int leftMotorIntensity = int(map(ballPositionX,0,levelPositionX,255,0)); //If the ball moves away from the path to the left, the motor on the left vibrates
        leftMotorIntensity = Math.max(leftMotorIntensity, 0);//Avoid sending negative values to the vibration motor
        int rightMotorIntensity = int(map(ballPositionX,levelPositionX,width,0,255)); //If the ball moves away from the path to the right, the motor on the right vibrates
        rightMotorIntensity = Math.max(rightMotorIntensity, 0);
        String command = "R" + rightMotorIntensity + "L" + leftMotorIntensity + "\n";
        //print("command: ", command);
        arduinoPort.write(command); 
      } 
    }else{ // When the game stops the vibration motors will stop
      String command = "R" + 0 + "L" + 0 + "\n";
      arduinoPort.write(command); 
    }
    
  }
  
}

float getXAtBallY(Level level, Ball ball) {
    for (PVector position : level.path) { // go through all level points
        if (position.y == ball.position.y) { // find the matching x
            return position.x; // return it
        }
    }
    return -1; // if not found, return -1
}
