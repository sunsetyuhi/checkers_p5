int y0, x0, y1, x1;  //選択した駒の座標(x0,y0)、移動先の駒の座標(x1,y1)
int p, q;  //続けて飛べる駒の座標
int click;  //first click select piece, second click moves piece
int bw;  //player color(1なら白、-1なら黒)
int side;  //一辺の長さ
boolean promote;  //駒の成り
boolean JumpJudg, multiJump, jumping;
int wKing, bKing, wPawn, bPawn;
int board[][] = new int[10][10];;

void setup() {
  size(400, 400);
  noStroke();
  textSize(width/8);
  textAlign(CENTER);
  side=height/8;

  wKing = 2;
  wPawn = 1;
  bPawn = -1;
  bKing = -2;
  
  startPosition();
}

void draw() {
  showBoard();
  
  
  //飛べる駒があるか判定
  if (mustJump(bw)) {jumping = true;}
  else {jumping = false;}
  
  //no legal moves
  if (finish(bw)) {
    fill(0, 255, 0);
    text("GAMEOVER", 0, height/2, width, height);
  }
}

void mousePressed() {
  if (finish(bw)) {startPosition();}
  
  x1 = floor(mouseX/(width/8) +1); //各マスの左上の座標を定義
  y1 = floor(mouseY/(height/8) +1); //floor()で小数点以下切り捨て
  
  if (validMove(x0, y0, x1, y1, bw)) {  //move piece
    movePiece(x0, y0, x1, y1);
    click = 0;
  }
  else {  //一度目のクリックで駒を選ぶ
    x0 = x1;
    y0 = y1;
    click = 1;
  }
  println(x0+","+y0+" -> "+x1+","+y1+"; "+p+","+q);
}

void keyPressed() {
  if (key=='r') {startPosition();}
}

void showBoard() {
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) { 
      //盤面
      if ((i+j)%2 == 0) fill(255, 206, 158);
      else {fill(209, 139, 71);}
      noStroke();
      rect((i-1)*side, (j-1)*side, side, side);
      
      //駒の色
      if (board[i][j]>=1) {  //w piece
        fill(255);
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, side, side);
        if (board[i][j]==2){
          stroke(0);
          ellipse((i-1)*side +side/2, (j-1)*side +side/2, side/2, side/2);
        }
      }
      else if (board[i][j]<=-1) {  //b piece
        fill(0);
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, side, side);
        if (board[i][j]==-2){
          stroke(255);
          ellipse((i-1)*side +side/2, (j-1)*side +side/2, side/2, side/2);
        }
      }
      
      //選択した駒の強調
      noStroke();
      if (validMove(x0, y0, i, j, bw)) {
        fill(255, 0, 0, 100);  //highlight posibble moves in red
        rect((i-1)*side, (j-1)*side, side, side);
      }
      if (i==x0 && j==y0 && board[i][j]!=0) {
        fill(0, 0, 255, 100);  //highlight piece in blue
        rect((i-1)*side, (j-1)*side, side, side);
      }
    }
  }
}

void startPosition() {
  for (int i=0; i<=9; i++){
    for (int j=0; j<=9; j++) {
      if (j<=3 && (i+j)%2==1){board[i][j] = bPawn;} //黒は-1
      else if (6<=j && (i+j)%2==1){board[i][j] = wPawn;} //白は1
      else if (i==0||j==0||i==9||j==9) {board[i][j] = 3;} //外縁は3
      else {board[i][j] = 0;}
    }
  }
  
  //global variables
  promote = false;
  y0=x0=y1=x1=-1;
  click = 0;
  bw = 1; //手番は白から
  multiJump = false;
}

boolean validMove(int x0, int y0, int x1, int y1, int bw) {
  if(x0<1||8<x0 || x1<1||8<x1 || y0<1||8<y0 || y1<1||8<y1) {return false;}  //駒が盤外の時
  if(board[x1][y1]!=0) {return false;}  //行先が空マスでない時
  if(multiJump && (x0!=p||y0!=q)) {return false;}  //他に続けて飛べる駒がある時
  if(jumping && (abs(x1-x0)!=2 || abs(y1-y0)!=2)) {return false;}  //他に飛べる駒がある時


  //
  if(board[x0][y0] == bw) {  //pawn
    if(abs(x1-x0)==1 && y1-y0==-bw && board[x1][y1]==0) {  //move forward
      return true;
    }
    if(abs(x1-x0)==2 && y1-y0==-2*bw && board[x1][y1]==0 && 
      (board[(x0+x1)/2][y0-bw]==-bw || board[(x0+x1)/2][y0-bw]==-2*bw)){  //行先が斜め2つ上で空、間に相手の駒がある時
      return true;
    }
  }
  else if(board[x0][y0] == 2*bw) {  //king
    if(abs(x1-x0)==1 && abs(y1-y0)==1 && board[x1][y1]==0) {  //move
      return true;
    }
    if(abs(x1-x0)==2 && abs(y1-y0)==2 && board[x1][y1]==0 &&
      (board[(x0+x1)/2][(y0+y1)/2]==-bw || board[(x0+x1)/2][(y0+y1)/2]==-2*bw)){  //行先が斜め2つ先で空、間に相手の駒がある時
      return true;
    }
  }
  
  return false;
}

void movePiece(int i0, int j0, int i1, int j1) {
  JumpJudg = true;
  multiJump = false;
  
  //promote
  if((board[i0][j0]==wPawn && j1==1) ||
     (board[i0][j0]==bPawn && j1==8)) {
    board[i0][j0] = 2*bw;  //ポーンをキングにする
    JumpJudg = false;
  }
  
  board[i1][j1] = board[i0][j0];  //move piece
  board[i0][j0] = 0;  //remove original piece
  
  //jump
  if (abs(i0-i1)==2 && abs(j0-j1)==2) {
    board[(i0+i1)/2][(j0+j1)/2] = 0;  //間の駒を消す
    p=i1;  q=j1;
    
    if (JumpJudg==true) {  //駒が成っていない時、続けて飛べるか判定
      if(validMove(i1,j1,i1+2,j1+2,bw) || validMove(i1,j1,i1+2,j1-2,bw) ||
         validMove(i1,j1,i1-2,j1+2,bw) || validMove(i1,j1,i1-2,j1-2,bw)){
        multiJump = true;
      }
    }
  }
  
  //続けて飛べないなら手番を変える
  if(multiJump==false){bw = -bw;}
}

boolean mustJump(int bw) {
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      if (validMove(k,l, k+2,l+2, bw)) {return true;}
      if (validMove(k,l, k+2,l-2, bw)) {return true;}
      if (validMove(k,l, k-2,l+2, bw)) {return true;}
      if (validMove(k,l, k-2,l-2, bw)) {return true;}
    }
  }
  return false;
}

boolean finish(int bw) {//no valid moves
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      for (int i=1; i<=8; i++) {
        for (int j=1; j<=8; j++) {
          if (abs(k-i)<=2 && abs(l-j)<=2 && validMove(k,l, i,j, bw)) {return false;}
        }
      }
    }
  }
  return true;
}
