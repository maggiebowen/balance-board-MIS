class HapticFeedback {
  Serial arduinoPort; // Create object to communicate with Arduino    
  Ball ball;
  Level level;

  HapticFeedback(Ball ball, Level level, Serial arduinoPort) {
    this.ball = ball;
    this.level = level;
    this.arduinoPort = arduinoPort; 
  }

  void sendFeedback() {
    if (ball.numberMoves>=50 && ball.numberMoves< ((height-150)/3) ){
      float ballPositionX = ball.position.x;
      float levelPositionX = level.path.get(ball.numberMoves-50).x; //The ball move number 50 is the first position for the path (Path starts in y=150)
      int leftMotorIntensity = int(map(ballPositionX,0,levelPositionX,255,0)); //If the ball moves away from the path to the left, the motor on the left vibrates
      leftMotorIntensity = Math.max(leftMotorIntensity, 0); //Avoid sending negative values to the vibration motor
      int rightMotorIntensity = int(map(ballPositionX,levelPositionX,width,0,255)); //If the ball moves away from the path to the right, the motor on the right vibrates
      rightMotorIntensity = Math.max(rightMotorIntensity, 0);
      String command = "R" + rightMotorIntensity + "L" + leftMotorIntensity + "\n";
      //print("command: ", command);
      arduinoPort.write(command); 
    }else{ // When the game stops the vibration motors will stop
      String command = "R" + 0 + "L" + 0 + "\n";
      arduinoPort.write(command); 
    }
  }
  
  

}
