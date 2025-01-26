// Superclass
abstract class Level {
  ArrayList<PVector> path; // trajectory to be drawn
  float thickness;         // thickness of drawing
  float id;                // level number
  ArrayList<PVector> alienPositions; // Store alien positions
  float alienRadius;       // Radius of aliens
  ArrayList<PVector> alienVelocities; // Store velocities of aliens

  Level(float thickness, float id) {
    this.thickness = thickness;
    this.id = id;
    this.alienRadius = thickness; // will be equal to the spaceship
    path = new ArrayList<PVector>();
    alienPositions = new ArrayList<PVector>();
    alienVelocities = new ArrayList<PVector>();
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
    fill(255, 0, 0); // Red color for aliens
    noStroke();
    for (PVector alien : alienPositions) {
      ellipse(alien.x, alien.y, alienRadius * 2, alienRadius * 2);
    }
  }

  void updateAliens() {
    for (int i = 0; i < alienPositions.size(); i++) {
        PVector pos = alienPositions.get(i);
        PVector vel = alienVelocities.get(i);

        // Update position based on horizontal velocity only
        pos.x += vel.x;

        // Bounce off left and right walls
        if (pos.x < alienRadius || pos.x > width - alienRadius) {
            vel.x *= -1;
        }

        // Randomly adjust horizontal velocity slightly to simulate erratic movement
        vel.x += random(-0.5f, 0.5f);

        // Constrain position to screen bounds horizontally
        pos.x = constrain(pos.x, alienRadius, width - alienRadius);
    }
}


  float calculateAccuracy(Level level, Ball ball) {
    int pointsCovered = 0;
    int totalPoints = level.path.size();

    for (PVector p : level.path) {
      for (PVector ballPoint : ball.trajectory) {
        if (dist(p.x, p.y, ballPoint.x, ballPoint.y) <= ball.radius / 2) {
          pointsCovered++;
          break;
        }
      }
    }

    return (float) pointsCovered / totalPoints * 100;
  }

  void generateAliens(int numberOfAliens) {
    alienPositions.clear(); // Clear any existing aliens
    alienVelocities.clear(); // Clear any existing velocities

    // Define heights for the aliens
    float[] heights = {height / 4, height / 2, 3 * height / 4}; // Different heights for variety

    // Add two aliens on the left
    for (int i = 0; i < 2; i++) {
        float x = width / 4; // Left side, closer to the center
        float y = heights[i]; // Use predefined heights
        alienPositions.add(new PVector(x, y));

        float vx = random(1, 3); // Random horizontal velocity moving right
        alienVelocities.add(new PVector(vx, 0)); // Only horizontal velocity
    }

    // Add one alien on the right
    float x = 3 * width / 4; // Right side, closer to the center
    float y = heights[2]; // Use the third height
    alienPositions.add(new PVector(x, y));

    float vx = random(-3, -1); // Random horizontal velocity moving left
    alienVelocities.add(new PVector(vx, 0)); // Only horizontal velocity
  }

}


class SineWaveLevel extends Level {
  SineWaveLevel(float thickness, float id) {
    super(thickness, id);
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


class ZigzagLevel extends Level {
  ZigzagLevel(float thickness, float id) {
    super(thickness, id);
  }

  @Override
  void generatePath(float curveWidth, float startPath, float finishPath) {
    path.clear(); // Clear previous path
    float minY = startPath;
    float maxY = height - finishPath;

    float segmentLength = (maxY - minY) / 4; // Divide vertical space into 4 equal segments

    for (float y = minY; y < maxY; y += 2) { // Fixed increment for y
      // Determine the segment length for each section of the zigzag
      float segmentProgress = (y - minY) % segmentLength / segmentLength; // Progress in current segment
      float x;
    
      if (y < minY + segmentLength) {
        // Move down center
        x = width / 2;
      } else if (y < minY + 2 * segmentLength) {
        // Smooth transition to the left
        x = width / 2 - curveWidth * sin(segmentProgress * HALF_PI); // Use sin to ease left
      } else if (y < minY + 3 * segmentLength) {
        // Smooth transition to the right
        x = width / 2 + curveWidth * sin(segmentProgress * HALF_PI); // Use sin to ease right
      } else {
        // Back to center
        x = width / 2 + curveWidth * cos(segmentProgress * PI); // Smoothly return to center
      }
    
      path.add(new PVector(x, y)); // Add the point to the path
    }
  }
}
