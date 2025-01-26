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

    // Just step down in y, staying at a fixed x (e.g., the center of the screen)
    for (float y = minY; y < maxY; y += 2) {
      float x = width / 2;
      path.add(new PVector(x, y));
    }
  }
}

class SineWaveLevel extends Level {
  SineWaveLevel(float thickness, float id, PImage alien1, PImage alien2, PImage alien3) {
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


class ZigzagLevel extends Level {
  ZigzagLevel(float thickness, float id, PImage alien1, PImage alien2, PImage alien3) {
    super(thickness, id, alien1, alien2, alien3);
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
