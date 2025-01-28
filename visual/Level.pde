import java.util.ArrayList;

// Superclass
abstract class Level {
  ArrayList<PVector> path; // trajectory to be drawn
  float thickness;         // thickness of drawing
  float id;                // level number
  ArrayList<PVector> alienPositions; // Store alien positions
  float alienRadius;       // Radius of aliens
  ArrayList<PVector> alienVelocities; // Store velocities of aliens
  ArrayList<PImage> alienImages;    // Images for the aliens

  Level(float thickness, float id, PImage alien1, PImage alien2, PImage alien3) {
    this.thickness = thickness;
    this.id = id;
    this.alienRadius = thickness; // will be equal to the spaceship
    path = new ArrayList<PVector>();
    alienPositions = new ArrayList<PVector>();
    alienVelocities = new ArrayList<PVector>();
    alienImages = new ArrayList<PImage>();
    
    // Add images for each alien
    alienImages.add(alien1); // Alien 1 (left)
    alienImages.add(alien3); // Alien 3 (left)
    alienImages.add(alien2); // Alien 2 (right)
  }

  abstract void generatePath(float curveWidth, float startPath, float finishPath); // Abstract method

  void draw() {
    noFill();
    stroke(255, 224, 55, 150);
    strokeWeight(thickness);
    beginShape();
    for (PVector p : path) {
      vertex(p.x, p.y);
    }
    endShape();

    // Draw aliens
    for (int i = 0; i < alienPositions.size(); i++) {
      PVector alien = alienPositions.get(i);
      PImage alienImg = alienImages.get(i); // Get the corresponding image
      imageMode(CENTER); // Center the image on the alien position
      image(alienImg, alien.x, alien.y, alienRadius * 2, alienRadius * 2); // Scale to fit alien size
    }
  }

  void updateAliens() {
    for (int i = 0; i < alienPositions.size(); i++) {
        PVector pos = alienPositions.get(i);
        PVector vel = alienVelocities.get(i);

        // Update position based on horizontal velocity
        pos.x += vel.x;

        // Determine margin boundaries
        float leftLimit = (pos.x < width / 2) ? alienRadius : 3 * width / 4;
        float rightLimit = (pos.x < width / 2) ? width / 4 : width - alienRadius;

        // Bounce off the margin boundaries
        if (pos.x < leftLimit || pos.x > rightLimit) {
            vel.x *= -1;
        }

        // Randomly adjust horizontal velocity slightly to simulate erratic movement
        vel.x += random(-0.5f, 0.5f);

        // Constrain position to the respective margin
        pos.x = constrain(pos.x, leftLimit, rightLimit);
    }
}


  float calculateAccuracy(Level level, Ball ball) {
   
    int pointsCovered = 0;
    int totalPoints = 0;
    
    for (PVector ballPoint : ball.trajectory) {
        float closestX = getXAtBallY(level, ballPoint.y);
        if (closestX != -1 && abs(closestX - ballPoint.x) <= ball.radius*2) { //distance less to the diameter
            pointsCovered++;
        }
        if (closestX != -1){
          totalPoints++;
        }
    }

    return (float) pointsCovered / totalPoints * 100;
  }
  
float calculateSimilarity(Level level, Ball ball) {
    HashMap<Float, Float> ballXByY = new HashMap<>();
    HashMap<Float, Float> levelXByY = new HashMap<>();

    // 1. Map balls trayectory
    for (PVector ballPoint : ball.trajectory) {
        ballXByY.put(ballPoint.y, ballPoint.x);
    }

    // 2. Map levels trayectory
    for (PVector levelPoint : level.path) {
        levelXByY.put(levelPoint.y, levelPoint.x);
    }

    // 3.Compare X for each Y value
    float totalDifference = 0;
    int count = 0;

    for (Float y : levelXByY.keySet()) {
        if (ballXByY.containsKey(y)) {
            float ballX = ballXByY.get(y);
            float levelX = levelXByY.get(y);
            totalDifference += abs(ballX - levelX);
            count++;
        }
    }

    // 4. Calculate similarity (closer to 0, more similar)
    float maxDifference = width; 
    return count > 0 ? max(0, 100 * (1 - (totalDifference / (count * maxDifference)))) : 0;
  }

  float getXAtBallY(Level level, float y) {
      for (PVector position : level.path) {
          if (abs(position.y - y) == 0) {
            return position.x;
          }
      }
      return -1; // Not found
  }


  void generateAliens() {
    alienPositions.clear();
    alienVelocities.clear();

    // Define alien starting positions and velocities
    float[][] alienData = {
        {width / 4, height / 4, 1, 3},      // Left alien 1
        {width / 4, 3 * height / 4, 1, 3}, // Left alien 2
        {3 * width / 4, height / 2, -3, -1} // Right alien
    };

    for (float[] data : alienData) {
        float x = data[0];
        float y = data[1];
        float vxMin = data[2];
        float vxMax = data[3];

        alienPositions.add(new PVector(x, y));
        alienVelocities.add(new PVector(random(vxMin, vxMax), 0)); // Only horizontal velocity
    }
}

}


class TutorialLevel extends Level {
  TutorialLevel(float thickness, float id, PImage alien1, PImage alien2, PImage alien3) {
    super(thickness, id, alien1, alien2, alien3);
  }

  @Override
  void generatePath(float curveWidth, float startPath, float finishPath) {
    path.clear(); // Clear any previous path

    float minY = startPath;
    float maxY = height - finishPath;

    // Just step down in y, staying at a fixed x
    for (float y = minY; y < maxY; y += 2) {
      float x = width / 2;
      path.add(new PVector(x, y));
    }
  }
}

class easyLevel extends Level {
  easyLevel(float thickness, float id, PImage alien1, PImage alien2, PImage alien3) {
    super(thickness, id, alien1, alien2, alien3);
  }

  @Override
  void generatePath(float curveWidth, float startPath, float finishPath) {
    path.clear(); // Clear any previous path

    // We'll place the path between these Y limits
    float minY = startPath;
    float maxY = height - finishPath;

    // Number of full sine-wave curves from minY to maxY
    int totalCurves = 1;

    // The total vertical distance for the path
    float pathLength = maxY - minY;

    // We want exactly 'totalCurves' cycles over 'pathLength'
    float frequency = totalCurves * TWO_PI / pathLength;

    // Build the path in small increments
    for (float y = minY; y < maxY; y += 2) {
      // Shift y so that at y = minY, the sine begins at sin(0) = 0
      float relativeY = y - minY;

      // Center horizontally at width/2; sine wave amplitude = curveWidth
      float x = width / 2 + sin(relativeY * frequency) * curveWidth;

      path.add(new PVector(x, y));
    }
  }
}

class mediumLevel extends Level {
  mediumLevel(float thickness, float id, PImage alien1, PImage alien2, PImage alien3) {
    super(thickness, id, alien1, alien2, alien3);
  }

  @Override
  void generatePath(float curveWidth, float startPath, float finishPath) {
    path.clear(); // Clear any previous path

    // We'll place the path between these Y limits
    float minY = startPath;
    float maxY = height - finishPath;

    // Number of full sine-wave cycles from minY to maxY
    int totalCurves = 1;

    // The total vertical distance for the path
    float pathLength = maxY - minY;

    // We want exactly 'totalCurves' cycles over 'pathLength'
    float frequency = totalCurves * TWO_PI / pathLength;

    // Multiply curveWidth by 2.0 (or any factor) to make the path wider
    float amplitude = curveWidth * 2.0;

    // Build the path in small increments
    for (float y = minY; y < maxY; y += 2) {
      // Shift y so that at y = minY, the sine begins at sin(0) = 0
      float relativeY = y - minY;

      // Center horizontally at width/2; use 'amplitude' for extra width
      float x = width / 2 + sin(relativeY * frequency) * amplitude;

      path.add(new PVector(x, y));
    }
  }
}

class hardLevel extends Level {
  hardLevel(float thickness, float id, PImage alien1, PImage alien2, PImage alien3) {
    super(thickness, id, alien1, alien2, alien3);
  }

  @Override
  void generatePath(float curveWidth, float startPath, float finishPath) {
    path.clear(); // Clear previous path
    float minY = startPath;
    float maxY = height - finishPath;

    // Frequency based on total height
    int totalCurves = 3;
    float frequency = totalCurves * TWO_PI / height;

    for (float y = minY; y < maxY; y += 2) { // Fixed increment for y
      float x = width / 2 + sin(y * frequency) * curveWidth;
      path.add(new PVector(x, y));
    }
  }
}
