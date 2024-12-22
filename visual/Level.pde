class Level {
  ArrayList<PVector> path; // trajectory to be drawn
  float thickness;         // thickness of drawing
  float id;               // level number

  Level(float thickness, float id, int totalCurves, float curveWidth) {
    this.thickness = thickness;
    this.id = id;
    path = new ArrayList<PVector>();
    generatePath(totalCurves, curveWidth);
  }
  
  void generatePath(int totalCurves, float curveWidth) {  // curveWidth determines the width of the curves
    float distance = 150;
    float minY = 30;  // Start 30 pixels down from the top of the screen
    float maxY = height - distance;

    // generate a sinusoidal curve
    float frequency = totalCurves * TWO_PI / height;

    for (float y = minY; y < maxY; y += 5) {
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

}
