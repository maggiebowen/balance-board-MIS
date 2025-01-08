

class Level {
  ArrayList<PVector> path; // trajectory to be drawn
  float thickness;         // thickness of drawing
  float id;               // level number
  
  Level(float thickness, float id, float curveWidth, float startPath, float finishPath) {
    this.thickness = thickness;
    this.id = id;
    path = new ArrayList<PVector>();
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
  }
  
  // check accuracy 
  float calculateAccuracy(Ball ball) {
    int pointsCovered = 0;
    int totalTrajectoryPoints = ball.trajectory.size();
    int totalPathSegments = level.path.size() - 1; // One less than total path points
  
    for (PVector trajectoryPoint : ball.trajectory) {
      boolean isCovered = false;
  
      // Check the trajectory point against each segment of the path
      for (int i = 0; i < totalPathSegments; i++) {
        PVector start = level.path.get(i);
        PVector end = level.path.get(i + 1);
        float distance = distToSegment(trajectoryPoint, start, end);
  
        // If the point is within the ball's radius, count it as covered
        if (distance <= ball.radius) {
          isCovered = true;
          break;
        }
      }
  
      if (isCovered) {
        pointsCovered++;
      }
    }
  
    // Return percentage of covered points
    return (float) pointsCovered / totalTrajectoryPoints * 100;
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

}
