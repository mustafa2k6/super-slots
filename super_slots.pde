import g4p_controls.*;


boolean homeScreen = true;
boolean out_of_money = false;
boolean bet_more = false;
boolean showFAQbutton, showFAQbackButton, showFAQ;

PFont calistoga, abeezee;

ArrayList<symbol> ALL_SYMBOLS;

slots s;
User account;

String bet_info = "";
//code
int numImages = 9;

int colNum = 3;
//float betSlide = 10;  //for bet slider

PImage[][] symbols = new PImage[numImages][numImages];
PImage leverUp, leverDown, faqButton;

boolean spinning = false;


float spin_timer = -1; //used to count to spin_time
float spin_time = 3000; //milliseconds

float[] changeCol = new float[numImages];
float[] columnSpeeds = new float[numImages];


void setup() {

  account = new User("", 1000);

  calistoga = createFont("Calistoga-Regular.ttf", 50);
  abeezee = createFont("ABeeZee-Regular.ttf", 24);
  size(1200, 700);
  esrbRating = loadImage("esrbRating.png");
  gameLogo = loadImage("gameLogo.png");
  publisherLogo = loadImage("publisherLogo.png");
  homeScreenBackground = loadImage("homeScreenBackground.png");
  engineLogo = loadImage("engineLogo.png");
  startButton = loadImage("startButton.png");
  introBackground = loadImage("introBackground.jpg");
  loginBackground = loadImage("loginBackground.jpg");
  usernameTextField = loadImage("usernameTextField.png");
  loginButton = loadImage("loginButton.png");
  FAQbanner = loadImage("FAQbanner.png");
  FAQtextField = loadImage("FAQtextField.png");
  FAQbutton = loadImage("faqButton.png");
  clearProgressButton = loadImage("clearProgressButton.png");
  faqButton = loadImage("faqButton.png");
  confirmCancelButton = loadImage("confirmCancelButton.png");
  progress = loadStrings("progress.txt");

  FAQbutton.resize(411 / 4, 456 / 4);
  gameLogo.resize(350, 280);
  startButton.resize(int(300 / 1.5), int(119 / 1.5));
  introBackground.resize(int(2490 / 2), int(1960 / 2));
  esrbRating.resize(225 / 2, 300 / 2);
  faqButton.resize(411 / 4, 456 / 4);
  publisherLogo.resize(800 / 3, 265 / 3);
  engineLogo.resize(650 / 3, 218 / 3);
  loginBackground.resize(1600, 1200);
  usernameTextField.resize(int(300 / 1.3), int(92 / 1.3));
  loginButton.resize(int(308 / 2), int(114 / 2));
  clearProgressButton.resize(int(472 / 2), int(282 / 2));
  confirmCancelButton.resize(int(458 / 3), int(208 / 3));
  FAQtextField.resize(int(689 / 1.2), int(400 / 1.2));

  if (progress.length > 0) {
    account.username = progress[0];
    account.cash = float(progress[1]);
    displayBank = displayBank.substring(0, displayBank.length() - 1);
    displayBank += nf(float(progress[1]), 0, 2);
    showClearProgress = true;
  }

  if (homeScreen == true) {
    createGUI();
    col_slider.setVisible(false);
    //change_bet.setVisible(false);
    Change_BetLabel.setVisible(false);
    Change_Col.setVisible(false);
    increaseBet.setVisible(false);
    decreaseBet.setVisible(false);
    ALL_SYMBOLS = new ArrayList<symbol>();
    ALL_SYMBOLS.add(new symbol("0.png", "a", 5));
    ALL_SYMBOLS.add(new symbol("1.png", "b", 2));
    ALL_SYMBOLS.add(new symbol("2.png", "c", 1.35));
    ALL_SYMBOLS.add(new symbol("3.png", "d", 1.25));
    ALL_SYMBOLS.add(new symbol("4.png", "e", 1.5));
    numImages = ALL_SYMBOLS.size();


    for (int i=0; i<numImages; i++) {
      for (int j=0; j<numImages; j++) {
        symbols[i][j] = loadImage(i+".png"); //load symbols (in reels) images (named 0 to 8) in 2d array
        symbols[i][j].resize(150, 150);
      }
    }

    // Shuffle the images
    for (int i = 0; i < numImages; i++) {
      for (int j = 0; j < numImages; j++) {
        int randomI = int(random(numImages));
        int randomJ = int(random(numImages));
        PImage temp = symbols[i][j];
        symbols[i][j] = symbols[randomI][randomJ];
        symbols[randomI][randomJ] = temp;
      }
    }
    s = new slots(colNum);

    leverUp = loadImage("leverUp.png");
    leverUp.resize(200, 0);
    leverDown = loadImage("leverDown.png");
    leverDown.resize(200, 0);
    
  }
}

//set symbols to match the 2d ArrayList in slot class
void set_slots() {
  PImage[][] new_sym = s.get_2d_array();
  for (int i = 0; i < new_sym.length; ++i) {
    for (int j = 0; j < new_sym[i].length; ++j) {
      symbols[i][j] = new_sym[i][j];
      symbols[i][j].resize(150, 150);
    }
  }
}

void draw() {
  background(0);
  fill(0);
  if (!logoComplete) {
    introScreen();
  }
  if (logoComplete && !iconsComplete) {
    introIcons();
  }
  if (iconsComplete && !loginComplete) {
    login();
  }

  if (loginComplete && !showFAQ) {   //start slots once login button is preesed
    showFAQbutton = true;
    col_slider.isVisible();
    //change_bet.isVisible();
    Change_BetLabel.isVisible();
    Change_Col.isVisible();
    increaseBet.isVisible();
    decreaseBet.isVisible();
    image(homeScreenBackground, 0, 0);
    play_spin_animation();
    

    if (spinning == false) {
      draw_bet_info();
      account.saveProgress();
      text(round(account.bet), 1150, 220);
    }
  }
  
  if(showFAQ) {
    showFAQbutton = false;
    showFAQbackButton = true;
    FAQ();
  }
  
  
  if (out_of_money)
    text("need more money", 1050, 355);
  else
    out_of_money = false;
    
  if (bet_more)
    text("bet more", 1120, 355);
  else
    bet_more = false;
  
  if(!spinning) {
    s.draw_lines();  
  }
}



void mouseClicked() {   //when lever clicked, spin reels
  if (mouseX < ((width/colNum) + 150*colNum +180) && mouseX > (width/colNum) + 150*colNum) {   //  image width 150 x number of cols (from slider)   +   180 width (click range)   [symbol] [symbol] [symbol] [lever click range]
    if (mouseY > 100 && mouseY < 240) {    // 140 height (click range)
      if (!spinning) {
        if (account.cash > 0) {
          out_of_money = false;
          if (account.bet > 0) {
            bet_more = false;
            account.spin_slots();
            spin_timer = millis();
            for (int i = 0; i < numImages; i++) {
              changeCol[i] = 0;
              columnSpeeds[i] = random(2, 10);
            }
          }
          else {
            println("bet more");
            spinning = false;
            bet_more = true;
          }
        }
        else {
          println("need more cash");
            spinning = false;
            out_of_money = true;
        }
      }
    }
  }


}


void leverImage() {
  if (spinning) {
    image(leverDown, (width/colNum) + 150*colNum - 8, 100);
    col_slider.setVisible(false);
    //change_bet.setVisible(false);
    Change_Col.setVisible(false);
    Change_BetLabel.setVisible(false);
    increaseBet.setVisible(false);
    decreaseBet.setVisible(false);

  } else {
    image(leverUp, (width/colNum) + 150*colNum - 8, 100);
    col_slider.setVisible(true);
    //change_bet.setVisible(true);
    Change_Col.setVisible(true);
    Change_BetLabel.setVisible(true);
    increaseBet.setVisible(true);
    decreaseBet.setVisible(true);

  }
 
  noStroke();
  fill(0, 100);
  rect((width/colNum) - 50, 0, 150*colNum+50, 475, 0, 0, 25, 25);
}


void play_spin_animation() {
  if(showFAQbutton) {
    image(faqButton, 25, 15);
    //if(mousePressed) {
    //  showFAQ = true;
    //}
  }
  frameRate(30);
  float x = (width/colNum)-25;
  float y = 0;    
  
  leverImage(); //lever animation

  // Update column offsets and speeds
  if (spinning) {
    for (int i = 0; i < numImages; i++) {
      changeCol[i] += columnSpeeds[i];
      columnSpeeds[i] += 0.1; // Increase speed over time
      if (changeCol[i] >= 150) {
        changeCol[i] -= 150; // Reset to the top of the column
        columnSpeeds[i] = random(2, 10); // Set a new random speed
      }
    }
    if (millis() - spin_timer >= spin_time) {   //auto stop reels
      spinning = false;
      set_slots();
    }
  }

  // Draw the images
  int delayMS = 5;
  for (int i=0; i <3; i++) {
    for (int j=0; j<colNum; j++) {
      if (spinning) {
        image(symbols[i][(int(j + changeCol[j])) % numImages], x, y);
        delay(delayMS);
      } else {
        image(symbols[i][j], x, y);
      }
      x += 150;
    }
    x = (width/colNum)-25;    //standard 2d array nested forloop
    y += 150;
  }
}


void draw_bet_info() {
  fill(255);
  text(bet_info, 500, 500);
}

void FAQ() {
  col_slider.setVisible(false);
  change_bet.setVisible(false);
  Change_BetLabel.setVisible(false);
  Change_Col.setVisible(false);
  fill(0);
  image(homeScreenBackground, 0, 0);
  image(FAQbanner, width / 2 - 200, 50);
  textFont(calistoga);
  textAlign(CENTER);
  text("FAQ", width / 2, 150);
  image(FAQtextField, width / 2 - 287, 250);
  textFont(abeezee);
  //text("", ) FAQ Text
}
