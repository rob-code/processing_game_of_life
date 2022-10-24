
class Cell {
  int x, y;
  boolean dead_or_alive;

  Cell(int x, int y, boolean dead_or_alive) {
    this.x = x;
    this.y = y;
    this.dead_or_alive = dead_or_alive;
  }
}

class MouseCoordinate {
  int x, y;
  MouseCoordinate(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

int grid_size;
ArrayList <Cell> local_cells = new ArrayList<Cell>();
ArrayList <Cell> cells = new ArrayList<Cell>();
ArrayList <MouseCoordinate> mouse_coordinates = new ArrayList<MouseCoordinate>();
int k = 0;
boolean dead_or_alive;
boolean mouseclicked = false;
boolean backspace = false;
boolean mousedrag = false;
boolean firstrun = true;

void settings() {
  size(800, 800);
  grid_size = 2;
}

void setup() {
  background(255);
  createBlankStarterArray();
  drawInstructionText();
  frameRate(15);

  //2 other ways to start the game; a small seed array or a randomly generated full screen. Neither are as interesting as mouseDrag. Need drawArray() for both.
  //createSeedArray(); //use grid_spacing = 5
  //createRandomArray();
  //drawArray();
  
  //Tests
  //adjacentCellsTest();
}

void draw() {

  /* Event control is still a bit flakey in that relies on the user inputting correct
     mouse and key strokes, it doesnt parse out all out of sequence key strokes. But its good enough for now. 
     Maybe there's a better structure for handling code which requires several event driven flags to operate smoothly? */ 

  if (firstrun && mousedrag) {
    background(255); //clear all text
    firstrun = false;
  }

  if (mouseclicked) {
    background(255);
    createNextGeneration();
  }

  if (backspace && !mouseclicked) {
    background(255);
    createBlankStarterArray();
    drawArray();
    backspace = false;
  }
}

void createNextGeneration() {

  for (int i = 0; i < cells.size(); i++) {

    //this omits the cells at the border ie if none of these conditions is met the calculation proceeds
    if (!((cells.get(i).x == 0) || (cells.get(i).x == width - grid_size) || (cells.get(i).y == 0) || (cells.get(i).y == height - grid_size))) {

      int o = width/grid_size; // got to keep the 2d array square so that x = y
      int true_count = 0;

      // lets build an array which contains the cells directly adjacent to the ith cell - there are 8 adjacent cells
      //this is tested and correct for all grid_spacings
      local_cells.add(cells.get(i-o-1));
      local_cells.add(cells.get(i-o));
      local_cells.add(cells.get(i-o+1));
      local_cells.add(cells.get(i-1));
      local_cells.add(cells.get(i+1));
      local_cells.add(cells.get(i+o-1));
      local_cells.add(cells.get(i+o));
      local_cells.add(cells.get(i+o+1));

      //Count how many trues there are in adjacent cells .. this is used next to determine if the cell is alive or dead
      for (int j = 0; j < local_cells.size(); j++) {
        if (local_cells.get(j).dead_or_alive) {
          true_count++;
        }
      }
      local_cells.clear(); // dont need the content of the cells, only the number of trues. The number of adjacent cells which are true determines the fate of the cell
      
      /* 
       RULES TO CREATE THE NEXT GENERATION:
       - Every populated cell with 0 or 1 neighbour dies from isolation and becomes false.
       - Every populated cell with 2 or 3 neighbouring populated cells survives to the next generation and stays true. With 2 and unpopulated, it stays unpopulated.
       - Every unpopulated cell with 3 neighbours is a birth cell and becomes true.
       - Each populated cell with 4 or more neighbours dies from overpopulation.
       */

      switch(true_count) {

      case 0:
        cells.set(i, new Cell(cells.get(i).x, cells.get(i).y, false));
        break;

      case 1:
        cells.set(i, new Cell(cells.get(i).x, cells.get(i).y, false));
        break;

      case 2: // don't do anthing here, this option does not alter the cell.
        break;

      case 3:
        cells.set(i, new Cell(cells.get(i).x, cells.get(i).y, true));
        break;

      case 4:
        cells.set(i, new Cell(cells.get(i).x, cells.get(i).y, false));
        break;

      case 5:
        cells.set(i, new Cell(cells.get(i).x, cells.get(i).y, false));
        break;

      case 6:
        cells.set(i, new Cell(cells.get(i).x, cells.get(i).y, false));
        break;

      case 7:
        cells.set(i, new Cell(cells.get(i).x, cells.get(i).y, false));
        break;

      case 8:
        cells.set(i, new Cell(cells.get(i).x, cells.get(i).y, false));
        break;
      }
    }
  }

  drawArray();
}

void mouseDragged() {
  mousedrag = true;

  //map the mouseX, mouseY values to array grid values
  int xValue = 0;
  int yValue = 0;

  if (mouseX % grid_size <= grid_size/2) {
    xValue = mouseX - (mouseX % grid_size);
  } else {
    xValue = mouseX - (mouseX % grid_size) + grid_size;
  }

  if (mouseY % grid_size <= grid_size/2) {
    yValue = mouseY - (mouseY % grid_size);
  } else {
    yValue = mouseY - (mouseY % grid_size) + grid_size;
  }

  //Store the x,y values in an ArrayList
  mouse_coordinates.add(new MouseCoordinate(xValue, yValue));
  k++;

  drawMouseDragInput();
}

void mouseClicked() {

  mouseclicked = !mouseclicked;
  StringDict m = new StringDict();

  //Import the mouse_coordinates as stringified key value pairs into a hashmap. As there is only one value for each key, duplicates are removed
  for (int q = 0; q < mouse_coordinates.size(); q++) {
    m.set(str(mouse_coordinates.get(q).x) + "_" + str(mouse_coordinates.get(q).y), str(mouse_coordinates.get(q).x) + "_" + str(mouse_coordinates.get(q).y));
  }

  //convert the hashmap back to an array of mouse coordinates and upate mouse_coordinates[] with all duplicates now removed
  String[] n = m.keyArray();
  mouse_coordinates.clear();
  for (int i = 0; i < n.length; i++) {
    int[] xy = int(split(n[i], "_"));
    mouse_coordinates.add(new MouseCoordinate(xy[0], xy[1]));
  }

  //We now have an array of mouse_coordinate objects. We now need to update the starter_cells[] array for each of the mouse_coordinates[]
  for (int i = 0; i < mouse_coordinates.size(); i++) {
    for (int j = 0; j < cells.size(); j++) {
      if (mouse_coordinates.get(i).x == cells.get(j).x && mouse_coordinates.get(i).y == cells.get(j).y) {
        cells.set(j, new Cell(mouse_coordinates.get(i).x, mouse_coordinates.get(i).y, true));
      }
    }
  }
  mouse_coordinates.clear();
}

void keyPressed() {
  //BACKSPACE key clears the game when the its not running as a result of the mouseclick 
  if (!mouseclicked && key == BACKSPACE) {
    backspace = true;
  }
}

void createSeedArray() {
  createBlankStarterArray();
  int[] seeds = {9840, 9841, 9842, 9843, 9844, 10000, 10001, 10002, 10003, 10160, 10162, 10163};
  for (int s : seeds) {
    cells.set(s, new Cell(cells.get(s).x, cells.get(s).y, true));
  }
}

void createRandomArray() {
  for (int x = 0; x < width; x+=grid_size) {
    for (int y = 0; y < height; y+=grid_size) {
      if (random(1)<0.5) {
        dead_or_alive=false;
      } else {
        dead_or_alive =true;
      }
      cells.add(new Cell(x, y, dead_or_alive));
    }
  }
}

void drawArray() {
  fill(0);
  for (int i=0; i < cells.size(); i ++) {
    if (cells.get(i).dead_or_alive) {
      rect(cells.get(i).x, cells.get(i).y, grid_size/2, grid_size/2);
    }
  }
}

void drawMouseDragInput() {
  fill(0);
  for (int i=0; i < mouse_coordinates.size(); i ++) {
    rect(mouse_coordinates.get(i).x, mouse_coordinates.get(i).y, grid_size/2, grid_size/2);
  }
}

void createBlankStarterArray() {
  cells.clear();
  for (int x = 0; x < width; x+=grid_size) {
    for (int y = 0; y < height; y+=grid_size) {
      cells.add(new Cell(x, y, false));
    }
  }
}

void drawInstructionText() {
  String instructionText = "Drag the mouse in the window to make live cells\nClick the mouse to start\n\n\nClick the mouse to stop and add more live cells\n\n\nUse backspace to clear";
  fill(0, 150);
  textSize(20);
  textLeading(50);
  textAlign(CENTER);
  text(instructionText, width/2, 200);
  noFill();
}

//   ==================================== TESTS ==================================

void adjacentCellsTest() {
  ArrayList <Cell> test = new ArrayList<Cell>();
  int o = width/grid_size;
  int i = 3060;

  if (!((cells.get(i).x == 0) || (cells.get(i).x == width - grid_size) || (cells.get(i).y == 0) || (cells.get(i).y == height - grid_size))) {
    test.add(cells.get(i-o-1));
    test.add(cells.get(i-o));
    test.add(cells.get(i-o+1));
    test.add(cells.get(i-1));
    test.add(cells.get(i+1));
    test.add(cells.get(i+o-1));
    test.add(cells.get(i+o));
    test.add(cells.get(i+o+1));
  }
  fill(0);
  for (int j = 0; j< test.size(); j++) {
    rect(test.get(j).x, test.get(j).y, grid_size, grid_size);
  }
}
