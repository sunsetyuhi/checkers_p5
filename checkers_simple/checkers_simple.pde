int x0,y0, x1,y1;  //選択した駒の座標(x0,y0)、移動先の駒の座標(x1,y1)
int board[][] = new int[10][10];  //盤面
int bw;  //手番の色(1なら白、-1なら黒)
boolean mustJump;  //強制飛び判定
boolean multiJump;  //連続飛び判定
int jpos[] = new int[2];  //連続飛びしている駒の座標
int side;  //一辺の長さ
int numW,numB; //白駒の数、黒駒の数

void setup() {
  size(400, 400);
  noStroke();
  side=height/8;

  startPosition();
  showBoard();
}

void draw() {
  //合法手が無い時
  if (finish()) {
    fill(255, 0, 0);
    textSize(1.0*side);
    textAlign(CENTER);
    if (bw==-1){text("White win", width/2,height/2);}  //黒の手番の時
    else if (bw==1){text("Black win", width/2,height/2);}  //白の手番の時
  }
}

void mousePressed() {
  man();
}

void keyPressed() {
  if (key=='r') {
    startPosition();
    showBoard();
  }
}

void man(){
  x1 = floor(mouseX/side +1); //各マスの左上の座標を定義
  y1 = floor(mouseY/side +1); //floor()で小数点以下切り捨て
  
  if (validMove(x0,y0,x1,y1)) {  //駒を動かす
    movePiece(x0, y0, x1, y1);
    
    if(multiJump==false){bw = -bw;} //連続飛びでないなら手番交代
    showBoard();
    x0=y0=x1=y1=0;
  }
  else{  //一度目のクリックで駒を選ぶ
    x0 = x1;
    y0 = y1;
    showBoard();
  }
}

//初期設定
void startPosition() {
  x0=y0=x1=y1=0;
  bw=1; //手番は白から
  mustJump=multiJump=false;
  jpos[0]=jpos[1]=0;
  
  //駒の配置
  for (int i=0; i<=9; i++){
    for (int j=0; j<=9; j++) {
      if (i==0||j==0||i==9||j==9) {board[i][j]=3;}  //外縁は3
      else if (6<=j && (i+j)%2==1){board[i][j]=1;}  //白は1
      else if (j<=3 && (i+j)%2==1){board[i][j]=-1;}  //黒は-1
      else {board[i][j]=0;}  //空のマスは0
    }
  }
}

//盤面、両者の駒を描画
void showBoard() {
  //盤面(背景とグリッド)を描画
  background(230, 170, 120);
  noStroke();
  rectMode(CORNER);
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) {
      if ((i+j)%2 == 0) fill(240, 190, 150);  //ベージュ
      else {fill(210, 130, 70);}  //茶色
      rect((i-1)*side, (j-1)*side, side, side);
    }
  }
  
  //駒を描画
  numW=numB=0; //両者の石数を数える
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) {
      //駒の描画
      if (board[i][j]>=1) {  //w piece
        noStroke();  fill(255);
        ellipse(i*side -side/2, j*side -side/2, 0.9*side, 0.9*side);
        numW++;
        if (board[i][j]==2){  //king
          fill(0);
          ellipse(i*side -side/2, j*side -side/2, side/2, side/2);
        }
      }
      else if (board[i][j]<=-1) {  //b piece
        noStroke();  fill(0);
        ellipse(i*side -side/2, j*side -side/2, 0.9*side, 0.9*side);
        numB++;
        if (board[i][j]==-2){  //king
          fill(255);
          ellipse(i*side -side/2, j*side -side/2, side/2, side/2);
        }
      }
      
      //選択した駒の強調
      noStroke();
      if (i==x0 && j==y0 && board[i][j]!=0) {  //選択中のマス
        fill(255, 0, 0, 100);
        rect((i-1)*side, (j-1)*side, side, side);
      }
      else if (validMove(x0,y0, i,j)) {  //動ける先のマスを強調
        if(bw==-1){fill(0, 0, 0, 200);}
        else if(bw==1){fill(255, 255, 255, 200);}
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, side/3, side/3);
      }
    }
  }
}

//合法手の判定
boolean validMove(int i0, int j0, int i1, int j1) {
  if(i0<1||8<i0 || j0<1||8<j0 || i1<1||8<i1 || j1<1||8<j1) {return false;}  //盤外の手は指せない
  if(board[i0][j0]==0 || board[i1][j1]!=0) {return false;}  //空マスから、または駒があるマスには指せない
  if(multiJump && (i0!=jpos[0] || j0!=jpos[1])) {return false;}  //連続飛びの駒が他にあれば指せない
  if(mustJump && (abs(i1-i0)!=2 || abs(j1-j0)!=2)) {return false;}  //強制飛びの駒が他にあれば指せない

  if(board[i0][j0] == bw) {  //pawn
    //斜め前が空きマスの時
    if(abs(i1-i0)==1 && j1-j0==-bw && board[i1][j1]==0) {return true;}
    
    //行先が斜め2つ上で空、間に相手の駒がある時
    if(abs(i1-i0)==2 && j1-j0==-2*bw && board[i1][j1]==0 && 
      (board[int((i0+i1)/2)][j0-bw]==-bw || board[int((i0+i1)/2)][j0-bw]==-2*bw)){return true;}
  }
  else if(board[i0][j0] == 2*bw) {  //king
    //斜め前後が空きマスの時
    if(abs(i1-i0)==1 && abs(j1-j0)==1 && board[i1][j1]==0) {return true;}
    
    //行先が斜め2つ先で空、間に相手の駒がある時
    if(abs(i1-i0)==2 && abs(j1-j0)==2 && board[i1][j1]==0 &&
      (board[int((i0+i1)/2)][int((j0+j1)/2)]==-bw || board[int((i0+i1)/2)][int((j0+j1)/2)]==-2*bw)){return true;}
  }
  
  return false;
}

//駒を動かす
void movePiece(int i0, int j0, int i1, int j1) {
  boolean promote = false;
  mustJump = false;  //強制飛び判定をfalseにする
  multiJump = false;  //連続飛び判定をfalseにする
  
  //promote
  if((board[i0][j0]==1 && j1==1) || (board[i0][j0]==-1 && j1==8)) {
    board[i0][j0] = 2*bw;  //ポーンをキングにする
    promote = true;
  }
  
  board[i1][j1] = board[i0][j0];  //move piece
  board[i0][j0] = 0;  //remove original piece
  
  //飛んだ時の処理
  if (abs(i0-i1)==2 && abs(j0-j1)==2) {
    board[(i0+i1)/2][(j0+j1)/2] = 0;  //間の駒を消す
    jpos[0]=i1;  jpos[1]=j1;  //飛んだ先のマスを保存
    
    if (promote==false) {  //駒が成っていない時、続けて飛べるか判定
      if(validMove(i1,j1,i1+2,j1+2) || validMove(i1,j1,i1+2,j1-2) ||
         validMove(i1,j1,i1-2,j1+2) || validMove(i1,j1,i1-2,j1-2)){
        multiJump = true;
      }
    }
  }
  
  //次が強制飛びか判定
  if(multiJump==false){bw = -bw;}  //連続飛びでなければ相手番で考える
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      if (validMove(k,l, k+2,l+2)) {mustJump = true;}
      if (validMove(k,l, k+2,l-2)) {mustJump = true;}
      if (validMove(k,l, k-2,l+2)) {mustJump = true;}
      if (validMove(k,l, k-2,l-2)) {mustJump = true;}
    }
  }
  if(multiJump==false){bw = -bw;}
}

//終局判定（合法手がないことを確認）
boolean finish() {
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      if(board[k][l]!=0){  //空きマス以外
        if (validMove(k,l, k+1,l+1)) {return false;}
        if (validMove(k,l, k+1,l-1)) {return false;}
        if (validMove(k,l, k-1,l+1)) {return false;}
        if (validMove(k,l, k-1,l-1)) {return false;}
        
        if (validMove(k,l, k+2,l+2)) {return false;}
        if (validMove(k,l, k+2,l-2)) {return false;}
        if (validMove(k,l, k-2,l+2)) {return false;}
        if (validMove(k,l, k-2,l-2)) {return false;}
      }
    }
  }
  return true;
}
