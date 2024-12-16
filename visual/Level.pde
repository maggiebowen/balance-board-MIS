class Level {
  ArrayList<PVector> path; // trayectory to be drawn
  float thickness;         // thickness of drawing
  float id;               // level number

  Level(float thickness, float id) {
    this.thickness = thickness;
    this.id = id;
    path = new ArrayList<PVector>();
    genetePath();
  }
  
  void genetePath() {  // create Path
    
    float distance = 150;
    float minY = distance;
    float maxY = height - distance;
    // generate a sinusoidal curve
    int totalCurves = 1;
    float frequency = totalCurves * TWO_PI / height;
    for (float y = minY; y < maxY; y += 5) {
      // for example this (to be changed so it adapts to each level)
      float x = width / 2 + sin(y * frequency) * 100; 
      path.add(new PVector(x, y));
    }
    
    // straight line
    //for (float y= minY; y < maxY; y += 5) {
      //float x = width/2;
      //path.add(new PVector(x,y));
    //}
  }
  
  // draw the shape
  void draw() {
    noFill();
    stroke(200, 100, 100, 150);
    strokeWeight(thickness);
    beginShape();
    for (PVector p : path) {
      vertex(p.x, p.y);
    }
    endShape();
  }

}
