boolean start; //初期画面
int x0,y0, x1,y1;  //選択した駒の座標(x0,y0)、移動先の駒の座標(x1,y1)
int move;  //手数
int board[][] = new int[10][10];  //盤面
int board_rec[][][] = new int[1024][10][10];  //盤面の棋譜
int bw,turn;  //手番の色(1なら白、-1なら黒)。手番(1ならCOM、-1ならMAN)
int bw_rec[] = new int[1024];  //手番の記録
boolean mustJump;  //強制飛び判定
boolean mustJump_rec[] = new boolean[1024];  //強制飛び判定の記録
boolean multiJump;  //連続飛び判定
boolean multiJump_rec[] = new boolean[1024];  //連続飛び判定の記録
int jpos[] = new int[2];  //連続飛びしている駒の座標
int jpos_rec[][] = new int[1024][2];  //連続飛びしている駒の座標の記録
int side,flip;  //一辺の長さ。盤の上下(1なら白が下、-1なら黒が下)
int numW,numB; //白駒の数、黒駒の数

void setup() {
  size(500, 400);
  noStroke();
  textAlign(CENTER,CENTER);
  frameRate(2);
  
  side=height/8;
  start=true;
  startPosition();
  showBoard();
  
  //初期画面
  rectMode(CORNER);
  fill(230, 170, 120, 220);
  rect(0,0, width,height/3);
  textAlign(CENTER,TOP);
  textSize(side); //文字の大きさ
  fill(0,0,160);
  text("CHECKERS P5", width/2, 0.5*side);
  textSize(side/2);
  text("'HUMAN' vs 'COMPUTER'", width/2, 1.5*side);
  
  fill(255,220);
  rect(0,height/3, width/2,height);
  fill(0,220);
  rect(width/2,height/3, width,height);
  fill(0, 160, 255);
  text("The first move\n(White)", width/4, height/2);
  text("The second move\n (Black)", width*3/4, height/2);
}

void draw() {
  com();
  
  //合法手が無い時
  if (finish()) {
    fill(255, 0, 0);
    textSize(1.5*side);
    if(turn==-1){text("You lose", width/2, height/2);}
    else{text("You win", width/2, height/2);}
  }
  else if(drawCheck()) {
    fill(255, 0, 0);
    textSize(1.5*side);
    text("Draw", width/2, height/2);
  }
}

void mousePressed() {
  man();
  
  //flip
  if (start==false && 8.3*side<=mouseX && mouseX<=9.7*side){
    if (4.5*side<=mouseY && mouseY<=5.2*side){
      flip = -flip;
      showBoard();
    }
  }
  
  //手番選択
  if (start==true && mouseY>=height/3){
    if (mouseX<=width/2) {turn=-1;  flip=1;} //手番は人間から(the first move)
    if (mouseX>=width/2) {turn=1;  flip=-1;} //手番はAIから(the second move)
    start=false; //初期画面を消す
    showBoard(); //盤面、両者の石、次の手番、置ける所を描画
  }
  
  //戻るボタンの実行
  if (8.3*side<=mouseX && mouseX<=9.7*side){
    if (3.5*side<=mouseY && mouseY<=4.2*side){
      if(move==1){
        move=0;
        turn=-turn;
        recorder(false);
      }
      else if(2<=move){
        move--;
        while(bw!=bw_rec[move]){move--;}
        recorder(false); //前の局面に戻す
      }
      showBoard();
    }
  }
}

void man(){
  x1 = floor(mouseX/side +1); //各マスの左上の座標を定義
  y1 = floor(mouseY/side +1); //floor()で小数点以下切り捨て
  
  //盤の上下が逆の時
  if(flip==-1){x1=9-x1;  y1=9-y1;}
  
  if (start==false && turn==-1 && validMove(x0,y0,x1,y1)) {  //move piece
    float n=0;
    recorder(true); //石の配置を記録
    
    for (int k=1; k<=8; k++) {
      for (int l=1; l<=8; l++) {
        for (int i=-2; i<=2; i++) {
          for (int j=-2; j<=2; j++) {
            if (validMove(k,l, k+i,l+j)) {
              float m = posMoves(k,l, k+i,l+j);
              
              movePiece(k,l, k+i,l+j);
              move++;
              bw = -bw; //石の色を反転
              
              if(move <= opening) {  //opening手目まではバラつかせる
                n = 0.0;
              }
              else if(end_num < numW+numB) {  //残りend_num駒まではmid_d手読み
                n = -negaalpha(mid_d-2.0,-score_max,score_max)
                      +m -position() -numTandems() -numMoves();
              }
              else{
                n = -negaalpha(end_d-2.0,-score_max,score_max)
                      +m -position() -numTandems() -numMoves();
              }
              int mv0 = ceil(float(9-k)/2) +4*(9-l-1);
              int mv1 = ceil(float(9-(k+i))/2) +4*(9-(l+j)-1);
              print(mv0 +">" +mv1 +"," +nfs(round(n),4) +";   ");
              
              move--;
              recorder(false);  //元の盤面に戻す
            }
          }
        }
      }
    }
    println("");
    
    float m = posMoves(x0,y0,x1,y1);
    
    movePiece(x0, y0, x1, y1);
    if(multiJump==false){bw = -bw;} //連続飛びでないなら手番交代
    move++;
    
    if(move <= opening) { //1手目まではバラつかせる
      n = 0;
    }
    else if(end_num < numW+numB) {  //残りend_num駒まではmid_d手読み
      n = -negaalpha(mid_d-2.0,-score_max,score_max)
            +m -position() -numTandems() -numMoves();
    }
    else{
      n = -negaalpha(end_d-2.0,-score_max,score_max)
            +m -position() -numTandems() -numMoves();
    }
    
    if(multiJump==true){n = -n;}  //連続飛びなら評価値を反転
    
    int mv0 = ceil(float(9-x0)/2) +4*(9-y0-1);
    int mv1 = ceil(float(9-x1)/2) +4*(9-y1-1);
    println(">> mv" +nf(move,3) +",MAN" +mv0 +">" +mv1 +";  values = " +nfs(int(n),4) +";   ");
    println("");
    showBoard();
    
    //連続飛びでないなら手番を変える
    if(multiJump==false){turn = -turn;}
    x0=y0=x1=y1=0;
  }
  else if (start==false && turn==-1) {  //一度目のクリックで駒を選ぶ
    x0 = x1;
    y0 = y1;
    showBoard();
  }
}
