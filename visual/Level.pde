class Level {
  ArrayList<PVector> path; // trayectory to be drawn
  float thickness;         // thickness of drawing
  float id;               // level number

  Level(float thickness, float id) {
    this.thickness = thickness;
    this.id = id;
    path = new ArrayList<PVector>();
    generatePath();
  }
  
  void generatePath() {  // create Path
    
    float distance = 150;
    float minY = 30;  // Start 30 pixels down from the top of the screen
    float maxY = height - distance;
    // generate a sinusoidal curve
    int totalCurves = 1;
    float frequency = totalCurves * TWO_PI / height;
    for (float y = minY; y < maxY; y += 5) {
      // Create the curve centered in the middle of the screen
      float x = width / 2 + sin(y * frequency) * 100; 
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

}
