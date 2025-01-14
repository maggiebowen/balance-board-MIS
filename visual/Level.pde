class Level {
  ArrayList<PVector> path; // trajectory to be drawn
  float thickness;         // thickness of drawing
  float id;               // level number
  ArrayList<PVector> alienPositions; // Store alien positions
  float alienRadius;       // Radius of aliens
  ArrayList<PVector> alienVelocities; // Store velocities of aliens

  Level(float thickness, float id, float curveWidth, float startPath, float finishPath) {
    this.thickness = thickness;
    this.id = id;
    this.alienRadius = 20; // Default radius for aliens
    path = new ArrayList<PVector>();
    alienPositions = new ArrayList<PVector>();
    alienVelocities = new ArrayList<PVector>();
    generatePath(curveWidth, startPath, finishPath);
  }

  void generatePath(float curveWidth, float startPath, float finishPath) {  // curveWidth determines the width of the curves
    float minY = startPath;  // Start 30 pixels down from the top of the screen
    float maxY = height - finishPath;

    // generate a sinusoidal curve
    int totalCurves = 3;
    float frequency = totalCurves * TWO_PI / height;

    for (float y = minY; y < maxY; y += 2) {
        // Adjust curve width using the curveWidth parameter
        float x = width / 2 + sin(y * frequency) * curveWidth;
        path.add(new PVector(x, y));
    }

  }

  // draw the shape
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

      // Update position based on velocity
      pos.add(vel);

      // Bounce off walls
      if (pos.x < alienRadius || pos.x > width - alienRadius) {
        vel.x *= -1;
      }
      if (pos.y < alienRadius || pos.y > height - alienRadius) {
        vel.y *= -1;
      }

      // Randomly adjust velocity slightly to simulate erratic movement
      vel.x += random(-0.5f, 0.5f);
      vel.y += random(-0.5f, 0.5f);

      // Constrain position to screen bounds
      pos.x = constrain(pos.x, alienRadius, width - alienRadius);
      pos.y = constrain(pos.y, alienRadius, height - alienRadius);
    }
  }

  // check accuracy 
  float calculateAccuracy(Level level, Ball ball) {
    int pointsCovered = 0;
    int totalPoints = level.path.size();

    for (PVector p : level.path) {
      // see if level point is within trajectory of ball
      for (PVector ballPoint : ball.trajectory) {
        // if the distance between each point of the level is lower than the radius
        // ball.radius/2 can be used maybe, if not a bit easy?
        if (dist(p.x, p.y, ballPoint.x, ballPoint.y) <= ball.radius / 2) { 
          pointsCovered++; // increase the count
          break; 
        }
      }
    }

    return (float) pointsCovered / totalPoints * 100; // return the % of covered points
  }

  // Helper function: Calculate the shortest distance from a point to a line segment
  float distToSegment(PVector p, PVector v, PVector w) {
    float l2 = sq(dist(v.x, v.y, w.x, w.y)); // Squared length of segment
    if (l2 == 0) return dist(p.x, p.y, v.x, v.y); // Segment is a point
    float t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
    t = constrain(t, 0, 1); // Clamp t to the segment
    PVector projection = new PVector(v.x + t * (w.x - v.x), v.y + t * (w.y - v.y));
    return dist(p.x, p.y, projection.x, projection.y);
  }

  void generateAliens(int numberOfAliens) {
    alienPositions.clear(); // Clear any existing aliens
    alienVelocities.clear(); // Clear any existing velocities
    for (int i = 0; i < numberOfAliens; i++) {
      // Place aliens at random positions on the screen
      float x = random(alienRadius, width - alienRadius);
      float y = random(alienRadius, height - alienRadius);
      alienPositions.add(new PVector(x, y));

      // Assign random initial velocities
      float vx = random(-2, 2);
      float vy = random(-2, 2);
      alienVelocities.add(new PVector(vx, vy));
    }
  }
}
